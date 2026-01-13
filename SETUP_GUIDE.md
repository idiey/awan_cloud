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
    -   Enter Domain: `example.com` (or a fake domain like `my-panel.test`)
    -   Enable SSL: `y` (Auto-configures HTTPS)
    *   **Note**: If using a **fake domain**, answer `n` for SSL. You will need to edit your local `hosts` file to access it.

**Completion**:
Once finished, access your dashboard at: `https://example.com`

## Using a Fake Domain (Development)
The deployment script (`deploy.ps1` or `deploy.sh`) will now **automatically ask** if you want to map a fake domain to your server's IP.

If you choose `y`, it will add the entry to your `hosts` file for you.
*   **Windows**: You must run the script as **Administrator**.
*   **Linux/Mac**: You will be asked for your `sudo` password.

**Manual Verification:**
You can verify the entry was added by checking:
*   **Windows**: `C:\Windows\System32\drivers\etc\hosts`
*   **Linux**: `/etc/hosts`

## Safe Updates
You can **re-run the deployment script** at any time to update your application code.
*   **Updates Code**: It checks for changes in your local files and uploads them.
*   **Preserves Data**: It will **NOT** delete your database, uploads, or configuration (`.env`).
*   **Zero Downtime**: The installer detects existing setups and only performs necessary updates.

To update, simply run:
`.\scripts\deploy.ps1` (Windows) or `./scripts\deploy.sh` (Linux)

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
