provider "aws" {
  region = var.region
}

resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_security_group" "devops_sg" {
  name = "devops_sg"

  ingress {
    from_port   = 80
    to_port     = 80
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
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install ansible2 -y
              
              pip install boto3 botocore
              ansible-galaxy collection install amazon.aws

              EOF

  tags = { Name = "Ansible-Control-Node" }
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.devops_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = { Name = "Jenkins-Server" }
}

resource "aws_instance" "apache" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.devops_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = { Name = "Apache-Server" }
}

resource "aws_instance" "mysql" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.devops_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = { Name = "MySQL-Server" }
}

resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.devops_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  
  tags = { Name = "Monitoring-Server" }
}

resource "aws_s3_bucket" "ssm_bucket" {
  bucket = "my-ssm-bucket-unique-name"
}
resource "aws_iam_role_policy" "ssm_s3_policy" {
  name = "ssm-s3-access"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::my-ssm-bucket-unique-name",
          "arn:aws:s3:::my-ssm-bucket-unique-name/*"
        ]
      }
    ]
  })
}