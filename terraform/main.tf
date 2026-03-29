provider "aws" {
  region = var.region
}

# Security Group
resource "aws_security_group" "devops_sg" {
  name = "devops_sg"

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

# AMIs
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
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

data "aws_ami" "redhat" {
  most_recent = true
  owners = ["309956199498"]
  filter {
    name   = "name"
    values = ["RHEL-*"]
  }
}

# EC2 Instances
resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.amazon_linux.id
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

  tags = { Name = "Apache-Server" }
}

resource "aws_instance" "mysql" {
  ami           = data.aws_ami.redhat.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.devops_sg.name]

  tags = { Name = "MySQL-Server" }
}

resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.devops_sg.name]

  tags = { Name = "Monitoring-Server" }
}
