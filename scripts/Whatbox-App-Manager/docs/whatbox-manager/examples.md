# Whatbox App Manager - Examples

## Basic Usage Examples

### Check Status of All Apps
```bash
./whatbox-manager.sh --status
```

Output:
```
sonarr        Running      Port: 8989  (In Use (Correct))  PID: 12345   Config: Valid
radarr        Stopped      Port: 7878   (Free)              PID: N/A     Config: Valid
prowlarr      Running      Port: 9696   (In Use (Correct))  PID: 12346   Config: Valid
```

### Start a Specific App
```bash
./whatbox-manager.sh --start sonarr
```

### Stop a Specific App
```bash
./whatbox-manager.sh --stop radarr
```

### List All Apps in JSON
```bash
./whatbox-manager.sh --list --json
```

Output:
```json
[
{"app":"sonarr","status":"Running","pid":"12345","port":"8989","port_status":"In Use (Correct)","config_status":"Valid","binary_status":"Running","start_script":"Valid"},
{"app":"radarr","status":"Stopped","pid":"","port":"7878","port_status":"Free","config_status":"Valid","binary_status":"Not Running","start_script":"Valid"}
]
```

## Advanced Examples

### Filter Stopped Apps (JSON + jq)
```bash
./whatbox-manager.sh --status --json | jq '.[] | select(.status == "Stopped")'
```

### Start All Stopped Apps
```bash
./whatbox-manager.sh --status --json | \
  jq -r '.[] | select(.status == "Stopped") | .app' | \
  xargs -I {} ./whatbox-manager.sh --start {}
```

### Monitor App Status Continuously
```bash
watch -n 5 './whatbox-manager.sh --status'
```

### Check Specific App Status
```bash
./whatbox-manager.sh --status sonarr
```

### Verbose Debug Mode
```bash
./whatbox-manager.sh --start radarr --verbose --debug
```

## Automation Examples

### Auto-Start Script (Cron)
```bash
#!/bin/bash
# Add to crontab: @reboot /path/to/auto-start.sh

SCRIPT_DIR="/path/to/whatbox-manager"
cd "$SCRIPT_DIR"

# Start all apps on boot
./whatbox-manager.sh --start
```

### Health Check Script
```bash
#!/bin/bash
# Check and restart failed apps

SCRIPT_DIR="/path/to/whatbox-manager"
cd "$SCRIPT_DIR"

# Get apps that should be running but aren't
FAILED=$(./whatbox-manager.sh --status --json | \
  jq -r '.[] | select(.status == "Stopped" and .config_status == "Valid") | .app')

if [[ -n "$FAILED" ]]; then
    echo "Restarting failed apps: $FAILED"
    for app in $FAILED; do
        ./whatbox-manager.sh --start "$app"
    done
fi
```

### Status Dashboard Script
```bash
#!/bin/bash
# Generate a status dashboard

SCRIPT_DIR="/path/to/whatbox-manager"
cd "$SCRIPT_DIR"

echo "=== Whatbox App Status Dashboard ==="
echo "Generated: $(date)"
echo ""
./whatbox-manager.sh --status
echo ""
echo "=== Recent Logs ==="
tail -n 20 logs/agent/whatbox-manager.log
```

### Backup Before Stop Script
```bash
#!/bin/bash
# Backup configs before stopping apps

SCRIPT_DIR="/path/to/whatbox-manager"
cd "$SCRIPT_DIR"

APP="$1"
BACKUP_DIR="$HOME/backups/whatbox"

# Stop app
./whatbox-manager.sh --stop "$APP"

# Backup config
APP_UPPER="${APP^^}"
CONFIG_VAR="${APP_UPPER}_CONFIG_DIR"
CONFIG_DIR="${!CONFIG_VAR}"

mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/${APP}-$(date +%Y%m%d).tar.gz" "$CONFIG_DIR"

echo "Backup created: $BACKUP_DIR/${APP}-$(date +%Y%m%d).tar.gz"
```

## Integration Examples

### Systemd Service Integration
```ini
[Unit]
Description=Whatbox App Manager
After=network.target

[Service]
Type=oneshot
ExecStart=/path/to/whatbox-manager.sh --start
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

### Webhook Notification
```bash
#!/bin/bash
# Send webhook on app status change

WEBHOOK_URL="https://your-webhook-url"
APP="$1"
STATUS=$(./whatbox-manager.sh --status "$APP" --json | jq -r '.[0].status')

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{\"app\":\"$APP\",\"status\":\"$STATUS\",\"timestamp\":\"$(date -Iseconds)\"}"
```

### Log Rotation Script
```bash
#!/bin/bash
# Rotate logs older than 30 days

LOG_DIR="logs/agent"
RETENTION_DAYS=30

find "$LOG_DIR" -name "*.log" -type f -mtime +$RETENTION_DAYS -delete
echo "Log rotation complete"
```

## Interactive Mode Examples

### Full Interactive Session
```bash
$ ./whatbox-manager.sh

Whatbox App Manager
====================

Select action:
  1. Status
  2. Start
  3. Stop
  4. List All

Choice (1-4): 1

sonarr        Running      Port: 8989  (In Use (Correct))  PID: 12345   Config: Valid
radarr        Stopped      Port: 7878   (Free)              PID: N/A     Config: Valid
```

### FZF Multi-Select Example
When using `--start` or `--stop` without specifying an app:
- FZF menu appears (if available)
- Use TAB to select multiple apps
- Preview pane shows status
- Press ENTER to confirm

## Error Handling Examples

### Graceful Failure Handling
```bash
#!/bin/bash
# Script that handles failures gracefully

if ! ./whatbox-manager.sh --start sonarr; then
    echo "Failed to start sonarr, checking logs..."
    tail -n 50 logs/agent/whatbox-manager.log
    exit 1
fi
```

### Retry Logic
```bash
#!/bin/bash
# Retry starting an app up to 3 times

APP="sonarr"
MAX_RETRIES=3
RETRY=0

while [[ $RETRY -lt $MAX_RETRIES ]]; do
    if ./whatbox-manager.sh --start "$APP"; then
        echo "Successfully started $APP"
        exit 0
    fi
    RETRY=$((RETRY + 1))
    echo "Attempt $RETRY failed, retrying..."
    sleep 5
done

echo "Failed to start $APP after $MAX_RETRIES attempts"
exit 1
```

