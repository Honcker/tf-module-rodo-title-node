
variable "vpc_cidr" {
  description = "vpc cidr"
  type        = string
}

variable "bastion_linux_ami_name" {
  description = "ami id of the linux bastion host"
  type        = string
}

variable "bastion_windows_ami_id" {
  description = "ami id of the windows bastion host"
  type        = string
}

# https://docs.r3.com/en/platform/corda/4.9/enterprise/node/setup/host-prereq.html#node-databases
variable "db_engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}

# https://docs.r3.com/en/platform/corda/4.9/enterprise/node/setup/host-prereq.html#node-databases
# aws rds describe-db-engine-versions --engine postgres --db-parameter-group-family postgres13 --query DBEngineVersions[].EngineVersion
variable "db_engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "13.8"
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "db_allocated_storage" {
  description = "The allocated storage in gibibytes"
  type        = number
}

variable "db_public_accesible" {
  description = "database is publicly accessible"
  type        = bool
}

variable "bastion_ec2_instance_type" {
  description = "instance type for Bastion EC2 Instance"
  type        = string
}

variable "title_ec2_instance_type" {
  description = "instance type for title EC2 Instances"
  type        = string
}

variable "ssh_public_key" {
  description = "public key for rodo title ec2 instances"
  type        = string
}

variable "sns_name" {
  description = "Name of the SNS alert channel"
  type        = string
}

variable "sns_alert_emails" {
  description = "List of emails to create email subscriptions for metrics alerts"
  type        = list(any)
}

# Variables for RDS metric alarms
variable "burst_balance_threshold" {
  description = "The minimum percent of General Purpose SSD (gp2) burst-bucket I/O credits available."
  type        = number
  default     = 20
}

variable "replica_lag_warning_threshold" {
  description = "The maximum amount of replication lag on DB replicas."
  type        = number
  default     = 600

  # 600000 Milliseconds to 600 Seconds
}

variable "replica_lag_critical_threshold" {
  description = "The maximum amount of replication lag on DB replicas."
  type        = number
  default     = 1800

  # 1800000 Milliseconds to 1800 Seconds
}

variable "cpu_utilization_warning_threshold" {
  description = "The maximum percentage of CPU utilization."
  type        = number
  default     = 70
  # 70%
}

variable "cpu_utilization_critical_threshold" {
  description = "The maximum percentage of CPU utilization."
  type        = number
  default     = 90
  # 90%
}

variable "disk_queue_depth_warning_threshold" {
  description = "The maximum number of outstanding IOs (read/write requests) waiting to access the disk."
  type        = number
  default     = 64
  # 64 count
}

variable "freeable_memory_warning_threshold" {
  description = "The minimum amount of available random access memory in Byte."
  type        = number
  default     = 1000000000

  # 1 Gigabyte in Byte
}

variable "freeable_memory_critical_threshold" {
  description = "The minimum amount of available random access memory in Byte."
  type        = number
  default     = 1000000000

  # 1 Gigabyte in Byte
}

variable "free_storage_space_warning_threshold" {
  description = "The minumum amount of available storage space in Byte."
  type        = number
  default     = 26214400

  # 26214400 Bytes
}

variable "free_storage_space_critical_threshold" {
  description = "The minimum amount of available storage space in Byte."
  type        = number
  default     = 10485760

  # 10485760 Bytes
}

variable "swap_usage_warning_threshold" {
  description = "The amount of swap space used on the DB instance. This metric is not available for SQL Server."
  type        = number
  default     = 1000000000

  # 1 Gigabyte in Byte
}

variable "read_latency_warning_threshold" {
  description = "The average amount of time taken per disk I/O operation."
  type        = number
  default     = 1

  # 1 second
}

variable "write_latency_warning_threshold" {
  description = "The average amount of time taken per disk I/O operation."
  type        = number
  default     = 1

  # 1 second
}

variable "instance_size_db_connections_map" {
  description = "The size of the database instance"
  type        = map(any)
  default = {
    "db.t3.micro"     = 200
    "db.t4g.large"    = 200
    "db.m6i.large"    = 100
    "db.t4g.xlarge"   = 500
    "db.m6g.2xlarge"  = 500
    "db.r5.xlarge"    = 500
    "db.r5.2xlarge"   = 1000
    "db.m6g.4xlarge"  = 1000
    "db.m6g.large"    = 100
    "db.r5.4xlarge"   = 1000
    "db.t3.large"     = 100
    "db.r6g.12xlarge" = 1000
  }
}

variable "corda_address" {
  description = "The address of corda service"
  type        = string
}

variable "opt_acm_cert_enabled" {
  description = "optional switch to toggle cloudfront deployment"
  type        = bool
  default     = true
}

variable "opt_alert_email_subscription_enabled" {
  # VPC endpoints are not free
  description = "optional switch to toggle corda VPC endpoint deployment"
  type        = bool
  default     = true
}

variable "dns_public_domain" {
  description = "aws hosted zone name for public dns"
  default     = "rodo-infra.com"
}

variable "corda_networkmap_url" {
  description = "the cenm nmap url"
  type        = string
  nullable    = false
}

variable "corda_doorman_url" {
  description = "the cenm idman url"
  type        = string
  nullable    = false
}
