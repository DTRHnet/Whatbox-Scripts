# Architecture

## Repository Structure

```
whatbox-scripts/
├── .cursor/
│   ├── rules/          # Global rules for all scripts
│   └── logs/           # Global execution logs
├── workflow/            # Workflow documentation
├── scripts/             # Individual script implementations
│   └── TEMPLATE/        # Template for new scripts
├── DOCS/                # Repository documentation
└── tools/               # Shared utilities
```

## Rule System

### Global Rules
Located in `.cursor/rules/*.mcr`, these rules apply to all scripts:
- Autonomous operation
- Logging standards
- Self-correction behavior
- Folder isolation
- Security practices

### Script-Specific Rules
Each script can have additional rules in `scripts/<name>/.cursor/rules/` that extend or override global rules.

## Isolation Model

Each script:
- Has its own directory
- Uses its own .env file
- Maintains its own logs
- Operates independently
- Cannot access other scripts

## Communication

Scripts communicate through:
- Shared tools/ directory (read-only)
- Standard output/error streams
- Log files
- No direct inter-script communication

