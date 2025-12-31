# Migration Guide - Security Review Branch

**Branch:** `feature/security-review`  
**For users upgrading from master branch**

---

## 🔴 Breaking Changes

This branch has breaking changes that will affect your current installation:

### 1. CLI Flags Changed

| Old Flag | New Flag | Example |
|----------|----------|---------|
| `--unattended` | `--non-interactive` | `--non-interactive --install` |
| `--prpc-public` | `--prpc-mode public` | `--prpc-mode public` |
| `--prpc-private` | `--prpc-mode private` | `--prpc-mode private` |
| None | `--atlas-cluster CLUSTER` | `--atlas-cluster devnet` |
| None | `--enable-logrotate` | `--enable-logrotate` |
| None | `--log-retention-days N` | `--log-retention-days 14` |

**Old command:**
```bash
sudo bash install.sh --unattended --install --prpc-public
```

**New command:**
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode public \
  --atlas-cluster devnet
```

### 2. Installation Directory Changed

- **Old:** `/root/xandminer` and `/root/xandminerd`
- **New:** `/opt/xandeum/xandminer` and `/opt/xandeum/xandminerd`

**Note:** Uses vendor namespace `/opt/xandeum/` following industry best practices.

### 3. Service User Changed

- **Old:** Services ran as `root`
- **New:** Services run as `xand` (non-privileged user)

---

## 📋 Migration Steps

### If You Have an Existing Installation

The installer does NOT automatically migrate. Follow these steps:

#### Step 1: Backup Everything

```bash
sudo cp -r /root/xandminer /root/xandminer.backup.$(date +%Y%m%d)
sudo cp -r /root/xandminerd /root/xandminerd.backup.$(date +%Y%m%d)
sudo cp /root/xandminerd/keypairs/pnode-keypair.json /root/keypair.backup

# Also backup current installation if exists
sudo cp -r /opt/xandminer /opt/xandminer.backup.$(date +%Y%m%d) 2>/dev/null || true
sudo cp -r /opt/xandminerd /opt/xandminerd.backup.$(date +%Y%m%d) 2>/dev/null || true
```

#### Step 2: Stop Old Services

```bash
sudo systemctl stop xandminer.service xandminerd.service pod.service
sudo systemctl disable xandminer.service xandminerd.service pod.service
sudo rm /etc/systemd/system/xandminer.service
sudo rm /etc/systemd/system/xandminerd.service
sudo rm /etc/systemd/system/pod.service
sudo systemctl daemon-reload
```

#### Step 3: Migrate Keypair

```bash
sudo mkdir -p /local/keypairs
sudo cp /root/xandminerd/keypairs/pnode-keypair.json /local/keypairs/
sudo chmod 600 /local/keypairs/pnode-keypair.json
```

#### Step 4: Run New Installer

**Interactive mode (recommended):**
```bash
cd ~
wget -O install.sh https://raw.githubusercontent.com/T3chie-404/xandminer-installer/feature/security-review/install.sh
chmod +x install.sh
sudo ./install.sh
```

**Non-interactive mode:**
```bash
sudo ./install.sh --non-interactive --install \
  --keypair-path /local/keypairs/pnode-keypair.json \
  --prpc-mode private \
  --atlas-cluster devnet
```

#### Step 5: Verify Everything Works

```bash
# Check installation directory
ls -la /opt/xandeum/xandminer/
ls -la /opt/xandeum/xandminerd/

# Check services
sudo systemctl status xandminer.service xandminerd.service pod.service

# Check they run as xand user
ps aux | grep xandminer | grep -v grep

# Test web interface
curl http://localhost:3000

# Test API
curl http://localhost:4000

# Check keypair location
ls -la /local/keypairs/pnode-keypair.json
```

#### Step 6: Remove Old Directories (When Confident)

⚠️ **Only after verifying everything works!**

```bash
sudo rm -rf /root/xandminer /root/xandminerd
```

Or keep as backup:
```bash
sudo mv /root/xandminer /root/xandminer.old.backup
sudo mv /root/xandminerd /root/xandminerd.old.backup
```

---

## 🆕 New Features

### Atlas Cluster Selection

Choose which network to connect to:

```bash
--atlas-cluster trynet      # Testing network
--atlas-cluster devnet      # Development network (default)
--atlas-cluster mainnet-alpha  # Production network (requires dev mode)
```

**Note:** For mainnet-alpha, you need dev mode to install trynet pod:
```bash
sudo ./install.sh --dev
# Select mainnet-alpha when prompted
# Select a trynet pod version when prompted
```

### Optional Log Rotation

Log rotation is now **opt-in**:

**Enable in non-interactive mode:**
```bash
--enable-logrotate --log-retention-days 14
```

**In interactive mode:**
- You'll be prompted with a clear explanation
- Choose yes/no
- Set custom retention period if desired

---

## 🔒 Security Improvements

1. **Non-root services** - All services run as `xand` user
2. **Input sanitization** - Prevents command injection
3. **Secure file permissions** - Keypairs protected with chmod 600
4. **FHS compliance** - Installation in `/opt/` not `/root/`
5. **Optional log rotation** - User consent required

---

## 🧪 Testing Before Migrating

Test on a non-production system first:

```bash
# Fresh Ubuntu/Debian VM
sudo apt update
sudo apt install -y wget curl git

# Download and run installer
cd ~
wget -O install.sh https://raw.githubusercontent.com/T3chie-404/xandminer-installer/feature/security-review/install.sh
chmod +x install.sh
sudo ./install.sh
```

---

## 🆘 Troubleshooting

### Services Won't Start

```bash
sudo journalctl -u xandminer.service -n 50
sudo journalctl -u xandminerd.service -n 50
sudo journalctl -u pod.service -n 50
```

### Wrong User or Permissions

```bash
# Check service user
ps aux | grep -E "xandminer|xandminerd|pod" | grep -v grep

# Fix ownership if needed
sudo chown -R xand:xand /opt/xandminer
sudo chown -R xand:xand /opt/xandminerd
```

### MainNet-Alpha Not Working

Stable pod doesn't have `--mainnet-alpha` flag yet. Use dev mode:

```bash
sudo ./install.sh --dev
# Select mainnet-alpha cluster
# Select a trynet pod version (1.2.0+)
```

### Old Directories Still There

This is normal! The installer warns you but doesn't auto-delete. Remove manually after verification:

```bash
sudo rm -rf /root/xandminer /root/xandminerd
```

---

## 📞 Quick Reference

**Installation locations:**
- Code: `/opt/xandeum/xandminer/` and `/opt/xandeum/xandminerd/`
- Keypair: `/local/keypairs/pnode-keypair.json`
- Logs: `/opt/xandeum/logs/pod.log`
- Services: `/etc/systemd/system/*.service`

**Service commands:**
```bash
sudo systemctl status xandminer.service xandminerd.service pod.service
sudo systemctl restart xandminer.service xandminerd.service pod.service
sudo journalctl -u SERVICE_NAME -f
```

**Access:**
- Web interface: http://localhost:3000
- API: http://localhost:4000
- Pod RPC: http://localhost:6000 (if public mode)

---

**Questions?** See `TESTING_GUIDE_FOR_USERS.md` or open an issue on GitHub.
