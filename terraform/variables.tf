variable "project_name" {
  description = "Prefix used for all AWS resource names and tags"
  type = string
  default = "minecraft"
}

# ***********************************************
# AWS instance configuration variables
# ***********************************************
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "t3.medium is recommended for minimum Minecraft server hardware requirements"
  type = string
  default = "t3.medium"
}

variable "volume_size" {
  description = "Root volume size in GB"
  type = number
  default = 20
}

variable "allowed_ssh_cidr" {
  description = <<-EOT
    CIDR block allowed to reach port 22 (SSH).
    Set to your own IP for tighter security: e.g. \"203.0.113.5/32\".
    Defaults to open (0.0.0.0/0) for convenience in lab environments.
  EOT
  type        = string
  default     = "0.0.0.0/0"
}
