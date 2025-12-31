# Testing Guide - Security Review Branch

**Branch:** `feature/security-review`  
**Status:** Ready for testing  
**Last Updated:** December 31, 2025

Thank you for testing this security-enhanced version of the xandminer installer!

---

## 🚨 Important: This is a Test Branch

**What this means:**
- Major improvements to security and stability
- Breaking changes to command-line interface
- Installation directory changed from `/root` to `/opt`
- Services now run as non-root user

**Please test thoroughly before using in production!**

---

## 🎯 Quick Start

### Option 1: Interactive Installation (Recommended for Testing)

```bash
cd ~
wget -O install.sh https://raw.githubusercontent.com/T3chie-404/xandminer-installer/feature/security-review/install.sh
chmod +x install.sh
sudo ./install.sh
```

**Follow the prompts to configure:**
- Keypair location
- pRPC mode (public/private)
- Atlas cluster (trynet/devnet/mainnet-alpha)
- Log path
- Log rotation (optional)

### Option 2: Non-Interactive Installation

```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode private \
  --atlas-cluster devnet
```

### Option 3: Dev Mode (For Testing Trynet Pod)

**Use dev mode if you need:**
- Specific repository branches
- Trynet pod versions
- `--mainnet-alpha` flag support (requires trynet pod)

```bash
sudo bash install.sh --dev
```

---

## 🔴 Breaking Changes - Please Read!

### 1. Command-Line Flags Changed

**Old flags (master branch) → New flags (security-review):**

| Old Flag | New Flag | Notes |
|----------|----------|-------|
| `--unattended` | `--non-interactive` | Renamed for clarity |
| `--prpc-public` | `--prpc-mode public` | New format |
| `--prpc-private` | `--prpc-mode private` | New format |
| `--debug` | REMOVED | Removed from this branch |
| N/A | `--atlas-cluster CLUSTER` | NEW - Required in non-interactive |
| N/A | `--enable-logrotate` | NEW - Optional log rotation |
| N/A | `--log-retention-days N` | NEW - Configure retention |

**Migration Example:**

❌ **Old (don't use):**
```bash
sudo bash install.sh --unattended --install --prpc-public
```

✅ **New (use this):**
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode public \
  --atlas-cluster devnet
```

### 2. Installation Directory Changed

**Old:** `/root/xandminer` and `/root/xandminerd`  
**New:** `/opt/xandminer` and `/opt/xandminerd`

**What this means for you:**
- Fresh install goes to `/opt/`
- Old directories in `/root/` are NOT automatically removed
- You'll get a warning at the end about old directories
- Services use the new `/opt/` location

### 3. Service User Changed

**Old:** Services ran as `root`  
**New:** Services run as `xand` (non-privileged user)

**What this means:**
- Better security (services can't compromise entire system)
- File permissions automatically set correctly
- Services restart may require different permissions

---

## 📋 What to Test

### Critical Tests

1. **Fresh Installation**
   ```bash
   sudo bash install.sh
   ```
   - Does it complete without errors?
   - Do all services start?
   - Can you access web interface (port 3000)?

2. **Service Status**
   ```bash
   sudo systemctl status xandminer.service xandminerd.service pod.service
   ```
   - Are all services "active (running)"?
   - Do they run as `xand` user (not root)?

3. **Web Interface**
   - Open browser: http://YOUR_SERVER_IP:3000
   - Does it load?
   - Can you see mining status?

4. **API Endpoint**
   ```bash
   curl http://localhost:4000
   ```
   - Does it respond?

5. **Pod Service**
   ```bash
   sudo journalctl -u pod.service -n 20
   ```
   - Is it connecting to Atlas?
   - Any errors?

### Testing Different Modes

**Test with DevNet (default):**
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode private \
  --atlas-cluster devnet
```

**Test with Trynet:**
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode public \
  --atlas-cluster trynet
```

**Test with MainNet-Alpha (requires dev mode):**
```bash
sudo bash install.sh --dev
# Select mainnet-alpha when prompted
# Select a trynet pod version when prompted
```

### Testing Log Rotation (Optional)

**Enable log rotation:**
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode private \
  --atlas-cluster devnet \
  --enable-logrotate \
  --log-retention-days 14
```

**Verify logrotate config:**
```bash
cat /etc/logrotate.d/xandeum-pod
sudo logrotate -d /etc/logrotate.d/xandeum-pod  # Dry run test
```

---

## 🐛 Known Issues

### Issue 1: MainNet-Alpha Requires Dev Mode

**Problem:** Stable pod doesn't have `--mainnet-alpha` flag yet  
**Solution:** Use dev mode to select trynet pod version

```bash
sudo bash install.sh --dev
# Select trynet pod version when prompted
```

### Issue 2: inotify Watch Limit Warning

**Error:** `Failed to add a watch for /run/systemd/ask-password: inotify watch limit reached`

**Solution:** Not critical, but if it bothers you:
```bash
sudo sysctl fs.inotify.max_user_watches=262144
echo "fs.inotify.max_user_watches=262144" | sudo tee -a /etc/sysctl.conf
```

### Issue 3: Old Directories Remain

**Observation:** After installation, `/root/xandminer` and `/root/xandminerd` still exist

**Solution:** This is intentional! The installer warns you at the end. Remove them manually after verifying everything works:

```bash
# Verify new installation works first!
sudo systemctl status xandminer.service xandminerd.service pod.service

# Then remove old directories
sudo rm -rf /root/xandminer /root/xandminerd
```

---

## ✅ What to Report Back

Please test and report:

### 1. Installation Success
- [ ] Installation completed without errors
- [ ] All services started successfully
- [ ] Web interface accessible
- [ ] API responding

### 2. Service Status
- [ ] Services running as `xand` user (not root)
- [ ] Correct installation directory (`/opt/`)
- [ ] Correct file permissions

### 3. Functionality
- [ ] Mining operations working
- [ ] API calls working
- [ ] Pod syncing with network
- [ ] No unexpected errors in logs

### 4. New Features
- [ ] Atlas cluster selection working
- [ ] Log rotation configuration (if enabled)
- [ ] Old directory warning displayed

### 5. Issues Found
Please report any:
- Error messages
- Service failures
- Permission issues
- Configuration problems
- Unexpected behavior

---

## 🔧 Troubleshooting

### Services Won't Start

```bash
# Check logs
sudo journalctl -u xandminer.service -n 50
sudo journalctl -u xandminerd.service -n 50
sudo journalctl -u pod.service -n 50

# Check file permissions
ls -la /opt/xandminer/
ls -la /opt/xandminerd/
ls -la /local/keypairs/
```

### Web Interface Not Loading

```bash
# Check if xandminer service is running
sudo systemctl status xandminer.service

# Check if port is listening
sudo netstat -tulpn | grep 3000

# Check for errors
sudo journalctl -u xandminer.service -f
```

### Pod Service Failing

```bash
# Check pod version
pod --version

# Check pod command
cat /etc/systemd/system/pod.service | grep ExecStart

# For mainnet-alpha, ensure you have trynet pod
# Stable pod doesn't support --mainnet-alpha yet
```

---

## 📊 Verification Checklist

After installation, verify:

```bash
# 1. Check installation directory
ls -la /opt/xandminer/
ls -la /opt/xandminerd/

# 2. Check service user
ps aux | grep xandminer | grep -v grep
# Should show: xand user

# 3. Check services
sudo systemctl status xandminer.service xandminerd.service pod.service

# 4. Check web interface
curl -I http://localhost:3000

# 5. Check API
curl http://localhost:4000

# 6. Check pod connectivity
sudo journalctl -u pod.service -n 10 | grep -E "Atlas|Bootstrap"

# 7. Check old directories (should warn you)
ls -la /root/xandminer 2>/dev/null && echo "Old directory detected (installer should have warned)"
```

---

## 💬 Feedback & Issues

**How to report issues:**

1. **GitHub Issues** (preferred):
   - https://github.com/T3chie-404/xandminer-installer/issues

2. **Include in your report:**
   - Installation command used
   - Error messages (full output)
   - System info: `uname -a`
   - Log output: `sudo journalctl -u SERVICE -n 50`
   - File permissions: `ls -la /opt/xandminer*/`

---

## 🎓 Understanding the Changes

### Security Improvements

1. **Non-root services** - Services run as `xand` user (can't compromise entire system)
2. **Input sanitization** - Prevents command injection attacks
3. **Secure file permissions** - Keypairs protected with chmod 600
4. **FHS compliance** - Proper Linux directory structure
5. **Optional log rotation** - User consent required

### New Features

1. **Atlas cluster selection** - Choose trynet/devnet/mainnet-alpha
2. **Log rotation** - Optional automatic log management
3. **Dev mode improvements** - Select specific branches and pod versions
4. **Better non-interactive mode** - Explicit flags required

### Bug Fixes

1. **Git clone detection** - No more silent failures
2. **Service file paths** - Correct entry points
3. **Web GUI updates** - Keeps GUI alive during updates
4. **Migration warnings** - Alerts about old directories

---

## 📚 Additional Documentation

For more details, see:
- `SECURITY_REVIEW_CHANGES.md` - Complete change summary
- `CLI_MIGRATION_GUIDE.md` - Command-line flag reference
- `MIGRATION_GUIDE.md` - Detailed migration from /root to /opt
- `SECURITY_AUDIT_REPORT.md` - Security vulnerability analysis

---

## 🚀 Thank You!

Your testing helps make this installer better and more secure for everyone.

**Questions?** Open an issue on GitHub: https://github.com/T3chie-404/xandminer-installer/issues

**Found a bug?** Please report it with as much detail as possible!

---

**Happy Testing!** 🎉

