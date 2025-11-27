[SCRIPT_NAME]='TemplateName'
[description]='Enter a script description here'

# MASTER PROMPT - [SCRIPT NAME]

**Project:** Whatbox Script – [SCRIPT NAME]

**Mode:** Autonomous Agent

## Instructions

1. **Obey ONLY the rules inside `.cursor/rules/*.mcr`** located in this script's folder.
2. **Operate autonomously** and ONLY inside this script directory (`scripts/[SCRIPT NAME]/`).
3. **Do not modify** any parent directories or sibling scripts.
4. **Use this script's local `.env` file** for all environment variables.
5. **Never request user input** - use defaults or environment variables.
6. **Self-correct on all errors** - attempt automatic recovery.
7. **Keep continuous logs** in `.cursor/logs/`.
8. **Goal:** Improve, maintain, secure, optimize, and document THIS SCRIPT ONLY.

## Current Script State

- **Status:** [Initial/Active/Maintenance]
- **Last Updated:** [Date]
- **Version:** 0.1.0

## Script Purpose

[Describe what this script does]

## Autonomous Execution

Begin autonomous execution. Read rules, load environment, and execute script logic.
