# Security Review Branch Changes Summary

**Branch:** `feature/security-review`  
**Base:** `master`  
**Commits:** 4 commits ahead of master

## Overview

This feature branch implements comprehensive security fixes (PR #18) along with several feature additions and refactorings. The changes are significant and include **breaking changes** that will affect existing implementations.

---

## 🔴 BREAKING CHANGES

### 1. Command-Line Interface Changes

#### Removed Flags:
- `--unattended` / `-u` → **REMOVED**
- `--prpc-public` → **REMOVED**
- `--prpc-private` → **REMOVED**
- `--debug` → **REMOVED**

#### New/Changed Flags:
- `--non-interactive` / `-n` → **NEW** (replaces `--unattended`)
- `--prpc-mode MODE` → **NEW** (replaces `--prpc-public`/`--prpc-private`)
  - Values: `public` or `private`
- `--default-keypair` → **NEW** (explicit flag to use default keypair path)
- `--atlas-cluster CLUSTER` → **NEW** (required in non-interactive mode)
  - Values: `trynet`, `devnet`, or `mainnet-alpha`
  - Default: `devnet`
- `--log-path PATH` → **NEW** (optional, defaults to `/opt/xandminer/pod-logs/pod.log`)

#### Migration Guide:

**OLD (master branch):**
```bash
sudo bash install.sh --unattended --install --keypair-path /root/my-keypair.json --prpc-public
```

**NEW (feature/security-review branch):**
```bash
sudo bash install.sh --non-interactive --install --keypair-path /local/keypairs/my-keypair.json --prpc-mode public --atlas-cluster devnet
```

**OLD:**
```bash
sudo bash install.sh -u --update --prpc-private
```

**NEW:**
```bash
sudo bash install.sh --non-interactive --update --prpc-mode private --atlas-cluster devnet
```

### 2. Installation Directory Change

**BREAKING:** Installation location changed from `/root` to `/opt/xandminer`

- **Old:** `/root/xandminer` and `/root/xandminerd`
- **New:** `/opt/xandminer/xandminer` and `/opt/xandminer/xandminerd`

**Impact:**
- Existing installations in `/root` will NOT be automatically migrated
- New installations will use `/opt/xandminer`
- Scripts referencing `/root/xandminer*` will break
- Service files updated to use new paths

### 3. Service User Change

**BREAKING:** Services now run as non-privileged user `xand` instead of `root`

- New user `xand` is created automatically
- User has home directory: `/opt/xandminer`
- All services (xandminer, xandminerd, pod) run as `xand` user
- This is a security improvement but may affect file permissions

**Impact:**
- Existing installations running as root will need migration
- File ownership/permissions may need adjustment
- Log files owned by `xand` user

### 4. Service File Generation

**BREAKING:** Service files are now generated inline instead of downloaded from GitHub

- Old: Downloaded `xandminer.service` and `xandminerd.service` from GitHub
- New: Service files generated inline in the script
- More secure (no external dependencies for service files)

---

## ✅ Security Improvements

### 1. Non-Privileged Service User
- Created `xand` user with `/usr/sbin/nologin` shell
- All services run as `xand` instead of `root`
- Prevents privilege escalation attacks

### 2. Input Sanitization
- Added `sanitize_branch_name()` function
- Added `sanitize_version()` function  
- Added `sanitize_path()` function
- Prevents command injection attacks

### 3. Secure Temp File Handling
- Uses `mktemp` for temporary files
- Proper cleanup of temporary files
- Prevents temp file race conditions

### 4. Keypair File Permissions
- Sets `chmod 600` on keypair files
- Proper ownership (xand user)
- Prevents unauthorized access to keys

### 5. Installation Directory Security
- Moved from `/root` to `/opt/xandminer` (Linux FHS compliance)
- Better separation of concerns
- Reduces risk of accidental root directory modification

### 6. Inline Service File Generation
- No longer downloads service files from external source
- Reduces attack surface
- Ensures service files match script version

---

## 🆕 New Features

### 1. Atlas Cluster Selection
- New `--atlas-cluster` flag
- Supports: `trynet`, `devnet`, `mainnet-alpha`
- Default: `devnet`
- Required in non-interactive mode

### 2. Custom Log Path
- New `--log-path` flag
- Default: `/opt/xandminer/pod-logs/pod.log`
- Allows custom log file locations

### 3. Logrotate Configuration (Optional)
- **Optional** automatic logrotate setup for pod logs
- User must explicitly enable with `--enable-logrotate` flag
- Interactive mode prompts with clear explanation and warnings
- Configurable retention period (default: 7 days)
- Prevents log files from growing unbounded
- Respects compliance/audit requirements
- Configured in `/etc/logrotate.d/xandeum-pod`
- See `LOGROTATE_CHANGES.md` for detailed information

### 4. Improved Non-Interactive Mode
- More explicit flag requirements
- Better validation of required parameters
- Clearer error messages

---

## 📋 Files Changed

- **install.sh**: Complete refactoring (653 insertions, 504 deletions)

---

## 🧪 Testing Checklist

### Critical Tests:

1. **CLI Flag Compatibility**
   - [ ] Test old `--unattended` flag (should fail gracefully)
   - [ ] Test new `--non-interactive` flag
   - [ ] Test `--prpc-mode public` and `--prpc-mode private`
   - [ ] Test `--atlas-cluster` with all three values
   - [ ] Test `--default-keypair` flag
   - [ ] Test `--log-path` with custom path

2. **Installation Directory**
   - [ ] Verify installation creates `/opt/xandminer` directory
   - [ ] Verify repositories cloned to `/opt/xandminer/xandminer` and `/opt/xandminer/xandminerd`
   - [ ] Verify services reference correct paths
   - [ ] Test upgrade from existing `/root` installation (if applicable)

3. **Service User**
   - [ ] Verify `xand` user is created
   - [ ] Verify services run as `xand` user
   - [ ] Verify file permissions are correct
   - [ ] Verify log files are accessible

4. **Security Features**
   - [ ] Test input sanitization with malicious branch names
   - [ ] Test input sanitization with malicious paths
   - [ ] Verify keypair files have `chmod 600`
   - [ ] Verify temp files are cleaned up
   - [ ] Test service file generation (no external downloads)

5. **New Features**
   - [ ] Test Atlas cluster selection (trynet, devnet, mainnet-alpha)
   - [ ] Test custom log path
   - [ ] Verify logrotate configuration is created
   - [ ] Test pod version selection in dev mode

6. **Backward Compatibility**
   - [ ] Test interactive mode (should still work)
   - [ ] Test dev mode branch selection
   - [ ] Test upgrade path from master branch installations

7. **Service Functionality**
   - [ ] Verify xandminer service starts correctly
   - [ ] Verify xandminerd service starts correctly
   - [ ] Verify pod service starts correctly
   - [ ] Test service restart functionality
   - [ ] Test service stop/disable functionality

---

## 📝 Commit History

1. **0fbe5fe** - Security review: Implement PR #18 security fixes
2. **7cac73b** - Fix pod version selection in non-dev mode
3. **9ed1e11** - Add logrotate configuration for pod logs
4. **404ae5d** - Add cluster chooser and comprehensive features

---

## ⚠️ Migration Notes

### 🔴 CRITICAL: Migration Not Automatic

**The installer does NOT automatically migrate from `/root` to `/opt`.**

If you have an existing installation, you'll end up with TWO installations:
- Old: `/root/xandminer` and `/root/xandminerd` (orphaned, still there)
- New: `/opt/xandminer/xandminer` and `/opt/xandminer/xandminerd` (fresh install)

**See `MIGRATION_GUIDE.md` for complete migration instructions.**

### Quick Migration Steps:

1. **Backup current installation:**
   ```bash
   sudo cp -r /root/xandminer /root/xandminer.backup.$(date +%Y%m%d)
   sudo cp -r /root/xandminerd /root/xandminerd.backup.$(date +%Y%m%d)
   ```

2. **Stop and disable old services:**
   ```bash
   sudo systemctl stop xandminer.service xandminerd.service pod.service
   sudo systemctl disable xandminer.service xandminerd.service pod.service
   sudo rm /etc/systemd/system/{xandminer,xandminerd,pod}.service
   sudo systemctl daemon-reload
   ```

3. **Migrate keypair:**
   ```bash
   sudo mkdir -p /local/keypairs
   sudo cp /root/xandminerd/keypairs/pnode-keypair.json /local/keypairs/
   sudo chmod 600 /local/keypairs/pnode-keypair.json
   ```

4. **Remove old directories:**
   ```bash
   sudo rm -rf /root/xandminer
   sudo rm -rf /root/xandminerd
   ```

5. **Run new installer:**
   ```bash
   sudo bash install.sh --non-interactive --install \
     --keypair-path /local/keypairs/pnode-keypair.json \
     --prpc-mode private \
     --atlas-cluster devnet
   ```

6. **Update automation scripts:**
   - Replace `--unattended` with `--non-interactive`
   - Replace `--prpc-public` with `--prpc-mode public`
   - Replace `--prpc-private` with `--prpc-mode private`
   - Add `--atlas-cluster` flag (required)
   - Update paths from `/root` to `/opt/xandminer`

---

## 🔍 Key Differences Summary

| Aspect | Master Branch | Security Review Branch |
|--------|--------------|------------------------|
| Installation Dir | `/root` | `/opt/xandminer` |
| Service User | `root` | `xand` (non-privileged) |
| Unattended Flag | `--unattended` | `--non-interactive` |
| pRPC Flags | `--prpc-public` / `--prpc-private` | `--prpc-mode MODE` |
| Atlas Cluster | Not configurable | `--atlas-cluster CLUSTER` |
| Log Path | `/root/pod-logs/pod.log` | `/opt/xandminer/pod-logs/pod.log` |
| Service Files | Downloaded from GitHub | Generated inline |
| Input Validation | None | Sanitized |
| Temp Files | Basic | Secure (mktemp + cleanup) |
| Keypair Permissions | Default | `chmod 600` |

---

## 📞 Questions to Answer During Testing

1. Will existing automation scripts break? **YES** - CLI flags changed
2. Will existing installations break? **POTENTIALLY** - if paths hardcoded
3. Are services backward compatible? **NO** - user and paths changed
4. Can we upgrade from master? **YES** - but requires manual steps
5. Is data migration needed? **YES** - if upgrading existing installs

---

**Generated:** $(date)  
**Branch:** feature/security-review  
**Base:** master

