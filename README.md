# Whatbox Scripts

A repository of autonomous, isolated scripts designed to operate as independent Cursor agents. Each script maintains its own configuration, rules, and environment.

## 🏗️ Architecture

- **Isolated Scripts**: Each script in `scripts/` operates autonomously with its own `.cursor/rules/`, `.env`, and documentation
- **Global Rules**: Shared rules in `.cursor/rules/` define common autonomous behavior
- **Template-Based**: New scripts are created from `scripts/TEMPLATE/`

## 📁 Structure

```
whatbox-scripts/
├── .cursor/
│   ├── rules/          # Global autonomous agent rules
│   └── logs/           # Global execution logs
├── workflow/            # Workflow documentation
├── scripts/             # Individual script folders
│   └── TEMPLATE/        # Template for new scripts
├── DOCS/                # Repository documentation
└── tools/               # Utility scripts
```

## 🚀 Quick Start

### Create a New Script

```bash
cp -r scripts/TEMPLATE scripts/my-new-script
cd scripts/my-new-script
# Edit .env.example and rename to .env
# Edit README.md and MASTER_PROMPT.md
```

### Sync Global Rules to All Scripts

```bash
./tools/update-rules.sh
# Or on Windows:
./tools/update-rules.ps1
```

## 📚 Documentation

- [Overview](DOCS/overview.md)
- [Architecture](DOCS/architecture.md)
- [Autonomous Behavior](DOCS/autonomous-behavior.md)
- [Setup Guide](DOCS/setup.md)

## 🔒 Security

- Each script uses its own `.env` file
- Never commit `.env` files
- Use `.env.example` as templates

## 📝 License

MIT License - See LICENSE file for details

