#!/bin/bash

# Command-line arguments
NON_INTERACTIVE=false
USE_DEFAULT_KEYPAIR=false
KEYPAIR_PATH=""
PRPC_MODE=""
INSTALL_OPTION=""
DEV_MODE=false

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --non-interactive|-n)
            NON_INTERACTIVE=true
            shift
            ;;
        --default-keypair)
            USE_DEFAULT_KEYPAIR=true
            shift
            ;;
        --keypair-path)
            KEYPAIR_PATH="$2"
            shift 2
            ;;
        --prpc-mode)
            PRPC_MODE="$2"
            if [[ "$PRPC_MODE" != "public" && "$PRPC_MODE" != "private" ]]; then
                echo "Error: --prpc-mode must be 'public' or 'private'"
                exit 1
            fi
            shift 2
            ;;
        --install)
            INSTALL_OPTION="1"
            shift
            ;;
        --update)
            INSTALL_OPTION="2"
            shift
            ;;
        --dev-mode|-d)
            DEV_MODE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
done

show_help() {
    cat <<'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                     XANDEUM pNODE INSTALLER v2.0                           ║
║                    Non-Interactive Installation Support                    ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE:
    sudo bash install.sh [OPTIONS]

DESCRIPTION:
    Automated installer for Xandeum pNode software including xandminer (web UI),
    xandminerd (daemon), and pod (Xandeum pod system service).

OPTIONS:
    -h, --help
        Display this help message and exit

    -n, --non-interactive
        Run in non-interactive mode (no prompts)
        Requires: --install or --update flag
        
    --install
        Perform a fresh installation of all Xandeum pNode components
        
    --update
        Update existing Xandeum pNode installation to latest version
        
    --default-keypair
        Use default keypair path: /local/keypairs/pnode-keypair.json
        If not specified, will prompt in interactive mode or use default in 
        non-interactive mode
        
    --keypair-path <PATH>
        Specify custom path to pNode keypair JSON file
        Example: --keypair-path /root/custom-keypair.json
        
    --prpc-mode <public|private>
        Set pRPC (private RPC) mode
        Options:
          public  - pRPC accessible publicly
          private - pRPC restricted access
        If not specified, will prompt in interactive mode or default to 'public'
        
    -d, --dev-mode
        Enable development mode with additional debugging output and logging
        Useful for troubleshooting installation issues

INTERACTIVE MODE:
    If no flags are provided, the installer runs in interactive menu mode where
    you can select options via a text-based menu.

EXAMPLES:
    1. Interactive installation (default behavior):
       $ sudo bash install.sh

    2. Non-interactive fresh install with defaults:
       $ sudo bash install.sh --non-interactive --install --default-keypair --prpc-mode public

    3. Non-interactive fresh install with dev mode:
       $ sudo bash install.sh -n --install --default-keypair --prpc-mode public -d

    4. Non-interactive update of existing installation:
       $ sudo bash install.sh --non-interactive --update

    5. Install with custom keypair path:
       $ sudo bash install.sh -n --install --keypair-path /root/my-keypair.json --prpc-mode private

    6. Install with custom keypair and dev mode:
       $ sudo bash install.sh -n --install --keypair-path /root/pnode.json --prpc-mode public -d

    7. Show this help message:
       $ bash install.sh --help

SERVICES INSTALLED:
    - xandminer.service  : Web UI accessible on port 3000
    - xandminerd.service : Daemon service accessible on port 4000  
    - pod.service        : Xandeum pod system service

REQUIREMENTS:
    - Ubuntu 20.04+ or Debian-based Linux distribution
    - Root or sudo privileges
    - Active internet connection
    - Minimum 2GB RAM, 20GB free disk space

CONFIGURATION FILES:
    - Service files: /etc/systemd/system/
    - Keypair: /local/keypairs/ (default) or custom path
    - Pod config: /etc/tmpfiles.d/xandeum-pod.conf

TROUBLESHOOTING:
    - Check service status: sudo systemctl status xandminer.service
    - View logs: sudo journalctl -u xandminer.service -f
    - Enable dev mode for verbose output: -d or --dev-mode

SUPPORT:
    GitHub: https://github.com/Xandeum/xandminer-installer
    Discord: https://discord.gg/xandeum

EOF
}

cat <<"EOF"
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠄⡂⠌⠄⠅⠅⡂⢂⠂⡂⠂⡂⢐⠀⡂⢐⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠊⢔⠐⠌⠌⠌⢌⠐⠄⠅⢂⠂⠡⢐⢀⢂⠐⠠⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⡀⡄⡄⢄⠤⡀⡄⡄⡠⡠⡠⡠⡠⡠⢠⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⢔⠡⡊⠔⡡⠡⡡⢑⠄⠅⠅⠅⠢⠨⢈⠄⠂⠄⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⢌⢊⢢⠱⠨⡂⡪⡐⠔⢔⠰⡐⠌⡂⠢⠡⢑⢐⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠢⡊⡢⡑⢌⢌⠢⡑⡐⡡⠨⠨⡨⠨⠨⠨⢐⠈⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠢⡑⢅⠕⡰⢈⠪⡐⠡⢂⢑⠨⠨⠨⢐⠐⡈⡐⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢐⢌⢎⠢⡑⡌⡢⠢⡑⠔⠌⢔⠡⡑⠄⢅⠅⡑⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠢⡑⠌⡂⠕⠨⡈⡂⡂⠅⡡⢁⠂⡂⡐⠠⠐⠈⠀⠀⠀⠀⠀⠀⠀⢀⢔⢜⢌⢆⢕⢅⠣⡪⢨⢊⢌⠪⡘⢄⠕⡐⠅⠅⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠌⠔⠡⢑⢐⠐⠄⠅⢂⠐⡐⠠⠐⢈⢀⠁⡈⠐⡀⡀⠀⠀⠀⠑⡕⡕⡜⡔⢕⠜⡌⡪⢢⠱⡐⠕⡌⡢⡑⠌⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⢑⢐⠐⠨⠠⢁⠂⢂⠐⡀⠅⠠⠀⠄⠐⡀⢂⢐⠠⠀⠀⠈⠸⡸⡨⡪⡪⡊⡎⡜⢔⡑⡅⢇⢪⠰⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠈⠌⢐⠠⢈⠠⠐⢀⠐⠀⠂⡀⠁⠄⢂⠐⡈⠌⡀⡀⠀⠈⠘⡜⡜⡜⡌⡎⢆⢣⢊⠎⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠐⡀⠄⠐⠀⠄⠀⢁⠠⠀⠂⠨⠀⡂⠂⠅⠢⠨⡠⠀⠀⠀⠑⢕⢕⢪⢪⠪⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠁⠐⠀⠈⠀⠀⠠⠈⠄⠡⠠⠡⠡⠡⡑⠄⢕⠠⠀⠀⠀⠑⡕⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡈⢂⢀⠀⠂⠈⢀⠈⠄⠁⠌⠠⠡⡈⠢⡨⡈⡢⠈⠀⠀⢀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⢂⠐⡀⠄⠠⠀⠂⠠⠐⠈⠠⠁⠌⡐⡈⡂⡂⠂⠀⠀⠀⠐⠀⠀⠄⠐⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠡⢐⠀⡂⠄⠂⢂⠐⠀⠂⡀⠡⠈⠄⡁⢂⢂⠂⠀⠀⠀⠐⠀⡀⠂⢁⠠⠁⡐⠠⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⡂⠅⡡⢁⠂⡂⡐⡈⢐⠠⠈⠄⢁⠠⠐⢈⠀⡂⠂⠀⠀⠀⠠⠈⠀⠂⡀⠂⠄⠂⡁⠄⠌⢐⠀⠅⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⡂⡂⡢⢁⢂⠂⢅⢐⢀⠂⡂⠄⠅⠨⠀⠄⠂⡀⠂⠀⠀⠀⠀⠈⡀⢀⠡⠐⠀⠌⠠⠁⠄⠂⠌⠄⠌⡨⠐⡐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⡢⢂⠪⡐⡐⡡⠂⢅⢂⢂⠂⢌⠐⡈⠄⠅⠌⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠄⠐⡈⠄⠡⠁⠌⠄⡑⡈⠄⠅⡂⠅⡂⠅⢅⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⢆⠪⡐⢅⠕⡐⢅⠢⡑⡐⠔⡠⠑⠄⠅⡂⠡⠨⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠅⢐⠈⠄⠡⠨⢐⢀⠂⢅⠡⠂⢅⠢⠡⡑⢄⠕⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⡪⡊⡎⢜⢌⢢⠱⡨⢂⠕⡐⢌⠌⠔⡡⠡⡁⠢⠁⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠨⠠⠡⢁⢂⠂⠅⠢⠨⡨⢂⠪⠨⡂⢕⠨⡂⡢⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⢪⢪⢪⢸⢨⢢⢑⢆⠣⡊⡢⡑⢌⠢⡡⡑⡐⠅⠌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠂⠈⠈⠊⠈⠐⠐⠁⠑⠈⠂⠑⠑⠈⠊⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣠⢺⡸⡸⡸⡸⡸⡨⡪⡊⡆⡣⡱⡨⢪⠨⡊⢔⠌⠂⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⢞⡕⡧⡳⡹⡸⡪⡪⡪⡪⡪⡊⡎⡢⡣⡑⠕⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF

log_dev() {
    if [ "$DEV_MODE" = true ]; then
        echo "[DEV] $1"
    fi
}

show_menu() {
    echo "Please select an option:"
    echo "1. Install Xandeum pNode Software"
    echo "2. Update Xandeum pNode Software"
    echo "3. Stop/Restart/Disable Service"
    echo "4. Harden SSH (Disable Password Login)"
    echo "5. Exit"
    read -p "Enter your choice (1-5): " choice
    case $choice in
    1) start_install ;;
    2) upgrade_install ;;
    3) actions ;;
    4) harden_ssh ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option. Please try again."
        show_menu
        ;;
    esac
}

sudoCheck() {
    # Check for root/sudo privileges
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root or with sudo. Please try again with sudo."
        exit 1
    fi
    log_dev "Root/sudo check passed"
}

harden_ssh() {
    sudoCheck
    log_dev "Starting SSH hardening"
    
    # Backup current sshd_config and sshd.d files
    echo "Backing up SSH configuration files..."
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak-$(date +%Y%m%d%H%M%S)
    if [ -d /etc/ssh/sshd_config.d ]; then
        cp -r /etc/ssh/sshd_config.d /etc/ssh/sshd_config.d.bak-$(date +%Y%m%d%H%M%S)
    fi

    # Disable password authentication in sshd_config
    echo "Disabling password authentication in /etc/ssh/sshd_config..."
    sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^#*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config

    # Handle sshd.d directory if it exists
    if [ -d /etc/ssh/sshd_config.d ]; then
        echo "Configuring SSH settings in /etc/ssh/sshd_config.d..."
        SSHD_D_FILE="/etc/ssh/sshd_config.d/10-disable-password-auth.conf"
        cat >"$SSHD_D_FILE" <<EOL
        PasswordAuthentication no
        ChallengeResponseAuthentication no
EOL
        chmod 644 "$SSHD_D_FILE"
        log_dev "Created $SSHD_D_FILE"
    fi
    echo "SSH hardening completed successfully!"
}

upgrade_install() {
    sudoCheck
    log_dev "Starting upgrade process"
    stop_service
    start_install
    ensure_xandeum_pod_tmpfile
    echo "Upgrade completed successfully!"
    restart_service
    echo "Service restart completed."
}

handle_keypair() {
    log_dev "Handling keypair configuration"
    
    # Handle keypair configuration
    if [ "$USE_DEFAULT_KEYPAIR" = true ]; then
        echo "Using default keypair path: /local/keypairs/pnode-keypair.json"
        KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
        log_dev "Default keypair path selected"
    elif [ -n "$KEYPAIR_PATH" ]; then
        echo "Using specified keypair path: $KEYPAIR_PATH"
        log_dev "Custom keypair path: $KEYPAIR_PATH"
        # Validate keypair exists
        if [ ! -f "$KEYPAIR_PATH" ]; then
            echo "Warning: Keypair file not found at: $KEYPAIR_PATH"
            if [ "$NON_INTERACTIVE" = false ]; then
                read -p "Do you want to continue anyway? (y/n): " continue_choice
                if [ "$continue_choice" != "y" ]; then
                    echo "Installation aborted."
                    exit 1
                fi
            fi
        fi
    elif [ "$NON_INTERACTIVE" = false ]; then
        # Interactive mode: prompt user
        echo "Keypair configuration:"
        echo "1. Use default path (/local/keypairs/pnode-keypair.json)"
        echo "2. Specify custom path"
        read -p "Enter your choice (1-2): " kp_choice
        case $kp_choice in
            1)
                KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
                log_dev "User selected default keypair"
                ;;
            2)
                read -p "Enter keypair path: " KEYPAIR_PATH
                log_dev "User specified custom keypair: $KEYPAIR_PATH"
                ;;
            *)
                echo "Invalid choice. Using default."
                KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
                ;;
        esac
    else
        # Non-interactive mode without keypair specified - use default
        echo "No keypair specified in non-interactive mode. Using default: /local/keypairs/pnode-keypair.json"
        KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
        log_dev "Defaulting to standard keypair path in non-interactive mode"
    fi

    # Ensure directory exists
    mkdir -p "$(dirname "$KEYPAIR_PATH")"
    log_dev "Ensured keypair directory exists: $(dirname "$KEYPAIR_PATH")"
    
    # Export for use in service files if needed
    export PNODE_KEYPAIR_PATH="$KEYPAIR_PATH"
}

handle_prpc_mode() {
    log_dev "Handling pRPC mode configuration"
    
    # Handle pRPC mode configuration
    if [ -n "$PRPC_MODE" ]; then
        echo "pRPC mode set to: $PRPC_MODE"
        log_dev "pRPC mode: $PRPC_MODE"
    elif [ "$NON_INTERACTIVE" = false ]; then
        # Interactive mode: prompt user
        echo "pRPC Configuration:"
        echo "1. Public pRPC"
        echo "2. Private pRPC"
        read -p "Enter your choice (1-2): " prpc_choice
        case $prpc_choice in
            1)
                PRPC_MODE="public"
                log_dev "User selected public pRPC"
                ;;
            2)
                PRPC_MODE="private"
                log_dev "User selected private pRPC"
                ;;
            *)
                echo "Invalid choice. Using public."
                PRPC_MODE="public"
                ;;
        esac
    else
        # Non-interactive mode without mode specified - use public as default
        echo "No pRPC mode specified in non-interactive mode. Using default: public"
        PRPC_MODE="public"
        log_dev "Defaulting to public pRPC in non-interactive mode"
    fi

    # Export for use in service files if needed
    export PRPC_MODE
}

start_install() {
    sudoCheck
    log_dev "Starting fresh installation"
    
    # Handle configuration options
    handle_keypair
    handle_prpc_mode
    
    # Update system packages
    echo "Updating system packages..."
    log_dev "Running apt update && upgrade"
    apt update && apt upgrade -y
    apt install -y build-essential python3 make gcc g++ liblzma-dev

    # Install Node.js
    echo "Installing Node.js..."
    log_dev "Installing Node.js LTS"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
    
    if [ "$DEV_MODE" = true ]; then
        node --version
        npm --version
    fi

    if [ -d "xandminer" ] && [ -d "xandminerd" ]; then
        echo "Repositories already exist. Pulling latest changes..."
        log_dev "Found existing repositories, pulling updates"

        (
            cd xandminer
            git stash push -m "Auto-stash before pull" || true
            git pull
            log_dev "Updated xandminer repository"
        )

        (
            cd xandminerd
            git stash push -m "Auto-stash before pull" || true
            git pull
            log_dev "Updated xandminerd repository"

            if [ -f "keypairs/pnode-keypair.json" ]; then
                echo "Found pnode-keypair.json. Copying to $KEYPAIR_PATH if not already present..."

                mkdir -p "$(dirname "$KEYPAIR_PATH")"

                if [ ! -f "$KEYPAIR_PATH" ]; then
                    cp keypairs/pnode-keypair.json "$KEYPAIR_PATH"
                    echo "Copied pnode-keypair.json to $KEYPAIR_PATH"
                    log_dev "Copied keypair from repo to $KEYPAIR_PATH"
                else
                    echo "pnode-keypair.json already exists at $KEYPAIR_PATH. Skipping copy."
                    log_dev "Keypair already exists at destination"
                fi
            fi
        )
    else
        echo "Cloning repositories..."
        log_dev "Cloning xandminer and xandminerd repositories"
        git clone https://github.com/Xandeum/xandminer.git
        git clone https://github.com/Xandeum/xandminerd.git
    fi

    install_pod
    echo "Downloading application files..."
    log_dev "Downloading service files from GitHub"
    wget -O xandminerd.service "https://raw.githubusercontent.com/Xandeum/xandminer-installer/refs/heads/master/xandminerd.service"
    wget -O xandminer.service "https://raw.githubusercontent.com/Xandeum/xandminer-installer/refs/heads/master/xandminer.service"

    # Update service files with configuration
    echo "Configuring services with keypair path: $KEYPAIR_PATH and pRPC mode: $PRPC_MODE"
    log_dev "Adding environment variables to service files"
    
    # Add environment variables to service files
    sed -i "/Environment=NODE_ENV=production/a Environment=PNODE_KEYPAIR_PATH=$KEYPAIR_PATH" xandminerd.service
    sed -i "/Environment=NODE_ENV=production/a Environment=PRPC_MODE=$PRPC_MODE" xandminerd.service

    echo "Setting up Xandminer web as a system service..."
    cp /root/xandminer.service /etc/systemd/system/
    log_dev "Copied xandminer.service to systemd"

    # Build and run xandminer app
    echo "Building and running xandminer app..."
    cd xandminer
    log_dev "Installing npm packages for xandminer"
    npm install
    log_dev "Building xandminer"
    npm run build
    cd ..

    systemctl daemon-reload
    systemctl enable xandminer.service --now
    log_dev "Enabled and started xandminer.service"

    echo "Xandminer web Service Running On Port : 3000"

    cp /root/xandminerd.service /etc/systemd/system/
    log_dev "Copied xandminerd.service to systemd"

    # Set up Xandminer as a service
    echo "Setting up Xandminerd as a system service..."
    cd /root/xandminerd
    log_dev "Installing npm packages for xandminerd"
    npm install
    systemctl daemon-reload
    systemctl enable xandminerd.service --now
    log_dev "Enabled and started xandminerd.service"

    echo "Xandminerd Service Running On Port : 4000"

    cd ..

    rm xandminer.service xandminerd.service
    log_dev "Cleaned up temporary service files"

    echo "To access your Xandminer, use address localhost:3000 in your web browser"
    echo "Configuration:"
    echo "  - Keypair path: $KEYPAIR_PATH"
    echo "  - pRPC mode: $PRPC_MODE"

    echo "Setup completed successfully!"

    ensure_xandeum_pod_tmpfile
}

stop_service() {
    echo "Stopping Xandeum services..."
    log_dev "Stopping all Xandeum services"

    echo "Stopping xandminer web service..."
    systemctl stop xandminer.service
    log_dev "Stopped xandminer.service"

    echo "Stopping xandminerd system service..."
    systemctl stop xandminerd.service
    log_dev "Stopped xandminerd.service"

    echo "All services stopped successfully."
}

disable_service() {
    echo "Disabling Xandeum service..."
    log_dev "Disabling all Xandeum services"

    systemctl disable xandminerd.service --now
    systemctl disable xandminer.service --now
    log_dev "Disabled xandminerd and xandminer services"
}

restart_service() {
    echo "Restarting Xandeum service..."
    log_dev "Restarting all Xandeum services"

    # Ensure /etc/tmpfiles.d/xandeum-pod.conf exists and is correct
    ensure_xandeum_pod_tmpfile

    # Ensure /run/xandeum-pod symlink exists
    if [ ! -L /run/xandeum-pod ]; then
        echo "/run/xandeum-pod symlink missing. Recreating with systemd-tmpfiles..."
        systemd-tmpfiles --create
        log_dev "Recreated /run/xandeum-pod symlink"
    fi

    systemctl daemon-reload
    systemctl restart pod.service
    systemctl restart xandminerd.service
    systemctl restart xandminer.service
    log_dev "Restarted pod, xandminerd, and xandminer services"
}

install_pod() {
    log_dev "Installing pod package"
    sudo apt-get install -y apt-transport-https ca-certificates

    echo "deb [trusted=yes] https://xandeum.github.io/pod-apt-package/ stable main" | sudo tee /etc/apt/sources.list.d/xandeum-pod.list
    log_dev "Added Xandeum pod repository to sources"

    sudo apt-get update

    sudo apt-get install pod
    log_dev "Installed pod package"

    SERVICE_FILE="/etc/systemd/system/pod.service"

    sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description= Xandeum Pod System service
After=network.target

[Service]
ExecStart=/usr/bin/pod 
Restart=always
RestartSec=2
User=root
Environment=NODE_ENV=production
Environment=RUST_LOG=info
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=xandeum-pod

[Install]
WantedBy=multi-user.target
EOF

    log_dev "Created pod.service file"

    echo "Reloading systemd..."
    sudo systemctl daemon-reload

    echo "Enabling pod.service..."
    sudo systemctl enable pod.service

    echo "Starting pod.service..."
    sudo systemctl start pod.service
    log_dev "Enabled and started pod.service"

    echo "pod.service is now running. Check status with:"
    echo "sudo systemctl status pod.service"
}

actions() {
    echo "1. Restart Service"
    echo "2. Stop Service"
    echo "3. Disable Service"
    echo "4. Previous Menu"

    read -p "Enter your choice (1-4): " choice
    case $choice in
    1) restart_service ;;
    2) stop_service ;;
    3) disable_service ;;
    4)
        show_menu
        ;;
    *)
        echo "Invalid option. Please try again."
        actions
        ;;
    esac
}

ensure_xandeum_pod_tmpfile() {
    TMPFILE="/etc/tmpfiles.d/xandeum-pod.conf"
    if [ ! -f "$TMPFILE" ]; then
        echo "L /run/xandeum-pod - - - - /xandeum-pages" > "$TMPFILE"
        echo "Created $TMPFILE"
        log_dev "Created $TMPFILE"
    else
        echo "$TMPFILE already exists, skipping creation."
        log_dev "$TMPFILE already exists"
    fi

    # Create the symlink immediately
    systemd-tmpfiles --create
    log_dev "Ran systemd-tmpfiles --create"
}

# Main execution logic
if [ "$DEV_MODE" = true ]; then
    echo "═══════════════════════════════════════════════════════════"
    echo "  DEV MODE ENABLED - Verbose logging active"
    echo "═══════════════════════════════════════════════════════════"
    log_dev "Script started with flags: NON_INTERACTIVE=$NON_INTERACTIVE, KEYPAIR_PATH=$KEYPAIR_PATH, PRPC_MODE=$PRPC_MODE"
fi

if [ "$NON_INTERACTIVE" = true ]; then
    if [ -z "$INSTALL_OPTION" ]; then
        echo "Error: Non-interactive mode requires --install or --update"
        show_help
        exit 1
    fi
    
    sudoCheck
    log_dev "Running in non-interactive mode with option: $INSTALL_OPTION"
    
    case $INSTALL_OPTION in
        1) start_install ;;
        2) upgrade_install ;;
    esac
else
    # Interactive mode - show menu
    log_dev "Running in interactive menu mode"
    show_menu
fi
