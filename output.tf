output "bastion-publicIP" {
  description = "The public IP of the bastion instance"
  value       = aws_instance.rodo-title-bastion[*].public_ip
}

output "windows-bastion-publicIP" {
  description = "The public IP of the windows bastion instance"
  value       = aws_instance.rodo-title-windows-bastion[*].public_ip
}

output "CorDapp-instance-privateIP" {
  description = "The private IP of the CorDapp instance"
  value       = aws_instance.rodo-title-CorApp[*].private_ip
}

output "CorDapp-db-name" {
  description = "The CorDapp title database name"
  value       = aws_db_instance.rodo-postgres-cordapp.db_name
}

output "CorDapp-db-username" {
  description = "The CorDapp title database username"
  value       = aws_db_instance.rodo-postgres-cordapp.username
}

output "camunda-db-name" {
  description = "The CorDapp title database name"
  value       = aws_db_instance.rodo-postgres-camunda.db_name
}

output "camunda-db-username" {
  description = "The CorDapp title database username"
  value       = aws_db_instance.rodo-postgres-camunda.username
}

output "rodo-title-server-ecr" {
  description = "Rodo title server ecr"
  value       = aws_ecr_repository.rodo-title-server-repo.repository_url
}

# output "rodo-title-lb-url" {
#   description = "Rodo title load balancer url"
#   value = aws_lb.rodo-title-lb.dns_name
# }

# output "rodo-title-cloudfront-url" {
#   description = "Rodo title cloud front url"
#   value = var.opt_cloudfront_enabled ? aws_cloudfront_distribution.s3_distribution[0].domain_name : "** CF deployment skipped **"
# }

# output "cloudfront-cert-validation" {
#   value = aws_acm_certificate.cloudfront-cert.domain_validation_options
# }

# output "lb-cert-validation" {
#   value = aws_acm_certificate.lb-cert.domain_validation_options
# }

output "entities_maintained" {
  value = {
    entities_to_maintain        = local.entities_to_maintain
    node_entities_json          = local.node_entities_json
    cloudfronted_entities_names = local.cloudfronted_entities_names
    node_ui_cfg                 = var.node_ui_cfg
  }
}

output "route53_entries" {
  value = {
    ui           = aws_route53_record.ui
    proxy        = aws_route53_record.proxy
    ui_full_list = aws_route53_record.ui[*]
  }
}

output "s3_buckets" {
  value = aws_s3_bucket.rodo-title-s3-web
}
