# Whatbox App Manager - Usage Guide

## Quick Start

```bash
# Make script executable (if not already)
chmod +x whatbox-manager.sh

# Run in interactive mode
./whatbox-manager.sh

# Check status of all apps
./whatbox-manager.sh --status

# Start a specific app
./whatbox-manager.sh --start sonarr

# Stop a specific app
./whatbox-manager.sh --stop radarr

# List all detected apps in JSON format
./whatbox-manager.sh --list --json
```

## Command-Line Options

### `--status [APP]`
Show the status of all applications or a specific application.

**Examples:**
```bash
./whatbox-manager.sh --status
./whatbox-manager.sh --status sonarr
```

**Output includes:**
- Application name
- Running status (Running/Stopped/Conflict/Unavailable)
- Process ID (if running)
- Port number and status
- Configuration directory status

### `--start [APP]`
Start all applications or a specific application.

**Examples:**
```bash
./whatbox-manager.sh --start
./whatbox-manager.sh --start radarr
```

**Behavior:**
- Checks if app is already running
- Verifies port availability
- Validates start script
- Starts application in background
- Waits for confirmation (up to 30 seconds)

### `--stop [APP]`
Stop all applications or a specific application.

**Examples:**
```bash
./whatbox-manager.sh --stop
./whatbox-manager.sh --stop prowlarr
```

**Behavior:**
- Attempts graceful shutdown (SIGTERM)
- Waits up to 15 seconds
- Falls back to force kill (SIGKILL) if needed

### `--list` or `--all`
List all detected applications with their current status.

### `--json`
Output results in JSON format for machine parsing.

**Example:**
```bash
./whatbox-manager.sh --status --json
```

### `--verbose`
Enable verbose output showing additional information.

### `--debug`
Enable debug mode with detailed logging and command traces.

### `--help` or `-h`
Display help information.

### `--version` or `-v`
Display version information.

## Interactive Mode

When run without arguments, the script enters interactive mode:

1. **Select Action**
   - Status
   - Start
   - Stop
   - List All

2. **Select Applications** (if Start/Stop chosen)
   - FZF menu (if available) with multi-select support
   - Numbered menu (fallback)
   - Preview pane showing app status

## Status Indicators

- **Running** (Green): Application is running normally
- **Stopped** (Yellow): Application is not running
- **Conflict** (Red): Port conflict detected
- **Misconfigured** (Red): Configuration issues detected
- **Unavailable** (Cyan): Application directory not found

## Examples

### Check all app statuses
```bash
./whatbox-manager.sh --status
```

### Start multiple apps interactively
```bash
./whatbox-manager.sh --start
# Select apps using FZF or numbered menu
```

### Get JSON status for automation
```bash
./whatbox-manager.sh --status --json | jq '.[] | select(.status == "Stopped")'
```

### Verbose debugging
```bash
./whatbox-manager.sh --start sonarr --verbose --debug
```

## Integration Examples

### Cron Job - Auto-start on boot
```bash
# Add to crontab
@reboot /path/to/whatbox-manager.sh --start
```

### Health Check Script
```bash
#!/bin/bash
status=$(./whatbox-manager.sh --status sonarr --json | jq -r '.[0].status')
if [[ "$status" != "Running" ]]; then
    ./whatbox-manager.sh --start sonarr
fi
```

### Monitoring Script
```bash
#!/bin/bash
./whatbox-manager.sh --status --json | jq -r '.[] | "\(.app): \(.status)"'
```

