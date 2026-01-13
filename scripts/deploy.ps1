<#
.SYNOPSIS
    Automated Deployment Script for Hostiqo/Awan-Host
    
.DESCRIPTION
    This script automates the deployment process from a local Windows machine to a remote Linux server.
    It performs the following steps:
    1. Uploads the current project files to the remote server using SCP.
    2. Connects via SSH to run the installation script.
    
.EXAMPLE
    .\scripts\deploy.ps1
    
.NOTES
    Requires OpenSSH Client to be installed (standard on Windows 10/11).
#>

param (
    [string]$ServerIP,
    [string]$User = "root",
    [string]$RemotePath = "/tmp/awan_host_setup"
)

# -------------------------------------------------------------------------
# Helper Functions
# -------------------------------------------------------------------------

function Write-Header {
    param ([string]$Text)
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host " $Text" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param ([string]$Text)
    Write-Host " [OK] $Text" -ForegroundColor Green
}

function Write-Info {
    param ([string]$Text)
    Write-Host " [..] $Text" -ForegroundColor Yellow
}

function Write-Error {
    param ([string]$Text)
    Write-Host " [!!] $Text" -ForegroundColor Red
}

# -------------------------------------------------------------------------
# Main Execution
# -------------------------------------------------------------------------

Write-Header "Hostiqo Cloud Deployer"

# 1. Prerequisites Check
if (-not (Get-Command "ssh" -ErrorAction SilentlyContinue) -or -not (Get-Command "scp" -ErrorAction SilentlyContinue)) {
    Write-Error "OpenSSH Client is not installed or not in PATH."
    Write-Host "Please install OpenSSH Client via Windows Settings > Apps > Optional Features."
    exit 1
}

# 2. Configuration
if ([string]::IsNullOrWhiteSpace($ServerIP)) {
    $ServerIP = Read-Host "Enter Remote Server IP"
}

if ([string]::IsNullOrWhiteSpace($ServerIP)) {
    Write-Error "Server IP is required."
    exit 1
}

# 3. Confirm
Write-Host "Deploying to: $User@$ServerIP" -ForegroundColor White
Write-Host "Target Path:  $RemotePath" -ForegroundColor White
Write-Host ""
$Confirm = Read-Host "Continue? (y/n)"
if ($Confirm -ne "y") { exit 0 }

# 4. Upload Files
Write-Header "Step 1: Uploading Files"
Write-Info "Uploading files via SCP. Please enter password if prompted..."

# Get script root to determine project root
$ScriptRoot = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ScriptRoot

# Ensure remote directory exists
Write-Info "Creating remote directory..."
ssh -o StrictHostKeyChecking=no "$User@$ServerIP" "mkdir -p $RemotePath"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to connect to server. Check IP and credentials."
    exit 1
}

# Upload (excluding .git and node_modules likely handled by scp exclusions or we just copy everything and let remote handle it)
# PowerShell SCP doesn't have robust exclude like rsync. We will use a simple recursive copy.
# Ideally we should exclude .git and node_modules to save bandwidth.
# We will construct a specific file list or just warn user.

Write-Info "Copying project files (this may take a moment)..."

# Using scp -r. 
# Note: To exclude files properly on Windows without rsync is tricky.
# We will copy everything. User should clean up node_modules locally if they want faster upload.
scp -r "$ProjectRoot/*" "$User@${ServerIP}:$RemotePath/"

if ($LASTEXITCODE -eq 0) {
    Write-Success "Upload complete."
} else {
    Write-Error "Upload failed."
    exit 1
}

# 5. Remote Execution
Write-Header "Step 2: Remote Installation"
Write-Info "Connecting to server to run installer..."

# Command to run on server
$RemoteCommand = "cd $RemotePath && chmod +x scripts/install.sh && bash scripts/install.sh --local"

ssh -t "$User@$ServerIP" $RemoteCommand

Write-Header "Deployment Finished"
Write-Info "If installation was successful, your panel is ready."
