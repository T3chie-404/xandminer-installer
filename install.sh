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
  --generate-keypair       Generate a new pNode keypair after fresh install
  --prpc-mode MODE         Set pRPC mode: 'public' or 'private'
  --atlas-cluster CLUSTER  Set Atlas cluster: 'trynet', 'devnet', or 'mainnet-alpha' (default: devnet)
  --operator-revenue BPS   Set operator revenue in bps (10000 = 100%, 100 = 1%)
  --log-path PATH          Set pod log file path (default: /root/pod-logs/pod.log)
  -h, --help               Show this help message

Examples:
  # Interactive installation (default):
  sudo bash install.sh

  # Non-interactive fresh install with defaults:
  sudo bash install.sh --non-interactive --install --default-keypair --prpc-mode public --atlas-cluster devnet --operator-revenue 1000

  # Non-interactive update:
  sudo bash install.sh --non-interactive --update

  # Install with dev mode:
  sudo bash install.sh --non-interactive --install --dev --default-keypair --prpc-mode public --atlas-cluster devnet --operator-revenue 1000

  # Install with trynet:
  sudo bash install.sh --non-interactive --install --default-keypair --prpc-mode public --atlas-cluster trynet --operator-revenue 1000

  # Install with custom keypair and mainnet-alpha:
  sudo bash install.sh --non-interactive --install --keypair-path /root/my-keypair.json --prpc-mode private --atlas-cluster mainnet-alpha --operator-revenue 2000

  # Install and generate a new keypair:
  sudo bash install.sh --non-interactive --install --default-keypair --prpc-mode public --atlas-cluster devnet --operator-revenue 1000 --generate-keypair

EOF
}

# Command-line arguments
NON_INTERACTIVE=false
USE_DEFAULT_KEYPAIR=false
KEYPAIR_PATH=""
GENERATE_KEYPAIR=false
PRPC_MODE=""
ATLAS_CLUSTER=""
OPERATOR_REVENUE=""
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
        --generate-keypair)
            GENERATE_KEYPAIR=true
            shift
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
        --operator-revenue)
            OPERATOR_REVENUE="$2"
            if ! [[ "$OPERATOR_REVENUE" =~ ^[0-9]+$ ]]; then
                echo "Error: --operator-revenue must be a whole number in bps"
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
    start_install
    ensure_xandeum_pod_tmpfile
    
    # Note: setup_logrotate() is already called in start_install(), no need to call again
    
    echo "Upgrade completed successfully!"
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
        echo "1. TryNet"
        echo "2. DevNet (default)"
        echo "3. MainNet-Alpha"
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

    # Export for use in service files if needed
    export ATLAS_CLUSTER
}

handle_operator_revenue() {
    local existing_revenue=""

    if [ -f /etc/systemd/system/pod.service ]; then
        existing_revenue=$(sed -n 's/^ExecStart=.*--operator-revenue \([0-9][0-9]*\).*$/\1/p' /etc/systemd/system/pod.service | head -1)
    fi

    if [ -n "$OPERATOR_REVENUE" ]; then
        echo "Operator revenue set to: ${OPERATOR_REVENUE} bps"
    elif [ "$NON_INTERACTIVE" = false ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Operator Revenue Configuration"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Enter operator revenue in bps"
        echo "  10000 = 100%"
        echo "  100 = 1%"
        echo "  1000 = 10%"
        echo ""

        if [ -n "$existing_revenue" ]; then
            read -p "Operator revenue in bps [$existing_revenue]: " revenue_input
            OPERATOR_REVENUE="${revenue_input:-$existing_revenue}"
        else
            read -p "Operator revenue in bps: " revenue_input
            OPERATOR_REVENUE="$revenue_input"
        fi
    elif [ -n "$existing_revenue" ]; then
        echo "No operator revenue specified in non-interactive mode. Reusing existing value: ${existing_revenue} bps"
        OPERATOR_REVENUE="$existing_revenue"
    elif [ "$INSTALL_OPTION" = "1" ]; then
        echo "Error: Non-interactive fresh install requires --operator-revenue"
        exit 1
    else
        echo "Error: Could not determine operator revenue for update. Pass --operator-revenue explicitly."
        exit 1
    fi

    if ! [[ "$OPERATOR_REVENUE" =~ ^[0-9]+$ ]]; then
        echo "Error: Operator revenue must be a whole number in bps"
        exit 1
    fi

    export OPERATOR_REVENUE
}

handle_generate_keypair() {
    if [ "$INSTALL_OPTION" != "1" ]; then
        GENERATE_KEYPAIR=false
        return 0
    fi

    if [ -f "$KEYPAIR_PATH" ]; then
        echo "Existing keypair found at $KEYPAIR_PATH. New keypair generation will be skipped."
        GENERATE_KEYPAIR=false
        return 0
    fi

    if [ "$NON_INTERACTIVE" = true ]; then
        return 0
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  pNode Keypair Generation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "No keypair was found at $KEYPAIR_PATH"
    echo "You can generate a new pNode keypair after xandminerd starts."
    echo ""
    read -p "Generate a new pNode keypair after install? [y/N]: " keypair_choice
    case "$keypair_choice" in
        y|Y|yes|YES)
            GENERATE_KEYPAIR=true
            ;;
        *)
            GENERATE_KEYPAIR=false
            ;;
    esac
}

ensure_install_storage() {
    if [ ! -f /xandeum-pages ]; then
        echo "Creating /xandeum-pages (1g)..."
        fallocate /xandeum-pages -l 1g
    else
        echo "/xandeum-pages already exists. Skipping creation."
    fi

    if [ ! -e /run/xandeum-pod ]; then
        echo "Creating /run/xandeum-pod -> /xandeum-pages"
        ln -s /xandeum-pages /run/xandeum-pod
    else
        echo "/run/xandeum-pod already exists. Leaving it unchanged."
    fi
}

ensure_repo_branch() {
    local repo_dir="$1"
    local branch="$2"

    (
        cd "$repo_dir"
        git stash push -m "Auto-stash before pull" || true
        git fetch origin
        git checkout "$branch"
        git branch --set-upstream-to="origin/$branch" "$branch" >/dev/null 2>&1 || true
        git pull --ff-only origin "$branch"
    )
}

generate_install_keypair_if_requested() {
    local generated_source="/root/xandminerd/keypairs/pnode-keypair.json"

    if [ "$INSTALL_OPTION" != "1" ]; then
        return 0
    fi

    if [ "$GENERATE_KEYPAIR" != true ]; then
        return 0
    fi

    if [ -f "$KEYPAIR_PATH" ]; then
        echo "Refusing to generate a new keypair because one already exists at $KEYPAIR_PATH"
        if [ "$NON_INTERACTIVE" = true ]; then
            exit 1
        fi
        return 0
    fi

    echo "Waiting for xandminerd keypair API..."
    for _ in {1..20}; do
        if curl -fsS http://127.0.0.1:4000/keypair >/dev/null 2>&1 || curl -fsS -X POST http://127.0.0.1:4000/keypair/generate >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done

    echo "Generating new pNode keypair..."
    GENERATE_RESPONSE=$(curl -fsS -X POST http://127.0.0.1:4000/keypair/generate)
    echo "$GENERATE_RESPONSE"

    if [ ! -f "$KEYPAIR_PATH" ] && [ -f "$generated_source" ]; then
        mkdir -p "$(dirname "$KEYPAIR_PATH")"
        cp "$generated_source" "$KEYPAIR_PATH"
        chmod 600 "$KEYPAIR_PATH"
        echo "Copied generated keypair to $KEYPAIR_PATH"
    fi

    echo "Verifying generated keypair..."
    curl -fsS http://127.0.0.1:4000/keypair
    echo ""

    if [ ! -f "$KEYPAIR_PATH" ]; then
        echo "Error: Keypair generation completed, but no keypair was found at $KEYPAIR_PATH"
        exit 1
    fi
}

print_component_versions() {
    local xandminer_version
    local xandminer_codename
    local xandminerd_version=""
    local pod_version

    xandminer_version=$(sed -n 's/^export const VERSION_NO = "\([^"]*\)";$/\1/p' /root/xandminer/src/CONSTS.ts 2>/dev/null | head -1)
    xandminer_codename=$(sed -n 's/^export const VERSION_NAME = "\([^"]*\)";$/\1/p' /root/xandminer/src/CONSTS.ts 2>/dev/null | head -1)

    if command -v jq >/dev/null 2>&1; then
        xandminerd_version=$(curl -fsS http://127.0.0.1:4000/versions 2>/dev/null | jq -r '.data.xandminerd // empty' | head -1)
    elif command -v python3 >/dev/null 2>&1; then
        xandminerd_version=$(curl -fsS http://127.0.0.1:4000/versions 2>/dev/null | python3 -c 'import json,sys; data=json.load(sys.stdin); print(data.get("data", {}).get("xandminerd",""))' 2>/dev/null | head -1)
    fi

    pod_version=$(pod --version 2>/dev/null | sed -n 's/^pod \(.*\)$/v\1/p' | head -1)

    printf '\n'
    printf 'xandminer: %s%s\nxandminerd: %s\npod: %s\n' \
      "${xandminer_version:-N/A}" \
      "${xandminer_codename:+ ($xandminer_codename)}" \
      "${xandminerd_version:-N/A}" \
      "${pod_version:-N/A}"
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
        echo "Default: /root/pod-logs/pod.log"
        echo "Type 'none' to disable file logging"
        echo ""
        read -p "Log path [/root/pod-logs/pod.log] (press Enter for default): " log_input
        if [ -z "$log_input" ]; then
            POD_LOG_PATH="/root/pod-logs/pod.log"
        elif [ "$log_input" = "none" ] || [ "$log_input" = "NONE" ]; then
            POD_LOG_PATH=""
        else
            POD_LOG_PATH="$log_input"
        fi
    else
        # Non-interactive mode without path specified - use default
        echo "No pod log path specified in non-interactive mode. Using default: /root/pod-logs/pod.log"
        POD_LOG_PATH="/root/pod-logs/pod.log"
    fi

    # Ensure directory exists (create parent directory for the log file)
    if [ -n "$POD_LOG_PATH" ]; then
        mkdir -p "$(dirname "$POD_LOG_PATH")"
    fi
    
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
    git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)|%(committerdate:short)|%(contents:subject)' --count=10 > /tmp/branches.txt
    
    # Display branches with numbers
    local counter=1
    declare -a BRANCH_ARRAY
    
    while IFS='|' read -r branch date message; do
        BRANCH_ARRAY[$counter]="$branch"
        printf "%2d. %-30s %s  %s\n" "$counter" "$branch" "$date" "$message" >&2
        ((counter++))
    done < /tmp/branches.txt
    
    echo "" >&2
    
    # Clean up temp directory
    cd /
    rm -rf "$TEMP_DIR"
    rm -f /tmp/branches.txt
    
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
            # Treat as custom branch name
            echo "Using custom branch: $BRANCH_CHOICE" >&2
            echo "$BRANCH_CHOICE"
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
    apt-get update --allow-releaseinfo-change -y >/dev/null 2>&1
    
    echo "Fetching available trynet versions..." >&2
    echo "" >&2
    
    # Get trynet versions and format them
    apt-cache madison pod 2>/dev/null | grep trynet | head -10 | awk '{print $3}' > /tmp/pod_versions_$$.txt
    
    if [ ! -s /tmp/pod_versions_$$.txt ]; then
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
    done < /tmp/pod_versions_$$.txt
    
    echo "" >&2
    
    # Clean up
    rm -f /tmp/pod_versions_$$.txt
    
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
            # Treat as custom version string
            echo "Using custom version: $VERSION_CHOICE" >&2
            echo "$VERSION_CHOICE"
            return 0
        else
            echo "Invalid selection. Please try again." >&2
        fi
    done
}

start_install() {
    sudoCheck
    
    # Handle configuration options
    handle_keypair
    handle_prpc_mode
    handle_atlas_cluster
    handle_operator_revenue
    handle_pod_log_path
    handle_generate_keypair
    
    # Change to installation directory
    cd /root
    
    # Update system packages
    echo "Updating system packages..."
    apt-get update --allow-releaseinfo-change -y
    apt-get upgrade -y
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
        
        # Select branch for xandminerd
        XANDMINERD_BRANCH=$(select_branch "xandminerd" "https://github.com/Xandeum/xandminerd.git")
        
        # Select pod trynet version
        POD_VERSION=$(select_pod_version)
        
        echo ""
        echo "Selected branches:"
        echo "  xandminer: $XANDMINER_BRANCH"
        echo "  xandminerd: $XANDMINERD_BRANCH"
        echo "  pod: $POD_VERSION"
        echo ""
    elif [ "$DEV_MODE" = true ] && [ "$NON_INTERACTIVE" = true ]; then
        # Non-interactive dev mode - use defaults
        echo "Dev mode enabled in non-interactive mode - using default branches"
        XANDMINER_BRANCH="main"
        XANDMINERD_BRANCH="main"
        POD_VERSION="stable"
    fi

    if [ -d "xandminer" ] && [ -d "xandminerd" ]; then
        echo "Repositories already exist. Updating..."

        (
            cd xandminer
            if [ "$DEV_MODE" = true ] && [ -n "$XANDMINER_BRANCH" ]; then
                git fetch origin
                git checkout "$XANDMINER_BRANCH"
                git pull --ff-only origin "$XANDMINER_BRANCH"
            else
                ensure_repo_branch /root/xandminer main
            fi
        )

        (
            cd xandminerd
            if [ "$DEV_MODE" = true ] && [ -n "$XANDMINERD_BRANCH" ]; then
                git fetch origin
                git checkout "$XANDMINERD_BRANCH"
                git pull --ff-only origin "$XANDMINERD_BRANCH"
            else
                ensure_repo_branch /root/xandminerd main
            fi

            if [ -f "keypairs/pnode-keypair.json" ]; then
                echo "Found pnode-keypair.json. Copying to $KEYPAIR_PATH if not already present..."

                mkdir -p "$(dirname "$KEYPAIR_PATH")"

                if [ ! -f "$KEYPAIR_PATH" ]; then
                    cp keypairs/pnode-keypair.json "$KEYPAIR_PATH"
                    echo "Copied pnode-keypair.json to $KEYPAIR_PATH"
                else
                    echo "pnode-keypair.json already exists at $KEYPAIR_PATH. Skipping copy."
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
        else
            ensure_repo_branch /root/xandminer main
            ensure_repo_branch /root/xandminerd main
        fi
    fi

    if [ "$INSTALL_OPTION" = "1" ]; then
        ensure_install_storage
    fi

    install_pod
    echo "Downloading application files..."
    wget -O xandminerd.service "https://raw.githubusercontent.com/Xandeum/xandminer-installer/refs/heads/master/xandminerd.service"
    wget -O xandminer.service "https://raw.githubusercontent.com/Xandeum/xandminer-installer/refs/heads/master/xandminer.service"

    # Update service files with configuration
    echo "Configuring services with keypair path: $KEYPAIR_PATH and pRPC mode: $PRPC_MODE"
    
    # Add environment variables to service files
    sed -i "/Environment=NODE_ENV=production/a Environment=PNODE_KEYPAIR_PATH=$KEYPAIR_PATH" xandminerd.service
    sed -i "/Environment=NODE_ENV=production/a Environment=PRPC_MODE=$PRPC_MODE" xandminerd.service

    echo "Setting up Xandminer web as a system service..."
    cp /root/xandminer.service /etc/systemd/system/

    # Build and run xandminer app
    echo "Building and running xandminer app..."
    cd xandminer
    npm install
    npm run build
    cd ..

    systemctl daemon-reload
    systemctl enable xandminer.service

    echo "Xandminer web service configured (will start at end)"

    cp /root/xandminerd.service /etc/systemd/system/

    # Set up Xandminer as a service
    echo "Setting up Xandminerd as a system service..."
    cd /root/xandminerd
    npm install
    systemctl daemon-reload
    systemctl enable xandminerd.service

    echo "Xandminerd service configured (will start at end)"

    cd ..

    rm xandminer.service xandminerd.service

    echo "To access your Xandminer, use address localhost:3000 in your web browser"
    echo "Configuration:"
    echo "  - Keypair path: $KEYPAIR_PATH"
    echo "  - pRPC mode: $PRPC_MODE"
    echo "  - Atlas cluster: $ATLAS_CLUSTER"
    echo "  - Operator revenue: ${OPERATOR_REVENUE} bps"
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
    generate_install_keypair_if_requested
    check_services_health
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

    sudo apt-get update --allow-releaseinfo-change -y

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
    fi

    # POD_LOG_PATH is set by handle_pod_log_path.
    # If empty, file logging is intentionally disabled.

    local rpc_ip="127.0.0.1"
    local cluster_flag=""

    if [ "$PRPC_MODE" = "public" ]; then
        rpc_ip="0.0.0.0"
    fi

    case "$ATLAS_CLUSTER" in
        mainnet-alpha)
            cluster_flag="--mainnet-alpha"
            ;;
        trynet)
            cluster_flag="--trynet"
            ;;
        devnet|*)
            cluster_flag="--devnet"
            ;;
    esac

    echo "Configuring pod service with cluster: $ATLAS_CLUSTER"
    EXEC_START_CMD="/usr/bin/pod ${cluster_flag} --rpc-ip ${rpc_ip}"
    if [ -n "$POD_LOG_PATH" ]; then
        EXEC_START_CMD="${EXEC_START_CMD} --log ${POD_LOG_PATH}"
        echo "Pod logs will be written to: $POD_LOG_PATH"
    else
        echo "Pod file logging disabled."
    fi
    EXEC_START_CMD="${EXEC_START_CMD} --operator-revenue ${OPERATOR_REVENUE}"

    sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description= Xandeum Pod System service
After=network.target

[Service]
ExecStart=${EXEC_START_CMD}
Restart=always
RestartSec=2
User=root
Environment=NODE_ENV=production
Environment=LOG_LEVEL=info
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

check_services_health() {
    echo ""
    echo "Verifying services..."
    
    local failed=0
    
    # Check each service
    for service in xandminer xandminerd pod; do
        if systemctl is-active --quiet ${service}.service; then
            echo "  ✓ ${service}.service is running"
        else
            echo "  ✗ ${service}.service FAILED"
            ((failed++))
        fi
    done
    
    if [ $failed -eq 0 ]; then
        echo ""
        echo "✓ All services started successfully"
        print_component_versions
    else
        echo ""
        echo "⚠️  WARNING: $failed service(s) failed to start"
        echo "Check logs with: sudo journalctl -u SERVICE_NAME -n 50"
    fi
    echo ""
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
    create 0644 root root
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
