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
