# Logging Rules

## Log Location
- All logs go to .cursor/logs/ directory
- Use timestamped log files
- Format: YYYY-MM-DD-HH-MM-SS.log

## What to Log
- All script executions
- Error conditions and resolutions
- Configuration changes
- Performance metrics
- User actions (if applicable)

## Log Format
[TIMESTAMP] [LEVEL] [MODULE] MESSAGE
- TIMESTAMP: ISO 8601 format
- LEVEL: DEBUG, INFO, WARN, ERROR
- MODULE: Component name
- MESSAGE: Human-readable description

## Log Retention
- Keep logs for 30 days
- Archive older logs
- Never log sensitive data (passwords, tokens)

