#!/bin/bash

install_sonarqube() {
    # Define variables
    SONARQUBE_VERSION="9.9.1.69595"  # You can update this to the latest version if needed
    SONARQUBE_USER="sonarqube"
    SONARQUBE_GROUP="sonarqube"
    SONARQUBE_DIR="/opt/sonarqube"
    SONARQUBE_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip"

    # Create SonarQube user and group
    sudo groupadd -r $SONARQUBE_GROUP
    sudo useradd -r -g $SONARQUBE_GROUP -d $SONARQUBE_DIR -s /bin/false $SONARQUBE_USER

    # Install required packages
    sudo apt-get update
    sudo apt-get install -y unzip wget

    # Download and extract SonarQube
    echo "Downloading SonarQube from $SONARQUBE_URL"
    wget $SONARQUBE_URL -O sonarqube.zip
    sudo unzip sonarqube.zip -d /opt
    sudo mv /opt/sonarqube-${SONARQUBE_VERSION} $SONARQUBE_DIR
    rm sonarqube.zip

    # Set ownership
    sudo chown -R $SONARQUBE_USER:$SONARQUBE_GROUP $SONARQUBE_DIR

    # Create systemd service file
    echo "Creating systemd service file for SonarQube"
    sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOL
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=$SONARQUBE_DIR/bin/linux-x86-64/sonar.sh start
ExecStop=$SONARQUBE_DIR/bin/linux-x86-64/sonar.sh stop

User=$SONARQUBE_USER
Group=$SONARQUBE_GROUP
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOL

    # Reload systemd and start SonarQube service
    sudo systemctl daemon-reload
    sudo systemctl enable sonarqube.service
    sudo systemctl start sonarqube.service

    # Verify the service is running
    if systemctl is-active --quiet sonarqube.service; then
        echo "SonarQube installation completed successfully and is running."
    else
        echo "SonarQube installation failed or the service did not start correctly."
        exit 1
    fi

    echo "You can access SonarQube at http://<your-server-ip>:9000"
}

# Check for Java installation
if ! command -v java &> /dev/null; then
    echo "Java is not installed. Installing Java..."
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk
fi

# Run the installation function
install_sonarqube
