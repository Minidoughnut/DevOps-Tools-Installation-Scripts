#!/bin/bash

install_trivy() {
    # Check if Trivy is already installed
    if command -v trivy &>/dev/null; then
        echo "Trivy is already installed."
        read -p "Do you want to uninstall the previous Trivy version? (y/n): " check_ans
        if [ "$check_ans" = "y" ]; then
            sudo rm /usr/local/bin/trivy
        else
            echo "Skipping uninstallation of the previous Trivy version."
            exit
        fi
    fi

    # Determine the OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    # Map architecture for Trivy
    case "$ARCH" in
        x86_64)
            ARCH="64bit"
            ;;
        aarch64)
            ARCH="ARM64"
            ;;
        armv7l)
            ARCH="ARMv7"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    # Download the latest Trivy binary
    TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    TRIVY_URL="https://github.com/aquasecurity/trivy/releases/download/$TRIVY_VERSION/trivy_${TRIVY_VERSION}_${OS}-${ARCH}.tar.gz"

    echo "Downloading Trivy from $TRIVY_URL"
    curl -Lo trivy.tar.gz "$TRIVY_URL"

    # Extract the tarball and move the binary to /usr/local/bin
    tar -zxvf trivy.tar.gz
    sudo mv trivy /usr/local/bin/
    rm trivy.tar.gz

    # Check if the installation was successful
    if command -v trivy &>/dev/null; then
        echo "Trivy installation completed successfully."
        trivy --version
    else
        echo "Trivy installation failed."
        exit 1
    fi
}

# Run the installation function
install_trivy
