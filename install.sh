#!/bin/bash

# Show help function - MUST be defined before argument parsing
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

    -d, --dev
        Enable development mode with verbose logging and branch selection

    --gui-mode
        Run from GUI (delays xandminer restart until end with countdown)

    --default-keypair
        Use default keypair path (/local/keypairs/pnode-keypair.json)

    --keypair-path PATH
        Specify custom keypair path

    --prpc-mode MODE
        Set pRPC mode: 'public' or 'private'

    --install
        Perform fresh installation (for non-interactive mode)

    --update
        Perform update/upgrade (for non-interactive mode)

    --xandminer-branch BRANCH
        Specify xandminer branch to install (dev mode)

    --xandminerd-branch BRANCH
        Specify xandminerd branch to install (dev mode)

    --pod-version VERSION
        Specify pod version to install (dev mode)

EXAMPLES:
    Interactive installation:
        sudo bash install.sh

    Non-interactive fresh install with defaults:
        sudo bash install.sh --non-interactive --install --default-keypair --prpc-mode private

    Dev mode update with specific branches:
        sudo bash install.sh -d --update --xandminer-branch trynet --xandminerd-branch main

    GUI mode update (safe for running from xandminer web interface):
        sudo bash install.sh --gui-mode --update --default-keypair

EOF
}

# Command-line arguments
NON_INTERACTIVE=false
USE_DEFAULT_KEYPAIR=false
KEYPAIR_PATH=""
PRPC_MODE=""
INSTALL_OPTION=""
DEV_MODE=false
GUI_MODE=false
XANDMINER_BRANCH=""
XANDMINERD_BRANCH=""
POD_VERSION=""
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



# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --non-interactive|-n)
            NON_INTERACTIVE=true
            shift
            ;;
        --dev|-d)
            DEV_MODE=true
            shift
            ;;
        --gui-mode)
            GUI_MODE=true
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
        --xandminer-branch)
            XANDMINER_BRANCH="$2"
            shift 2
            ;;
        --xandminerd-branch)
            XANDMINERD_BRANCH="$2"
            shift 2
            ;;
        --pod-version)
            POD_VERSION="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Debug logging function
log_dev() {
    if [ "$DEV_MODE" = true ]; then
        echo "[DEV] $1"
    fi
}

# Display dev mode banner
if [ "$DEV_MODE" = true ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  DEV MODE ENABLED - Verbose logging active"
    echo "═══════════════════════════════════════════════════════════"
    log_dev "Script started with flags: NON_INTERACTIVE=$NON_INTERACTIVE, GUI_MODE=$GUI_MODE, KEYPAIR_PATH=$KEYPAIR_PATH, PRPC_MODE=$PRPC_MODE"
fi

stop_service() {
    log_dev "Stopping all Xandeum services (GUI_MODE=$GUI_MODE)"
    
    if [ "$GUI_MODE" = false ]; then
        echo "Stopping xandminer web service..."
        systemctl stop xandminer.service 2>/dev/null || true
        log_dev "Stopped xandminer.service"
    else
        log_dev "GUI_MODE active - skipping xandminer service stop"
    fi
    
    echo "Stopping xandminerd system service..."
    systemctl stop xandminerd.service 2>/dev/null || true
    log_dev "Stopped xandminerd.service"
    
    echo "Stopping xandeum-pod system service..."
    systemctl stop xandeum-pod.service 2>/dev/null || true
    log_dev "Stopped xandeum-pod.service"
    
    if [ "$GUI_MODE" = false ]; then
        echo "All services stopped successfully."
    else
        echo "Backend services stopped (xandminer still running for GUI)."
    fi
}

restart_service() {
    log_dev "Restarting Xandeum services (GUI_MODE=$GUI_MODE)"
    
    if [ "$GUI_MODE" = true ]; then
        echo ""
        echo "══════════════════════════════════════════════════════════════"
        echo "  Installation Complete!"
        echo "  Xandminer web interface will restart in 30 seconds..."
        echo "══════════════════════════════════════════════════════════════"
        for i in {30..1}; do
            echo -ne "\rRestarting in $i seconds...  "
            sleep 1
        done
        echo ""
    fi
    
    echo "Starting xandminerd system service..."
    systemctl start xandminerd.service
    systemctl enable xandminerd.service
    log_dev "Started xandminerd.service"
    
    echo "Starting xandeum-pod system service..."
    systemctl start xandeum-pod.service
    systemctl enable xandeum-pod.service
    log_dev "Started xandeum-pod.service"
    
    echo "Starting xandminer web service..."
    systemctl start xandminer.service
    systemctl enable xandminer.service
    log_dev "Started xandminer.service"
    
    echo "All services restarted successfully."
}

sudoCheck() {
    log_dev "Root/sudo check"
    if [ "$(id -u)" -ne 0 ]; then
        echo 'Please run this script with sudo or as root.'
        exit 1
    fi
    log_dev "Root/sudo check passed"
}

# Function to fetch and display branches for a repository
fetch_branches() {
    local repo_name=$1
    local repo_url=$2
    local temp_dir=$(mktemp -d)
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ${repo_name^^} REPOSITORY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Fetching branches from $repo_url..."
    
    # Clone just refs (no files)
    git ls-remote --heads "$repo_url" 2>/dev/null | \
        awk '{print $2}' | \
        sed 's|refs/heads/||' | \
        grep -v '^HEAD$' | \
        head -n 10 > "$temp_dir/branches.txt"
    
    if [ ! -s "$temp_dir/branches.txt" ]; then
        echo "Warning: Could not fetch branches. Using defaults."
        echo "main" > "$temp_dir/branches.txt"
        echo "master" >> "$temp_dir/branches.txt"
    fi
    
    echo ""
    echo "Available branches:"
    local i=1
    while IFS= read -r branch; do
        echo "  $i. $branch"
        i=$((i+1))
    done < "$temp_dir/branches.txt"
    
    echo "$temp_dir/branches.txt"
    rm -rf "$temp_dir" 2>/dev/null || true
}

# Function to fetch and display pod versions
fetch_pod_versions() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  XANDEUM POD VERSIONS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Fetching available versions..."
    
    # Update apt cache for xandeum repo
    apt-get update -qq 2>/dev/null
    
    # Get available versions from apt
    apt-cache madison xandeum-pod 2>/dev/null | \
        awk '{print $3}' | \
        head -n 10 > /tmp/pod_versions.txt
    
    if [ ! -s /tmp/pod_versions.txt ]; then
        echo "Warning: Could not fetch pod versions. Using latest."
        echo "latest" > /tmp/pod_versions.txt"
    fi
    
    echo ""
    echo "Available versions:"
    echo "  1. latest (stable release)"
    local i=2
    while IFS= read -r version; do
        if [ "$version" != "latest" ]; then
            echo "  $i. $version"
            i=$((i+1))
        fi
    done < /tmp/pod_versions.txt
}

# Function to select branch from list
select_branch() {
    local repo_name=$1
    local branches_file=$2
    local default_choice=1
    
    read -p "Select $repo_name branch number [$default_choice]: " choice
    choice=${choice:-$default_choice}
    
    local selected_branch=$(sed -n "${choice}p" "$branches_file")
    
    if [ -z "$selected_branch" ]; then
        selected_branch=$(sed -n "1p" "$branches_file")
        echo "Invalid selection. Using: $selected_branch"
    else
        echo "Selected: $selected_branch"
    fi
    
    echo "$selected_branch"
}

# Function to select pod version
select_pod_version() {
    read -p "Select pod version number [1]: " choice
    choice=${choice:-1}
    
    if [ "$choice" -eq 1 ]; then
        echo "latest"
        return
    fi
    
    # Adjust for the "latest" option at position 1
    actual_line=$((choice - 1))
    local selected_version=$(sed -n "${actual_line}p" /tmp/pod_versions.txt)
    
    if [ -z "$selected_version" ]; then
        selected_version="latest"
        echo "Invalid selection. Using: latest"
    else
        echo "Selected: $selected_version"
    fi
    
    echo "$selected_version"
}

# Dev mode branch/version selection
dev_mode_selection() {
    if [ "$DEV_MODE" != true ]; then
        return
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  DEV MODE: Branch & Version Selection"
    echo "═══════════════════════════════════════════════════════════"
    
    # xandminer branch selection
    if [ -z "$XANDMINER_BRANCH" ]; then
        local xandminer_branches=$(fetch_branches "xandminer" "https://github.com/Xandeum/xandminer.git")
        XANDMINER_BRANCH=$(select_branch "xandminer" "$xandminer_branches")
    else
        echo "Using pre-specified xandminer branch: $XANDMINER_BRANCH"
    fi
    
    # xandminerd branch selection
    if [ -z "$XANDMINERD_BRANCH" ]; then
        local xandminerd_branches=$(fetch_branches "xandminerd" "https://github.com/Xandeum/xandminerd.git")
        XANDMINERD_BRANCH=$(select_branch "xandminerd" "$xandminerd_branches")
    else
        echo "Using pre-specified xandminerd branch: $XANDMINERD_BRANCH"
    fi
    
    # pod version selection
    if [ -z "$POD_VERSION" ]; then
        fetch_pod_versions
        POD_VERSION=$(select_pod_version)
    else
        echo "Using pre-specified pod version: $POD_VERSION"
    fi
    
    log_dev "Branch selection complete: xandminer=$XANDMINER_BRANCH, xandminerd=$XANDMINERD_BRANCH, pod=$POD_VERSION"
}

start_install() {
    sudoCheck
    log_dev "Starting fresh installation (GUI_MODE=$GUI_MODE)"
    
    # Dev mode branch selection if enabled
    dev_mode_selection
    
    # Set default branches if not in dev mode
    if [ "$DEV_MODE" != true ]; then
        XANDMINER_BRANCH="main"
        XANDMINERD_BRANCH="main"
        POD_VERSION="latest"
    fi
    
    handle_keypair
    handle_prpc_mode
    
    echo "Starting installation..."
    
    # Add Xandeum repository if not already added
    if ! grep -q "deb https://repo.xandeum.com/apt" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        echo "Adding Xandeum repository..."
        curl -fsSL https://repo.xandeum.com/xandeum-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/xandeum-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/xandeum-keyring.gpg] https://repo.xandeum.com/apt stable main" | tee /etc/apt/sources.list.d/xandeum.list
    fi
    
    echo "Updating package lists..."
    apt-get update
    
    # Install dependencies
    echo "Installing dependencies..."
    apt-get install -y git curl build-essential pkg-config libssl-dev npm redis-server
    
    # Install xandeum-pod
    echo "Installing xandeum-pod..."
    if [ "$POD_VERSION" = "latest" ]; then
        apt-get install -y xandeum-pod
    else
        apt-get install -y xandeum-pod=$POD_VERSION
    fi
    
    # Clone and install xandminerd
    echo "Installing xandminerd from branch: $XANDMINERD_BRANCH..."
    rm -rf /root/xandminerd
    git clone -b "$XANDMINERD_BRANCH" https://github.com/Xandeum/xandminerd.git /root/xandminerd
    cd /root/xandminerd
    
    # Install xandminerd dependencies
    npm install
    npm run build
    
    # Create xandminerd service
    cp /root/xandminerd/xandminerd.service /etc/systemd/system/
    
    # Clone and install xandminer
    echo "Installing xandminer from branch: $XANDMINER_BRANCH..."
    rm -rf /root/xandminer
    git clone -b "$XANDMINER_BRANCH" https://github.com/Xandeum/xandminer.git /root/xandminer
    cd /root/xandminer
    
    # Install xandminer dependencies
    npm install
    npm run build
    
    # Create xandminer service
    cp /root/xandminer/xandminer.service /etc/systemd/system/
    
    # Update service files with keypair path if specified
    if [ -n "$KEYPAIR_PATH" ]; then
        sed -i "s|/local/keypairs/pnode-keypair.json|$KEYPAIR_PATH|g" /etc/systemd/system/xandminerd.service
    fi
    
    # Reload systemd
    systemctl daemon-reload
    
    echo "Installation completed successfully!"
}

ensure_xandeum_pod_tmpfile() {
    log_dev "Ensuring xandeum-pod tmpfiles.d configuration"
    
    # Create tmpfiles.d config for xandeum-pod
    cat >/etc/tmpfiles.d/xandeum-pod.conf <<EOF
d /var/run/xandeum-pod 0755 root root -
EOF
    
    # Create the directory now
    systemd-tmpfiles --create /etc/tmpfiles.d/xandeum-pod.conf
    
    log_dev "xandeum-pod tmpfiles.d configuration complete"
}

harden_ssh() {
    sudoCheck
    log_dev "Starting SSH hardening"
    
    echo "Backing up SSH configuration..."
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak-$(date +%Y%m%d%H%M%S)
    
    if [ -d /etc/ssh/sshd_config.d ]; then
        cp -r /etc/ssh/sshd_config.d /etc/ssh/sshd_config.d.bak-$(date +%Y%m%d%H%M%S)
    fi
    
    # Disable password authentication
    echo "Disabling password authentication..."
    sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^#*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
    
    # Handle sshd_config.d directory
    if [ -d /etc/ssh/sshd_config.d ]; then
        cat >/etc/ssh/sshd_config.d/10-disable-password-auth.conf <<EOF
PasswordAuthentication no
ChallengeResponseAuthentication no
EOF
        chmod 644 /etc/ssh/sshd_config.d/10-disable-password-auth.conf
    fi
    
    echo "Restarting SSH service..."
    systemctl restart sshd
    
    echo "SSH hardening completed successfully!"
    log_dev "SSH hardening complete"
}

upgrade_install() {
    sudoCheck
    log_dev "Starting upgrade process (GUI_MODE=$GUI_MODE)"
    stop_service
    start_install
    ensure_xandeum_pod_tmpfile
    echo "Upgrade completed successfully!"
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
        # Interactive mode: prompt user with default
        echo ""
        echo "Keypair configuration:"
        echo "1. Use default path (/local/keypairs/pnode-keypair.json)"
        echo "2. Specify custom path"
        read -p "Enter your choice [1]: " kp_choice
        kp_choice=${kp_choice:-1}
        
        case $kp_choice in
            1)
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
        echo "No keypair specified. Using default: /local/keypairs/pnode-keypair.json"
        KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
    fi
    
    # Ensure directory exists
    mkdir -p "$(dirname "$KEYPAIR_PATH")"
    
    # Export for use in service files
    export PNODE_KEYPAIR_PATH="$KEYPAIR_PATH"
    
    log_dev "Keypair path set to: $KEYPAIR_PATH"
}

handle_prpc_mode() {
    # Handle pRPC mode configuration
    if [ -n "$PRPC_MODE" ]; then
        echo "pRPC mode set to: $PRPC_MODE"
    elif [ "$NON_INTERACTIVE" = false ]; then
        # Interactive mode: prompt user with default = private (N)
        echo ""
        echo "pRPC Configuration:"
        echo "Will you be using PUBLIC pRPC ports?"
        read -p "(y/N) [N]: " prpc_choice
        prpc_choice=${prpc_choice:-N}
        
        case $prpc_choice in
            y|Y|yes|YES)
                PRPC_MODE="public"
                ;;
            *)
                PRPC_MODE="private"
                ;;
        esac
    else
        # Non-interactive mode without pRPC specified - use private as default
        echo "No pRPC mode specified. Using default: private"
        PRPC_MODE="private"
    fi
    
    export PNODE_PRPC_MODE="$PRPC_MODE"
    log_dev "pRPC mode set to: $PRPC_MODE"
}

# Main menu function
show_menu() {
    if [ "$NON_INTERACTIVE" = true ]; then
        log_dev "Running in non-interactive mode with INSTALL_OPTION=$INSTALL_OPTION"
        
        if [ -z "$INSTALL_OPTION" ]; then
            echo "Error: --install or --update must be specified in non-interactive mode"
            exit 1
        fi
        
        case $INSTALL_OPTION in
            1)
                start_install
                ensure_xandeum_pod_tmpfile
                restart_service
                ;;
            2)
                upgrade_install
                ;;
        esac
        return
    fi
    
    log_dev "Running in interactive menu mode"
    
    while true; do
        echo "Please select an option:"
        echo "1. Install Xandeum pNode Software"
        echo "2. Update Xandeum pNode Software"
        echo "3. Stop/Restart/Disable Service"
        echo "4. Harden SSH (Disable Password Login)"
        echo "5. Exit"
        read -p "Enter your choice (1-5): " choice
        
        case $choice in
            1)
                start_install
                ensure_xandeum_pod_tmpfile
                restart_service
                break
                ;;
            2)
                upgrade_install
                break
                ;;
            3)
                echo "Service Management:"
                echo "1. Stop all services"
                echo "2. Restart all services"
                echo "3. Disable all services"
                read -p "Enter your choice (1-3): " svc_choice
                
                case $svc_choice in
                    1)
                        stop_service
                        ;;
                    2)
                        restart_service
                        ;;
                    3)
                        systemctl disable xandminer.service xandminerd.service xandeum-pod.service
                        echo "Services disabled."
                        ;;
                    *)
                        echo "Invalid choice."
                        ;;
                esac
                ;;
            4)
                harden_ssh
                break
                ;;
            5)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 5."
                ;;
        esac
    done
}

# Main execution
show_menu
