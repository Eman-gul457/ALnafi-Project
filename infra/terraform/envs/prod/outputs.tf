output "vpc_id" { value = module.network.vpc_id }
output "eks_cluster_name" { value = module.eks.cluster_name }
output "eks_cluster_endpoint" { value = module.eks.cluster_endpoint }
output "mysql_endpoint" { value = aws_db_instance.mysql.address }
output "redis_endpoint" { value = aws_elasticache_replication_group.redis.primary_endpoint_address }
output "mongo_private_ip" { value = aws_instance.mongo.private_ip }
output "opensearch_endpoint" {
  value = var.enable_opensearch ? aws_opensearch_domain.openedx[0].endpoint : null
}
output "elasticsearch_endpoint" {
  value = aws_instance.elasticsearch.private_ip
}
output "cloudfront_domain_name" {
  value = var.enable_cloudfront ? aws_cloudfront_distribution.openedx[0].domain_name : null
}
output "waf_web_acl_arn" {
  value = var.enable_cloudfront ? aws_wafv2_web_acl.openedx[0].arn : null
}
