
#!/bin/bash

set -Eeuo pipefail

# ==========================================
# DevOps Tools Installation Script
# OS: Ubuntu 24.04 LTS
# Tools: Git, kubectl, eksctl, Terraform,
#        AWS CLI, Ansible, Trivy
# ==========================================

echo "======================================"
echo " Installing DevOps Tools"
echo " Ubuntu 24.04"
echo "======================================"

# ==========================================
# Step 0: Root privileges
# ==========================================

if [ "$(id -u)" -ne 0 ]; then
    echo "Checking Jenkins sudo permissions..."

    if ! sudo -n true 2>/dev/null; then
        echo "ERROR: Passwordless sudo is not configured."
        exit 1
    fi

    exec sudo -n bash "$0" "$@"
fi

echo "Running with root privileges."

# ==========================================
# Common functions
# ==========================================

check_installed() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "$1 is already installed. Skipping."
        return 0
    else
        echo "$1 is not installed. Installing..."
        return 1
    fi
}

export DEBIAN_FRONTEND=noninteractive

ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    amd64) BINARY_ARCH="amd64" ;;
    arm64) BINARY_ARCH="arm64" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Detected architecture: $ARCH"

# ==========================================
# Step 1: Update repositories
# ==========================================

apt-get update -y

# ==========================================
# Step 2: Dependencies
# ==========================================

apt-get install -y \
    curl wget unzip gnupg \
    ca-certificates lsb-release

# ==========================================
# Step 3: Git
# ==========================================

if ! check_installed git; then
    apt-get install -y git
fi

# ==========================================
# Step 4: kubectl
# ==========================================

if ! check_installed kubectl; then

    KUBECTL_VERSION=$(curl -fsSL \
        https://dl.k8s.io/release/stable.txt)

    curl -fL --retry 3 \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${BINARY_ARCH}/kubectl" \
        -o /tmp/kubectl

    install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
fi

# ==========================================
# Step 5: eksctl
# ==========================================

if ! check_installed eksctl; then

    EKSCTL_URL="https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_${BINARY_ARCH}.tar.gz"

    curl -fL --retry 3 "$EKSCTL_URL" \
        -o /tmp/eksctl.tar.gz

    tar -xzf /tmp/eksctl.tar.gz -C /tmp

    install -m 0755 /tmp/eksctl /usr/local/bin/eksctl
fi

# ==========================================
# Step 6: Terraform
# ==========================================

if ! check_installed terraform; then

    install -d -m 0755 /usr/share/keyrings

    curl -fsSL https://apt.releases.hashicorp.com/gpg \
        | gpg --dearmor --yes \
        -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

    chmod 0644 /usr/share/keyrings/hashicorp-archive-keyring.gpg

    echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" \
        > /etc/apt/sources.list.d/hashicorp.list

    apt-get update -y
    apt-get install -y terraform
fi

# ==========================================
# Step 7: AWS CLI
# ==========================================

if ! check_installed aws; then

    if [ "$BINARY_ARCH" = "amd64" ]; then
        AWS_ARCH="x86_64"
    else
        AWS_ARCH="aarch64"
    fi

    curl -fL --retry 3 \
        "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" \
        -o /tmp/awscliv2.zip

    unzip -q -o /tmp/awscliv2.zip -d /tmp

    /tmp/aws/install
fi

# ==========================================
# Step 8: Ansible
# ==========================================

if ! check_installed ansible; then
    apt-get install -y ansible-core
fi

# ==========================================
# Step 9: Docker permissions for Jenkins
# ==========================================

if getent group docker >/dev/null 2>&1; then
    usermod -aG docker jenkins
    echo "Jenkins added to Docker group."
else
    echo "Docker group not found. Install Docker first if required."
fi

# ==========================================
# Step 10: Trivy
# ==========================================

if ! check_installed trivy; then

    install -d -m 0755 /usr/share/keyrings

    curl -fsSL \
        https://aquasecurity.github.io/trivy-repo/deb/public.key \
        | gpg --dearmor --yes \
        -o /usr/share/keyrings/trivy.gpg

    chmod 0644 /usr/share/keyrings/trivy.gpg

    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
        > /etc/apt/sources.list.d/trivy.list

    apt-get update -y
    apt-get install -y trivy
fi

# ==========================================
# Step 11: Ansible Docker Collection
# ==========================================

if ! ansible-galaxy collection list 2>/dev/null \
    | grep -q 'community.docker'; then

    echo "Installing community.docker collection..."

    ansible-galaxy collection install community.docker

else
    echo "community.docker already installed. Skipping."
fi

# ==========================================
# Step 12: Verification
# ==========================================

echo ""
echo "======================================"
echo " Verifying DevOps Tools"
echo "======================================"

git --version
kubectl version --client
eksctl version
terraform version
aws --version
ansible --version
trivy --version

echo ""
echo "======================================"
echo " Installation Completed Successfully"
echo "======================================"

# ==========================================
# Step 13: Cleanup
# ==========================================

rm -f /tmp/kubectl \
      /tmp/eksctl.tar.gz \
      /tmp/eksctl \
      /tmp/awscliv2.zip

rm -rf /tmp/aws

echo "Cleanup completed."
