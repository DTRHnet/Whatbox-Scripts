#!/usr/bin/env bash
# ========================================
# Whatbox Media Manager Config Generator
# ========================================

set -euo pipefail

# Load .env if it exists
ENV_FILE=".env"
if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: .env file not found!"
    exit 1
fi
export $(grep -v '^#' "$ENV_FILE" | xargs)

# Function to create directories and config files
setup_app() {
    local NAME=$1
    local DIR_VAR=$2
    local CONFIG_DIR_VAR=$3
    local LOG_DIR_VAR=$4
    local START_SCRIPT_VAR=$5
    local BIN_VAR=$6
    local PORT_VAR=$7

    eval DIR="\$$DIR_VAR"
    eval CONFIG_DIR="\$$CONFIG_DIR_VAR"
    eval LOG_DIR="\$$LOG_DIR_VAR"
    eval START_SCRIPT="\$$START_SCRIPT_VAR"
    eval BIN="\$$BIN_VAR"
    eval PORT="\$$PORT_VAR"

    echo "Setting up $NAME..."

    # Create necessary directories
    mkdir -p "$DIR" "$CONFIG_DIR" "$LOG_DIR"

    # Create a default start.sh
    cat > "$START_SCRIPT" <<EOF
#!/usr/bin/env bash
# Auto-generated start script for $NAME
"$BIN" --config "$CONFIG_DIR" --port "$PORT"
EOF

    chmod +x "$START_SCRIPT"

    # Create a default config.json if missing
    CONFIG_FILE="$CONFIG_DIR/config.json"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" <<EOF
{
    "name": "$NAME",
    "port": $PORT,
    "log_dir": "$LOG_DIR",
    "data_dir": "$DIR"
}
EOF
    fi

    echo "$NAME setup complete."
}

# List of apps to configure
APPS=(
    "SONARR:SONARR_DIR:SONARR_CONFIG_DIR:SONARR_LOG_DIR:SONARR_START:SONARR_BIN:SONARR_PORT"
    "RADARR:RADARR_DIR:RADARR_CONFIG_DIR:RADARR_LOG_DIR:RADARR_START:RADARR_BIN:RADARR_PORT"
    "PROWLARR:PROWLARR_DIR:PROWLARR_CONFIG_DIR:PROWLARR_LOG_DIR:PROWLARR_START:PROWLARR_BIN:PROWLARR_PORT"
    "LIDARR:LIDARR_DIR:LIDARR_CONFIG_DIR:LIDARR_LOG_DIR:LIDARR_START:LIDARR_BIN:LIDARR_PORT"
    "READARR:READARR_DIR:READARR_CONFIG_DIR:READARR_LOG_DIR:READARR_START:READARR_BIN:READARR_PORT"
    "WHISPARR:WHISPARR_DIR:WHISPARR_CONFIG_DIR:WHISPARR_LOG_DIR:WHISPARR_START:WHISPARR_BIN:WHISPARR_PORT"
    "JELLYFIN:JELLYFIN_DIR:JELLYFIN_CONFIG_DIR:JELLYFIN_LOG_DIR:JELLYFIN_START:JELLYFIN_BIN:JELLYFIN_PORT"
    "EMBY:EMBY_DIR:EMBY_CONFIG_DIR:EMBY_LOG_DIR:EMBY_START:EMBY_BIN:EMBY_PORT"
    "PLEX:PLEX_DIR:PLEX_CONFIG_DIR:PLEX_LOG_DIR:PLEX_START:PLEX_BIN:PLEX_PORT"
)

# Iterate and setup apps
for APP in "${APPS[@]}"; do
    IFS=":" read -r NAME DIR CONFIG LOG START BIN PORT <<< "$APP"
    setup_app "$NAME" "$DIR" "$CONFIG" "$LOG" "$START" "$BIN" "$PORT"
done

echo "All apps have been configured successfully!"
