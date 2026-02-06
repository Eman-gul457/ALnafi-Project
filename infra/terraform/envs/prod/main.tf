terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "network" {
  source               = "../../modules/network"
  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  az_count             = var.az_count
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security" {
  source      = "../../modules/security"
  name_prefix = var.name_prefix
  vpc_id      = module.network.vpc_id
}

module "eks" {
  source               = "../../modules/eks"
  name_prefix          = var.name_prefix
  cluster_version      = var.cluster_version
  vpc_id               = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids
  node_instance_types  = var.node_instance_types
  node_desired_size    = var.node_desired_size
  node_min_size        = var.node_min_size
  node_max_size        = var.node_max_size
  node_ami_type        = var.node_ami_type
}

locals {
  elasticsearch_ami_id = var.elasticsearch_ami_id != "" ? var.elasticsearch_ami_id : var.mongo_ami_id
}

resource "aws_db_subnet_group" "openedx" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = module.network.private_subnet_ids
}

resource "aws_elasticache_subnet_group" "openedx" {
  name       = "${var.name_prefix}-cache-subnets"
  subnet_ids = module.network.private_subnet_ids
}

resource "aws_opensearch_domain" "openedx" {
  count          = var.enable_opensearch ? 1 : 0
  domain_name    = "${var.name_prefix}-search"
  engine_version = "OpenSearch_2.13"

  cluster_config {
    instance_type  = var.opensearch_instance_type
    instance_count = 2
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 50
    volume_type = "gp3"
  }

  vpc_options {
    subnet_ids         = slice(module.network.private_subnet_ids, 0, 2)
    security_group_ids = [module.security.data_services_sg_id]
  }

  access_policies = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { AWS = "*" },
      Action = "es:*",
      Resource = "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.name_prefix}-search/*"
    }]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_db_instance" "mysql" {
  identifier              = "${var.name_prefix}-mysql"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.mysql_instance_class
  allocated_storage       = 100
  storage_type            = "gp3"
  db_name                 = var.mysql_db_name
  username                = var.mysql_username
  password                = var.mysql_password
  db_subnet_group_name    = aws_db_subnet_group.openedx.name
  vpc_security_group_ids  = [module.security.data_services_sg_id]
  backup_retention_period = 1
  multi_az                = false
  skip_final_snapshot     = true
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.name_prefix}-redis"
  description                = "Redis for OpenEdX"
  node_type                  = var.redis_node_type
  num_cache_clusters         = 2
  parameter_group_name       = "default.redis7"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.openedx.name
  security_group_ids         = [module.security.data_services_sg_id]
  automatic_failover_enabled = true
}

resource "aws_instance" "mongo" {
  ami                    = var.mongo_ami_id
  instance_type          = var.mongo_instance_type
  subnet_id              = module.network.private_subnet_ids[0]
  vpc_security_group_ids = [module.security.data_services_sg_id]
  iam_instance_profile   = aws_iam_instance_profile.mongo_profile.name

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  user_data = file("${path.module}/mongo-userdata.sh")

  tags = {
    Name = "${var.name_prefix}-mongo"
  }
}

resource "aws_instance" "elasticsearch" {
  ami                    = local.elasticsearch_ami_id
  instance_type          = var.elasticsearch_instance_type
  subnet_id              = module.network.private_subnet_ids[1]
  vpc_security_group_ids = [module.security.data_services_sg_id]

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  user_data = file("${path.module}/elasticsearch-userdata.sh")

  tags = {
    Name = "${var.name_prefix}-elasticsearch"
  }
}

resource "aws_iam_role" "mongo_role" {
  name = "${var.name_prefix}-mongo-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "mongo_ssm" {
  role       = aws_iam_role.mongo_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "mongo_profile" {
  name = "${var.name_prefix}-mongo-profile"
  role = aws_iam_role.mongo_role.name
}

resource "aws_wafv2_web_acl" "openedx" {
  count    = var.enable_cloudfront ? 1 : 0
  provider = aws.us_east_1
  name  = "${var.name_prefix}-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedCommonRuleSet"
    priority = 1
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common-rules"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimit"
    priority = 2
    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 1500
      }
    }
    action {
      block {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "openedx-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudfront_distribution" "openedx" {
  count               = var.enable_cloudfront ? 1 : 0
  provider            = aws.us_east_1
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "OpenEdX CDN"
  default_root_object = ""
  aliases             = [var.lms_domain]
  web_acl_id          = aws_wafv2_web_acl.openedx[0].arn

  origin {
    domain_name = var.ingress_alb_dns_name
    origin_id   = "eks-ingress"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "eks-ingress"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = true
      headers      = ["Host", "Authorization", "CloudFront-Forwarded-Proto"]
      cookies {
        forward = "all"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/static/*"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "eks-ingress"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn_us_east_1
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
