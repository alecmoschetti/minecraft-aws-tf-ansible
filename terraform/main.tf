provider "aws" {
  region = "us-east-1"
}

# ***********************************************
# Automatic SSH Key Pair Gen
# ***********************************************

resource "tls_private_key" "minecraft" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "minecraft" {
  key_name = "${var.project_name}-key"
  public_key = tls_private_key.minecraft.public_key_openssh
}

# *.pem is in .gitignore so to never commit generated keys!
resource "local_file" "private_key" {
  content = tls_private_key.minecraft.private_key_pem
  filename = "${path.module}/../${var.project_name}-key.pem"
  file_permission = "0600"
}
