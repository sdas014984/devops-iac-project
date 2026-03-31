output "ips" {
  value = {
    ansible    = aws_instance.ansible.public_ip
    jenkins    = aws_instance.jenkins.public_ip
    apache     = aws_instance.apache.public_ip
    mysql      = aws_instance.mysql.public_ip
    monitoring = aws_instance.monitoring.public_ip
  }
}
