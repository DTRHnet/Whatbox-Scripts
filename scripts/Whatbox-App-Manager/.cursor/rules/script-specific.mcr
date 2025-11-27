 {
  "version": "1.0",
  "rules": [
    {
      "name": "Purpose",
      "description": "Defines the strict scope and purpose of the Whatbox App Manager script.",
      "content": [
        "These rules apply only to scripts/whatbox-manager/ and its documentation.",
        "Rules supplement but never override the repository-wide .cursor/rules/*.mcr files.",
        "All behavior, generation, and improvements must remain within this script's scope."
      ]
    },

    {
      "name": "Autonomous Script Behavior",
      "description": "Defines how the script must behave at runtime and during development.",
      "content": [
        "The script must run fully autonomously and never request user input.",
        "FZF is the primary UI selector. Use multi-select when supported.",
        "If FZF is missing, fallback to a text-based numbered menu.",
        "Automatically detect Whatbox applications including radarr, sonarr, lidarr, prowlarr, jellyfin, and any future supported apps.",
        "Detection must include: binary presence, PID, port status, config folder, log folder, version if available.",
        "All script output must be cleanly formatted and color-coded when supported.",
        "After every ~500 characters of generated code, the agent must self-review for POSIX safety, security, robustness, efficiency, and maintainability.",
        "Script actions must be idempotent and safe to re-run multiple times.",
        "The .env file is the authoritative source for ports, paths, configs, logs, and app-specific metadata.",
        "Missing .env keys must be created automatically with safe defaults."
      ]
    },

    {
      "name": "Error Handling",
      "description": "Defines fault-tolerance and fallback strategies.",
      "content": [
        "All external commands must be wrapped in safe error handlers.",
        "Non-critical failures may not terminate execution.",
        "If an app cannot be detected, log the failure and mark its status as Unknown or Unavailable.",
        "If a port is in use by another process, classify status as Conflict and log details.",
        "If binary, config directory, log directory, or PID is missing, continue using fallback logic.",
        "If .env is missing or malformed, auto-generate and repair it immediately.",
        "All errors must log: timestamp, component, attempted action, detected issue, recovery strategy.",
        "Critical dependency failure must exit gracefully with a clear message."
      ]
    },

    {
      "name": "Logging Requirements",
      "description": "Defines how logging must be performed.",
      "content": [
        "All internal decisions must be logged to logs/agent/.",
        "Log categories: dependency-check, app-detection, fallback-used, port-probe, pid-check, env-repair, conflict-detected.",
        "Logs must be timestamped with precise granularity.",
        "The logs directory must auto-create itself if missing.",
        "Verbose mode logs resolved paths, commands, fallbacks, environment interpretations.",
        "Debug mode logs executed commands, raw outputs, exit codes, stack traces.",
        "JSON mode must not log anything other than JSON output.",
        "Sensitive data (tokens, credentials, private URLs) must never be logged.",
        "Logs must rotate automatically when exceeding a defined size threshold."
      ]
    },

    {
      "name": "Dependency Handling",
      "description": "Defines required and optional dependencies and fallback logic.",
      "content": [
        "Required core tools: bash, coreutils, ss or lsof or netstat.",
        "Preferred tools: fzf, jq, curl.",
        "If fzf is missing, fallback to numeric menu with warnings.",
        "If jq is missing, use raw text parsing.",
        "If curl is missing, fallback to wget.",
        "If tput is missing, disable color output automatically.",
        "Missing dependencies must never cause fatal termination except for core shell utilities.",
        "The script must auto-detect OS and shell capabilities and adapt behavior accordingly."
      ]
    }
  ]
}
