#!/usr/bin/env bash
# ========================================
# Whatbox App Manager
# ========================================
# A robust, autonomous manager for Whatbox applications
# Supports: Sonarr, Radarr, Prowlarr, Lidarr, Readarr, Whisparr, Jellyfin, Emby, Plex

set -euo pipefail

# Script metadata
SCRIPT_NAME="whatbox-manager"
SCRIPT_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ========================================
# Configuration & Environment
# ========================================

ENV_FILE="${SCRIPT_DIR}/.env"
LOG_DIR="${SCRIPT_DIR}/logs/agent"
LOG_FILE="${LOG_DIR}/whatbox-manager.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# ========================================
# Logging Functions
# ========================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" >> "${LOG_FILE}"
}

log_info() {
    log "INFO" "$@"
    [[ "${VERBOSE:-false}" == "true" ]] && echo "ℹ️  $*" >&2
}

log_warn() {
    log "WARN" "$@"
    echo "⚠️  $*" >&2
}

log_error() {
    log "ERROR" "$@"
    echo "❌ $*" >&2
}

log_debug() {
    log "DEBUG" "$@"
    [[ "${DEBUG:-false}" == "true" ]] && echo "🔍 [DEBUG] $*" >&2
}

# ========================================
# Color Support Detection
# ========================================

init_colors() {
    if [[ "${USE_COLORS:-true}" != "true" ]]; then
        export COLOR_RESET=""
        export COLOR_GREEN=""
        export COLOR_RED=""
        export COLOR_YELLOW=""
        export COLOR_BLUE=""
        export COLOR_CYAN=""
        export COLOR_BOLD=""
        return
    fi

    if command -v tput >/dev/null 2>&1; then
        export COLOR_RESET=$(tput sgr0)
        export COLOR_GREEN=$(tput setaf 2)
        export COLOR_RED=$(tput setaf 1)
        export COLOR_YELLOW=$(tput setaf 3)
        export COLOR_BLUE=$(tput setaf 4)
        export COLOR_CYAN=$(tput setaf 6)
        export COLOR_BOLD=$(tput bold)
    else
        export COLOR_RESET=""
        export COLOR_GREEN=""
        export COLOR_RED=""
        export COLOR_YELLOW=""
        export COLOR_BLUE=""
        export COLOR_CYAN=""
        export COLOR_BOLD=""
        log_warn "tput not found, disabling colors"
    fi
}

# ========================================
# Dependency Detection
# ========================================

check_dependency() {
    local cmd="$1"
    local fallback="${2:-}"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        log_debug "Found dependency: $cmd"
        return 0
    fi
    
    if [[ -n "$fallback" ]] && command -v "$fallback" >/dev/null 2>&1; then
        log_warn "$cmd not found, using fallback: $fallback"
        return 0
    fi
    
    log_warn "$cmd not found (fallback: ${fallback:-none})"
    return 1
}

detect_dependencies() {
    log_info "Detecting dependencies..."
    
    # Critical dependencies
    if ! command -v bash >/dev/null 2>&1; then
        log_error "bash is required but not found"
        exit 1
    fi
    
    if ! command -v pgrep >/dev/null 2>&1; then
        log_error "pgrep is required but not found"
        exit 1
    fi
    
    # Optional dependencies with fallbacks
    check_dependency "fzf" || log_warn "fzf not available, will use numbered menu"
    check_dependency "jq" || log_warn "jq not available, JSON parsing will be limited"
    check_dependency "curl" "wget" || log_warn "curl/wget not available, API checks disabled"
    check_dependency "lsof" "ss" || log_warn "lsof/ss not available, port checking limited"
    
    log_info "Dependency detection complete"
}

# ========================================
# Environment Loading & Validation
# ========================================

load_env() {
    if [[ ! -f "${ENV_FILE}" ]]; then
        log_warn ".env file not found, creating from template"
        if [[ -f "${ENV_FILE}.example" ]]; then
            cp "${ENV_FILE}.example" "${ENV_FILE}"
            log_info "Created .env from template"
        else
            log_error "No .env.example found, cannot create .env"
            return 1
        fi
    fi
    
    # Source .env file
    set -a
    source "${ENV_FILE}" 2>/dev/null || {
        log_error "Failed to load .env file"
        return 1
    }
    set +a
    
    log_info "Environment loaded from ${ENV_FILE}"
    validate_env
}

validate_env() {
    local missing_keys=()
    local apps=("SONARR" "RADARR" "PROWLARR" "LIDARR" "READARR" "WHISPARR" "JELLYFIN" "EMBY" "PLEX")
    
    for app in "${apps[@]}"; do
        local port_var="${app}_PORT"
        local dir_var="${app}_DIR"
        local config_var="${app}_CONFIG_DIR"
        local bin_var="${app}_BIN"
        
        if [[ -z "${!port_var:-}" ]]; then
            missing_keys+=("${port_var}")
        fi
        if [[ -z "${!dir_var:-}" ]]; then
            missing_keys+=("${dir_var}")
        fi
        if [[ -z "${!config_var:-}" ]]; then
            missing_keys+=("${config_var}")
        fi
        if [[ -z "${!bin_var:-}" ]]; then
            missing_keys+=("${bin_var}")
        fi
    done
    
    if [[ ${#missing_keys[@]} -gt 0 ]]; then
        log_warn "Missing environment keys: ${missing_keys[*]}"
        # Auto-fix with defaults
        repair_env "${missing_keys[@]}"
    fi
}

repair_env() {
    local keys=("$@")
    log_info "Repairing .env file with defaults..."
    
    for key in "${keys[@]}"; do
        case "$key" in
            *_PORT)
                local app="${key%_PORT}"
                local default_port=""
                case "$app" in
                    SONARR) default_port="8989" ;;
                    RADARR) default_port="7878" ;;
                    PROWLARR) default_port="9696" ;;
                    LIDARR) default_port="8686" ;;
                    READARR) default_port="8787" ;;
                    WHISPARR) default_port="9697" ;;
                    JELLYFIN) default_port="8096" ;;
                    EMBY) default_port="8096" ;;
                    PLEX) default_port="32400" ;;
                esac
                echo "${key}=${default_port}" >> "${ENV_FILE}"
                ;;
            *_DIR)
                local app="${key%_DIR}"
                echo "${key}=\$HOME/apps/${app,,}" >> "${ENV_FILE}"
                ;;
            *_CONFIG_DIR)
                local app="${key%_CONFIG_DIR}"
                echo "${key}=\$HOME/.config/${app}" >> "${ENV_FILE}"
                ;;
            *_BIN)
                local app="${key%_BIN}"
                echo "${key}=${app}" >> "${ENV_FILE}"
                ;;
        esac
    done
    
    log_info "Environment repaired"
}

# ========================================
# Application Detection
# ========================================

detect_app_status() {
    local app_name="$1"
    local app_upper="${app_name^^}"
    
    local app_dir_var="${app_upper}_DIR"
    local app_bin_var="${app_upper}_BIN"
    local app_port_var="${app_upper}_PORT"
    local app_config_var="${app_upper}_CONFIG_DIR"
    local app_start_var="${app_upper}_START"
    
    local app_dir="${!app_dir_var:-}"
    local app_bin="${!app_bin_var:-}"
    local app_port="${!app_port_var:-}"
    local app_config="${!app_config_var:-}"
    local app_start="${!app_start_var:-}"
    
    # Initialize status
    local status="Unknown"
    local pid=""
    local port_status="Unknown"
    local config_status="Unknown"
    local binary_status="Unknown"
    
    # Check if app directory exists
    if [[ ! -d "${app_dir}" ]]; then
        status="Unavailable"
        echo "{\"app\":\"${app_name}\",\"status\":\"${status}\",\"pid\":\"\",\"port\":\"${app_port}\",\"port_status\":\"Unknown\",\"config_status\":\"Missing\",\"binary_status\":\"Missing\"}"
        return
    fi
    
    # Check for running process
    if pid=$(pgrep -f "${app_bin}" 2>/dev/null | head -n1); then
        status="Running"
        binary_status="Running"
    else
        status="Stopped"
        binary_status="Not Running"
    fi
    
    # Check port status
    if command -v lsof >/dev/null 2>&1; then
        if lsof -ti:${app_port} >/dev/null 2>&1; then
            local port_pid=$(lsof -ti:${app_port} 2>/dev/null | head -n1)
            if [[ "$port_pid" == "$pid" ]]; then
                port_status="In Use (Correct)"
            else
                port_status="In Use (Conflict)"
                status="Conflict"
            fi
        else
            port_status="Free"
        fi
    elif command -v ss >/dev/null 2>&1; then
        if ss -tuln | grep -q ":${app_port} "; then
            port_status="In Use"
        else
            port_status="Free"
        fi
    fi
    
    # Check config directory
    if [[ -d "${app_config}" ]] && [[ -r "${app_config}" ]]; then
        config_status="Valid"
    else
        config_status="Missing/Invalid"
        if [[ "$status" == "Stopped" ]]; then
            status="Misconfigured"
        fi
    fi
    
    # Check start script
    local start_status="Unknown"
    if [[ -f "${app_start}" ]] && [[ -x "${app_start}" ]]; then
        start_status="Valid"
    else
        start_status="Missing/Invalid"
    fi
    
    # Output JSON
    echo "{\"app\":\"${app_name}\",\"status\":\"${status}\",\"pid\":\"${pid}\",\"port\":\"${app_port}\",\"port_status\":\"${port_status}\",\"config_status\":\"${config_status}\",\"binary_status\":\"${binary_status}\",\"start_script\":\"${start_status}\"}"
}

detect_all_apps() {
    local apps=("sonarr" "radarr" "prowlarr" "lidarr" "readarr" "whisparr" "jellyfin" "emby" "plex")
    local detected=()
    local results=()
    
    log_info "Detecting installed applications..."
    
    for app in "${apps[@]}"; do
        local app_upper="${app^^}"
        local app_dir_var="${app_upper}_DIR"
        local app_dir="${!app_dir_var:-}"
        
        if [[ -d "${app_dir}" ]]; then
            detected+=("${app}")
            local status_json=$(detect_app_status "${app}")
            results+=("${status_json}")
            log_debug "Detected: ${app}"
        fi
    done
    
    if [[ ${#detected[@]} -eq 0 ]]; then
        log_warn "No Whatbox applications detected"
        return 1
    fi
    
    log_info "Detected ${#detected[@]} applications: ${detected[*]}"
    
    # Output results
    if [[ "${JSON_OUTPUT:-false}" == "true" ]]; then
        echo "["
        local first=true
        for result in "${results[@]}"; do
            [[ "$first" == "false" ]] && echo ","
            echo -n "$result"
            first=false
        done
        echo ""
        echo "]"
    else
        for result in "${results[@]}"; do
            format_app_status "$result"
        done
    fi
    
    return 0
}

format_app_status() {
    local status_json="$1"
    local app=$(echo "$status_json" | grep -o '"app":"[^"]*' | cut -d'"' -f4)
    local status=$(echo "$status_json" | grep -o '"status":"[^"]*' | cut -d'"' -f4)
    local pid=$(echo "$status_json" | grep -o '"pid":"[^"]*' | cut -d'"' -f4)
    local port=$(echo "$status_json" | grep -o '"port":"[^"]*' | cut -d'"' -f4)
    local port_status=$(echo "$status_json" | grep -o '"port_status":"[^"]*' | cut -d'"' -f4)
    local config_status=$(echo "$status_json" | grep -o '"config_status":"[^"]*' | cut -d'"' -f4)
    
    local status_color="${COLOR_GREEN}"
    case "$status" in
        Running) status_color="${COLOR_GREEN}" ;;
        Stopped) status_color="${COLOR_YELLOW}" ;;
        Conflict|Misconfigured) status_color="${COLOR_RED}" ;;
        Unavailable) status_color="${COLOR_CYAN}" ;;
    esac
    
    printf "${COLOR_BOLD}%-12s${COLOR_RESET} ${status_color}%-12s${COLOR_RESET} Port: %-5s (%-15s) PID: %-8s Config: %s\n" \
        "${app}" "${status}" "${port}" "${port_status}" "${pid:-N/A}" "${config_status}"
}

# ========================================
# Application Control
# ========================================

start_app() {
    local app_name="$1"
    local app_upper="${app_name^^}"
    
    local app_start_var="${app_upper}_START"
    local app_start="${!app_start_var:-}"
    local app_port_var="${app_upper}_PORT"
    local app_port="${!app_port_var:-}"
    
    log_info "Starting ${app_name}..."
    
    if [[ -z "${app_start}" ]] || [[ ! -f "${app_start}" ]]; then
        log_error "${app_name}: Start script not found: ${app_start}"
        return 1
    fi
    
    if [[ ! -x "${app_start}" ]]; then
        log_warn "${app_name}: Start script not executable, fixing..."
        chmod +x "${app_start}" || {
            log_error "${app_name}: Failed to make start script executable"
            return 1
        }
    fi
    
    # Check if already running
    local pid=$(pgrep -f "${app_upper}_BIN" 2>/dev/null | head -n1)
    if [[ -n "${pid}" ]]; then
        log_warn "${app_name}: Already running (PID: ${pid})"
        return 0
    fi
    
    # Check port
    if command -v lsof >/dev/null 2>&1; then
        if lsof -ti:${app_port} >/dev/null 2>&1; then
            log_error "${app_name}: Port ${app_port} is already in use"
            return 1
        fi
    fi
    
    # Start the application
    nohup bash "${app_start}" >/dev/null 2>&1 &
    local start_pid=$!
    
    # Wait for startup
    local waited=0
    while [[ $waited -lt ${START_TIMEOUT:-30} ]]; do
        sleep 1
        waited=$((waited + 1))
        if pgrep -f "${app_upper}_BIN" >/dev/null 2>&1; then
            log_info "${app_name}: Started successfully"
            return 0
        fi
    done
    
    log_error "${app_name}: Failed to start within timeout"
    return 1
}

stop_app() {
    local app_name="$1"
    local app_upper="${app_name^^}"
    local app_bin_var="${app_upper}_BIN"
    local app_bin="${!app_bin_var:-}"
    
    log_info "Stopping ${app_name}..."
    
    local pid=$(pgrep -f "${app_bin}" 2>/dev/null | head -n1)
    if [[ -z "${pid}" ]]; then
        log_warn "${app_name}: Not running"
        return 0
    fi
    
    # Try graceful shutdown first
    kill "$pid" 2>/dev/null || true
    
    # Wait for shutdown
    local waited=0
    while [[ $waited -lt ${STOP_TIMEOUT:-15} ]]; do
        sleep 1
        waited=$((waited + 1))
        if ! kill -0 "$pid" 2>/dev/null; then
            log_info "${app_name}: Stopped successfully"
            return 0
        fi
    done
    
    # Force kill if still running
    log_warn "${app_name}: Graceful shutdown failed, forcing..."
    kill -9 "$pid" 2>/dev/null || true
    sleep 1
    
    if ! kill -0 "$pid" 2>/dev/null; then
        log_info "${app_name}: Force stopped"
        return 0
    fi
    
    log_error "${app_name}: Failed to stop"
    return 1
}

# ========================================
# FZF Selection (with fallback)
# ========================================

select_apps_fzf() {
    local apps=("$@")
    
    if ! command -v fzf >/dev/null 2>&1; then
        select_apps_menu "${apps[@]}"
        return
    fi
    
    local preview=""
    if [[ "${FZF_PREVIEW:-true}" == "true" ]]; then
        preview="--preview='echo {} | xargs -I {} bash -c \"detect_app_status {}\"' --preview-window=right:50%"
    fi
    
    local selected
    selected=$(printf '%s\n' "${apps[@]}" | fzf -m --header="Select applications (TAB for multi-select)" ${preview})
    
    if [[ -z "${selected}" ]]; then
        return 1
    fi
    
    # Convert to array
    readarray -t selected_apps <<< "${selected}"
    echo "${selected_apps[@]}"
}

select_apps_menu() {
    local apps=("$@")
    local count=${#apps[@]}
    
    echo "${COLOR_BOLD}Available Applications:${COLOR_RESET}"
    for i in "${!apps[@]}"; do
        echo "  $((i+1)). ${apps[$i]}"
    done
    echo "  $((count+1)). All"
    echo ""
    read -p "Select (1-$((count+1))): " choice
    
    if [[ "$choice" == "$((count+1))" ]]; then
        echo "${apps[@]}"
    elif [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$count" ]]; then
        echo "${apps[$((choice-1))]}"
    else
        log_error "Invalid selection"
        return 1
    fi
}

# ========================================
# CLI Argument Parsing
# ========================================

parse_args() {
    local action=""
    local target_app=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --status)
                action="status"
                [[ $# -gt 1 ]] && target_app="$2" && shift
                ;;
            --start)
                action="start"
                [[ $# -gt 1 ]] && target_app="$2" && shift
                ;;
            --stop)
                action="stop"
                [[ $# -gt 1 ]] && target_app="$2" && shift
                ;;
            --list|--all)
                action="list"
                ;;
            --json)
                export JSON_OUTPUT=true
                ;;
            --verbose)
                export VERBOSE=true
                ;;
            --debug)
                export DEBUG=true
                export VERBOSE=true
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --version|-v)
                echo "${SCRIPT_NAME} ${SCRIPT_VERSION}"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 4
                ;;
        esac
        shift
    done
    
    # Default action if none specified
    if [[ -z "$action" ]]; then
        action="interactive"
    fi
    
    execute_action "$action" "$target_app"
}

execute_action() {
    local action="$1"
    local target_app="${2:-}"
    
    case "$action" in
        status)
            if [[ -n "$target_app" ]]; then
                local status_json=$(detect_app_status "$target_app")
                if [[ "${JSON_OUTPUT:-false}" == "true" ]]; then
                    echo "$status_json"
                else
                    format_app_status "$status_json"
                fi
            else
                detect_all_apps
            fi
            ;;
        start)
            if [[ -n "$target_app" ]]; then
                start_app "$target_app"
            else
                local apps=($(get_available_apps))
                local selected
                if command -v fzf >/dev/null 2>&1; then
                    selected=($(select_apps_fzf "${apps[@]}"))
                else
                    selected=($(select_apps_menu "${apps[@]}"))
                fi
                for app in "${selected[@]}"; do
                    start_app "$app"
                done
            fi
            ;;
        stop)
            if [[ -n "$target_app" ]]; then
                stop_app "$target_app"
            else
                local apps=($(get_available_apps))
                local selected
                if command -v fzf >/dev/null 2>&1; then
                    selected=($(select_apps_fzf "${apps[@]}"))
                else
                    selected=($(select_apps_menu "${apps[@]}"))
                fi
                for app in "${selected[@]}"; do
                    stop_app "$app"
                done
            fi
            ;;
        list)
            detect_all_apps
            ;;
        interactive)
            interactive_mode
            ;;
    esac
}

get_available_apps() {
    local apps=("sonarr" "radarr" "prowlarr" "lidarr" "readarr" "whisparr" "jellyfin" "emby" "plex")
    local available=()
    
    for app in "${apps[@]}"; do
        local app_upper="${app^^}"
        local app_dir_var="${app_upper}_DIR"
        local app_dir="${!app_dir_var:-}"
        
        if [[ -d "${app_dir}" ]]; then
            available+=("${app}")
        fi
    done
    
    echo "${available[@]}"
}

interactive_mode() {
    local apps=($(get_available_apps))
    
    if [[ ${#apps[@]} -eq 0 ]]; then
        log_error "No applications available"
        exit 1
    fi
    
    echo "${COLOR_BOLD}Whatbox App Manager${COLOR_RESET}"
    echo "===================="
    echo ""
    echo "Select action:"
    echo "  1. Status"
    echo "  2. Start"
    echo "  3. Stop"
    echo "  4. List All"
    echo ""
    read -p "Choice (1-4): " choice
    
    case "$choice" in
        1) detect_all_apps ;;
        2)
            local selected
            if command -v fzf >/dev/null 2>&1; then
                selected=($(select_apps_fzf "${apps[@]}"))
            else
                selected=($(select_apps_menu "${apps[@]}"))
            fi
            for app in "${selected[@]}"; do
                start_app "$app"
            done
            ;;
        3)
            local selected
            if command -v fzf >/dev/null 2>&1; then
                selected=($(select_apps_fzf "${apps[@]}"))
            else
                selected=($(select_apps_menu "${apps[@]}"))
            fi
            for app in "${selected[@]}"; do
                stop_app "$app"
            done
            ;;
        4) detect_all_apps ;;
        *)
            log_error "Invalid choice"
            exit 1
            ;;
    esac
}

show_help() {
    cat <<EOF
${COLOR_BOLD}Whatbox App Manager${COLOR_RESET} ${SCRIPT_VERSION}

Usage: ${SCRIPT_NAME}.sh [OPTIONS]

Options:
  --status [APP]     Show status of all apps or specific app
  --start [APP]      Start all apps or specific app
  --stop [APP]       Stop all apps or specific app
  --list, --all      List all detected applications
  --json             Output in JSON format
  --verbose          Enable verbose output
  --debug            Enable debug output
  --help, -h         Show this help message
  --version, -v      Show version information

Examples:
  ${SCRIPT_NAME}.sh --status
  ${SCRIPT_NAME}.sh --start sonarr
  ${SCRIPT_NAME}.sh --stop radarr
  ${SCRIPT_NAME}.sh --list --json
  ${SCRIPT_NAME}.sh              # Interactive mode

EOF
}

# ========================================
# Main Execution
# ========================================

main() {
    log_info "Starting ${SCRIPT_NAME} v${SCRIPT_VERSION}"
    
    # Initialize
    init_colors
    detect_dependencies
    load_env || {
        log_error "Failed to load environment"
        exit 1
    }
    
    # Parse and execute
    parse_args "$@"
    
    log_info "Completed successfully"
    exit 0
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

