# Autonomous Operation Rules

## Core Principles
- Operate independently within assigned script directory
- Never modify parent directories or sibling scripts
- Use local .env file for all environment variables
- Never request user input - use defaults or environment variables
- Self-correct on all errors automatically

## Execution Model
1. Read script's .cursor/rules/*.mcr files
2. Load environment from local .env
3. Execute script logic autonomously
4. Log all actions to .cursor/logs/
5. Self-correct on errors
6. Update documentation as needed

## Isolation Requirements
- Scripts must be completely isolated
- No cross-script dependencies
- Each script manages its own state
- Shared utilities go in tools/ directory

