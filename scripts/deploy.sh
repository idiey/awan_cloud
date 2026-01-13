#!/bin/bash

# Cloud Hosting Automated Deployer (Linux/Mac)
# Automates the deployment from local machine to remote server

# Default Configuration
DEFAULT_USER="root"
DEFAULT_REMOTE_PATH="/tmp/awan_host_setup"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo ""
}

print_success() { echo -e "${GREEN} [OK] $1${NC}"; }
print_error() { echo -e "${RED} [!!] $1${NC}"; }
print_info() { echo -e "${BLUE} [..] $1${NC}"; }

# Check Prerequisites
if ! command -v ssh &> /dev/null || ! command -v scp &> /dev/null; then
    print_error "SSH/SCP not found. Please install OpenSSH client."
    exit 1
fi

print_header "Hostiqo Cloud Deployer"

# Get Arguments
SERVER_IP="$1"
USER="${2:-$DEFAULT_USER}"

# Prompt for IP if not provided
if [ -z "$SERVER_IP" ]; then
    read -p "Enter Remote Server IP: " SERVER_IP
fi

if [ -z "$SERVER_IP" ]; then
    print_error "Server IP is required."
    exit 1
fi

echo -e "Deploying to: ${GREEN}$USER@$SERVER_IP${NC}"
echo -e "Target Path:  ${GREEN}$DEFAULT_REMOTE_PATH${NC}"
echo ""
read -p "Continue? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then exit 0; fi

# Optional: Map Domain
read -p "Do you want to map a domain in /etc/hosts? (y/n): " MAP_DOMAIN
if [[ "$MAP_DOMAIN" == "y" ]]; then
    read -p "Enter Domain Name: " DOMAIN
    
    if grep -q "$SERVER_IP.*$DOMAIN" /etc/hosts; then
        print_info "Entry already exists in /etc/hosts."
    else
        print_info "Adding $DOMAIN to /etc/hosts (requires sudo)..."
        echo "$SERVER_IP $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
        if [ $? -eq 0 ]; then
            print_success "Added to /etc/hosts"
        else
            print_error "Failed to write to /etc/hosts"
        fi
    fi
fi

# 1. Prepare Remote Directory
print_header "Step 1: Uploading Files"
print_info "Creating remote directory..."

ssh -o StrictHostKeyChecking=no "$USER@$SERVER_IP" "mkdir -p $DEFAULT_REMOTE_PATH"

if [ $? -ne 0 ]; then
    print_error "Failed to connect to server. Check IP and credentials."
    exit 1
fi

# 2. Upload Files
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

print_info "Uploading files..."

if command -v rsync &> /dev/null; then
    # Use rsync for efficiency if available
    rsync -av --exclude='.git' --exclude='node_modules' --exclude='vendor' --exclude='.env' "$PROJECT_ROOT/" "$USER@$SERVER_IP:$DEFAULT_REMOTE_PATH/"
else
    # Fallback to SCP
    scp -r "$PROJECT_ROOT/"* "$USER@$SERVER_IP:$DEFAULT_REMOTE_PATH/"
fi

if [ $? -eq 0 ]; then
    print_success "Upload complete."
else
    print_error "Upload failed."
    exit 1
fi

# 3. Remote Execution
print_header "Step 2: Remote Installation"
print_info "Connecting to server..."

ssh -t "$USER@$SERVER_IP" "cd $DEFAULT_REMOTE_PATH && chmod +x scripts/install.sh && sudo bash scripts/install.sh --local"

print_header "Deployment Finished"
