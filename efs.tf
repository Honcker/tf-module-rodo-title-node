
resource "aws_efs_file_system" "corda" {
  creation_token  = "${local.node_slug}-corda-file-system"
  throughput_mode = "bursting" # semi usage based, but supports access points better

  # R3 specifies this must not be encrypted
  encrypted = false #tfsec:ignore:aws-efs-enable-at-rest-encryption

  # files will be moved to IA storage after 30d of inactivity
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  # but moved back after 1 access
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
}

resource "aws_efs_mount_target" "private" {
  count = length(aws_subnet.private-subnets[*].id)

  file_system_id = aws_efs_file_system.corda.id
  subnet_id      = aws_subnet.private-subnets[count.index].id
  security_groups = [
    aws_security_group.rodo-title-sg.id
  ]
}

resource "aws_efs_access_point" "truststore" {
  file_system_id = aws_efs_file_system.corda.id

  root_directory {
    path = "/opt/corda/certificates"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0777"
    }
  }
  posix_user {
    gid = 1000
    uid = 1000
  }
}
