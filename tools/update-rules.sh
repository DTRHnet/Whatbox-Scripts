#!/bin/bash

# Update Rules Script
# Syncs global .cursor/rules/*.mcr to all scripts' .cursor/rules/ directories

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOBAL_RULES_DIR="$REPO_ROOT/.cursor/rules"
SCRIPTS_DIR="$REPO_ROOT/scripts"

echo "🔄 Syncing global rules to all scripts..."

# Check if global rules directory exists
if [ ! -d "$GLOBAL_RULES_DIR" ]; then
    echo "❌ Error: Global rules directory not found: $GLOBAL_RULES_DIR"
    exit 1
fi

# Find all script directories
find "$SCRIPTS_DIR" -mindepth 1 -maxdepth 1 -type d ! -name "TEMPLATE" | while read -r script_dir; do
    script_name=$(basename "$script_dir")
    script_rules_dir="$script_dir/.cursor/rules"
    
    # Create .cursor/rules directory if it doesn't exist
    mkdir -p "$script_rules_dir"
    
    echo "📋 Syncing rules to: $script_name"
    
    # Copy all .mcr files from global rules
    cp -v "$GLOBAL_RULES_DIR"/*.mcr "$script_rules_dir/" 2>/dev/null || {
        echo "⚠️  Warning: No .mcr files found in global rules directory"
    }
    
    echo "✅ Rules synced to $script_name"
done

echo "✨ Rule sync complete!"

