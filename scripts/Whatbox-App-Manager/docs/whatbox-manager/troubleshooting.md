# Whatbox App Manager - Troubleshooting

## Common Issues

### Apps Not Detected

**Symptoms:**
- `--list` shows no applications
- `--status` reports "No Whatbox applications detected"

**Solutions:**
1. Verify app directories exist:
   ```bash
   ls -la $HOME/apps/
   ```

2. Check `.env` file has correct paths:
   ```bash
   grep "_DIR=" .env
   ```

3. Run with verbose mode:
   ```bash
   ./whatbox-manager.sh --list --verbose
   ```

4. Ensure directory names match (case-sensitive):
   - `$HOME/apps/sonarr` (lowercase)
   - Not `$HOME/apps/Sonarr`

### Port Conflicts

**Symptoms:**
- Status shows "Conflict"
- Port status shows "In Use (Conflict)"
- App won't start

**Solutions:**
1. Check what's using the port:
   ```bash
   lsof -i :8989
   # or
   ss -tuln | grep 8989
   ```

2. Verify port in `.env` matches app configuration:
   ```bash
   grep SONARR_PORT .env
   ```

3. Check app's actual config file for port setting

4. Kill conflicting process (if safe):
   ```bash
   kill <PID>
   ```

### Start Script Issues

**Symptoms:**
- "Start script not found"
- "Start script not executable"
- App fails to start

**Solutions:**
1. Verify start script exists:
   ```bash
   ls -la $HOME/apps/sonarr/start.sh
   ```

2. Make executable:
   ```bash
   chmod +x $HOME/apps/*/start.sh
   ```

3. Check start script content:
   ```bash
   cat $HOME/apps/sonarr/start.sh
   ```

4. Test start script manually:
   ```bash
   $HOME/apps/sonarr/start.sh
   ```

### Configuration Directory Issues

**Symptoms:**
- Status shows "Misconfigured"
- Config status shows "Missing/Invalid"

**Solutions:**
1. Verify config directory exists:
   ```bash
   ls -la $HOME/.config/Sonarr
   ```

2. Check permissions:
   ```bash
   ls -ld $HOME/.config/Sonarr
   ```

3. Ensure directory is readable:
   ```bash
   chmod -R u+r $HOME/.config/Sonarr
   ```

4. Check `.env` config path:
   ```bash
   grep SONARR_CONFIG_DIR .env
   ```

### Permission Errors

**Symptoms:**
- "Permission denied" errors
- Script can't read/write files

**Solutions:**
1. Check script permissions:
   ```bash
   ls -l whatbox-manager.sh
   chmod +x whatbox-manager.sh
   ```

2. Check directory permissions:
   ```bash
   ls -ld $HOME/apps $HOME/.config
   ```

3. Run with appropriate user (not root unless necessary)

### FZF Not Working

**Symptoms:**
- Falls back to numbered menu
- "fzf not available" warning

**Solutions:**
1. Check if fzf is installed:
   ```bash
   command -v fzf
   ```

2. Install fzf (if needed):
   ```bash
   # On Whatbox, may need to compile from source
   # Or use package manager if available
   ```

3. Script will automatically use numbered menu fallback

### JSON Parsing Issues

**Symptoms:**
- JSON output malformed
- jq fails to parse

**Solutions:**
1. Verify JSON output:
   ```bash
   ./whatbox-manager.sh --status --json | jq .
   ```

2. Check for special characters in app names/paths

3. Use `--verbose` to see raw output

### Logging Issues

**Symptoms:**
- No log file created
- Can't write to log directory

**Solutions:**
1. Check log directory exists:
   ```bash
   ls -ld logs/agent
   ```

2. Create if missing:
   ```bash
   mkdir -p logs/agent
   ```

3. Check permissions:
   ```bash
   chmod -R u+w logs/
   ```

4. Verify log file:
   ```bash
   tail -f logs/agent/whatbox-manager.log
   ```

## Debugging Tips

### Enable Debug Mode
```bash
./whatbox-manager.sh --status --debug
```

### Check Logs
```bash
tail -n 100 logs/agent/whatbox-manager.log
```

### Verbose Output
```bash
./whatbox-manager.sh --start sonarr --verbose
```

### Test Individual Components
```bash
# Test detection only
./whatbox-manager.sh --list

# Test specific app
./whatbox-manager.sh --status sonarr --verbose

# Test start without actually starting
# (check what would happen)
```

## Environment Issues

### .env File Problems

**Symptoms:**
- "Failed to load .env file"
- Missing configuration keys

**Solutions:**
1. Verify .env exists:
   ```bash
   ls -la .env
   ```

2. Check syntax:
   ```bash
   # No spaces around =
   CORRECT: KEY=value
   WRONG: KEY = value
   ```

3. Recreate from template:
   ```bash
   cp .env.example .env
   # Edit as needed
   ```

4. Check for special characters:
   ```bash
   cat .env | grep -v '^#' | grep -v '^$'
   ```

### Variable Expansion Issues

**Symptoms:**
- Paths not expanding correctly
- `$HOME` shows literally

**Solutions:**
1. Use quotes in .env:
   ```bash
   SONARR_DIR="$HOME/apps/sonarr"
   ```

2. Or use full paths:
   ```bash
   SONARR_DIR=/home/username/apps/sonarr
   ```

## Performance Issues

### Slow Detection

**Symptoms:**
- Status check takes too long
- Timeouts occur

**Solutions:**
1. Reduce timeout values in `.env`:
   ```bash
   CHECK_TIMEOUT=3
   ```

2. Disable unnecessary checks:
   - Skip API checks if not needed
   - Reduce port check frequency

3. Check system load:
   ```bash
   top
   ```

## Getting Help

### Collect Debug Information
```bash
# Create debug report
{
  echo "=== System Info ==="
  uname -a
  echo ""
  echo "=== Bash Version ==="
  bash --version
  echo ""
  echo "=== Dependencies ==="
  command -v fzf && echo "fzf: OK" || echo "fzf: MISSING"
  command -v jq && echo "jq: OK" || echo "jq: MISSING"
  command -v curl && echo "curl: OK" || echo "curl: MISSING"
  echo ""
  echo "=== Environment ==="
  cat .env | head -20
  echo ""
  echo "=== Recent Logs ==="
  tail -n 50 logs/agent/whatbox-manager.log
} > debug-report.txt
```

### Check Script Integrity
```bash
# Verify script syntax
bash -n whatbox-manager.sh

# Test with strict mode
bash -x whatbox-manager.sh --status 2>&1 | head -50
```

