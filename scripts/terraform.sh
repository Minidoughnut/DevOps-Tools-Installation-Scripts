#!/bin/bash

install_terraform() {
    # Check if Terraform is already installed
    if command -v terraform &>/dev/null; then
        echo "Terraform is already installed."
        read -p "Do you want to uninstall the previous Terraform version? (y/n): " check_ans
        if [ "$check_ans" = "y" ]; then
            sudo rm /usr/local/bin/terraform
        else
            echo "Skipping uninstallation of the previous Terraform version."
            exit
        fi
    fi

    # Determine the OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    # Map architecture for Terraform
    case "$ARCH" in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64)
            ARCH="arm64"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    # Get the latest version of Terraform
    TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)
    TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip"

    echo "Downloading Terraform from $TERRAFORM_URL"
    curl -Lo terraform.zip "$TERRAFORM_URL"

    # Unzip the Terraform binary
    unzip terraform.zip

    # Move the Terraform binary to /usr/local/bin
    sudo mv terraform /usr/local/bin/

    # Clean up
    rm terraform.zip

    # Check if the installation was successful
    if command -v terraform &>/dev/null; then
        echo "Terraform installation completed successfully."
        terraform -version
    else
        echo "Terraform installation failed."
        exit 1
    fi
}

# Run the installation function
install_terraform
