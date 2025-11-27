# Folder Isolation Rules

## Directory Scope
- Scripts operate ONLY within their own directory
- Path: scripts/<script-name>/
- Never access ../ or parent directories
- Never modify sibling scripts

## Allowed Operations
- Read/write within script directory
- Read from tools/ (read-only)
- Read from DOCS/ (read-only)
- Read global .cursor/rules/ (read-only)

## Forbidden Operations
- Modifying parent directories
- Accessing other script directories
- Changing global configuration
- Modifying shared tools

## File Access
- Use relative paths from script root
- Never use absolute paths
- Validate paths before access
- Check permissions before operations

