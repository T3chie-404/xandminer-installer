#!/bin/bash

# Parse command-line arguments
DEV_MODE=false
DEBUG_MODE=false
UNATTENDED_MODE=false
INSTALL_ACTION=""
KEYPAIR_PATH_ARG=""
PRPC_PUBLIC_ARG=""

show_help() {
    cat <<EOF
╔════════════════════════════════════════════════════════════════════════════╗
║                     XANDEUM pNODE INSTALLER                                ║
║                  Interactive & Unattended Installation                     ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE:
    sudo bash $0 [OPTIONS]

OPTIONS:
    -h, --help
        Display this help message and exit

    -d, --dev
        Enable development mode with branch/version selection
        Allows you to select specific branches for xandminer and xandminerd,
        and specific trynet versions for pod

    --debug
        Enable debug output with 10s delays (shows detailed git operations)

    -u, --unattended
        Run in unattended mode (no interactive prompts)
        Must be combined with installation action (--install or --update)

    --install
        Perform fresh installation (use with --unattended)

    --update
        Perform update/upgrade (use with --unattended)

    --keypair-path PATH
        Specify custom keypair path
        If not specified in unattended mode: uses /local/keypairs/pnode-keypair.json

    --prpc-public
        Configure pRPC API for public access (0.0.0.0)
        Default in unattended mode: private (127.0.0.1)

    --prpc-private
        Configure pRPC API for private access (127.0.0.1)
        This is the default if not specified

EXAMPLES:
    Interactive installation (default):
        sudo bash $0

    Interactive with dev mode:
        sudo bash $0 -d

    Interactive with debug output:
        sudo bash $0 --debug

    Unattended fresh install with defaults:
        sudo bash $0 --unattended --install

    Unattended update with custom keypair and public pRPC:
        sudo bash $0 -u --update --keypair-path /root/my-keypair.json --prpc-public

    Dev mode unattended update:
        sudo bash $0 -d -u --update --prpc-private

    Debug mode with dev branches:
        sudo bash $0 -d --debug

NOTES:
    - Unattended mode uses defaults: private pRPC, standard keypair path
    - After installation, services restart with a 30-second countdown (unattended)
      or "press enter to restart" prompt (interactive)
    - Dev mode allows selection of specific branches and trynet versions
    - Debug mode adds detailed output and 10-second pauses after git operations

EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -d|--dev)
            DEV_MODE=true
            shift
            ;;
        --debug)
            DEBUG_MODE=true
            shift
            ;;
        -u|--unattended)
            UNATTENDED_MODE=true
            shift
            ;;
        --install)
            INSTALL_ACTION="install"
            shift
            ;;
        --update)
            INSTALL_ACTION="update"
            shift
            ;;
        --keypair-path)
            KEYPAIR_PATH_ARG="$2"
            shift 2
            ;;
        --prpc-public)
            PRPC_PUBLIC_ARG="yes"
            shift
            ;;
        --prpc-private)
            PRPC_PUBLIC_ARG="no"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Validate unattended mode requirements
if [ "$UNATTENDED_MODE" = true ]; then
    if [ -z "$INSTALL_ACTION" ]; then
        echo "Error: --unattended requires either --install or --update"
        exit 1
    fi
fi

# Set installation directory based on mode
if [ "$DEV_MODE" = true ]; then
    INSTALL_DIR="/root"
    echo ""
else
    INSTALL_DIR="/root"
fi

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

show_menu() {
    echo "Please select an option:"
    echo "1. Install Xandeum pNode Software"
    echo "2. Update Xandeum pNode Software"
    echo "3. Stop/Restart/Disable Service"
    echo "4. Upgrade This Installer Script"
    echo "5. Harden SSH (Disable Password Login)"
    echo "6. Exit"
    read -p "Enter your choice (1-6):" choice
    case $choice in
    1) start_install ;;
    2) upgrade_install ;;
    3) actions ;;
    4) upgrade_installer_script ;;
    5) harden_ssh ;;
    6)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option. Please try again."
        show_menu
        ;;
    esac
}

# Handle unattended mode
handle_unattended_mode() {
    if [ "$UNATTENDED_MODE" = true ]; then
        case "$INSTALL_ACTION" in
            install)
                start_install
                ;;
            update)
                upgrade_install
                ;;
        esac
        exit 0
    fi
}

sudoCheck() {
    # Check for root/sudo privileges
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root or with sudo. Please try again with sudo."
        exit 1
    fi
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
            echo "$BRANCH_CHOICE" >&2
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

upgrade_installer_script() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Upgrading Installer Script"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    SCRIPT_URL="https://raw.githubusercontent.com/Xandeum/xandminer-installer/master/install.sh"
    SCRIPT_PATH="$0"
    BACKUP_PATH="${SCRIPT_PATH}.bak-$(date +%Y%m%d%H%M%S)"
    TEMP_SCRIPT="/tmp/install.sh.tmp"
    
    echo "Downloading latest version from GitHub..."
    if wget -q -O "$TEMP_SCRIPT" "$SCRIPT_URL"; then
        echo "✓ Download successful"
        
        # Check if the downloaded file is valid
        if [ -s "$TEMP_SCRIPT" ]; then
            echo "Creating backup at: $BACKUP_PATH"
            cp "$SCRIPT_PATH" "$BACKUP_PATH"
            
            echo "Replacing current script with new version..."
            mv "$TEMP_SCRIPT" "$SCRIPT_PATH"
            chmod +x "$SCRIPT_PATH"
            
            echo ""
            echo "✓ Installer script upgraded successfully!"
            echo "✓ Backup saved at: $BACKUP_PATH"
            echo ""
            echo "Restarting script with new version..."
            echo ""
            sleep 2
            exec "$SCRIPT_PATH"
        else
            echo "✗ Downloaded file is empty or invalid"
            rm -f "$TEMP_SCRIPT"
            echo "Upgrade failed. Returning to menu..."
            sleep 2
            show_menu
        fi
    else
        echo "✗ Failed to download the script from GitHub"
        echo "Please check your internet connection and try again."
        rm -f "$TEMP_SCRIPT"
        sleep 2
        show_menu
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
    echo "Setup completed successfully!"
}

upgrade_install() {
    sudoCheck
    start_install
    # Note: show_completion_and_restart is called within start_install
}

start_install() {
    sudoCheck
    
    # Initialize version tracking variables
    INSTALLED_XANDMINER_BRANCH=""
    INSTALLED_XANDMINERD_BRANCH=""
    INSTALLED_POD_VERSION=""
    
    # Change to installation directory
    cd "$INSTALL_DIR"
    
    # Update system packages
    echo "Updating system packages..."
    apt update && apt upgrade -y
    apt install -y build-essential python3 make gcc g++ liblzma-dev

    # Install Node.js
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs

    # Handle dev mode branch selection
    if [ "$DEV_MODE" = true ]; then
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
    fi

    if [ -d "xandminer" ] && [ -d "xandminerd" ]; then
        echo "Repositories already exist. Updating..."
        [ "$DEBUG_MODE" = true ] && echo "DEBUG: DEV_MODE = $DEV_MODE"

        # Update xandminer
        cd xandminer
        if [ "$DEBUG_MODE" = true ]; then
            echo "DEBUG: Updating xandminer..."
            echo "DEBUG: Current branch before update: $(git branch --show-current)"
        fi
        git stash push -m "Auto-stash before pull" || true
            if [ "$DEV_MODE" = true ]; then
                [ "$DEBUG_MODE" = true ] && echo "DEBUG: In DEV_MODE - using branch $XANDMINER_BRANCH"
                git fetch origin
                git checkout "$XANDMINER_BRANCH"
                git pull origin "$XANDMINER_BRANCH"
                if [ "$DEBUG_MODE" = true ]; then
                    echo "DEBUG: Pausing for 10 seconds..."
                    sleep 10
                fi
            else
                [ "$DEBUG_MODE" = true ] && echo "DEBUG: In STANDARD MODE - pulling default branch"
                git fetch origin
                DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD --short | sed 's@^origin/@@')
                [ "$DEBUG_MODE" = true ] && echo "DEBUG: Default branch is: $DEFAULT_BRANCH"
                git checkout "$DEFAULT_BRANCH"
                git pull
                if [ "$DEBUG_MODE" = true ]; then
                    echo "DEBUG: Pausing for 10 seconds..."
                    sleep 10
                fi
            fi
            INSTALLED_XANDMINER_BRANCH=$(git branch --show-current)
            [ "$DEBUG_MODE" = true ] && echo "DEBUG: Current branch after update: $INSTALLED_XANDMINER_BRANCH"
        cd ..

        # Update xandminerd
        cd xandminerd
        if [ "$DEBUG_MODE" = true ]; then
            echo "DEBUG: Updating xandminerd..."
            echo "DEBUG: Current branch before update: $(git branch --show-current)"
        fi
        git stash push -m "Auto-stash before pull" || true
            if [ "$DEV_MODE" = true ]; then
                [ "$DEBUG_MODE" = true ] && echo "DEBUG: In DEV_MODE - using branch $XANDMINERD_BRANCH"
                git fetch origin
                git checkout "$XANDMINERD_BRANCH"
                git pull origin "$XANDMINERD_BRANCH"
                if [ "$DEBUG_MODE" = true ]; then
                    echo "DEBUG: Pausing for 10 seconds..."
                    sleep 10
                fi
            else
                [ "$DEBUG_MODE" = true ] && echo "DEBUG: In STANDARD MODE - pulling default branch"
                git fetch origin
                DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD --short | sed 's@^origin/@@')
                [ "$DEBUG_MODE" = true ] && echo "DEBUG: Default branch is: $DEFAULT_BRANCH"
                git checkout "$DEFAULT_BRANCH"
                git pull
                if [ "$DEBUG_MODE" = true ]; then
                    echo "DEBUG: Pausing for 10 seconds..."
                    sleep 10
                fi
            fi
            INSTALLED_XANDMINERD_BRANCH=$(git branch --show-current)
            [ "$DEBUG_MODE" = true ] && echo "DEBUG: Current branch after update: $INSTALLED_XANDMINERD_BRANCH"

        if [ -f "keypairs/pnode-keypair.json" ]; then
            echo "Found pnode-keypair.json. Copying to /local/keypairs/ if not already present..."

            mkdir -p /local/keypairs

            if [ ! -f "/local/keypairs/pnode-keypair.json" ]; then
                cp keypairs/pnode-keypair.json /local/keypairs/
                echo "Copied pnode-keypair.json to /local/keypairs/"
            else
                echo "pnode-keypair.json already exists in /local/keypairs/. Skipping copy."
            fi
        fi
        cd ..
    else
        if [ "$DEBUG_MODE" = true ]; then
            echo "DEBUG: Repositories don't exist (or one is missing). Initial clone..."
            echo "DEBUG: xandminer exists: [ -d 'xandminer' ] = $([ -d 'xandminer' ] && echo 'YES' || echo 'NO')"
            echo "DEBUG: xandminerd exists: [ -d 'xandminerd' ] = $([ -d 'xandminerd' ] && echo 'YES' || echo 'NO')"
        fi
        
        echo "Cloning repositories..."
        git clone https://github.com/Xandeum/xandminer.git
        git clone https://github.com/Xandeum/xandminerd.git
        
        if [ "$DEV_MODE" = true ]; then
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
        
        # Track installed branches for new clones
        INSTALLED_XANDMINER_BRANCH=$(cd xandminer && git branch --show-current)
        INSTALLED_XANDMINERD_BRANCH=$(cd xandminerd && git branch --show-current)
    fi

    install_pod
    echo "Downloading application files..."
    wget -O xandminerd.service "https://raw.githubusercontent.com/Xandeum/xandminer-installer/refs/heads/master/xandminerd.service"
    wget -O xandminer.service "https://raw.githubusercontent.com/Xandeum/xandminer-installer/refs/heads/master/xandminer.service"

    echo "Setting up Xandminer web as a system service..."
    
    
    cp xandminer.service /etc/systemd/system/

    # Build and run xandminer app
    echo "Building and running xandminer app..."
    cd xandminer
    npm install
    npm run build
    cd ..

    systemctl daemon-reload
    systemctl enable xandminer.service

    echo "Xandminer web configured for Port : 3000"

    cp xandminerd.service /etc/systemd/system/

    # Set up Xandminer as a service
    echo "Setting up Xandminerd as a system service..."
    cd xandminerd
    npm install
    systemctl daemon-reload
    systemctl enable xandminerd.service

    echo "Xandminerd configured for Port : 4000"

    cd ..

    rm xandminer.service xandminerd.service

    ensure_xandeum_pod_tmpfile
    
    show_completion_and_restart "install"
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

    echo "deb [trusted=yes] https://xandeum.github.io/pod-apt-package/ stable main" | sudo tee /etc/apt/sources.list.d/xandeum-pod.list

    sudo apt-get update

    # Install pod (version depends on installation mode)
    if [ "$DEV_MODE" = true ] && [ -n "$POD_VERSION" ] && [ "$POD_VERSION" != "stable" ]; then
        echo "Installing trynet pod version: $POD_VERSION"
        echo "⚠️  Note: This may downgrade from a newer stable version"
        sudo apt-get install -y --allow-downgrades pod=$POD_VERSION
        INSTALLED_POD_VERSION="$POD_VERSION"
    else
        echo "Installing latest stable pod version"
        sudo apt-get install -y pod
        INSTALLED_POD_VERSION=$(dpkg -s pod | grep '^Version:' | awk '{print $2}')
    fi

    # Keypair configuration
    if [ "$UNATTENDED_MODE" = true ]; then
        # Use argument or default
        if [ -n "$KEYPAIR_PATH_ARG" ]; then
            KEYPAIR_PATH="$KEYPAIR_PATH_ARG"
            echo "Using keypair path from argument: $KEYPAIR_PATH"
        else
            KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
            echo "Using default keypair path: $KEYPAIR_PATH"
        fi
    else
        # Interactive mode - ask for keypair path
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Keypair Configuration"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Enter the path to your pNode keypair file."
        echo ""
        echo "  • Press Enter to use default: /local/keypairs/pnode-keypair.json"
        echo "  • Enter a custom path if your keypair is elsewhere"
        echo "  • Type 'none' to skip keypair configuration (pod will run without --keypair flag)"
        echo ""
        read -p "Keypair path [/local/keypairs/pnode-keypair.json]: " KEYPAIR_PATH
        
        # Handle the three cases
        if [ -z "$KEYPAIR_PATH" ]; then
            KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
        elif [ "$KEYPAIR_PATH" = "none" ] || [ "$KEYPAIR_PATH" = "NONE" ]; then
            KEYPAIR_PATH=""
        fi
    fi

    # pRPC configuration
    if [ "$UNATTENDED_MODE" = true ]; then
        # Use argument or default to private
        if [ "$PRPC_PUBLIC_ARG" = "yes" ]; then
            MAKE_PUBLIC="y"
            echo "Configuring pRPC API for public access (from argument)"
        else
            MAKE_PUBLIC="n"
            echo "Configuring pRPC API for private access (default)"
        fi
    else
        # Interactive mode - ask for public/private configuration
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "pRPC API Access Configuration"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Would you like to make the pRPC API publicly accessible?"
        echo ""
        echo "  Private (default): --rpc-ip 127.0.0.1 (localhost only)"
        echo "  Public:            --rpc-ip 0.0.0.0 (accessible from any network interface)"
        echo ""
        echo "⚠️  WARNING: Public access exposes your pRPC API to the network."
        echo "    Only use this if you understand the security implications."
        echo ""
        read -p "Make pRPC API public? (y/N): " MAKE_PUBLIC
    fi

    # Construct ExecStart command based on user input
    EXEC_START_CMD="/usr/bin/pod"
    
    # Add keypair if provided
    if [ -n "$KEYPAIR_PATH" ]; then
        # Validate the path exists
        if [ -f "$KEYPAIR_PATH" ]; then
            echo "Using keypair at: $KEYPAIR_PATH"
            EXEC_START_CMD="$EXEC_START_CMD --keypair $KEYPAIR_PATH"
        else
            echo "WARNING: File not found at $KEYPAIR_PATH"
            read -p "File doesn't exist. Continue anyway? (y/n): " CONTINUE
            if [[ "$CONTINUE" =~ ^[Yy]$ ]]; then
                echo "Proceeding with the provided path anyway..."
                EXEC_START_CMD="$EXEC_START_CMD --keypair $KEYPAIR_PATH"
            else
                echo "Skipping keypair configuration."
            fi
        fi
    else
        echo "No keypair path provided."
    fi
    
    # Add RPC IP configuration
    if [[ "$MAKE_PUBLIC" =~ ^[Yy]$ ]]; then
        echo "✓ Configuring pod with PUBLIC pRPC API (--rpc-ip 0.0.0.0)"
        echo "⚠️  Make sure port 6000 is accessible through your firewall"
        EXEC_START_CMD="$EXEC_START_CMD --rpc-ip 0.0.0.0"
    else
        echo "✓ Configuring pod with PRIVATE pRPC API (--rpc-ip 127.0.0.1)"
        EXEC_START_CMD="$EXEC_START_CMD --rpc-ip 127.0.0.1"
    fi

    SERVICE_FILE="/etc/systemd/system/pod.service"

    sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description= Xandeum Pod System service
After=network.target

[Service]
ExecStart=$EXEC_START_CMD
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

    echo "Reloading systemd..."
    sudo systemctl daemon-reload

    echo " Enabling pod.service..."
    sudo systemctl enable pod.service

    echo "Starting pod.service..."
    sudo systemctl start pod.service

    echo " pod.service is now running. Check status with:"
    echo " sudo systemctl status pod.service"
    
    if [[ "$MAKE_PUBLIC" =~ ^[Yy]$ ]]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "⚠️  SECURITY REMINDER"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Your pRPC API is now publicly accessible on port 6000"
        echo "Ensure your firewall is properly configured:"
        echo "  sudo ufw allow 6000/tcp"
        echo "  sudo ufw allow 9001/tcp  # For gossip protocol"
        echo ""
    fi

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

show_completion_and_restart() {
    local ACTION=$1  # "install" or "update"
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    INSTALLATION COMPLETED SUCCESSFULLY                     ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Installed Versions"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ -n "$INSTALLED_XANDMINER_BRANCH" ]; then
        echo "  xandminer:  $INSTALLED_XANDMINER_BRANCH"
    fi
    if [ -n "$INSTALLED_XANDMINERD_BRANCH" ]; then
        echo "  xandminerd: $INSTALLED_XANDMINERD_BRANCH"
    fi
    if [ -n "$INSTALLED_POD_VERSION" ]; then
        echo "  pod:        $INSTALLED_POD_VERSION"
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Services to be Started/Restarted"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  • xandminer.service  (Port 3000)"
    echo "  • xandminerd.service (Port 4000)"
    echo "  • pod.service        (Xandeum pNode)"
    echo ""
    
    if [ "$UNATTENDED_MODE" = true ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Services will restart in 30 seconds..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        for i in {30..1}; do
            printf "\r  Restarting in %2d seconds... " "$i"
            sleep 1
        done
        echo ""
        echo ""
    else
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        read -p "  Press Enter to restart services and complete installation... " 
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    fi
    
    # Now restart services
    echo "Restarting services..."
    systemctl daemon-reload
    systemctl restart pod.service
    systemctl restart xandminerd.service
    systemctl restart xandminer.service
    
    echo ""
    echo "✓ All services restarted successfully!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Access Information"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Web Interface: http://localhost:3000"
    echo "  API Endpoint:  http://localhost:4000"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
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

# Main execution
handle_unattended_mode
show_menu

