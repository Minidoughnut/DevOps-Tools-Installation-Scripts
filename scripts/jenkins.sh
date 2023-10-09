#!/bin/bash

# Function to ask whether to uninstall Jenkins
ask_before_uninstall() {
    read -p "Do you want to uninstall Jenkins? (y/n) " check_ans
    if [ "$check_ans" = "y" ]; then
        uninstall_jenkins
    elif [ "$check_ans" = "n" ]; then
        clear
        echo "Skipping uninstallation of the previous Jenkins version."
        exit
    else
        clear
        echo "Invalid input. Please enter 'y' or 'n'."
        ask_before_uninstall
    fi
}

# Function to uninstall Jenkins
uninstall_jenkins() {
    sudo apt-get remove -y jenkins
    sudo apt-get purge -y jenkins
    clear
    echo "Previous Jenkins version uninstalled."
    echo
    sleep 2
}

# Function to install Jenkins and its dependencies
install_jenkins() {
    # Update package list and install Java and other dependencies
    sudo apt update
    sudo apt install -y openjdk-11-jdk wget git maven curl

    # Add JAVA_HOME to /etc/environment file for Jenkins to work
    echo 'JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"' | sudo tee -a /etc/environment

    # Reload environment variables
    source /etc/environment

    # Check if JAVA_HOME is set
    clear
    java -version
    echo
    echo "Java is installed and configured."
    echo
    sleep 2

    # Install Maven
    mvn --version
    echo
    echo "Maven is installed."
    echo
    sleep 2

    # Install Git
    git --version
    echo "Git is installed."
    echo
    sleep 2

    # Install Curl
    curl --version
    echo "Curl is installed."
    echo
    sleep 1

    clear
    echo "Jenkins dependencies are installed."
    echo
    echo "Installing Jenkins..."
    echo
    sleep 2

    # Installing Jenkins
    sudo rm -f /usr/share/keyrings/jenkins.gpg
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
    sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt update
    sudo apt install -y jenkins

    # Append Java path to Jenkins service
    echo PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/lib/jvm/java-8-openjdk-amd64/bin/ >> /etc/init.d/jenkins

    sudo systemctl start jenkins.service
    sudo systemctl enable jenkins

    clear

    echo "Jenkins is now up and running :)"
    echo
    echo "You can check its state with the following command:"
    echo "sudo systemctl status jenkins"
    echo
    echo "To unlock Jenkins, run the following command and copy the initial admin password:"
    echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}

# Check if Jenkins is already installed
check_jenkins() {
    if [ -x "$(command -v jenkins)" ]; then
        echo "Jenkins is already installed."
        echo
        ask_before_uninstall
    else
        install_jenkins
    fi
}

# Run the script
check_jenkins


echo " To complement other security measures"
echo "Remember to set a strong password for Jenkins admin account"
echo "Implement firewall rules to restrict access to Jenkins web interface. Allow access only from trusted IP."
echo "You may change the default port number for Jenkins from 8080."
