#!/bin/bash

# Function to install Docker on Ubuntu or Debian
install_docker_ubuntu_debian() {
    # Check if Docker is already installed
    if command -v docker &>/dev/null; then
        echo "Docker is already installed."
        read -p "Do you want to uninstall the previous Docker version? (y/n): " check_ans
        if [ "$check_ans" = "y" ]; then
            sudo apt-get remove -y docker docker-ce docker.io containerd runc
            sudo apt-get autoremove -y
            sudo rm -rf /var/lib/docker
        else
            echo "Skipping uninstallation of the previous Docker version."
            exit
        fi
    fi

    # 1. Set up the repository
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

    # Add Docker’s official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  
    # Set up the stable repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 2. Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

    # Add the current user to the docker group
    sudo usermod -aG docker $USER

     # Add the Jenkins user to the docker group
    sudo usermod -aG docker jenkins

    clear
    echo "Docker Engine and Docker Compose installed."
    echo "Restarting Docker service..."
    echo
    sleep 10

    # Restart Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo systemctl restart docker
    clear
    sleep 5
    echo "Docker is now up and running :)"
    echo "Try running 'docker ps' to check if it's working."
}

# Function to install Docker on CentOS or RHEL
install_docker_centos_rhel() {
    # Check if Docker is already installed
    if command -v docker &>/dev/null; then
        echo "Docker is already installed."
        read -p "Do you want to uninstall the previous Docker version? (y/n): " check_ans
        if [ "$check_ans" = "y" ]; then
            # Remove existing Docker packages
            sudo yum remove -y docker-ce docker-ce-cli containerd.io
            sudo rm -rf /var/lib/docker
        else
            echo "Skipping uninstallation of the previous Docker version."
            exit
        fi
    fi

    # 1. Set up the repository
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # 2. Install Docker Engine
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose

    # Add the current user to the docker group
    sudo usermod -aG docker $USER

     # Add the Jenkins user to the docker group
    sudo usermod -aG docker jenkins 

    clear
    echo "Docker Engine and Docker Compose installed."
    echo "Restarting Docker service..."
    echo
    sleep 10
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo systemctl restart docker
    clear
    sleep 5
    echo "Docker is now up and running :)"
    echo "Try running 'docker ps' to check if it's working."
}

# Determine the distribution and call the appropriate function
if [ -f /etc/debian_version ]; then
    echo "Distribution is Ubuntu or Debian."
    install_docker_ubuntu_debian
elif [ -f /etc/redhat-release ]; then
    echo "Distribution is CentOS or RHEL."
    install_docker_centos_rhel
else
    echo "Unsupported distribution. Please install Docker manually."
    exit 1
fi
