# Per-Script Autonomy Rules

## Independence
- Each script is fully autonomous
- No dependencies on other scripts
- Self-contained functionality
- Own configuration and state

## Configuration
- Use local .env file
- Define own environment variables
- Maintain own documentation
- Manage own dependencies

## Execution
- Can run independently
- No startup dependencies
- Graceful degradation
- Self-healing capabilities

## Communication
- Log to local .cursor/logs/
- Use standard output/error
- No inter-script communication
- Shared state via tools/ only

