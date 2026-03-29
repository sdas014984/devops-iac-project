output "public_ips" {
  value = [
    aws_instance.jenkins.public_ip,
    aws_instance.apache.public_ip,
    aws_instance.mysql.public_ip,
    aws_instance.monitoring.public_ip
  ]
}
