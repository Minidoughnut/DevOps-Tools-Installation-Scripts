#!/bin/bash

install_vault() {
    # Check if Vault is already installed
    if command -v vault &>/dev/null; then
        echo "Vault is already installed."
        read -p "Do you want to uninstall the previous Vault version? (y/n): " check_ans
        if [ "$check_ans" = "y" ]; then
            sudo rm /usr/local/bin/vault
        else
            echo "Skipping uninstallation of the previous Vault version."
            exit
        fi
    fi

    # Determine the OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    # Map architecture for Vault
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

    # Get the latest version of Vault
    VAULT_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/vault | jq -r .current_version)
    VAULT_URL="https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_${OS}_${ARCH}.zip"

    echo "Downloading Vault from $VAULT_URL"
    curl -Lo vault.zip "$VAULT_URL"

    # Unzip the Vault binary
    unzip vault.zip

    # Move the Vault binary to /usr/local/bin
    sudo mv vault /usr/local/bin/

    # Clean up
    rm vault.zip

    # Check if the installation was successful
    if command -v vault &>/dev/null; then
        echo "Vault installation completed successfully."
        vault -version
    else
        echo "Vault installation failed."
        exit 1
    fi

    # Create Vault user and group
    sudo useradd --system --home /etc/vault.d --shell /bin/false vault

    # Create necessary directories
    sudo mkdir --parents /etc/vault.d
    sudo mkdir --parents /var/lib/vault

    # Set permissions
    sudo chown --recursive vault:vault /etc/vault.d /var/lib/vault

    # Create a systemd service file for Vault
    echo "Creating systemd service file for Vault"
    sudo tee /etc/systemd/system/vault.service > /dev/null <<EOL
[Unit]
Description=Vault service
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOL

    # Reload systemd and enable the Vault service
    sudo systemctl daemon-reload
    sudo systemctl enable vault

    # Start the Vault service
    sudo systemctl start vault

    # Verify the service is running
    if systemctl is-active --quiet vault; then
        echo "Vault installation completed successfully and is running."
    else
        echo "Vault installation failed or the service did not start correctly."
        exit 1
    fi

    echo "Vault is running as a service."
}

# Run the installation function
install_vault
