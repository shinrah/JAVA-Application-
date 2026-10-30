
#!/bin/bash

set -Eeuo pipefail

# Log all installation output
exec > >(tee -a /var/log/sonarqube-install.log) 2>&1

echo "======================================"
echo " Starting SonarQube Installation"
echo "======================================"

# Update Ubuntu
apt-get update -y

# Install Docker
echo "Installing Docker..."

apt-get install -y docker.io

systemctl enable docker
systemctl start docker

# Configure Elasticsearch requirements
echo "Configuring kernel parameters..."

cat > /etc/sysctl.d/99-sonarqube.conf <<EOF
vm.max_map_count=524288
fs.file-max=131072
EOF

sysctl --system

# Create persistent Docker volumes
echo "Creating Docker volumes..."

docker volume create sonarqube_data
docker volume create sonarqube_extensions
docker volume create sonarqube_logs

# Start SonarQube container
echo "Starting SonarQube container..."

docker run -d \
    --name sonarqube \
    --restart unless-stopped \
    --memory=6g \
    --ulimit nofile=131072:131072 \
    --ulimit nproc=8192:8192 \
    -p 9000:9000 \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    -v sonarqube_logs:/opt/sonarqube/logs \
    sonarqube:community

echo "======================================"
echo " SonarQube Installation Completed"
echo "======================================"

echo "SonarQube is starting on port 9000"
