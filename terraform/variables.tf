variable "project_name" {
  description = "Prefix used for all AWS resource names and tags"
  type = string
  default = "minecraft"
}

# ***********************************************
# AWS instance configuration variables
# ***********************************************

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
