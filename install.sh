#!/bin/bash

show_help() {
    cat <<EOF
Xandeum pNode Installer

Usage: sudo bash install.sh [OPTIONS]

Options:
  -n, --non-interactive    Run in non-interactive mode (requires --install or --update)
  --install                Perform fresh installation
  --update                 Update existing installation
  -d, --dev                Enable dev mode (interactive branch selection for repos and pod trynet versions)
  --default-keypair        Use default keypair path (/local/keypairs/pnode-keypair.json)
  --keypair-path PATH      Specify custom keypair path
  --prpc-mode MODE         Set pRPC mode: 'public' or 'private'
  --atlas-cluster CLUSTER  Set Atlas cluster: 'trynet', 'devnet', or 'mainnet-alpha' (default: devnet)
  --log-path PATH          Set pod log file path (default: /opt/xandminer/pod-logs/pod.log)
  -h, --help               Show this help message

Examples:
  # Interactive installation (default):
  sudo bash install.sh

  # Non-interactive fresh install with defaults:
  sudo bash install.sh --non-interactive --install --default-keypair --prpc-mode public --atlas-cluster devnet

  # Non-interactive update:
  sudo bash install.sh --non-interactive --update

  # Install with dev mode:
  sudo bash install.sh --non-interactive --install --dev --default-keypair --prpc-mode public --atlas-cluster devnet

  # Install with trynet:
  sudo bash install.sh --non-interactive --install --default-keypair --prpc-mode public --atlas-cluster trynet

  # Install with custom keypair and mainnet-alpha:
  sudo bash install.sh --non-interactive --install --keypair-path /local/keypairs/my-keypair.json --prpc-mode private --atlas-cluster mainnet-alpha

EOF
}

# Command-line arguments
NON_INTERACTIVE=false
USE_DEFAULT_KEYPAIR=false
KEYPAIR_PATH=""
PRPC_MODE=""
ATLAS_CLUSTER=""
POD_LOG_PATH=""
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
        --atlas-cluster)
            ATLAS_CLUSTER="$2"
            if [[ "$ATLAS_CLUSTER" != "trynet" && "$ATLAS_CLUSTER" != "devnet" && "$ATLAS_CLUSTER" != "mainnet-alpha" ]]; then
                echo "Error: --atlas-cluster must be 'trynet', 'devnet', or 'mainnet-alpha'"
                exit 1
            fi
            shift 2
            ;;
        --log-path)
            POD_LOG_PATH="$2"
            shift 2
            ;;
        --dev|-d)
            DEV_MODE=true
            shift
            ;;
        --install)
            INSTALL_OPTION="1"
            shift
            ;;
        --update)
            INSTALL_OPTION="2"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

cat <<"EOF"
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠄⡂⠌⠄⠅⠅⡂⢂⠂⡂⠂⡂⢐⠀⡂⢐⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠊⢔⠐⠌⠌⠌⢌⠐⠄⠅⢂⠂⠡⢐⢀⢂⠐⠠⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
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
}

# Security functions
ensure_service_user() {
    if ! id -u xand >/dev/null 2>&1; then
        echo "Creating xand service user..."
        useradd -r -s /usr/sbin/nologin -d /opt/xandminer -m xand || {
            echo "Error: Failed to create xand user"
            exit 1
        }
        echo "✓ Created xand user"
    else
        echo "✓ xand user already exists"
    fi
}

sanitize_branch_name() {
    echo "$1" | sed 's/[^a-zA-Z0-9._/-]//g'
}

sanitize_version() {
    echo "$1" | sed 's/[^a-zA-Z0-9.~+-]//g'
}

sanitize_path() {
    local path="$1"
    path=$(echo "$path" | sed 's/[^a-zA-Z0-9./_-]//g')
    if [[ ! "$path" =~ ^/ ]]; then
        path="/$path"
    fi
    echo "$path"
}

harden_ssh() {
    sudoCheck
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
    fi
    echo "SSH hardening completed successfully!"
}

upgrade_install() {
    sudoCheck
    stop_service
    start_install
    ensure_xandeum_pod_tmpfile
    
    # Note: setup_logrotate() is already called in start_install(), no need to call again
    
    echo "Upgrade completed successfully!"
    
    # Restart services at the end
    if [ "$NON_INTERACTIVE" = true ]; then
        echo ""
        echo "Waiting 30 seconds before restarting services..."
        sleep 30
    fi
    
    restart_service
    echo "Service restart completed."
}

handle_keypair() {
    # Handle keypair configuration
    if [ "$USE_DEFAULT_KEYPAIR" = true ]; then
        echo "Using default keypair path: /local/keypairs/pnode-keypair.json"
        KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
    elif [ -n "$KEYPAIR_PATH" ]; then
        echo "Using specified keypair path: $KEYPAIR_PATH"
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
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Keypair Configuration"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "1. Use default path (/local/keypairs/pnode-keypair.json) (default)"
        echo "2. Specify custom path"
        echo ""
        read -p "Enter your choice (1-2, press Enter for default): " kp_choice
        case $kp_choice in
            1|"")
                KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
                ;;
            2)
                read -p "Enter keypair path: " KEYPAIR_PATH
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
    fi

    # Ensure directory exists
    mkdir -p "$(dirname "$KEYPAIR_PATH")"
    
    # Export for use in service files if needed
    export PNODE_KEYPAIR_PATH="$KEYPAIR_PATH"
}

handle_prpc_mode() {
    # Handle pRPC mode configuration
    if [ -n "$PRPC_MODE" ]; then
        echo "pRPC mode set to: $PRPC_MODE"
    elif [ "$NON_INTERACTIVE" = false ]; then
        # Interactive mode: prompt user
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  pRPC Configuration"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "1. Public pRPC"
        echo "2. Private pRPC (default)"
        echo ""
        read -p "Enter your choice (1-2, press Enter for default): " prpc_choice
        case $prpc_choice in
            1)
                PRPC_MODE="public"
                ;;
            2|"")
                PRPC_MODE="private"
                ;;
            *)
                echo "Invalid choice. Using private."
                PRPC_MODE="private"
                ;;
        esac
    else
        # Non-interactive mode without mode specified - use private as default
        echo "No pRPC mode specified in non-interactive mode. Using default: private"
        PRPC_MODE="private"
    fi

    # Export for use in service files if needed
    export PRPC_MODE
}

handle_atlas_cluster() {
    # Handle Atlas cluster configuration
    if [ -n "$ATLAS_CLUSTER" ]; then
        echo "Atlas cluster set to: $ATLAS_CLUSTER"
    elif [ "$NON_INTERACTIVE" = false ]; then
        # Interactive mode: prompt user
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Atlas Cluster Configuration"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "1. TryNet (65.108.233.175)"
        echo "2. DevNet (atlas.devnet.xandeum.com) (default)"
        echo "3. MainNet-Alpha (atlas.mainnet.xandeum.com)"
        echo ""
        read -p "Enter your choice (1-3, press Enter for default): " atlas_choice
        case $atlas_choice in
            1)
                ATLAS_CLUSTER="trynet"
                ;;
            2|"")
                ATLAS_CLUSTER="devnet"
                ;;
            3)
                ATLAS_CLUSTER="mainnet-alpha"
                ;;
            *)
                echo "Invalid choice. Using devnet."
                ATLAS_CLUSTER="devnet"
                ;;
        esac
    else
        # Non-interactive mode without cluster specified - use devnet as default
        echo "No Atlas cluster specified in non-interactive mode. Using default: devnet"
        ATLAS_CLUSTER="devnet"
    fi

    # Map cluster name to atlas hostname/IP
    case $ATLAS_CLUSTER in
        trynet)
            ATLAS_HOST="65.108.233.175"
            ;;
        devnet)
            ATLAS_HOST="atlas.devnet.xandeum.com"
            ;;
        mainnet-alpha)
            ATLAS_HOST="atlas.mainnet.xandeum.com"
            ;;
        *)
            echo "Warning: Unknown atlas cluster '$ATLAS_CLUSTER'. Using devnet."
            ATLAS_HOST="atlas.devnet.xandeum.com"
            ATLAS_CLUSTER="devnet"
            ;;
    esac

    echo "Atlas hostname: $ATLAS_HOST:5000"

    # Export for use in service files if needed
    export ATLAS_CLUSTER
    export ATLAS_HOST
}

handle_pod_log_path() {
    # Handle pod log path configuration
    if [ -n "$POD_LOG_PATH" ]; then
        echo "Pod log path set to: $POD_LOG_PATH"
    elif [ "$NON_INTERACTIVE" = false ]; then
        # Interactive mode: prompt user
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Pod Log Configuration"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Enter the file path for pod logs"
        echo "Default: /opt/xandminer/pod-logs/pod.log"
        echo ""
        read -p "Log path [/opt/xandminer/pod-logs/pod.log] (press Enter for default): " log_input
        if [ -z "$log_input" ]; then
            POD_LOG_PATH="/opt/xandminer/pod-logs/pod.log"
        else
            POD_LOG_PATH=$(sanitize_path "$log_input")
        fi
    else
        # Non-interactive mode without path specified - use default
        echo "No pod log path specified in non-interactive mode. Using default: /opt/xandminer/pod-logs/pod.log"
        POD_LOG_PATH="/opt/xandminer/pod-logs/pod.log"
    fi

    # Ensure directory exists (create parent directory for the log file)
    mkdir -p "$(dirname "$POD_LOG_PATH")"
    
    # Export for use in service files if needed
    export POD_LOG_PATH
}

select_branch() {
    local REPO_NAME=$1
    local REPO_URL=$2
    
    echo "" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "  Branch Selection for $REPO_NAME" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "" >&2
    echo "Fetching branches from $REPO_URL..." >&2
    
    # Create temporary directory for branch listing
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Clone with minimal depth to get branch info
    git clone --bare "$REPO_URL" repo.git 2>/dev/null || {
        echo "Error: Failed to fetch repository information" >&2
        rm -rf "$TEMP_DIR"
        return 1
    }
    
    cd repo.git
    
    # Get 10 most recent branches with commit info
    echo "Most recent 10 branches:" >&2
    echo "" >&2
    
    # Format: branch-name | commit-date | commit-message
    BRANCHES_FILE="$TEMP_DIR/branches.txt"
    git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)|%(committerdate:short)|%(contents:subject)' --count=10 > "$BRANCHES_FILE"
    
    # Display branches with numbers
    local counter=1
    declare -a BRANCH_ARRAY
    
    while IFS='|' read -r branch date message; do
        BRANCH_ARRAY[$counter]="$branch"
        printf "%2d. %-30s %s  %s\n" "$counter" "$branch" "$date" "$message" >&2
        ((counter++))
    done < "$BRANCHES_FILE"
    
    echo "" >&2
    
    # Clean up temp directory
    cd /
    rm -rf "$TEMP_DIR"
    
    # Prompt for selection
    while true; do
        read -p "Select branch number (1-10) or enter custom branch name: " BRANCH_CHOICE >&2
        
        # Check if input is a number
        if [[ "$BRANCH_CHOICE" =~ ^[0-9]+$ ]] && [ "$BRANCH_CHOICE" -ge 1 ] && [ "$BRANCH_CHOICE" -lt "$counter" ]; then
            SELECTED_BRANCH="${BRANCH_ARRAY[$BRANCH_CHOICE]}"
            echo "Selected: $SELECTED_BRANCH" >&2
            echo "$SELECTED_BRANCH"
            return 0
        elif [ -n "$BRANCH_CHOICE" ]; then
            # Treat as custom branch name - sanitize it
            SELECTED_BRANCH=$(sanitize_branch_name "$BRANCH_CHOICE")
            echo "Using custom branch: $SELECTED_BRANCH" >&2
            echo "$SELECTED_BRANCH"
            return 0
        else
            echo "Invalid selection. Please try again." >&2
        fi
    done
}

select_pod_version() {
    # All output to stderr for visibility during command substitution
    echo "" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "  Trynet Pod Version Selection" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "" >&2
    echo "Adding trynet repository..." >&2
    
    # Add trynet repository
    echo "deb [trusted=yes] https://raw.githubusercontent.com/Xandeum/trynet-packages/main/ stable main" | tee /etc/apt/sources.list.d/xandeum-pod-trynet.list >/dev/null
    apt-get update >/dev/null 2>&1
    
    echo "Fetching available trynet versions..." >&2
    echo "" >&2
    
    # Get trynet versions and format them
    VERSIONS_TEMP_DIR=$(mktemp -d)
    VERSIONS_FILE="$VERSIONS_TEMP_DIR/pod_versions.txt"
    trap "rm -rf '$VERSIONS_TEMP_DIR'" RETURN EXIT
    
    apt-cache madison pod 2>/dev/null | grep trynet | head -10 | awk '{print $3}' > "$VERSIONS_FILE"
    
    if [ ! -s "$VERSIONS_FILE" ]; then
        echo "Error: Could not fetch trynet versions. Using latest stable." >&2
        echo "stable"
        return 0
    fi
    
    echo "Available trynet pod versions (10 most recent):" >&2
    echo "" >&2
    
    # Display versions with numbers
    local counter=1
    declare -a VERSION_ARRAY
    
    while read -r version; do
        VERSION_ARRAY[$counter]="$version"
        # Extract timestamp and commit from version string
        # Format: 0.4.2~trynet.20251126115954.bedda09-1
        local timestamp=$(echo "$version" | grep -oP '(?<=trynet\.)\d{14}' | sed 's/\(.\{4\}\)\(.\{2\}\)\(.\{2\}\)/\1-\2-\3/')
        local commit=$(echo "$version" | grep -oP '[a-f0-9]{7}(?=-1)' | head -1)
        
        printf "%2d. %-50s %s  %s\n" "$counter" "$version" "$timestamp" "$commit" >&2
        ((counter++))
    done < "$VERSIONS_FILE"
    
    echo "" >&2
    
    # Prompt for selection
    while true; do
        read -p "Select version number (1-10), enter custom version, or press Enter for latest stable: " VERSION_CHOICE >&2
        
        # Empty = use stable
        if [ -z "$VERSION_CHOICE" ]; then
            echo "Using latest stable version" >&2
            echo "stable"
            return 0
        # Check if input is a number
        elif [[ "$VERSION_CHOICE" =~ ^[0-9]+$ ]] && [ "$VERSION_CHOICE" -ge 1 ] && [ "$VERSION_CHOICE" -lt "$counter" ]; then
            SELECTED_VERSION="${VERSION_ARRAY[$VERSION_CHOICE]}"
            echo "Selected: $SELECTED_VERSION" >&2
            echo "$SELECTED_VERSION"
            return 0
        elif [ -n "$VERSION_CHOICE" ]; then
            # Treat as custom version string - sanitize it
            SELECTED_VERSION=$(sanitize_version "$VERSION_CHOICE")
            echo "Using custom version: $SELECTED_VERSION" >&2
            echo "$SELECTED_VERSION"
            return 0
        else
            echo "Invalid selection. Please try again." >&2
        fi
    done
}

start_install() {
    sudoCheck
    
    # Create service user first
    ensure_service_user
    
    # Handle configuration options
    handle_keypair
    handle_prpc_mode
    handle_atlas_cluster
    handle_pod_log_path
    
    # Sanitize inputs
    KEYPAIR_PATH=$(sanitize_path "$KEYPAIR_PATH")
    POD_LOG_PATH=$(sanitize_path "$POD_LOG_PATH")
    ATLAS_CLUSTER=$(sanitize_branch_name "$ATLAS_CLUSTER")
    
    # Change to installation directory
    INSTALL_BASE="/opt"
    mkdir -p "$INSTALL_BASE"
    cd "$INSTALL_BASE"
    
    # Update system packages
    echo "Updating system packages..."
    apt update && apt upgrade -y
    apt install -y build-essential python3 make gcc g++ liblzma-dev

    # Install Node.js
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs

    # Handle dev mode branch selection (only in interactive mode)
    if [ "$DEV_MODE" = true ] && [ "$NON_INTERACTIVE" = false ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  DEV MODE: Repository Branch Selection"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # Select branch for xandminer
        XANDMINER_BRANCH=$(select_branch "xandminer" "https://github.com/Xandeum/xandminer.git")
        XANDMINER_BRANCH=$(sanitize_branch_name "$XANDMINER_BRANCH")
        
        # Select branch for xandminerd
        XANDMINERD_BRANCH=$(select_branch "xandminerd" "https://github.com/Xandeum/xandminerd.git")
        XANDMINERD_BRANCH=$(sanitize_branch_name "$XANDMINERD_BRANCH")
        
        # Select pod trynet version
        POD_VERSION=$(select_pod_version)
        POD_VERSION=$(sanitize_version "$POD_VERSION")
        
        echo ""
        echo "Selected branches:"
        echo "  xandminer: $XANDMINER_BRANCH"
        echo "  xandminerd: $XANDMINERD_BRANCH"
        echo "  pod: $POD_VERSION"
        echo ""
    elif [ "$DEV_MODE" = true ] && [ "$NON_INTERACTIVE" = true ]; then
        # Non-interactive dev mode - use defaults
        echo "Dev mode enabled in non-interactive mode - using default branches"
        XANDMINER_BRANCH="master"
        XANDMINERD_BRANCH="master"
        POD_VERSION="stable"
    fi

    if [ -d "xandminer" ] && [ -d "xandminerd" ]; then
        echo "Repositories already exist. Updating..."

        (
            cd xandminer
            git stash push -m "Auto-stash before pull" || true
            if [ "$DEV_MODE" = true ] && [ -n "$XANDMINER_BRANCH" ]; then
                git fetch origin
                git checkout "$XANDMINER_BRANCH"
                git pull origin "$XANDMINER_BRANCH"
            else
                git pull
            fi
        )

        (
            cd xandminerd
            git stash push -m "Auto-stash before pull" || true
            if [ "$DEV_MODE" = true ] && [ -n "$XANDMINERD_BRANCH" ]; then
                git fetch origin
                git checkout "$XANDMINERD_BRANCH"
                git pull origin "$XANDMINERD_BRANCH"
            else
                git pull
            fi

            if [ -f "keypairs/pnode-keypair.json" ]; then
                echo "Found pnode-keypair.json. Copying to $KEYPAIR_PATH if not already present..."

                mkdir -p "$(dirname "$KEYPAIR_PATH")"

                if [ ! -f "$KEYPAIR_PATH" ]; then
                    cp keypairs/pnode-keypair.json "$KEYPAIR_PATH"
                    chmod 600 "$KEYPAIR_PATH"
                    chown xand:xand "$KEYPAIR_PATH" 2>/dev/null || true
                    echo "Copied pnode-keypair.json to $KEYPAIR_PATH"
                else
                    echo "pnode-keypair.json already exists at $KEYPAIR_PATH. Skipping copy."
                    chmod 600 "$KEYPAIR_PATH"
                    chown xand:xand "$KEYPAIR_PATH" 2>/dev/null || true
                fi
            fi
        )
    else
        echo "Cloning repositories..."
        git clone https://github.com/Xandeum/xandminer.git
        git clone https://github.com/Xandeum/xandminerd.git
        
        if [ "$DEV_MODE" = true ] && [ -n "$XANDMINER_BRANCH" ] && [ -n "$XANDMINERD_BRANCH" ]; then
            # Checkout selected branches
            (
                cd xandminer
                git checkout "$XANDMINER_BRANCH"
            )
            
            (
                cd xandminerd
                git checkout "$XANDMINERD_BRANCH"
            )
        fi
    fi

    install_pod
    
    # Generate service files inline (more secure than downloading)
    echo "Generating service files..."
    
    # Generate xandminer.service
    sudo tee /etc/systemd/system/xandminer.service >/dev/null <<EOF
[Unit]
Description=Xandeum Miner Web Interface
After=network.target

[Service]
Type=simple
User=xand
Group=xand
WorkingDirectory=$INSTALL_BASE/xandminer
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10
Environment=NODE_ENV=production
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=xandminer

[Install]
WantedBy=multi-user.target
EOF

    # Generate xandminerd.service
    sudo tee /etc/systemd/system/xandminerd.service >/dev/null <<EOF
[Unit]
Description=Xandeum Miner Daemon
After=network.target

[Service]
Type=simple
User=xand
Group=xand
WorkingDirectory=$INSTALL_BASE/xandminerd
ExecStart=/usr/bin/node index.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PNODE_KEYPAIR_PATH=$KEYPAIR_PATH
Environment=PRPC_MODE=$PRPC_MODE
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=xandminerd

[Install]
WantedBy=multi-user.target
EOF

    echo "Setting up Xandminer web as a system service..."

    # Build and run xandminer app
    echo "Building and running xandminer app..."
    cd xandminer
    npm install
    npm run build
    cd ..

    # Set ownership of installation directories
    chown -R xand:xand "$INSTALL_BASE/xandminer"
    chown -R xand:xand "$INSTALL_BASE/xandminerd"

    systemctl daemon-reload
    systemctl enable xandminer.service

    echo "Xandminer web service configured (will start at end)"

    # Set up Xandminerd as a service
    echo "Setting up Xandminerd as a system service..."
    cd "$INSTALL_BASE/xandminerd"
    npm install
    systemctl daemon-reload
    systemctl enable xandminerd.service

    echo "Xandminerd service configured (will start at end)"

    cd "$INSTALL_BASE"
    
    # Set ownership and permissions of keypair
    if [ -f "$KEYPAIR_PATH" ]; then
        chmod 600 "$KEYPAIR_PATH"
        chown xand:xand "$KEYPAIR_PATH" 2>/dev/null || true
    fi
    
    # Set ownership and permissions of log file
    if [ -n "$POD_LOG_PATH" ]; then
        mkdir -p "$(dirname "$POD_LOG_PATH")"
        touch "$POD_LOG_PATH"
        chmod 644 "$POD_LOG_PATH"
        chown xand:xand "$POD_LOG_PATH" 2>/dev/null || true
    fi

    echo "To access your Xandminer, use address localhost:3000 in your web browser"
    echo "Configuration:"
    echo "  - Keypair path: $KEYPAIR_PATH"
    echo "  - pRPC mode: $PRPC_MODE"
    echo "  - Atlas cluster: $ATLAS_CLUSTER ($ATLAS_HOST:5000)"
    echo "  - Pod log path: $POD_LOG_PATH"
    if [ "$DEV_MODE" = true ]; then
        echo "  - Dev mode: enabled"
        if [ -n "$XANDMINER_BRANCH" ]; then
            echo "  - xandminer branch: $XANDMINER_BRANCH"
        fi
        if [ -n "$XANDMINERD_BRANCH" ]; then
            echo "  - xandminerd branch: $XANDMINERD_BRANCH"
        fi
        if [ -n "$POD_VERSION" ]; then
            echo "  - pod version: $POD_VERSION"
        fi
    fi

    echo "Setup completed successfully!"

    ensure_xandeum_pod_tmpfile
    
    # Setup logrotate if logs are enabled
    setup_logrotate
    
    # Restart services at the end
    if [ "$NON_INTERACTIVE" = true ]; then
        echo ""
        echo "Waiting 30 seconds before restarting services..."
        sleep 30
    fi
    
    restart_service
    echo ""
    echo "Xandminer web Service Running On Port : 3000"
    echo "Xandminerd Service Running On Port : 4000"
}

stop_service() {
    echo "Stopping Xandeum services..."

    echo "Stopping xandminer web service..."
    systemctl stop xandminer.service

    echo "Stopping xandminerd system service..."
    systemctl stop xandminerd.service

    echo "All services stopped successfully."
}

disable_service() {
    echo "Disabling Xandeum service..."

    systemctl disable xandminerd.service --now
    systemctl disable xandminer.service --now
}

restart_service() {
    echo "Restarting Xandeum service..."

    # Ensure /etc/tmpfiles.d/xandeum-pod.conf exists and is correct
    ensure_xandeum_pod_tmpfile

    # Ensure /run/xandeum-pod symlink exists
    if [ ! -L /run/xandeum-pod ]; then
        echo "/run/xandeum-pod symlink missing. Recreating with systemd-tmpfiles..."
        systemd-tmpfiles --create
    fi

    systemctl daemon-reload
    systemctl restart pod.service
    systemctl restart xandminerd.service
    systemctl restart xandminer.service
}

install_pod() {
    sudo apt-get install -y apt-transport-https ca-certificates

    # Remove trynet repository if it exists (only use in dev mode)
    if [ "$DEV_MODE" != true ] && [ -f /etc/apt/sources.list.d/xandeum-pod-trynet.list ]; then
        echo "Removing trynet repository (not in dev mode)..."
        sudo rm -f /etc/apt/sources.list.d/xandeum-pod-trynet.list
        # Clear apt cache to remove trynet packages
        sudo apt-get clean
    fi

    echo "deb [trusted=yes] https://xandeum.github.io/pod-apt-package/ stable main" | sudo tee /etc/apt/sources.list.d/xandeum-pod.list

    sudo apt-get update

    # Install pod (version depends on installation mode)
    if [ "$DEV_MODE" = true ] && [ -n "$POD_VERSION" ] && [ "$POD_VERSION" != "stable" ]; then
        echo "Installing trynet pod version: $POD_VERSION"
        echo "⚠️  Note: This may downgrade from a newer stable version"
        sudo apt-get install -y --allow-downgrades pod=$POD_VERSION
    else
        echo "Installing latest stable pod version"
        # Check if pod is already installed with trynet version
        CURRENT_POD_VERSION=$(pod --version 2>/dev/null || echo "")
        if [[ "$CURRENT_POD_VERSION" == *"trynet"* ]]; then
            echo "⚠️  Detected trynet version installed. Removing to install stable version..."
            sudo systemctl stop pod.service 2>/dev/null || true
            sudo apt-get remove -y pod 2>/dev/null || true
        fi
        
        # Explicitly install from stable repository, ignoring trynet versions
        # First, try to get the stable version explicitly
        STABLE_VERSION=$(apt-cache madison pod 2>/dev/null | grep -v trynet | grep "https://xandeum.github.io" | head -1 | awk '{print $3}')
        if [ -n "$STABLE_VERSION" ]; then
            echo "Installing stable version: $STABLE_VERSION"
            sudo apt-get install -y --allow-downgrades pod=$STABLE_VERSION
        else
            # Fallback: install latest (should be stable if trynet repo is removed)
            sudo apt-get install -y pod
        fi
    fi

    SERVICE_FILE="/etc/systemd/system/pod.service"

    # Ensure ATLAS_CLUSTER is set (should be set by handle_atlas_cluster, but default if not)
    if [ -z "$ATLAS_CLUSTER" ]; then
        echo "Warning: ATLAS_CLUSTER not set. Using default devnet."
        ATLAS_CLUSTER="devnet"
        ATLAS_HOST="atlas.devnet.xandeum.com"
    fi

    # Ensure POD_LOG_PATH is set (should be set by handle_pod_log_path, but default if not)
    if [ -z "$POD_LOG_PATH" ]; then
        POD_LOG_PATH="/opt/xandminer/pod-logs/pod.log"
        mkdir -p "$(dirname "$POD_LOG_PATH")"
    fi

    # Build ExecStart command based on cluster type
    if [ "$ATLAS_CLUSTER" = "mainnet-alpha" ]; then
        echo "Configuring pod service with --mainnet-alpha flag (includes gossip peers)"
        EXEC_START_CMD="/usr/bin/pod --mainnet-alpha --log $POD_LOG_PATH"
    else
        # Ensure ATLAS_HOST is set for trynet/devnet
        if [ -z "$ATLAS_HOST" ]; then
            case $ATLAS_CLUSTER in
                trynet)
                    ATLAS_HOST="65.108.233.175"
                    ;;
                devnet)
                    ATLAS_HOST="atlas.devnet.xandeum.com"
                    ;;
                *)
                    ATLAS_HOST="atlas.devnet.xandeum.com"
                    ;;
            esac
        fi
        echo "Configuring pod service with Atlas: $ATLAS_HOST:5000"
        EXEC_START_CMD="/usr/bin/pod --atlas-ip ${ATLAS_HOST}:5000 --log $POD_LOG_PATH"
    fi
    
    echo "Pod logs will be written to: $POD_LOG_PATH"

    sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description=Xandeum Pod System service
After=network.target

[Service]
ExecStart=${EXEC_START_CMD}
Restart=always
RestartSec=2
User=xand
Group=xand
Environment=NODE_ENV=production
Environment=RUST_LOG=info
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=xandeum-pod

[Install]
WantedBy=multi-user.target
EOF

    echo "Reloading systemd..."
    sudo systemctl daemon-reload

    echo "Enabling pod.service..."
    sudo systemctl enable pod.service

    echo "pod.service configured (will start with other services at end)"
    echo "Check status after restart with: sudo systemctl status pod.service"
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
    else
        echo "$TMPFILE already exists, skipping creation."
    fi

        # Create the symlink immediately
    systemd-tmpfiles --create
}

setup_logrotate() {
    # Setup logrotate for pod logs if POD_LOG_PATH is configured
    if [ -z "$POD_LOG_PATH" ]; then
        return 0
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Setting up Logrotate for Pod Logs"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Install logrotate if not already installed
    if ! command -v logrotate &> /dev/null; then
        echo "Installing logrotate..."
        apt-get install -y logrotate
    else
        echo "logrotate is already installed"
    fi
    
    # Create logrotate configuration file
    LOGROTATE_CONFIG="/etc/logrotate.d/xandeum-pod"
    LOG_DIR=$(dirname "$POD_LOG_PATH")
    LOG_FILE=$(basename "$POD_LOG_PATH")
    
    echo "Creating logrotate configuration for $POD_LOG_PATH..."
    
    sudo tee "$LOGROTATE_CONFIG" >/dev/null <<EOF
$POD_LOG_PATH {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 xand xand
    sharedscripts
    postrotate
        systemctl reload pod.service > /dev/null 2>&1 || true
    endscript
}
EOF
    
    echo "✓ Logrotate configuration created at $LOGROTATE_CONFIG"
    echo "  - Logs will rotate daily"
    echo "  - Keeps 7 days of rotated logs"
    echo "  - Compresses old logs"
    echo ""
}

# Main execution logic
if [ "$NON_INTERACTIVE" = true ]; then
    if [ -z "$INSTALL_OPTION" ]; then
        echo "Error: Non-interactive mode requires --install or --update"
        show_help
        exit 1
    fi
    
    sudoCheck
    
    case $INSTALL_OPTION in
        1) start_install ;;
        2) upgrade_install ;;
    esac
else
    # Interactive mode - show menu
    show_menu
fi

