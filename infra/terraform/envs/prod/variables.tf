variable "aws_region" { type = string }
variable "name_prefix" { type = string }
variable "vpc_cidr" { type = string }
variable "az_count" { type = number }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "cluster_version" { type = string }
variable "node_instance_types" { type = list(string) }
variable "node_desired_size" { type = number }
variable "node_min_size" { type = number }
variable "node_max_size" { type = number }
variable "node_ami_type" {
  type    = string
  default = "AL2023_x86_64_STANDARD"
}
variable "mysql_instance_class" { type = string }
variable "mysql_db_name" { type = string }
variable "mysql_username" { type = string }
variable "mysql_password" {
  type      = string
  sensitive = true
}
variable "mongo_ami_id" { type = string }
variable "mongo_instance_type" { type = string }
variable "opensearch_instance_type" { type = string }
variable "elasticsearch_ami_id" {
  type    = string
  default = ""
}
variable "elasticsearch_instance_type" {
  type    = string
  default = "t3.micro"
}
variable "redis_node_type" { type = string }
variable "lms_domain" { type = string }
variable "ingress_alb_dns_name" {
  type    = string
  default = ""
}
variable "acm_certificate_arn_us_east_1" {
  type    = string
  default = ""
}
variable "enable_cloudfront" {
  type    = bool
  default = false
}
variable "enable_opensearch" {
  type    = bool
  default = false
}
