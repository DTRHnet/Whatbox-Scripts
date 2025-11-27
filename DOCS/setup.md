# Setup Guide

## Prerequisites
- Cursor IDE
- Git
- [Add other prerequisites]

## Installation

### 1. Clone Repository
```bash
git clone [repository-url]
cd whatbox-scripts
```

### 2. Create a New Script
```bash
cp -r scripts/TEMPLATE scripts/my-script
cd scripts/my-script
```

### 3. Configure Environment
```bash
cp .env.example .env
# Edit .env with your configuration
```

### 4. Sync Rules (Optional)
```bash
./tools/update-rules.sh
# Or on Windows:
./tools/update-rules.ps1
```

## Configuration

### Global Configuration
- Edit `.cursor/rules/*.mcr` for global behavior
- Modify `workflow/*.md` for workflow changes

### Script Configuration
- Edit `scripts/<name>/.env` for script-specific settings
- Modify `scripts/<name>/.cursor/rules/` for script-specific rules
- Update `scripts/<name>/README.md` for documentation

## Running Scripts

### Autonomous Mode
Scripts run automatically when opened in Cursor with the MASTER_PROMPT.md file.

### Manual Execution
[Add manual execution instructions based on script type]

## Troubleshooting

### Common Issues
1. **Missing .env file**: Copy .env.example to .env
2. **Permission errors**: Check file permissions
3. **Rule conflicts**: Check script-specific rules

### Getting Help
- Check script's README.md
- Review .cursor/logs/ for errors
- Consult DOCS/ documentation

