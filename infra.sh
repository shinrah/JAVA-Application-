#!/bin/bash
set -Eeuo pipefail

# Check root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Re-executing script with root privileges..."
    exec sudo -n bash "$0" "$@"
fi

# ==========================================
# Configure Jenkins Passwordless Sudo Access
# ==========================================

JENKINS_USER="jenkins"

if id "$JENKINS_USER" >/dev/null 2>&1; then

    echo "Configuring sudo access for Jenkins..."

    SUDOERS_FILE="/etc/sudoers.d/jenkins"
    TEMP_FILE=$(mktemp)

    printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$JENKINS_USER" > "$TEMP_FILE"

    # Validate configuration before installing
    visudo -cf "$TEMP_FILE"

    # Install with correct ownership and permissions
    install -o root -g root -m 0440 "$TEMP_FILE" "$SUDOERS_FILE"

    rm -f "$TEMP_FILE"

    echo "Jenkins sudo access configured successfully."

else
    echo "ERROR: Jenkins user does not exist."
    exit 1
fi

# ==========================================
# Continue with existing installation steps
# ==========================================
set -Eeuo pipefail

# ==========================================
# DevOps Tools Installation Script
# OS: Ubuntu 24.04 LTS
# Tools: Git, kubectl, eksctl, Terraform
# ==========================================

echo "======================================"
echo " Installing DevOps Tools"
echo " Ubuntu 24.04"
echo "======================================"

# Automatically request root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Re-executing script with root privileges..."
    exec sudo -n bash "$0" "$@"
fi

set -Eeuo pipefail

echo "======================================"
echo " Installing DevOps Tools"
echo " Ubuntu 24.04"
echo "======================================"

# Detect architecture
ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    amd64)
        BINARY_ARCH="amd64"
        ;;
    arm64)
        BINARY_ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Detected architecture: $ARCH"

# Non-interactive installation
export DEBIAN_FRONTEND=noninteractive

# ==========================================
# Step 1: Update package repository
# ==========================================

echo "Updating package repository..."

apt-get update -y

# ==========================================
# Step 2: Install dependencies and Git
# ==========================================

echo "Installing dependencies and Git..."

apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    gnupg \
    ca-certificates \
    lsb-release

echo "Git installation completed"

# ==========================================
# Step 3: Install kubectl
# ==========================================

echo "Installing kubectl..."

KUBECTL_VERSION=$(curl -fsSL \
    https://dl.k8s.io/release/stable.txt)

echo "Kubectl version: $KUBECTL_VERSION"

curl -fL --retry 3 \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${BINARY_ARCH}/kubectl" \
    -o /tmp/kubectl

install -m 0755 /tmp/kubectl /usr/local/bin/kubectl

echo "kubectl installation completed"

# ==========================================
# Step 4: Install eksctl
# ==========================================

echo "Installing eksctl..."

EKSCTL_URL="https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_${BINARY_ARCH}.tar.gz"

curl -fL --retry 3 \
    "$EKSCTL_URL" \
    -o /tmp/eksctl.tar.gz

tar -xzf /tmp/eksctl.tar.gz -C /tmp

install -m 0755 /tmp/eksctl /usr/local/bin/eksctl

echo "eksctl installation completed"

# ==========================================
# Step 5: Install Terraform
# ==========================================

echo "Installing Terraform..."

install -d -m 0755 /usr/share/keyrings

curl -fsSL \
    https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor --yes \
    -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

chmod 0644 /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" \
    > /etc/apt/sources.list.d/hashicorp.list

apt-get update -y

apt-get install -y terraform

echo "Terraform installation completed"

# ==========================================
# Step 6: Verify all installations
# ==========================================

echo ""
echo "======================================"
echo " Verifying DevOps Tools"
echo "======================================"

echo ""
echo "Git Version:"
git --version

echo ""
echo "Kubectl Version:"
kubectl version --client

echo ""
echo "Eksctl Version:"
eksctl version

echo ""
echo "Terraform Version:"
terraform version

# ==========================================
# Step 7: Cleanup
# ==========================================

rm -f /tmp/kubectl /tmp/eksctl.tar.gz /tmp/eksctl

echo ""
echo "======================================"
echo " Installation Completed Successfully"
echo "======================================"

