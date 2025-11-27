# Whatbox App Manager - Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-26

### Added
- Initial release of Whatbox App Manager
- Support for 9 Whatbox applications:
  - Sonarr
  - Radarr
  - Prowlarr
  - Lidarr
  - Readarr
  - Whisparr
  - Jellyfin
  - Emby
  - Plex
- Application detection system
  - Auto-discovery of installed apps
  - PID detection
  - Port status checking
  - Configuration validation
  - Start script verification
- Application control
  - Start applications
  - Stop applications (graceful + force)
  - Status checking
- CLI interface
  - `--status` flag
  - `--start` flag
  - `--stop` flag
  - `--list` / `--all` flags
  - `--json` output mode
  - `--verbose` mode
  - `--debug` mode
  - Interactive mode
- FZF integration
  - Interactive selection with preview
  - Multi-select support
  - Fallback to numbered menu
- Error handling
  - Graceful dependency fallbacks
  - Auto-repair for .env file
  - Non-fatal error continuation
  - Comprehensive logging
- Logging system
  - Timestamped logs
  - Categorized messages (INFO, WARN, ERROR, DEBUG)
  - Log file rotation support
- Configuration management
  - .env file support
  - Auto-validation
  - Auto-repair with defaults
  - Template-based setup
- Color output
  - Color-coded status indicators
  - Automatic fallback for non-color terminals
- Documentation
  - Architecture documentation
  - Usage guide
  - Setup instructions
  - Examples
  - Troubleshooting guide

### Security
- Input validation
- Safe path handling
- Permission checks
- No hardcoded secrets

### Performance
- Efficient process detection
- Cached dependency checks
- Timeout controls
- Minimal resource usage

## [Unreleased]

### Planned
- API health checks for *arr applications
- Backup/restore functionality
- Port reassignment logic
- Systemd integration
- Webhook notifications
- Metrics collection
- Remote management support

