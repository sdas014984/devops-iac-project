provider "aws" {
  region = var.region
}

resource "aws_security_group" "devops_sg" {
  name = "devops_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*"]
  }
}

resource "aws_instance" "ansible" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.devops_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install ansible2 -y

              # Create .ssh directory
              mkdir -p /home/ec2-user/.ssh

              # generate the ansible key
              ssh-keygen -t rsa -b 4096 -f ansible_key

              # Add private key
              echo '${file("ansible_key")}' > /home/ec2-user/.ssh/id_rsa
              chmod 600 /home/ec2-user/.ssh/id_rsa

              chown -R ec2-user:ec2-user /home/ec2-user/.ssh
              EOF

  tags = { Name = "Ansible-Control-Node" }
}
resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.devops_sg.name]
  tags = { Name = "Jenkins-Server" }
}

resource "aws_instance" "apache" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.devops_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ubuntu/.ssh
              echo '${var.ansible_public_key}' >> /home/ubuntu/.ssh/authorized_keys
              chmod 600 /home/ubuntu/.ssh/authorized_keys
              chown -R ubuntu:ubuntu /home/ubuntu/.ssh
              EOF

  tags = { Name = "Apache-Server" }
}

resource "aws_instance" "mysql" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.devops_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ec2-user/.ssh
              echo '${var.ansible_public_key}' >> /home/ec2-user/.ssh/authorized_keys
              chmod 600 /home/ec2-user/.ssh/authorized_keys
              chown -R ec2-user:ec2-user /home/ec2-user/.ssh
              EOF

  tags = { Name = "MySQL-Server" }
}

resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.devops_sg.name]
  tags = { Name = "Monitoring-Server" }
}
