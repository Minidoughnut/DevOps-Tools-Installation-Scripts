#!/bin/bash

install_aws_cli() {
    # Check if AWS CLI is already installed
    if command -v aws &>/dev/null; then
        echo "AWS CLI is already installed."
        read -p "Do you want to uninstall the previous AWS CLI version? (y/n): " check_ans
        if [ "$check_ans" = "y" ]; then
            sudo rm -rf /usr/local/aws-cli
            sudo rm /usr/local/bin/aws
        else
            echo "Skipping uninstallation of the previous AWS CLI version."
            exit
        fi
    fi

    # Determine the OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    # Map architecture for AWS CLI
    case "$ARCH" in
        x86_64)
            ARCH="x86_64"
            ;;
        aarch64)
            ARCH="aarch64"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    # Download the latest AWS CLI version 2 installer
    AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-${OS}-${ARCH}.zip"
    echo "Downloading AWS CLI from $AWS_CLI_URL"
    curl -Lo "awscliv2.zip" "$AWS_CLI_URL"

    # Unzip the installer
    unzip awscliv2.zip

    # Run the installer
    sudo ./aws/install

    # Check if the installation was successful
    if command -v aws &>/dev/null; then
        echo "AWS CLI installation completed successfully."
        aws --version
    else
        echo "AWS CLI installation failed."
        exit 1
    fi

    # Clean up
    rm -rf awscliv2.zip aws
}

# Run the installation function
install_aws_cli
