#!/bin/bash

LOGFILE="$HOME/whatbox_app_manager.log"
CACHE_DIR="$HOME/.cache/whatbox-app-manager"
BIN_CACHE="$CACHE_DIR/binaries"
CONFIG_CACHE="$CACHE_DIR/configs"

set -uo pipefail

# --------- APPS & CONFIG ---------
declare -A APPS=(
    [Sonarr]=NzbDrone
    [Radarr]=Radarr
    [Lidarr]=Lidarr
    [Prowlarr]=Prowlarr
    [Jellyfin]=jellyfin
    [qBittorrent]=qbittorrent-nox
    [Autobrr]=autobrr
    [FlexGet]=flexget
    [SABnzbd]=SABnzbd.py
    [SickChill]=SickChill.py
    [Medusa]=Medusa.py
    [Headphones]=Headphones.py
    [Mylar]=Mylar.py
    [Bazarr]=Bazarr
    [Jackett]=Jackett
)
declare -A APP_PORTS=(
    [Sonarr]=8989
    [Radarr]=7878
    [Lidarr]=8686
    [Prowlarr]=9696
    [Jellyfin]=8096
    [qBittorrent]=8080
    [Autobrr]=7474
    [FlexGet]=0
    [SABnzbd]=8085
    [SickChill]=8081
    [Medusa]=8083
    [Headphones]=8181
    [Mylar]=8090
    [Bazarr]=6767
    [Jackett]=9117
)
declare -A APP_PATHS=(
    [Sonarr]=$HOME/bin/NzbDrone
    [Radarr]=$HOME/bin/Radarr
    [Lidarr]=$HOME/bin/Lidarr
    [Prowlarr]=$HOME/bin/Prowlarr
    [Jellyfin]=$HOME/jellyfin/jellyfin/bin/jellyfin
    [qBittorrent]=$HOME/bin/qbittorrent-nox
    [Autobrr]=$HOME/apps/autobrr/autobrr
    [FlexGet]=$HOME/apps/flexget/.venv/bin/flexget
    [SABnzbd]=$HOME/apps/sabnzbd/run.sh
    [SickChill]=$HOME/apps/sickchill/run.sh
    [Medusa]=$HOME/apps/medusa/run.sh
    [Headphones]=$HOME/apps/headphones/run.sh
    [Mylar]=$HOME/apps/mylar/run.sh
    [Bazarr]=$HOME/apps/bazarr/run.sh
    [Jackett]=$HOME/apps/jackett/Jackett
)
# Start command templates referencing official Whatbox wiki recommendations
# {binary} placeholder replaced at runtime, {config} for config dir
declare -A APP_START_CMDS=(
    [Sonarr]='screen -dmS sonarr "{binary}" --nobrowser'
    [Radarr]='screen -dmS radarr "{binary}" --nobrowser'
    [Lidarr]='screen -dmS lidarr "{binary}" --nobrowser'
    [Prowlarr]='screen -dmS prowlarr "{binary}"'
    [Jellyfin]='screen -dmS jellyfin "{binary}"'
    [qBittorrent]='screen -dmS qbittorrent "{binary}" --profile="{config}"'
    [Autobrr]='screen -dmS autobrr "{binary}" --config="{config}/config.toml"'
    [FlexGet]='screen -dmS flexget "{binary}" daemon start --config "{config}/config.yml"'
    [SABnzbd]='screen -dmS sabnzbd "{binary}" --config-file "{config}/sabnzbd.ini"'
    [SickChill]='screen -dmS sickchill "{binary}" --nolaunch --datadir "{config}"'
    [Medusa]='screen -dmS medusa "{binary}" --nolaunch --datadir "{config}"'
    [Headphones]='screen -dmS headphones "{binary}" --datadir "{config}"'
    [Mylar]='screen -dmS mylar "{binary}" --datadir "{config}"'
    [Bazarr]='screen -dmS bazarr "{binary}" --config "{config}"'
    [Jackett]='screen -dmS jackett "{binary}" --NoUpdates --DataFolder "{config}"'
)
# Official, non-404 links as of Nov 2025
declare -A APP_URLS=(
    [Sonarr]="https://services.sonarr.tv/v1/download/main/latest?version=3&os=linux&arch=x64"
    [Radarr]="https://github.com/Radarr/Radarr/releases/latest/download/Radarr.master.linux-core-x64.tar.gz"  
    [Lidarr]="https://github.com/Lidarr/Lidarr/releases/download/v3.1.0.4875/Lidarr.master.3.1.0.4875.linux-core-x64.tar.gz"
    [Prowlarr]="https://github.com/Prowlarr/Prowlarr/releases/latest/download/Prowlarr.develop.linux-core-x64.tar.gz"
    [Jellyfin]="https://repo.jellyfin.org/releases/server/linux/portable/latest-jellyfin-linux-amd64.tar.gz"  
    [qBittorrent]="https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/qbittorrent-nox-linux-glibc-amd64"
    [Autobrr]="https://github.com/autobrr/autobrr/releases/latest/download/autobrr-linux-amd64.tar.gz"        
    [SABnzbd]="https://github.com/sabnzbd/sabnzbd/releases/latest/download/SABnzbd-latest-src.tar.gz"
    [SickChill]="https://github.com/SickChill/SickChill/archive/refs/heads/master.tar.gz"
    [Medusa]="https://github.com/pymedusa/Medusa/archive/refs/heads/master.tar.gz"
    [Headphones]="https://github.com/rembo10/headphones/archive/refs/heads/master.tar.gz"
    [Mylar]="https://github.com/evilhero/mylar3/archive/refs/heads/master.tar.gz"
    [Bazarr]="https://github.com/morpheus65535/bazarr/releases/latest/download/bazarr.zip"
    [Jackett]="https://github.com/Jackett/Jackett/releases/latest/download/Jackett.Binaries.LinuxAMDx64.tar.gz"
    [FlexGet]="https://pypi.org/project/FlexGet/"
)

# --------- UTILS ---------
log() { echo "[$(date '+%F %T')] $*" | tee -a "$LOGFILE"; }
err() { echo "[$(date '+%F %T')] ERROR: $*" | tee -a "$LOGFILE"; }

APP_ROOT="$HOME/apps"
PYTHON_BIN="${PYTHON_BIN_OVERRIDE:-$(command -v python3 || command -v python || echo python3)}"

app_install_dir() {
    local app="$1"
    echo "$APP_ROOT/${app,,}"
}

ensure_app_dir() {
    local dir
    dir=$(app_install_dir "$1")
    mkdir -p "$dir"
    echo "$dir"
}

create_python_runner() {
    local app="$1"
    local dir="$2"
    local entry="$3"
    local target="$dir/run.sh"
    cat >"$target"<<EOF
#!/bin/bash
set -euo pipefail
cd "$dir"
exec "$PYTHON_BIN" "$dir/$entry" "\$@"
EOF
    chmod +x "$target"
    update_binary_cache "$app" "$target"
}

ensure_config_dir_for() {
    local app="$1"
    local dir="$HOME/.config/${app,,}"
    mkdir -p "$dir"
    echo "$dir"
}

ensure_cache_dirs() {
    mkdir -p "$CACHE_DIR" "$BIN_CACHE" "$CONFIG_CACHE" "$APP_ROOT"
}

cache_file_for() { local app="$1"; echo "$BIN_CACHE/${app}.path"; }
config_cache_file_for() { local app="$1"; echo "$CONFIG_CACHE/${app}.cfg"; }

write_cache_value() {
    local file="$1"; shift
    local value="$*"
    [[ -z "$value" ]] && return
    printf "%s" "$value" > "$file"
}

read_cache_value() {
    local file="$1"
    [[ -f "$file" ]] && cat "$file" || echo ""
}

exists() {
    local app="$1"
    local resolved=$(resolve_app_binary "$app")
    [[ -n "$resolved" && -x "$resolved" ]] && return 0
    [[ -f "${APP_PATHS[$app]}" ]] && return 0
    return 1
}

# Efficiently call ps aux once for process detection and capture binary paths
PS_CACHE=""
get_ps_cache() {
    PS_CACHE=$(ps aux 2>/dev/null || echo "")
}

detect_binary_from_cmd() {
    local cmd="$1"
    [[ -z "$cmd" ]] && return
    local binary=$(echo "$cmd" | awk '{print $1}')
    if [[ "$binary" =~ ^/ && -x "$binary" ]]; then
        echo "$binary"
    elif command -v "$binary" >/dev/null 2>&1; then
        command -v "$binary"
    else
        echo ""
    fi
}

update_binary_cache() {
    local app="$1" path="$2"
    [[ -z "$path" ]] && return
    write_cache_value "$(cache_file_for "$app")" "$path"
}

resolve_app_binary() {
    local app="$1"
    [[ -z "$PS_CACHE" ]] && get_ps_cache
    local cached=$(read_cache_value "$(cache_file_for "$app")")
    if [[ -n "$cached" && -x "$cached" ]]; then
        echo "$cached"
        return
    fi
    local default="${APP_PATHS[$app]}"
    [[ -n "$default" && -x "$default" ]] && echo "$default" && return
    local found_lines=()
    find_process_lines "$app" found_lines
    if [[ ${#found_lines[@]} -gt 0 ]]; then
        local cmd=$(echo "${found_lines[0]}" | awk '{for(i=11;i<=NF;++i) printf $i" "; print ""}' | sed 's/[[:space:]]*$//')
        local detected=$(detect_binary_from_cmd "$cmd")
        [[ -n "$detected" ]] && echo "$detected" && return
    fi
    [[ -n "$default" ]] && echo "$default"
}

find_process_lines() {
    local app="$1"
    local pattern="${APPS[$app]}"
    # Also try matching the app name itself (case-insensitive)
    local alt_pattern="${app,,}"  # lowercase app name
    local -n _result=$2
    _result=()
    [[ -z "$PS_CACHE" ]] && get_ps_cache
    if [[ -n "$PS_CACHE" ]]; then
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            _result+=("$line")
            local cmd=$(echo "$line" | awk '{for(i=11;i<=NF;++i) printf $i" "; print ""}' | sed 's/[[:space:]]*$//')
            local detected=$(detect_binary_from_cmd "$cmd")
            [[ -n "$detected" ]] && update_binary_cache "$app" "$detected"
        done < <(echo "$PS_CACHE" | grep -iE "($pattern|$alt_pattern)" | grep -v "grep" | grep -v "whatbox-init")
    fi
}

extract_pid_cmd() {
    local ps_line="$1"
    [[ -z "$ps_line" ]] && return
    local pid cmdpath
    pid=$(echo "$ps_line" | awk '{print $2}')
    cmdpath=$(echo "$ps_line" | awk '{for(i=11;i<=NF;++i) printf $i" "; print ""}' | sed 's/[[:space:]]*$//') 
    [[ -n "$pid" ]] && echo "PID:$pid CMD:$cmdpath"
}

# Extract actual binary path from process command
extract_binary_path() {
    local ps_line="$1"
    [[ -z "$ps_line" ]] && return
    local cmdpath
    cmdpath=$(echo "$ps_line" | awk '{for(i=11;i<=NF;++i) printf $i" "; print ""}' | sed 's/[[:space:]]*$//') 
    # Extract the first word (the binary path)
    local binary=$(echo "$cmdpath" | awk '{print $1}')
    # If it's an absolute path, return it; otherwise try to find it
    if [[ "$binary" =~ ^/ ]]; then
        echo "$binary"
    elif command -v "$binary" >/dev/null 2>&1; then
        command -v "$binary"
    else
        echo ""
    fi
}

# Find actual port from process (check lsof or process args)
get_process_port() {
    local pid="$1"
    local app="$2"
    local expected_port=${APP_PORTS[$app]}

    # Try lsof first
    if command -v lsof >/dev/null 2>&1; then
        local port=$(lsof -Pan -p "$pid" -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {print $9}' | sed 's/.*://' | head -1)
        [[ -n "$port" ]] && echo "$port" && return
    fi

    # Try ss/netstat
    if command -v ss >/dev/null 2>&1; then
        local port=$(ss -lnptu 2>/dev/null | grep "pid=$pid" | head -1 | grep -oP ':\K[0-9]+' | head -1)      
        [[ -n "$port" ]] && echo "$port" && return
    fi

    # Fallback to expected port
    echo "$expected_port"
}

# Find config directory for app
find_config_dir() {
    local app="$1"
    local found_lines=()
    find_process_lines "$app" found_lines

    # Try to find from process args first (most accurate)
    for line in "${found_lines[@]}"; do
        local cmd=$(echo "$line" | awk '{for(i=11;i<=NF;++i) printf $i" "; print ""}')
        # Look for --data-dir, --config, -c, etc in command
        if echo "$cmd" | grep -qE "(--data-dir|--config|-c|--config-dir|--data)"; then
            local config=$(echo "$cmd" | grep -oE "(--data-dir|--config|-c|--config-dir|--data)\s+[^\s]+" | awk '{print $2}' | head -1)
            [[ -n "$config" && -d "$config" ]] && echo "$config" && return
        fi
    done

    # App-specific common config locations
    case "$app" in
        Sonarr)
            [[ -d "$HOME/.config/NzbDrone" ]] && echo "$HOME/.config/NzbDrone" && return
            [[ -d "$HOME/.config/Sonarr" ]] && echo "$HOME/.config/Sonarr" && return
            ;;
        Radarr)
            [[ -d "$HOME/.config/Radarr" ]] && echo "$HOME/.config/Radarr" && return
            ;;
        Lidarr)
            [[ -d "$HOME/.config/Lidarr" ]] && echo "$HOME/.config/Lidarr" && return
            ;;
        Prowlarr)
            [[ -d "$HOME/.config/Prowlarr" ]] && echo "$HOME/.config/Prowlarr" && return
            ;;
        Jellyfin)
            [[ -d "$HOME/.config/jellyfin" ]] && echo "$HOME/.config/jellyfin" && return
            [[ -d "$HOME/jellyfin" ]] && echo "$HOME/jellyfin" && return
            ;;
        qBittorrent)
            [[ -d "$HOME/.config/qBittorrent" ]] && echo "$HOME/.config/qBittorrent" && return
            ;;
    esac

    # Generic fallback locations
    local config_dirs=(
        "$HOME/.config/${app,,}"
        "$HOME/.config/${APPS[$app]}"
        "$HOME/${app,,}"
        "$HOME/.${app,,}"
    )

    for dir in "${config_dirs[@]}"; do
        [[ -d "$dir" ]] && echo "$dir" && return
    done

    echo ""
}

port_open() {
    local port="$1"
    [[ -z "$port" ]] && return 1
    # Check with space after colon for exact match
    ss -lnptu 2>/dev/null | grep -qE ":$port[[:space:]]" && return 0 || return 1
}

# Get actual listening port for app
get_actual_port() {
    local app="$1"
    local found_lines=()
    find_process_lines "$app" found_lines

    if [[ ${#found_lines[@]} -gt 0 ]]; then
        local pid=$(echo "${found_lines[0]}" | awk '{print $2}')
        local detected_port=$(get_process_port "$pid" "$app")
        echo "$detected_port"
    else
        echo "${APP_PORTS[$app]}"
    fi
}

running_status() {
    local app="$1"
    local found_lines=()
    find_process_lines "$app" found_lines
    local po=
    local actual_port=$(get_actual_port "$app")
    port_open "$actual_port" && po=1
    [[ ${#found_lines[@]} -gt 0 || $po ]] && echo "🟢 Running" || echo "⛔ Not Running"
}

detailed_status() {
    local app="$1"
    local found_lines=()
    local portstat=""
    find_process_lines "$app" found_lines
    [[ ${#found_lines[@]} -gt 0 ]] && portstat+="proc "
    local actual_port=$(get_actual_port "$app")
    port_open "$actual_port" && portstat+="port"
    portstat="${portstat:-none}"
    echo "$portstat"
}

get_app_status_line() {
    local app=$1
    local found_lines=()
    find_process_lines "$app" found_lines

    # Detect actual installation path
    local pathdisplay="${APP_PATHS[$app]}"
    if [[ ${#found_lines[@]} -gt 0 ]]; then
        local actual_path=$(extract_binary_path "${found_lines[0]}")
        [[ -n "$actual_path" && -f "$actual_path" ]] && pathdisplay="$actual_path"
    fi
    [[ -f "$pathdisplay" ]] || pathdisplay="(not found)"

    # Truncate long paths for display
    if [[ ${#pathdisplay} -gt 33 ]]; then
        pathdisplay="...${pathdisplay: -30}"
    fi

    # Check if installed (either expected path or actual path exists)
    local inst="❌ Not Installed"
    if [[ -f "$pathdisplay" ]] || exists "$app" || [[ ${#found_lines[@]} -gt 0 ]]; then
        inst="✅ Installed"
    fi

    # Get actual port
    local port=$(get_actual_port "$app")
    local portstat
    port_open "$port" && portstat="open" || portstat="closed"

    # Running status
    local rstat=$(running_status "$app")

    # Process info
    local procinfo=""
    for line in "${found_lines[@]}"; do
        local pid=$(echo "$line" | awk '{print $2}')
        [[ -n "$pid" ]] && procinfo+="PID:$pid "
    done
    [[ -z "$procinfo" ]] && procinfo="(no process)"

    # Truncate process info
    if [[ ${#procinfo} -gt 23 ]]; then
        procinfo="${procinfo:0:20}..."
    fi

    # Config directory
    local config_dir=$(find_config_dir "$app")
    local config_display=""
    [[ -n "$config_dir" ]] && config_display="$(basename "$config_dir")"

    # Format: App | Installed | Running | Port | PortSt | Path | Process | Config
    printf "%-12s|%-9s|%-13s|%-6s|%-7s|%-35s|%-25s|%s" \
        "$app" "$inst" "$rstat" "$port" "$portstat" "$pathdisplay" "$procinfo" "$config_display"
}

fzf_app_select() {
    # Ensure PS cache is fresh
    get_ps_cache
    # List status lines, allow multi-select, retain column order for lookup
    {
        for app in $(printf '%s\n' "${!APPS[@]}" | sort); do
            local line=$(get_app_status_line "$app")
            [[ -n "$line" ]] && echo "$line"
        done
        echo "QUIT        | -         | -           | -     | -      | -                            | -                         | Quit"
    } | \
    fzf --multi \
        --header="Select one or more applications (Tab to select, Enter to confirm):" \
        --prompt="App(s): " \
        --no-sort \
        --delimiter='|' \
        --height=90% \
        --layout=reverse-list \
        --border
}

fzf_action_select() {
    printf "%s\n" "status" "start" "stop" "restart" "install" "reinstall" "Back to Main Screen" | \
        fzf --prompt="Choose an action: "
}

show_status_table() {
    get_ps_cache
    echo
    printf "%-12s|%-9s|%-13s|%-6s|%-7s|%-35s|%-25s|%s\n" \
      "App" "Installed" "Running" "Port" "PortSt" "Path" "Process" "Config"
    echo "--------------------------------------------------------------------------------------------------------------------------------------------"
    for app in $(printf '%s\n' "${!APPS[@]}" | sort); do
        get_app_status_line "$app"
        echo
    done
    echo
}

# -------- INSTALLERS --------
install_Sonarr() {
    cd "$HOME"
    wget -qO Sonarr.tar.gz "${APP_URLS[Sonarr]}"
    tar -xzf Sonarr.tar.gz
    mkdir -p bin
    mv Sonarr/* bin/
    rm -rf Sonarr Sonarr.tar.gz
    chmod +x bin/NzbDrone
    update_binary_cache "Sonarr" "$HOME/bin/NzbDrone"
    log "Sonarr installed at ~/bin/NzbDrone"
}
install_Radarr() {
    cd "$HOME"
    wget -qO Radarr.tar.gz "${APP_URLS[Radarr]}"
    tar -xzf Radarr.tar.gz
    mkdir -p bin
    mv Radarr/* bin/
    rm -rf Radarr Radarr.tar.gz
    chmod +x bin/Radarr
    update_binary_cache "Radarr" "$HOME/bin/Radarr"
    log "Radarr installed at ~/bin/Radarr"
}
install_Lidarr() {
    cd "$HOME"
    wget -qO Lidarr.tar.gz "${APP_URLS[Lidarr]}"
    tar -xzf Lidarr.tar.gz
    mkdir -p bin
    mv Lidarr/* bin/
    rm -rf Lidarr Lidarr.tar.gz
    chmod +x bin/Lidarr
    update_binary_cache "Lidarr" "$HOME/bin/Lidarr"
    log "Lidarr installed at ~/bin/Lidarr"
}
install_Prowlarr() {
    cd "$HOME"
    wget -qO Prowlarr.tar.gz "${APP_URLS[Prowlarr]}"
    tar -xzf Prowlarr.tar.gz
    mkdir -p bin
    mv Prowlarr/* bin/
    rm -rf Prowlarr Prowlarr.tar.gz
    chmod +x bin/Prowlarr
    update_binary_cache "Prowlarr" "$HOME/bin/Prowlarr"
    log "Prowlarr installed at ~/bin/Prowlarr"
}
install_Jellyfin() {
    cd "$HOME"
    mkdir -p jellyfin
    wget -qO jellyfin.tar.gz "${APP_URLS[Jellyfin]}"
    tar -xzf jellyfin.tar.gz -C jellyfin
    rm jellyfin.tar.gz
    log "Jellyfin extracted to ~/jellyfin"
    update_binary_cache "Jellyfin" "$HOME/jellyfin/jellyfin/bin/jellyfin"
}
install_qBittorrent() {
    cd "$HOME"
    mkdir -p bin
    wget -qO qbittorrent-nox "${APP_URLS[qBittorrent]}"
    chmod +x qbittorrent-nox
    mv qbittorrent-nox bin/
    mkdir -p "$HOME/.config/qBittorrent"
    update_binary_cache "qBittorrent" "$HOME/bin/qbittorrent-nox"
    log "qBittorrent-nox placed at ~/bin/qbittorrent-nox"
}

install_Autobrr() {
    local dir
    dir=$(ensure_app_dir "Autobrr")
    local tmp
    tmp=$(mktemp -d)
    wget -qO "$tmp/autobrr.tar.gz" "${APP_URLS[Autobrr]}"
    tar -xzf "$tmp/autobrr.tar.gz" -C "$tmp"
    local bin_candidate
    bin_candidate=$(find "$tmp" -type f -name autobrr -perm -u+x | head -1)
    if [[ -z "$bin_candidate" ]]; then
        err "Autobrr binary not found in archive"
        rm -rf "$tmp"
        return 1
    fi
    mkdir -p "$dir"
    mv "$bin_candidate" "$dir/autobrr"
    chmod +x "$dir/autobrr"
    update_binary_cache "Autobrr" "$dir/autobrr"
    rm -rf "$tmp"
    ensure_config_dir_for "Autobrr"
    log "Autobrr installed to $dir"
}

install_FlexGet() {
    local dir
    dir=$(ensure_app_dir "FlexGet")
    python3 -m venv "$dir/.venv"
    "$dir/.venv/bin/pip" install --upgrade pip wheel flexget
    update_binary_cache "FlexGet" "$dir/.venv/bin/flexget"
    local cfg
    cfg=$(ensure_config_dir_for "FlexGet")
    [[ ! -f "$cfg/config.yml" ]] && cat >"$cfg/config.yml"<<'EOF'
tasks:
  example:
    rss: https://example.com/rss
    accept_all: yes
EOF
    log "FlexGet installed with virtualenv at $dir/.venv"
}

install_SABnzbd() {
    local dir
    dir=$(ensure_app_dir "SABnzbd")
    python3 -m venv "$dir/.venv"
    "$dir/.venv/bin/pip" install --upgrade pip wheel sabnzbd
    cat >"$dir/run.sh"<<EOF
#!/bin/bash
set -euo pipefail
CONFIG_DIR="${HOME}/.config/sabnzbd"
mkdir -p "\$CONFIG_DIR"
exec "$dir/.venv/bin/python3" -m sabnzbd --config-file "\$CONFIG_DIR/sabnzbd.ini" --server 0.0.0.0:8085 "\$@" 
EOF
    chmod +x "$dir/run.sh"
    update_binary_cache "SABnzbd" "$dir/run.sh"
    log "SABnzbd installed to $dir/.venv"
}

install_from_tarball() {
    local app="$1"
    local url="$2"
    local target_dir
    target_dir=$(ensure_app_dir "$app")
    rm -rf "$target_dir"
    mkdir -p "$target_dir"
    local tmp
    tmp=$(mktemp -d)
    wget -qO "$tmp/archive.tar.gz" "$url"
    tar -xzf "$tmp/archive.tar.gz" --strip-components=1 -C "$target_dir"
    rm -rf "$tmp"
    echo "$target_dir"
}

install_SickChill() {
    local dir
    dir=$(install_from_tarball "SickChill" "${APP_URLS[SickChill]}")
    create_python_runner "SickChill" "$dir" "SickChill.py"
    ensure_config_dir_for "SickChill"
    log "SickChill installed to $dir"
}

install_Medusa() {
    local dir
    dir=$(install_from_tarball "Medusa" "${APP_URLS[Medusa]}")
    create_python_runner "Medusa" "$dir" "Medusa.py"
    ensure_config_dir_for "Medusa"
    log "Medusa installed to $dir"
}

install_Headphones() {
    local dir
    dir=$(install_from_tarball "Headphones" "${APP_URLS[Headphones]}")
    create_python_runner "Headphones" "$dir" "Headphones.py"
    ensure_config_dir_for "Headphones"
    log "Headphones installed to $dir"
}

install_Mylar() {
    local dir
    dir=$(install_from_tarball "Mylar" "${APP_URLS[Mylar]}")
    create_python_runner "Mylar" "$dir" "Mylar.py"
    ensure_config_dir_for "Mylar"
    log "Mylar installed to $dir"
}

install_Bazarr() {
    local dir
    dir=$(ensure_app_dir "Bazarr")
    rm -rf "$dir"
    mkdir -p "$dir"
    local tmp
    tmp=$(mktemp -d)
    wget -qO "$tmp/bazarr.zip" "${APP_URLS[Bazarr]}"
    unzip -q "$tmp/bazarr.zip" -d "$tmp/bazarr"
    mv "$tmp/bazarr"/* "$dir/"
    rm -rf "$tmp"
    create_python_runner "Bazarr" "$dir" "bazarr.py"
    ensure_config_dir_for "Bazarr"
    log "Bazarr installed to $dir"
}

install_Jackett() {
    local dir
    dir=$(ensure_app_dir "Jackett")
    rm -rf "$dir"
    mkdir -p "$dir"
    local tmp
    tmp=$(mktemp -d)
    wget -qO "$tmp/jackett.tar.gz" "${APP_URLS[Jackett]}"
    tar -xzf "$tmp/jackett.tar.gz" -C "$tmp"
    local extracted
    extracted=$(find "$tmp" -maxdepth 1 -type d -name "Jackett"* | head -1)
    if [[ -z "$extracted" ]]; then
        err "Unable to locate Jackett folder"
        rm -rf "$tmp"
        return 1
    fi
    mv "$extracted"/* "$dir/"
    rm -rf "$tmp"
    chmod +x "$dir/Jackett"
    update_binary_cache "Jackett" "$dir/Jackett"
    ensure_config_dir_for "Jackett"
    log "Jackett installed to $dir"
}

# -------- OPERATIONS ---------
start_app() {
    local app=$1
    log "Starting $app"
    local binary=$(resolve_app_binary "$app")
    if [[ ! -x "$binary" ]]; then
        err "Cannot start $app: binary not found ($binary)"
        return 1
    fi
    local template="${APP_START_CMDS[$app]}"
    if [[ -z "$template" ]]; then
        err "No start template defined for $app"
        return 1
    fi
    local config_dir=$(find_config_dir "$app")
    [[ -z "$config_dir" ]] && config_dir="$HOME/.config/${app,,}"
    mkdir -p "$config_dir"
    local cmd=${template//\{binary\}/$binary}
    cmd=${cmd//\{config\}/$config_dir}
    eval "$cmd" && log "$app started via: $cmd"
}
stop_app() {
    local app=$1
    log "Stopping $app"
    local binary=$(resolve_app_binary "$app")
    local pattern="${APPS[$app]}"
    pkill -f "$pattern" >/dev/null 2>&1 && log "Stopped $pattern processes." || log "No matching processes."  
    [[ -n "$binary" ]] && pkill -f "$binary" >/dev/null 2>&1 && log "Stopped $binary" || true
    screen -ls | grep -iq "$app" && screen -S "$app" -X quit || true
}
restart_app() { stop_app "$1"; sleep 2; start_app "$1"; }
status_app() {
    for app in "$@"; do
        log "$(get_app_status_line "$app")"
    done
}
install_app() { install_$1; }
reinstall_app() { stop_app "$1"; install_app "$1"; start_app "$1"; }

check_deps() {
    command -v fzf >/dev/null || { err "fzf missing. Install it first!"; exit 1; }
    command -v ss >/dev/null || command -v netstat >/dev/null || { err "ss/netstat missing!"; exit 1; }       
    command -v wget >/dev/null || command -v curl >/dev/null || { err "wget or curl missing!"; exit 1; }      
    command -v tar >/dev/null || { err "tar missing!"; exit 1; }
    command -v ps >/dev/null || { err "ps missing!"; exit 1; }
    command -v grep >/dev/null || { err "grep missing!"; exit 1; }
    command -v screen >/dev/null || { err "screen missing!"; exit 1; }
    command -v unzip >/dev/null || { err "unzip missing!"; exit 1; }
    command -v git >/dev/null || { err "git missing!"; exit 1; }
}

# --------- MAIN LOOP ---------
main_menu_loop() {
    while :; do
        clear
        get_ps_cache
        show_status_table
        local chosen_lines
        chosen_lines=$(fzf_app_select)
        [[ -z "$chosen_lines" ]] && continue

        if echo "$chosen_lines" | grep -q "QUIT"; then
          log "User chose to quit."
          echo "Goodbye!"
          exit 0
        fi

        # Parse app names out of the chosen lines (first field)
        readarray -t selected_apps < <(echo "$chosen_lines" | awk '{print $1}')
        if [[ ${#selected_apps[@]} -eq 0 ]]; then
            log "No apps selected"
            continue
        fi
        # Choose action
        local op
        op=$(fzf_action_select)
        [[ "$op" == "Back to Main Screen" || -z "$op" ]] && continue
        # Apply to all selected
        for app in "${selected_apps[@]}"; do
            # Defensive: skip dummy lines (like QUIT)
            [[ -z "${APPS[$app]+_}" ]] && continue
            case $op in
                status) status_app "$app" ;;
                start) start_app "$app" ;;
                stop) stop_app "$app" ;;
                restart) restart_app "$app" ;;
                install) install_app "$app" ;;
                reinstall) reinstall_app "$app" ;;
            esac
        done
        echo
        read -rp "Press Enter to return to the main menu..."
    done
}

ensure_cache_dirs
check_deps
main_menu_loop
