# Migration Guide: /root to /opt Installation

## ⚠️ CRITICAL ISSUE DISCOVERED

The security review branch installer does **NOT** automatically migrate existing installations from `/root` to `/opt`.

### What Happens Now

1. **Installer changes to `/opt`:** `INSTALL_BASE="/opt"`
2. **Checks for repos:** `if [ -d "xandminer" ] && [ -d "xandminerd" ]`
3. **BUT:** This check happens AFTER `cd "$INSTALL_BASE"` (i.e., in `/opt/`)
4. **Result:** Doesn't find your old `/root/xandminer` and `/root/xandminerd`
5. **Outcome:** Does a FRESH install in `/opt/`, leaving old directories orphaned

### The Problem

If you have an existing installation in `/root/`:

```
/root/xandminer/          ← Old installation (still there)
/root/xandminerd/         ← Old installation (still there)

/opt/xandminer/xandminer/     ← New installation (fresh clone)
/opt/xandminer/xandminerd/    ← New installation (fresh clone)
```

**Issues:**
- ❌ Two copies of the code (wasting disk space)
- ❌ Old service files still reference `/root/` paths
- ❌ Potential conflicts between old and new services
- ❌ Confusion about which installation is active
- ❌ Old keypairs might not be migrated

---

## 🔴 RECOMMENDATION: Manual Migration Required

### Option 1: Clean Migration (Recommended)

**Step 1: Backup current installation**
```bash
# Backup old directories
sudo cp -r /root/xandminer /root/xandminer.backup.$(date +%Y%m%d)
sudo cp -r /root/xandminerd /root/xandminerd.backup.$(date +%Y%m%d)

# Backup keypair if it exists
sudo cp -r /root/xandminerd/keypairs /root/keypairs.backup.$(date +%Y%m%d)
```

**Step 2: Stop old services**
```bash
sudo systemctl stop xandminer.service
sudo systemctl stop xandminerd.service
sudo systemctl stop pod.service
sudo systemctl disable xandminer.service
sudo systemctl disable xandminerd.service
sudo systemctl disable pod.service
```

**Step 3: Remove old service files**
```bash
sudo rm /etc/systemd/system/xandminer.service
sudo rm /etc/systemd/system/xandminerd.service
sudo rm /etc/systemd/system/pod.service
sudo systemctl daemon-reload
```

**Step 4: Move keypairs to standard location**
```bash
# If you have keypairs in old location
sudo mkdir -p /local/keypairs
sudo cp /root/xandminerd/keypairs/pnode-keypair.json /local/keypairs/
sudo chmod 600 /local/keypairs/pnode-keypair.json
```

**Step 5: Remove old directories**
```bash
# Verify backups exist first!
ls -la /root/*.backup.*

# Then remove old installations
sudo rm -rf /root/xandminer
sudo rm -rf /root/xandminerd
```

**Step 6: Run new installer**
```bash
cd /root/xandminer-installer
git checkout feature/security-review
sudo bash install.sh --non-interactive --install \
  --keypair-path /local/keypairs/pnode-keypair.json \
  --prpc-mode private \
  --atlas-cluster devnet
```

### Option 2: Keep Old Installation (Temporary)

If you want to keep the old installation for now:

**Safe approach:**
1. Leave `/root/xandminer` and `/root/xandminerd` alone
2. Run the new installer (it will install to `/opt/`)
3. New services will use `/opt/` paths
4. Old directories just sit there (no harm, just wasted space)
5. Remove old directories later when confident

**Verification:**
```bash
# Check new installation
ls -la /opt/xandminer/

# Check old installation (still there)
ls -la /root/xandminer/

# Check which services are running
systemctl status xandminer.service
systemctl status xandminerd.service
systemctl status pod.service

# Check service user
ps aux | grep xandminer
# Should show: xand user (not root)
```

### Option 3: Migrate Data (Preserve History)

If you want to preserve git history and local changes:

**Step 1: Stop services**
```bash
sudo systemctl stop xandminer.service
sudo systemctl stop xandminerd.service
sudo systemctl stop pod.service
```

**Step 2: Move directories**
```bash
# Create new base directory
sudo mkdir -p /opt/xandminer

# Move old installations
sudo mv /root/xandminer /opt/xandminer/
sudo mv /root/xandminerd /opt/xandminer/

# Update ownership
sudo chown -R xand:xand /opt/xandminer/xandminer
sudo chown -R xand:xand /opt/xandminer/xandminerd
```

**Step 3: Run installer in "update" mode**
```bash
cd /root/xandminer-installer
git checkout feature/security-review
sudo bash install.sh --non-interactive --update \
  --atlas-cluster devnet
```

---

## 🛠️ RECOMMENDED FIX FOR INSTALLER

The installer should detect and handle existing installations. Here's what should be added:

```bash
start_install() {
    sudoCheck
    
    # Check for old installation in /root
    if [ -d "/root/xandminer" ] || [ -d "/root/xandminerd" ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  ⚠️  EXISTING INSTALLATION DETECTED"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Found existing installation in /root/"
        echo "  • /root/xandminer/"
        echo "  • /root/xandminerd/"
        echo ""
        echo "This installer uses the new location: /opt/xandminer/"
        echo ""
        echo "Options:"
        echo "  1. Migrate (move /root/ installation to /opt/)"
        echo "  2. Fresh install (backup and remove /root/ installation)"
        echo "  3. Abort (exit and migrate manually)"
        echo ""
        
        if [ "$NON_INTERACTIVE" = true ]; then
            echo "Non-interactive mode: Aborting."
            echo "Please migrate manually using MIGRATION_GUIDE.md"
            exit 1
        fi
        
        read -p "Choose option (1-3): " migration_choice
        
        case $migration_choice in
            1)
                migrate_from_root_to_opt
                ;;
            2)
                backup_and_remove_old_installation
                ;;
            3)
                echo "Installation aborted. See MIGRATION_GUIDE.md for manual steps."
                exit 0
                ;;
            *)
                echo "Invalid choice. Aborting."
                exit 1
                ;;
        esac
    fi
    
    # ... rest of installation ...
}
```

---

## 📋 Pre-Migration Checklist

Before running the new installer, verify:

- [ ] You have backups of current installation
- [ ] You've noted your current configuration (keypair path, ports, etc.)
- [ ] You've saved any custom modifications
- [ ] You've documented which branch/version you're running
- [ ] Services are stopped
- [ ] You have the keypair file location

---

## ⚠️ What NOT To Do

❌ **Don't run new installer without migration plan**
- You'll end up with two installations

❌ **Don't delete old directories before backup**
- You might lose your keypair

❌ **Don't leave old service files**
- They'll conflict with new services

❌ **Don't forget to move keypairs**
- New installation won't find them

---

## 🔍 Verification After Migration

```bash
# Check new installation exists
ls -la /opt/xandminer/xandminer
ls -la /opt/xandminer/xandminerd

# Check old installation is gone
ls -la /root/xandminer  # Should show: No such file or directory
ls -la /root/xandminerd # Should show: No such file or directory

# Check services are running
systemctl status xandminer.service
systemctl status xandminerd.service
systemctl status pod.service

# Check service user
ps aux | grep -E "xandminer|xandminerd|pod" | grep -v grep
# Should show: xand user

# Check file ownership
ls -la /opt/xandminer/
# Should show: xand:xand ownership

# Check keypair
ls -la /local/keypairs/pnode-keypair.json
# Should show: -rw------- xand xand

# Test web interface
curl http://localhost:3000
curl http://localhost:4000
```

---

## 📞 Summary

**Answer to your question:**

> "Do we need to manually remove /xandminer or /xandminerd?"

**YES** - You should manually remove them AFTER:
1. Creating backups
2. Stopping services
3. Migrating keypairs
4. Running new installer
5. Verifying new installation works

**OR**

Leave them for now (safe but wastes space), remove later when confident.

**The installer does NOT:**
- Detect old installations
- Migrate automatically
- Remove old directories
- Handle conflicts

**This should be fixed in the installer for a smooth upgrade path.**

