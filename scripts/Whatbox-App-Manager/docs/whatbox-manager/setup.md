# Whatbox App Manager - Setup Guide

## Prerequisites

### Required
- **Bash** 4.0 or higher
- **pgrep** (usually included with procps)
- **Whatbox account** with applications installed

### Optional (with fallbacks)
- **fzf** - For interactive selection (falls back to numbered menu)
- **jq** - For JSON parsing (falls back to basic parsing)
- **curl** or **wget** - For API checks (falls back to wget or disabled)
- **lsof** or **ss** - For port checking (falls back to ss or limited checking)
- **tput** - For color output (falls back to plain text)

## Installation

### 1. Clone or Download

If using the whatbox-scripts repository:
```bash
cd whatbox-scripts/scripts/Whatbox-App-Manager
```

### 2. Make Script Executable

```bash
chmod +x whatbox-manager.sh
```

### 3. Configure Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your specific paths and ports
nano .env  # or use your preferred editor
```

### 4. Verify Configuration

The `.env` file should contain:
- Application ports (SONARR_PORT, RADARR_PORT, etc.)
- Application directories (SONARR_DIR, RADARR_DIR, etc.)
- Configuration directories (SONARR_CONFIG_DIR, etc.)
- Log directories (SONARR_LOG_DIR, etc.)
- Start scripts (SONARR_START, etc.)
- Binary names (SONARR_BIN, etc.)

### 5. Test Installation

```bash
# Check if script can detect your apps
./whatbox-manager.sh --list

# Check status
./whatbox-manager.sh --status
```

## Configuration Details

### Default Paths

The script expects applications in the standard Whatbox structure:
```
$HOME/apps/
├── sonarr/
│   ├── start.sh
│   └── Sonarr
├── radarr/
│   ├── start.sh
│   └── Radarr
└── ...
```

Configuration directories:
```
$HOME/.config/
├── Sonarr/
├── Radarr/
├── Prowlarr/
└── ...
```

### Customizing Paths

Edit `.env` to match your installation:

```bash
# Example: Custom Sonarr location
SONARR_DIR=/custom/path/to/sonarr
SONARR_CONFIG_DIR=/custom/path/to/config
SONARR_START=/custom/path/to/sonarr/start.sh
```

### Port Configuration

Ensure ports match your application settings:

```bash
SONARR_PORT=8989
RADARR_PORT=7878
# ... etc
```

## Dependency Installation

### On Whatbox (typically already available)
Most dependencies are pre-installed. If missing:

```bash
# fzf (optional but recommended)
# Usually available via package manager or can be compiled from source

# jq (optional)
# Available via package manager
```

### Verification

Check if dependencies are available:
```bash
./whatbox-manager.sh --status --verbose
# Will show warnings for missing optional dependencies
```

## Post-Installation

### 1. Test Detection
```bash
./whatbox-manager.sh --list
```

### 2. Test Status Check
```bash
./whatbox-manager.sh --status
```

### 3. Test Start/Stop (on a test app)
```bash
./whatbox-manager.sh --stop sonarr
./whatbox-manager.sh --start sonarr
```

### 4. Verify Logging
```bash
cat logs/agent/whatbox-manager.log
```

## Troubleshooting Setup

### Script Not Executable
```bash
chmod +x whatbox-manager.sh
```

### .env File Missing
```bash
cp .env.example .env
# Edit .env with your paths
```

### Apps Not Detected
1. Verify app directories exist in `$HOME/apps/`
2. Check `.env` has correct `*_DIR` variables
3. Run with `--verbose` to see detection process

### Permission Errors
```bash
# Ensure start scripts are executable
chmod +x $HOME/apps/*/start.sh
```

### Port Conflicts
- Check if ports in `.env` match actual app ports
- Verify no other processes are using those ports
- Use `lsof -i :PORT` or `ss -tuln | grep PORT` to check

## Next Steps

After setup:
1. Review [Usage Guide](usage.md)
2. Check [Examples](examples.md)
3. Read [Troubleshooting](troubleshooting.md)

