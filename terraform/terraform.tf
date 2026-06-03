terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    # TLS generates the RSA SSH key-pair in Terraform in order to automate the ssh-keygen process
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
    # Needed to write the generated private key pair from above to a local .pem file so Ansible can use it
    local = {
      source = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
