# ***********************************************
# Outputs to Console
# This is necessary for the run.sh program
# to find and use these outputs
# ***********************************************

output "public_ip" {
  description = "Public IP address of the Minecraft EC2 instance"
  value       = aws_instance.minecraft.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.minecraft.id
}

output "private_key_path" {
  description = "Local path to the generated SSH private key (used by Ansible)"
  value       = local_file.private_key.filename
}

output "minecraft_connect" {
  description = "Address to use in the Minecraft client"
  value       = "${aws_instance.minecraft.public_ip}:25565"
}

output "nmap_command" {
  description = "Command to verify the server is reachable"
  value       = "nmap -sV -Pn -p T:25565 ${aws_instance.minecraft.public_ip}"
}
