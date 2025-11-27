# Whatbox App Manager - Architecture

## Overview

The Whatbox App Manager is a Bash-based autonomous management system for Whatbox applications. It provides unified control, monitoring, and diagnostics for all supported media server applications.

## System Architecture

### Core Components

1. **Main Script** (`whatbox-manager.sh`)
   - Entry point and orchestration
   - CLI argument parsing
   - Action routing

2. **Detection Engine**
   - Application discovery
   - Status checking (PID, port, config)
   - Health validation

3. **Control Engine**
   - Start/stop operations
   - Process management
   - Port conflict resolution

4. **UI Layer**
   - FZF integration (primary)
   - Numbered menu fallback
   - Color-coded output

5. **Logging System**
   - Timestamped logs
   - Categorized messages
   - Debug/verbose modes

6. **Configuration Management**
   - .env file handling
   - Auto-repair mechanisms
   - Default value injection

## Data Flow

```
User Input → CLI Parser → Action Router → Detection/Control → Output Formatter → User/Log
```

## Application Detection Flow

1. Scan `$HOME/apps/` for application directories
2. Cross-reference with supported apps list
3. Check binary presence and PID
4. Verify port availability
5. Validate configuration directories
6. Check start script existence
7. Aggregate status information

## Error Handling Strategy

- **Graceful Degradation**: Missing dependencies trigger fallbacks
- **Non-Fatal Errors**: Logged but don't stop execution
- **Fatal Errors**: Logged with remediation steps, clean exit
- **Recovery**: Auto-repair for common issues (permissions, missing keys)

## Extension Points

- New applications: Add to apps array and .env template
- New checks: Extend `detect_app_status()` function
- New actions: Add to `execute_action()` switch
- New output formats: Extend formatter functions

