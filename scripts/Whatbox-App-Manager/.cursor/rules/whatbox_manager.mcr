{
  "version": "1.0",
  "rules": [
    {
      "name": "General Behavior",
      "description": "Non-interactive execution unless critical config missing. Continue with fallbacks when possible.",
      "content": [
        "Script must run autonomously without user interaction except when critical configuration is missing.",
        "If data is missing but not critical, warn and continue with fallback logic.",
        "If a critical component is missing, log the error, show remediation steps, and exit cleanly.",
        "All actions must be idempotent and safe to re-run."
      ]
    },
    {
      "name": "Dependency Handling",
      "description": "Graceful detection and fallback logic.",
      "content": [
        "Detect required binaries via command -v, which, or direct filesystem checks.",
        "If a dependency is missing, show a yellow warning, suggest install commands, but never crash.",
        "Fallback rules:",
        "• Missing curl → use wget.",
        "• Missing jq → fallback to raw parsing.",
        "• Missing tput → disable color output.",
        "• Missing Whatbox app directory → mark status as Unavailable."
      ]
    },
    {
      "name": "Error Handling",
      "description": "Zero unhandled failures.",
      "content": [
        "Every command with a failure path must be wrapped in handler blocks.",
        "Use structured exit codes: 0=ok, 1=fatal, 2=partial, 3=recovered-missing-dep, 4=invalid-arg.",
        "If a status probe fails, mark the app status Unknown and continue.",
        "If .env is missing, auto-generate it, warn, and continue."
      ]
    },
    {
      "name": "Color and Formatting",
      "description": "Strict formatting for readable output.",
      "content": [
        "Colors (if supported): green=success, red=error, yellow=warning, blue=header, cyan=paths.",
        "Use consistent two-space indentation.",
        "Format all tables with padded columns.",
        "Use horizontal rules to divide output sections."
      ]
    },
    {
      "name": "Verbose and Debug Modes",
      "description": "Controlled, consistent verbosity.",
      "content": [
        "Default mode = concise human output.",
        "Verbose mode must show dependency checks, resolved paths, missing items, and fallback triggers.",
        "Debug mode must show executed commands, exit codes, stack traces, and environment dumps (excluding secrets)."
      ]
    },
    {
      "name": "App Detection Logic",
      "description": "Unified detection and classification system.",
      "content": [
        "Detect apps by checking: config directory, binary directory, PID, port availability, version file.",
        "Status rules:",
        "1. Port open → Running",
        "2. PID running → Running",
        "3. Folder exists but no PID → Stopped",
        "4. Port used by foreign process → Conflict",
        "5. Folder missing → Unavailable",
        "Collect metadata: version, config path, log path, install path, last-modified timestamp."
      ]
    },
    {
      "name": "Environment and Config Rules",
      "description": "Self-healing configuration management.",
      "content": [
        "Script must auto-load .env.",
        "Validate every key.",
        "If a key is missing, auto-create it with defaults.",
        "Malformed values are replaced with defaults and a warning is emitted.",
        "Write repaired values back to .env immediately."
      ]
    },
    {
      "name": "CLI Behavior",
      "description": "Unified behavior for all flags and execution modes.",
      "content": [
        "Supported flags: --verbose, --debug, --json, --list, --status APP, --start APP, --stop APP.",
        "JSON mode outputs machine-readable structured data only.",
        "Invalid flags must trigger exit code 4."
      ]
    },
    {
      "name": "Self-Integrity Validation",
      "description": "Health checks before execution.",
      "content": [
        "Validate working directory structure.",
        "Validate .env integrity.",
        "Detect OS and shell capabilities.",
        "If running in a Git repo, detect branch, uncommitted changes, and outdated code."
      ]
    },
    {
      "name": "Performance and Safety",
      "description": "Ensure efficiency and prevent breakage.",
      "content": [
        "Avoid unnecessary subshells.",
        "No infinite loops.",
        "Timeout all network operations.",
        "Cache repetitive results.",
        "Limit probing to safe I/O operations.",
        "No destructive commands unless explicitly requested with --start or --stop operations."
      ]
    }
  ]
}