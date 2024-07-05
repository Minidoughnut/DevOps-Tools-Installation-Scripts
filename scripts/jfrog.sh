#!/bin/bash

install_jfrog_artifactory() {
    # Define variables
    ARTIFACTORY_VERSION="7.46.13"  # You can update this to the latest version if needed
    ARTIFACTORY_USER="artifactory"
    ARTIFACTORY_GROUP="artifactory"
    ARTIFACTORY_DIR="/opt/jfrog/artifactory"
    ARTIFACTORY_URL="https://releases.jfrog.io/artifactory/artifactory-pro/org/artifactory/pro/jfrog-artifactory-pro/${ARTIFACTORY_VERSION}/jfrog-artifactory-pro-${ARTIFACTORY_VERSION}-linux.tar.gz"

    # Create Artifactory user and group
    sudo groupadd -r $ARTIFACTORY_GROUP
    sudo useradd -r -g $ARTIFACTORY_GROUP -d $ARTIFACTORY_DIR -s /bin/false $ARTIFACTORY_USER

    # Install required packages
    sudo apt-get update
    sudo apt-get install -y wget

    # Download and extract Artifactory
    echo "Downloading JFrog Artifactory from $ARTIFACTORY_URL"
    wget $ARTIFACTORY_URL -O artifactory.tar.gz
    sudo mkdir -p /opt/jfrog
    sudo tar -xzvf artifactory.tar.gz -C /opt/jfrog
    sudo mv /opt/jfrog/artifactory-pro-${ARTIFACTORY_VERSION} $ARTIFACTORY_DIR
    rm artifactory.tar.gz

    # Set ownership
    sudo chown -R $ARTIFACTORY_USER:$ARTIFACTORY_GROUP $ARTIFACTORY_DIR

    # Create systemd service file
    echo "Creating systemd service file for JFrog Artifactory"
    sudo tee /etc/systemd/system/artifactory.service > /dev/null <<EOL
[Unit]
Description=JFrog Artifactory service
After=syslog.target network.target

[Service]
Type=simple

ExecStart=$ARTIFACTORY_DIR/app/bin/artifactoryManage.sh start
ExecStop=$ARTIFACTORY_DIR/app/bin/artifactoryManage.sh stop

User=$ARTIFACTORY_USER
Group=$ARTIFACTORY_GROUP
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOL

    # Reload systemd and start Artifactory service
    sudo systemctl daemon-reload
    sudo systemctl enable artifactory.service
    sudo systemctl start artifactory.service

    # Verify the service is running
    if systemctl is-active --quiet artifactory.service; then
        echo "JFrog Artifactory installation completed successfully and is running."
    else
        echo "JFrog Artifactory installation failed or the service did not start correctly."
        exit 1
    fi

    echo "You can access JFrog Artifactory at http://<your-server-ip>:8081"
}

# Check for Java installation
if ! command -v java &> /dev/null; then
    echo "Java is not installed. Installing Java..."
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk
fi

# Run the installation function
install_jfrog_artifactory
