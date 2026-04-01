

variable "key_name" {
  description = "yahoo-keypair"
}
variable "region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ansible_public_key" {
  description = "Public key for Ansible server access"
}

