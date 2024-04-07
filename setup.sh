#!/bin/bash

# Exit if any command fails
set -e

# Set color variables
GREEN='\033[0;32m'
RED='\033[0;91m' # Use bright red for better visibility
YELLOW='\033[0;33m'
BYELLOW='\033[1;33m'
NC='\033[0m' # Reset color

# Get current user id
USER_ID=$(id -un)

# Setup sudo permissions to avoid timeouts
echo "Defaults:$USER_ID timestamp_timeout=-1" | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/xahlnode_deploy

# Absolute path of the script directory
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/xahl_node.vars"

# Current date in UTC
FDATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

check_and_install_packages() {
    echo -e "${GREEN}Checking and installing necessary packages...${NC}"

    # Define required packages
    declare -a packages=("git" "ufw" "nginx" "curl")

    # Update and upgrade system
    [[ "$INSTALL_UPDATES" == "true" ]] && sudo apt-get update && sudo apt-get upgrade -y

    # Install packages
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -qw "$pkg"; then
            echo "Installing: $pkg"
            sudo apt-get install -y "$pkg"
        else
            echo "Package $pkg already installed."
        fi
    done
}

clone_and_setup_node() {
    echo -e "${GREEN}Cloning and setting up Xahau Node...${NC}"
    local repo_url="https://github.com/Xahau/$VARVAL_CHAIN_REPO"

    # Clone repository if it doesn't exist
    if [ ! -d "$HOME/$VARVAL_CHAIN_REPO" ]; then
        git clone "$repo_url" "$HOME/$VARVAL_CHAIN_REPO"
    fi

    # Run install/update script
    (cd "$HOME/$VARVAL_CHAIN_REPO" && sudo ./xahaud-install-update.sh)

    # Configure .cfg file
    # Example of configuring the .cfg file
}

setup_ufw_ports() {
    echo -e "${GREEN}Configuring UFW ports...${NC}"
    # Example: Setup UFW to allow Nginx and SSH ports
    sudo ufw allow 'Nginx Full'
    sudo ufw allow ssh
}

enable_ufw() {
    echo -e "${GREEN}Enabling UFW...${NC}"
    sudo ufw --force enable
}

install_certbot() {
    echo -e "${GREEN}Installing and setting up Certbot...${NC}"
    # Example: Install Certbot and request certificates
}

logrotate_config() {
    echo -e "${GREEN}Configuring logrotate...${NC}"
    # Example: Create logrotate configuration
}

update_nginx_configuration() {
    echo -e "${GREEN}Updating Nginx configuration...${NC}"
    # Example: Create or update Nginx site configurations
}

# Main deployment function
deploy_node() {
    check_and_install_packages
    clone_and_setup_node
    setup_ufw_ports
    enable_ufw
    install_certbot
    logrotate_config
    update_nginx_configuration

    echo -e "${GREEN}Node deployment completed.${NC}"
}

# Cleanup function to remove temporary sudo configuration
cleanup() {
    sudo rm -f /etc/sudoers.d/xahlnode_deploy
    echo -e "${GREEN}Cleanup complete.${NC}"
}

# Execute the main deployment function
deploy_node

# Cleanup on exit
cleanup