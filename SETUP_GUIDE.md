# Hostiqo Cloud Setup Guide

This guide describes how to automatically setup Hostiqo (Awan Host) on a fresh Linux Cloud VPS.

## Prerequisites
- **Cloud Server**: Ubuntu 22.04 LTS or 24.04 LTS (Recommended)
- **Root Access**: You must be logged in as `root`
- **Domain Name**: Pointed to your server's IP address (A Record)

## Automated Setup Workflow

### 1. Access Cloud Linux Server
Provision a fresh Ubuntu 22.04/24.04 server on your cloud provider (Digital Ocean, AWS, Linode, etc.).
Make sure you have the **IP Address** and **Root Password** (or SSH Key) ready.

### 2. Run Automated Deployment
We have provided automated scripts that handle the file upload and installation process for you.

**Windows (PowerShell):**
```powershell
.\scripts\deploy.ps1
```

**Linux / Mac (Terminal):**
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

The script will guide you through:
1.  **Server Connection**: It will ask for your Server IP.
2.  **Upload**: automatically uploads the `awan-nano` code to your server.
3.  **Installation**: It automatically triggers the installer on the server.

### 3. Application Guide until Finish
Once the script connects to the server, it will verify prerequisites and launch the **Setup Wizard**. Follow the interactive guide to finish configuration:

1.  **Confirm Installation**: `y`
2.  **Database Setup**: `y` (Auto-creates user/password)
3.  **Admin Account**: `y` (Create your login credentials)
4.  **Web Server & SSL**:
    -   Enter Domain: `example.com`
    -   Enable SSL: `y` (Auto-configures HTTPS)

**Completion**:
Once finished, access your dashboard at: `https://example.com`

## Troubleshooting

### Permissions Issue
If you encounter permission errors during file copy, run:
```bash
chown -R root:root /tmp/awan_host_setup
```

### 502 Bad Gateway
If Nginx shows 502 Bad Gateway, likely PHP-FPM or Supervisor isn't running.
```bash
systemctl status php8.2-fpm
supervisorctl status
```

### Check Logs
```bash
tail -f /var/www/hostiqo/storage/logs/laravel.log
```
