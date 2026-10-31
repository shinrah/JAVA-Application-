
# ==========================================
# Fetch Latest Ubuntu 24.04 AMI
# ==========================================

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ==========================================
# SonarQube EC2 Instance
# ==========================================

resource "aws_instance" "sonarqube" {
  for_each = {
    Nexus = "Nexus-Server"
    sonarqube = "SonarQube-Server"
   }
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  key_name = var.key_pair_name

  associate_public_ip_address = true

  user_data = file("${path.module}/userdata/sonarqube.sh")

  user_data_replace_on_change = true

  root_block_device {
    volume_size           = var.disk_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = each.value
    Environment = var.environment
    Application = "SonarQube"
    ManagedBy   = "Terraform"
  }
}
