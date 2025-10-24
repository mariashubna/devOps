#!/bin/bash

set -e

# --- Functions ---
check_installed() {
    command -v "$1" >/dev/null 2>&1
}

# --- Update system ---
echo "Updating package list..."
sudo apt update -y

# --- Install Docker ---
if check_installed docker; then
    echo "Docker is already installed: $(docker --version)"
else
    echo "Installing Docker..."
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "Docker installed successfully!"
fi

# --- Install Docker Compose ---
if check_installed docker-compose; then
    echo "Docker Compose is already installed: $(docker-compose --version)"
else
    echo "Installing Docker Compose..."
    DOCKER_COMPOSE_VERSION="2.21.0"
    sudo curl -L "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully!"
fi

# --- Install Python 3.9+ ---
PYTHON_MIN_VERSION="3.9"
PYTHON_CURRENT_VERSION=$(python3 -V 2>&1 | awk '{print $2}' || echo "0")

version_greater_equal() {
    printf '%s\n%s\n' "$1" "$2" | sort -C -V
}

if check_installed python3 && version_greater_equal "$PYTHON_CURRENT_VERSION" "$PYTHON_MIN_VERSION"; then
    echo "Python is already installed: $(python3 --version)"
else
    echo "Installing Python 3.12 and venv..."
    sudo apt install -y python3 python3-pip python3-venv
fi

# --- Setup Python virtual environment ---
PROJECT_DIR="$HOME/dev_env"
VENV_DIR="$PROJECT_DIR/venv"

mkdir -p "$PROJECT_DIR"

if [ ! -d "$VENV_DIR" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

echo "Activating virtual environment..."
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

# Upgrade pip in venv
python -m pip install --upgrade pip

# Install Django in venv
if python -m django --version >/dev/null 2>&1; then
    echo "Django is already installed in virtual environment."
else
    echo "Installing Django in virtual environment..."
    python -m pip install django
    echo "Django installed successfully!"
fi

echo "All tools installed successfully!"
echo "To use Django, activate your venv with:"
echo "source $VENV_DIR/bin/activate"

