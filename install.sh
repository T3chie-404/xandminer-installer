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
          public  - pRPC accessible publicly (DEFAULT)
          private - pRPC restricted access
        If not specified, will prompt in interactive mode or default to 'public'
        
    -d, --dev-mode
        Enable development mode with:
        - Branch selection for xandminer and xandminerd repos
        - View 10 most recent branches for each repo
        - Pod version selection with numbered list
        - Verbose debugging output
        Useful for testing and development

    --gui-mode
        GUI-safe update mode for running from xandminer web interface
        - Keeps xandminer service running during update
        - 30-second countdown before final restart
        - All services restart together at the end
        Use this when updating from the web GUI to avoid disconnection

INTERACTIVE MODE:
    If no flags are provided, the installer runs in interactive menu mode where
    you can select options via a text-based menu.

EXAMPLES:
    1. Interactive installation (default behavior):
       $ sudo bash install.sh

    2. Non-interactive fresh install with defaults:
       $ sudo bash install.sh --non-interactive --install --default-keypair --prpc-mode public

    3. Update from GUI (keeps GUI running until complete):
       $ sudo bash install.sh -n --update --gui-mode

    4. Dev mode interactive (select branches and versions):
       $ sudo bash install.sh -d

    5. Show this help message:
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

SUPPORT:
    GitHub: https://github.com/T3chie-404/xandminer-installer
    Discord: https://discord.gg/xandeum

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
POD_PACKAGE_VERSION=""

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
        --gui-mode)
            GUI_MODE=true
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

fetch_and_show_branches() {
    local repo_name=$1
    local repo_url=$2
    local temp_dir="/tmp/${repo_name}_branches_$$"
    
    echo ""
    echo "Fetching recent branches for $repo_name..."
    
    # Clone the repo (shallow to save bandwidth)
    git clone --depth 50 "$repo_url" "$temp_dir" &>/dev/null
    
    if [ $? -eq 0 ]; then
        cd "$temp_dir"
        echo ""
        echo "───────────────────────────────────────────────────────────"
        echo "  Available Branches for $repo_name:"
        echo "───────────────────────────────────────────────────────────"
        
        # Get all remote branches, sorted by commit date, most recent first
        local branches=()
        local count=1
        
        while IFS= read -r branch; do
            # Remove 'origin/' prefix
            branch_clean=$(echo "$branch" | sed 's/origin\///')
            branches+=("$branch_clean")
            
            # Get the last commit info for this branch
            commit_msg=$(git log -1 --format="%h - %s" "origin/$branch_clean" 2>/dev/null | cut -c1-70)
            printf "  %2d. %-20s %s\n" "$count" "$branch_clean" "$commit_msg"
            ((count++))
        done < <(git for-each-ref --sort=-committerdate refs/remotes/origin --format='%(refname:short)' | grep -v 'HEAD' | head -10 | sed 's/origin\///')
        
        echo "───────────────────────────────────────────────────────────"
        
        cd - &>/dev/null
        rm -rf "$temp_dir"
        
        # Return the branches array by echoing each element
        for branch in "${branches[@]}"; do
            echo "$branch"
        done
    else
        echo "  [Warning] Could not fetch branches for $repo_name"
        return 1
    fi
}

show_pod_versions() {
    echo ""
    echo "Fetching available pod versions..."
    echo ""
    echo "───────────────────────────────────────────────────────────"
    echo "  Available Pod Versions:"
    echo "───────────────────────────────────────────────────────────"
    
    # Add both stable and trynet repos temporarily
    echo "deb [trusted=yes] https://xandeum.github.io/pod-apt-package/ stable main" | sudo tee /etc/apt/sources.list.d/xandeum-pod-stable.list >/dev/null 2>&1
    echo "deb [trusted=yes] https://xandeum.github.io/pod-apt-package/ trynet main" | sudo tee /etc/apt/sources.list.d/xandeum-pod-trynet.list >/dev/null 2>&1
    sudo apt-get update >/dev/null 2>&1
    
    # Get versions and display
    local versions=()
    local count=1
    
    # Show stable first
    echo "  STABLE (Production):"
    local stable_version=$(apt-cache policy pod 2>/dev/null | grep "Candidate" | awk '{print $2}')
    if [ -n "$stable_version" ]; then
        versions+=("stable:$stable_version")
        printf "    %2d. %s\n" "$count" "$stable_version"
        ((count++))
    fi
    
    echo ""
    echo "  TRYNET (Development):"
    # Get trynet versions
    while IFS= read -r line; do
        version=$(echo "$line" | awk '{print $3}')
        if [ -n "$version" ]; then
            versions+=("trynet:$version")
            printf "    %2d. %s\n" "$count" "$version"
            ((count++))
        fi
    done < <(apt-cache madison pod 2>/dev/null | grep trynet | head -9)
    
    echo "───────────────────────────────────────────────────────────"
    
    # Return the versions
    for version in "${versions[@]}"; do
        echo "$version"
    done
}

select_dev_branches() {
    if [ "$DEV_MODE" = true ] && [ "$NON_INTERACTIVE" = false ]; then
        echo ""
        echo "═══════════════════════════════════════════════════════════"
        echo "  DEV MODE: Branch & Version Selection"
        echo "═══════════════════════════════════════════════════════════"
        
        # Fetch and show xandminer branches
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  XANDMINER REPOSITORY"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        mapfile -t xandminer_branches < <(fetch_and_show_branches "xandminer" "https://github.com/Xandeum/xandminer.git")
        
        # Select xandminer branch
        echo ""
        read -p "Select xandminer branch number [1]: " xm_choice
        xm_choice=${xm_choice:-1}
        
        if [[ "$xm_choice" =~ ^[0-9]+$ ]] && [ "$xm_choice" -ge 1 ] && [ "$xm_choice" -le "${#xandminer_branches[@]}" ]; then
            XANDMINER_BRANCH="${xandminer_branches[$((xm_choice-1))]}"
            echo "✓ Selected: $XANDMINER_BRANCH"
        else
            XANDMINER_BRANCH="${xandminer_branches[0]}"
            echo "✓ Using default: $XANDMINER_BRANCH"
        fi
        log_dev "Selected xandminer branch: $XANDMINER_BRANCH"
        
        # Fetch and show xandminerd branches
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  XANDMINERD REPOSITORY"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        mapfile -t xandminerd_branches < <(fetch_and_show_branches "xandminerd" "https://github.com/Xandeum/xandminerd.git")
        
        # Select xandminerd branch
        echo ""
        read -p "Select xandminerd branch number [1]: " xmd_choice
        xmd_choice=${xmd_choice:-1}
        
        if [[ "$xmd_choice" =~ ^[0-9]+$ ]] && [ "$xmd_choice" -ge 1 ] && [ "$xmd_choice" -le "${#xandminerd_branches[@]}" ]; then
            XANDMINERD_BRANCH="${xandminerd_branches[$((xmd_choice-1))]}"
            echo "✓ Selected: $XANDMINERD_BRANCH"
        else
            XANDMINERD_BRANCH="${xandminerd_branches[0]}"
            echo "✓ Using default: $XANDMINERD_BRANCH"
        fi
        log_dev "Selected xandminerd branch: $XANDMINERD_BRANCH"
        
        # Show pod versions
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  POD PACKAGE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        mapfile -t pod_versions < <(show_pod_versions)
        
        # Select pod version
        echo ""
        read -p "Select pod version number [1]: " pod_choice
        pod_choice=${pod_choice:-1}
        
        if [[ "$pod_choice" =~ ^[0-9]+$ ]] && [ "$pod_choice" -ge 1 ] && [ "$pod_choice" -le "${#pod_versions[@]}" ]; then
            selected_pod="${pod_versions[$((pod_choice-1))]}"
            POD_VERSION=$(echo "$selected_pod" | cut -d: -f1)
            POD_PACKAGE_VERSION=$(echo "$selected_pod" | cut -d: -f2)
            echo "✓ Selected: $POD_PACKAGE_VERSION ($POD_VERSION)"
        else
            POD_VERSION="stable"
            POD_PACKAGE_VERSION=""
            echo "✓ Using default: stable (latest)"
        fi
        log_dev "Selected pod version: $POD_VERSION $POD_PACKAGE_VERSION"
        
        echo "═══════════════════════════════════════════════════════════"
    else
        # Non-interactive or dev mode off - use defaults
        XANDMINER_BRANCH="main"
        XANDMINERD_BRANCH="main"
        POD_VERSION="stable"
        POD_PACKAGE_VERSION=""
        log_dev "Using default branches: main/stable"
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
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root or with sudo. Please try again with sudo."
        exit 1
    fi
    log_dev "Root/sudo check passed"
}

harden_ssh() {
    sudoCheck
    log_dev "Starting SSH hardening"
    
    echo "Backing up SSH configuration files..."
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak-$(date +%Y%m%d%H%M%S)
    if [ -d /etc/ssh/sshd_config.d ]; then
        cp -r /etc/ssh/sshd_config.d /etc/ssh/sshd_config.d.bak-$(date +%Y%m%d%H%M%S)
    fi

    echo "Disabling password authentication in /etc/ssh/sshd_config..."
    sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^#*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config

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
    log_dev "Starting upgrade process (GUI_MODE=$GUI_MODE)"
    
    if [ "$GUI_MODE" = true ]; then
        echo "═══════════════════════════════════════════════════════════"
        echo "  GUI MODE: Keeping xandminer running during update"
        echo "═══════════════════════════════════════════════════════════"
        log_dev "GUI mode enabled - will not stop xandminer service"
        
        echo "Stopping xandminerd and pod services..."
        systemctl stop xandminerd.service
        systemctl stop pod.service 2>/dev/null || true
        log_dev "Stopped xandminerd and pod (xandminer still running)"
    else
        stop_service
    fi
    
    start_install
    ensure_xandeum_pod_tmpfile
    echo "Upgrade completed successfully!"
    
    if [ "$GUI_MODE" = true ]; then
        gui_restart_countdown
    else
        restart_service
        echo "Service restart completed."
    fi
}

gui_restart_countdown() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  UPDATE COMPLETE!"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "All services will restart in 30 seconds..."
    echo "You will be disconnected from the web interface briefly."
    echo ""
    echo "Press Ctrl+C to cancel the restart (not recommended)"
    echo ""
    
    log_dev "Starting 30-second countdown before restart"
    
    for i in {30..1}; do
        printf "\rRestarting in %2d seconds..." $i
        sleep 1
    done
    
    echo ""
    echo ""
    echo "Restarting all services now..."
    log_dev "Countdown complete, restarting all services"
    
    systemctl daemon-reload
    systemctl restart pod.service
    systemctl restart xandminerd.service  
    systemctl restart xandminer.service
    
    log_dev "All services restarted successfully"
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  All services restarted successfully!"
    echo "  Please refresh your browser to reconnect."
    echo "═══════════════════════════════════════════════════════════"
}

handle_keypair() {
    log_dev "Handling keypair configuration"
    
    if [ "$USE_DEFAULT_KEYPAIR" = true ]; then
        echo "Using default keypair path: /local/keypairs/pnode-keypair.json"
        KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
        log_dev "Default keypair path selected"
    elif [ -n "$KEYPAIR_PATH" ]; then
        echo "Using specified keypair path: $KEYPAIR_PATH"
        log_dev "Custom keypair path: $KEYPAIR_PATH"
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
        echo ""
        echo "Keypair Configuration:"
        read -p "Enter keypair path [/local/keypairs/pnode-keypair.json]: " input_path
        if [ -z "$input_path" ]; then
            KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
            echo "Using default: $KEYPAIR_PATH"
        else
            KEYPAIR_PATH="$input_path"
        fi
        log_dev "User selected keypair: $KEYPAIR_PATH"
    else
        echo "No keypair specified in non-interactive mode. Using default: /local/keypairs/pnode-keypair.json"
        KEYPAIR_PATH="/local/keypairs/pnode-keypair.json"
        log_dev "Defaulting to standard keypair path in non-interactive mode"
    fi

    mkdir -p "$(dirname "$KEYPAIR_PATH")"
    log_dev "Ensured keypair directory exists: $(dirname "$KEYPAIR_PATH")"
    
    export PNODE_KEYPAIR_PATH="$KEYPAIR_PATH"
}

handle_prpc_mode() {
    log_dev "Handling pRPC mode configuration"
    
    if [ -n "$PRPC_MODE" ]; then
        echo "pRPC mode set to: $PRPC_MODE"
        log_dev "pRPC mode: $PRPC_MODE"
    elif [ "$NON_INTERACTIVE" = false ]; then
        echo ""
        echo "pRPC Configuration:"
        echo "1. Public pRPC (default)"
        echo "2. Private pRPC"
        read -p "Enter choice [1]: " prpc_choice
        prpc_choice=${prpc_choice:-1}
        case $prpc_choice in
            2)
                PRPC_MODE="private"
                log_dev "User selected private pRPC"
                ;;
            *)
                PRPC_MODE="public"
                log_dev "User selected public pRPC (or default)"
                ;;
        esac
    else
        echo "No pRPC mode specified in non-interactive mode. Using default: public"
        PRPC_MODE="public"
        log_dev "Defaulting to public pRPC in non-interactive mode"
    fi

    export PRPC_MODE
}

start_install() {
    sudoCheck
    log_dev "Starting fresh installation (GUI_MODE=$GUI_MODE)"
    
    select_dev_branches
    
    handle_keypair
    handle_prpc_mode
    
    echo "Updating system packages..."
    log_dev "Running apt update && upgrade"
    apt update && apt upgrade -y
    apt install -y build-essential python3 make gcc g++ liblzma-dev

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
            git checkout $XANDMINER_BRANCH
            git pull
            log_dev "Updated xandminer repository (branch: $XANDMINER_BRANCH)"
        )

        (
            cd xandminerd
            git stash push -m "Auto-stash before pull" || true
            git checkout $XANDMINERD_BRANCH
            git pull
            log_dev "Updated xandminerd repository (branch: $XANDMINERD_BRANCH)"

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
        git clone -b $XANDMINER_BRANCH https://github.com/Xandeum/xandminer.git
        git clone -b $XANDMINERD_BRANCH https://github.com/Xandeum/xandminerd.git
        log_dev "Cloned repos with branches: xandminer=$XANDMINER_BRANCH, xandminerd=$XANDMINERD_BRANCH"
    fi

    install_pod
    echo "Downloading application files..."
    log_dev "Downloading service files from GitHub"
    wget -O xandminerd.service "https://raw.githubusercontent.com/Xandeum/xandminer-installer/refs/heads/master/xandminerd.service"
    wget -O xandminer.service "https://raw.githubusercontent.com/Xandeum/xandminer-installer/refs/heads/master/xandminer.service"

    echo "Configuring services with keypair path: $KEYPAIR_PATH and pRPC mode: $PRPC_MODE"
    log_dev "Adding environment variables to service files"
    
    sed -i "/Environment=NODE_ENV=production/a Environment=PNODE_KEYPAIR_PATH=$KEYPAIR_PATH" xandminerd.service
    sed -i "/Environment=NODE_ENV=production/a Environment=PRPC_MODE=$PRPC_MODE" xandminerd.service

    if [ "$GUI_MODE" = false ]; then
        echo "Setting up Xandminer web as a system service..."
        cp /root/xandminer.service /etc/systemd/system/
        log_dev "Copied xandminer.service to systemd"
    else
        log_dev "GUI mode - skipping xandminer service copy (will update at end)"
    fi

    echo "Building xandminer app..."
    cd xandminer
    log_dev "Installing npm packages for xandminer"
    npm install
    log_dev "Building xandminer"
    npm run build
    cd ..

    if [ "$GUI_MODE" = false ]; then
        systemctl daemon-reload
        systemctl enable xandminer.service --now
        log_dev "Enabled and started xandminer.service"
        echo "Xandminer web Service Running On Port : 3000"
    else
        cp /root/xandminer.service /etc/systemd/system/
        systemctl daemon-reload
        log_dev "Updated xandminer service file (will restart after countdown)"
        echo "Xandminer service updated (restart pending)"
    fi

    cp /root/xandminerd.service /etc/systemd/system/
    log_dev "Copied xandminerd.service to systemd"

    echo "Setting up Xandminerd as a system service..."
    cd /root/xandminerd
    log_dev "Installing npm packages for xandminerd"
    npm install
    
    if [ "$GUI_MODE" = false ]; then
        systemctl daemon-reload
        systemctl enable xandminerd.service --now
        log_dev "Enabled and started xandminerd.service"
        echo "Xandminerd Service Running On Port : 4000"
    else
        systemctl daemon-reload
        systemctl enable xandminerd.service
        log_dev "Enabled xandminerd service (will start after countdown)"
        echo "Xandminerd service enabled (start pending)"
    fi

    cd ..

    rm xandminer.service xandminerd.service
    log_dev "Cleaned up temporary service files"

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    if [ "$GUI_MODE" = false ]; then
        echo "To access your Xandminer, use address localhost:3000 in your web browser"
    fi
    echo "Configuration:"
    echo "  - Keypair path: $KEYPAIR_PATH"
    echo "  - pRPC mode: $PRPC_MODE"
    if [ "$DEV_MODE" = true ]; then
        echo "  - Xandminer branch: $XANDMINER_BRANCH"
        echo "  - Xandminerd branch: $XANDMINERD_BRANCH"
        echo "  - Pod version: $POD_VERSION $POD_PACKAGE_VERSION"
    fi
    if [ "$GUI_MODE" = true ]; then
        echo "  - GUI Mode: Active (delayed restart enabled)"
    fi
    echo "═══════════════════════════════════════════════════════════"

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

    ensure_xandeum_pod_tmpfile

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
    log_dev "Installing pod package (version: $POD_VERSION)"
    sudo apt-get install -y apt-transport-https ca-certificates

    echo "deb [trusted=yes] https://xandeum.github.io/pod-apt-package/ $POD_VERSION main" | sudo tee /etc/apt/sources.list.d/xandeum-pod.list
    log_dev "Added Xandeum pod repository ($POD_VERSION) to sources"

    sudo apt-get update

    if [ -n "$POD_PACKAGE_VERSION" ]; then
        sudo apt-get install -y pod=$POD_PACKAGE_VERSION
        log_dev "Installed pod package version $POD_PACKAGE_VERSION"
    else
        sudo apt-get install -y pod
        log_dev "Installed pod package (latest from $POD_VERSION)"
    fi

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

    if [ "$GUI_MODE" = false ]; then
        echo "Starting pod.service..."
        sudo systemctl start pod.service
        log_dev "Enabled and started pod.service"
        echo "pod.service is now running. Check status with:"
        echo "sudo systemctl status pod.service"
    else
        log_dev "Enabled pod service (will start after countdown)"
        echo "pod.service enabled (start pending)"
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

    systemd-tmpfiles --create
    log_dev "Ran systemd-tmpfiles --create"
}

# Main execution logic
if [ "$DEV_MODE" = true ]; then
    echo "═══════════════════════════════════════════════════════════"
    echo "  DEV MODE ENABLED - Verbose logging active"
    echo "═══════════════════════════════════════════════════════════"
    log_dev "Script started with flags: NON_INTERACTIVE=$NON_INTERACTIVE, GUI_MODE=$GUI_MODE, KEYPAIR_PATH=$KEYPAIR_PATH, PRPC_MODE=$PRPC_MODE"
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
    log_dev "Running in interactive menu mode"
    show_menu
fi
