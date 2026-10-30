
# SonarQube EC2 Instance ID
output "sonarqube_instance_id" {
  description = "SonarQube EC2 Instance ID"
  value       = aws_instance.sonarqube.id
}

# SonarQube Public IP
output "sonarqube_public_ip" {
  description = "SonarQube Server Public IP"
  value       = aws_instance.sonarqube.public_ip
}

# SonarQube Private IP
output "sonarqube_private_ip" {
  description = "SonarQube Server Private IP"
  value       = aws_instance.sonarqube.private_ip
}

# SonarQube URL
output "sonarqube_url" {
  description = "SonarQube Web Application URL"
  value       = "http://${aws_instance.sonarqube.public_ip}:9000"
}
