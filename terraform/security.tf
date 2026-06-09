# ***********************************************
# Security Group
# ***********************************************

resource "aws_security_group" "minecraft" {
  name        = "${var.project_name}-sg"
  description = "Allow Minecraft and SSH traffic"
  vpc_id      = aws_vpc.minecraft.id

  # SSH — needed for Ansible to configure the server
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Minecraft Java Edition default port
  ingress {
    description = "Minecraft"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound (needed for package installs, JAR download)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

