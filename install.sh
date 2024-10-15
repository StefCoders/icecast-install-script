#!/bin/bash

# Variables
ICECAST_VERSION="icecast-2.4.4"  # Update if a newer version is released
INSTALL_DIR=$(pwd)
ICECAST_URL="http://downloads.xiph.org/releases/icecast/${ICECAST_VERSION}.tar.gz"
SERVICE_NAME="icecast"

# Functions
print_message() {
  echo -e "\n\033[1;34m$1\033[0m"
}

check_success() {
  if [ $? -ne 0 ]; then
    echo -e "\033[1;31m[ERROR]\033[0m $1 failed. Exiting..."
    exit 1
  fi
}

print_separator() {
  echo -e "\n-----------------------------------------\n"
}

# Welcome message
print_message "Welcome to the Icecast Installation Script!"
echo "This script will install Icecast in the current directory: ${INSTALL_DIR}"
echo "Icecast Version: ${ICECAST_VERSION}"

# Confirmation prompt
read -p "Do you wish to proceed with the installation? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
  echo "Installation aborted."
  exit 0
fi

print_separator

# Update system and install prerequisites
print_message "Step 1: Updating system and installing necessary packages..."
sudo apt-get update
check_success "System update"

sudo apt-get install -y build-essential curl tar
check_success "Package installation"

print_separator

# Download and extract Icecast
print_message "Step 2: Downloading Icecast source files..."
curl -O ${ICECAST_URL}
check_success "Icecast download"

print_message "Extracting Icecast files..."
if file "${ICECAST_VERSION}.tar.gz" | grep -q gzip; then
    tar -xzf ${ICECAST_VERSION}.tar.gz
    check_success "File extraction"
else
    echo -e "\033[1;31m[ERROR]\033[0m Downloaded file is not a valid gzip archive. Please check the download URL."
    exit 1
fi

print_separator

# Update system and install prerequisites
print_message "Step 1: Updating system and installing necessary packages..."
sudo apt-get update
check_success "System update"

sudo apt-get install -y build-essential curl tar
check_success "Package installation"

print_separator

# Download and extract Icecast
print_message "Step 2: Downloading Icecast source files..."
curl -O http://downloads.xiph.org/releases/icecast/${ICECAST_VERSION}.tar.gz
check_success "Icecast download"

print_message "Extracting Icecast files..."
tar -xzf ${ICECAST_VERSION}.tar.gz
check_success "File extraction"

print_separator

# Build and install Icecast
print_message "Step 3: Building and installing Icecast..."
cd ${ICECAST_VERSION}
./configure --prefix=$INSTALL_DIR
check_success "Configuration"

make
check_success "Build"

make install
check_success "Installation"

cd ..
print_message "Icecast has been successfully installed to: ${INSTALL_DIR}"

print_separator

# Create the Icecast systemd service file
print_message "Step 4: Creating systemd service for Icecast..."

sudo bash -c 'cat << EOF > /etc/systemd/system/icecast.service
[Unit]
Description=Icecast Streaming Media Server
After=network.target

[Service]
ExecStart='${INSTALL_DIR}'/bin/icecast -c '${INSTALL_DIR}'/etc/icecast.xml
Restart=on-failure
User=root 
Group=root

[Install]
WantedBy=multi-user.target
EOF'
check_success "Service creation"

print_separator

# Reload systemd and enable Icecast service
print_message "Step 5: Enabling and starting Icecast service..."
sudo systemctl daemon-reload
check_success "Systemd reload"

sudo systemctl enable $SERVICE_NAME
check_success "Service enablement"

sudo systemctl start $SERVICE_NAME
check_success "Service startup"

print_separator

# Success message
print_message "Icecast installation completed successfully!"
echo "Icecast is now running as a service and will start on boot."
echo "To check the status of the service, use: sudo systemctl status icecast"
echo "The Icecast configuration file is located at: ${INSTALL_DIR}/etc/icecast.xml"
