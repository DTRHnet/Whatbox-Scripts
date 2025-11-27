# **WHATBOX APP MANAGER**

## **Overview**

The **Whatbox App Manager** is a command-line utility designed to monitor, control, diagnose, and maintain all supported Whatbox applications (e.g., Sonarr, Radarr, Prowlarr, Jellyfin, Lidarr, etc.).
It provides a single command that gracefully handles process detection, port conflicts, broken symlinks, corrupted configs, and service restarts—while giving you a clean fzf-driven UI to choose the apps you want to manage.

The tool is engineered for **stability, safety, robustness, and autonomous error recovery**.

---

# **Core Capabilities**

### **1. Application State Detection**

The script performs real-time detection of:

* Whether the application binary is currently running
* Whether its expected port is free or occupied
* Whether config directories exist and are readable
* Whether symlinks in `~/apps/<appname>/` point to valid files
* Whether essential startup scripts exist and are executable
* Whether log directories are present

Detection is modular, allowing easy extension for new apps.

---

### **2. Auto-Discovery of Installed Applications**

Instead of relying on a hard-coded list, the script:

* Scans `~/apps/`
* Cross-references detected folders against supported apps
* Checks for binary activity with `pgrep`
* Verifies each app’s start script and required config folders

If it appears on Whatbox and acts like an app, the manager will find it.

---

### **3. fzf-Based Selection Menu**

The script presents an interactive menu where you can:

* Select a single application
* Select multiple applications
* Select “all applications available”
* View detailed, real-time preview information
* Inspect state, ports, processes, and issues immediately

The preview pane shows **running status, port status, binary path, and config directory health**.

---

### **4. Graceful Start/Stop Operations**

App control is extremely defensive:

* Start operations verify the port is free, configs exist, binaries run properly, and retries occur on transient errors.
* Stop operations verify the process exists before attempting termination.
* Multi-app operations run apps sequentially with full error protection per app.
* Failures are logged and do not interrupt the management of other apps.

---

### **5. Error Handling & Safety Features**

The script includes robust fault-tolerance for common Whatbox failure conditions, such as:

* Invalid or broken symlinks
* Start scripts missing or with incorrect permissions
* Ports in use by unknown or stray processes
* Zombie or stale processes
* Misconfigured applications
* Missing databases (Radarr/Sonarr DB corruption alerts)
* Log directories removed or full
* Insufficient permissions

All errors are reported cleanly and logged without crashing the script.

---

### **6. Logging & Troubleshooting**

Every action the script performs—including failures and warnings—is logged automatically:

* Start/stop operations
* System checks
* Port conflicts
* Broken links
* Invalid configuration paths
* Missing binaries

Logs ensure you can identify where automation failed or why an app refused to start.

---

### **7. Extensible Architecture**

The script is built so you can easily add:

* New Whatbox apps
* New detection routines
* Additional process checks
* Additional port checks
* Custom health checks
* API-driven diagnostics (e.g., Radarr/Sonarr system status)

Every major function is isolated, documented, and modifiable.

---

# **Detailed Behavior & Script Guarantees**

### **The Script MUST:**

* Never crash on failure
* Never assume an app exists—always detect
* Never assume configs or logs exist—validate paths
* Always fail gracefully and continue processing others
* Always provide helpful messages
* Always log all actions
* Support fully automated operation

### **The Script SHOULD:**

* Try multiple fallback strategies for predictable errors
* Warn loudly when something is misconfigured
* Expose enough detail to troubleshoot without extra commands
* Allow future automated control (systemctl-like behavior)
* Handle unexpected data like:

  * weird ports
  * duplicated processes
  * misnamed binaries
  * missing folders

---

# **Script Workflow Summary**

### **1. Detect installed apps**

* Scan `~/apps/`
* Verify app folder
* Verify binary name
* Verify start script
* Verify configs

### **2. Build dynamic menu**

* fzf menu displays apps
* Preview shows:

  * running or stopped
  * port in use or free
  * config validity
  * binary path
  * logs status

### **3. Perform actions**

Available actions include:

* `status`
* `start`
* `stop`
* `start_all`
* `stop_all`

Each action is applied to one or more apps.

### **4. Gracefully handle failures**

If an operation fails:

* Error is displayed
* Error is logged
* Script continues safely

### **5. Complete log output**

A single log file tracks everything:

* Timestamp
* Operation
* App name
* Result
* Exit codes
* Errors

---

# **Environment Variables**

The script uses an `.env` file to store:

* App ports
* App paths
* Configuration paths
* Log paths
* Binary names
* Network tools
* Security preferences

The `.env` file must be loaded early so scripts can reference consistent parameters across all operations.

---

# **Requirements**

### **System tools**

* `bash`
* `fzf`
* `pgrep`
* `lsof`
* `curl` (optional)

### **Whatbox environment**

* Standard `~/apps/<appname>/` structure
* Valid `start.sh` per app
* Configs stored in `$HOME/.config/<AppName>/`

---

# **Usage**

Run:

```bash
./manage_media_servers.sh
```

From there:

* Choose an action
* Choose the apps
* Preview live status
* Execute operations gracefully

---

# **Development Notes**

When extending or modifying the script:

* Always update `.env`
* Never hard-code paths in the script
* Use function modularity for new checks
* Keep logging consistent
* Validate assumptions (ports, configs, binaries)
* Test handling of invalid states

Refactoring recommendations:

* Add health-check hooks
* Add backup/restore routines
* Integrate JSON API checks from Radarr/Sonarr
* Add port reassignment logic
