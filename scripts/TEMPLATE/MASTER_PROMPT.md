**Project:** Whatbox App Manager
**Repository:** Dedicated Whatbox utility repo
**Scope:** All work must remain strictly inside:
`/scripts/whatbox-manager/`, `/docs/whatbox-manager/`, and `/logs/agent/`.

---

## **Core Directives**

* Cursor must operate **fully autonomously**, requiring **no user prompts or confirmations**.
* Cursor must **always apply and obey** every rule defined in:
  `.cursor/rules/*.mcr`
* The `.mcr` files are authoritative. Cursor’s behavior must align strictly with them.
* All development activity must remain limited to this specific script and its supporting ecosystem.
* After ~500 characters of new code, Cursor must perform internal self-review for:
  security, stability, POSIX compliance, efficiency, and error safety.

---

## **Primary Objective**

Build, maintain, and autonomously improve a fully robust Whatbox App Manager Bash script capable of:

1. Auto-detecting Whatbox applications (radarr, sonarr, prowlarr, lidarr, jellyfin, etc).
2. Checking binaries, config paths, log paths, running PIDs, and port status.
3. Presenting a color-formatted, readable status dashboard.
4. Using **FZF** as the primary selector for choosing apps and actions.

   * Fallback to a numbered menu if fzf is unavailable.
5. Interacting entirely through command flags (`--status`, `--all`, `--start`, `--stop`, `--list`, `--json`, `--verbose`, `--debug`).
6. Maintaining a validated `.env` containing ports, paths, config locations, log directories, and app metadata.

   * Auto-generate or repair `.env` if missing or malformed.
7. Handling errors gracefully, never exiting abruptly unless critical system utilities are missing.
8. Logging every internal action, decision, fallback, and failure recovery into `logs/agent/`.
9. Maintaining full documentation inside `docs/whatbox-manager/`
   (architecture, usage, setup, examples, troubleshooting, changelog).
10. Ensuring code is idempotent, stable, secure, and compatible with typical Whatbox environments.

---

## **Operational Requirements**

* Cursor must never ask the user what to do next.
* Cursor must infer all goals from this prompt + `.mcr` rule files.
* Cursor must continuously:

  * Harden error handling
  * Improve formatting
  * Strengthen dependency detection and fallbacks
  * Enhance internal logging
  * Validate configuration data
  * Keep documentation accurate
* All logs must be timestamped and categorized.
* Color output must degrade automatically when unsupported.
* JSON output mode must produce machine-parseable JSON without formatting.

---

## **Expected Maintained Files**

Cursor must maintain and keep updated:

* `scripts/whatbox-manager/whatbox-manager.sh`
* `scripts/whatbox-manager/.env`
* `scripts/whatbox-manager/README.md`
* `docs/whatbox-manager/*.md`
* `logs/agent/*.log`

Cursor must also create missing folders when required.

---

## **Execution Directive**

On initialization:

1. Scan the repository to understand current state.
2. Ensure `.env` exists and populate it with required keys.
3. Implement or refine FZF-driven selection logic.
4. Implement or refine graceful fallbacks for:

   * missing fzf
   * missing jq
   * missing curl
   * missing tput
5. Implement robust detection for all Whatbox apps.
6. Improve error handling, logging, output formatting, and internal tooling.
7. Generate or update all documentation in `docs/whatbox-manager/`.
8. Maintain continuous compliance with all `.mcr` rule files.
9. Continue iterating until the script is stable, hardened, documented, and reliable.

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
