# Testing Checklist for Security Review Branch

## Quick Summary
- **Branch:** `feature/security-review`
- **Files Changed:** 1 file (`install.sh`)
- **Lines Changed:** +653 / -504 (net +149 lines)
- **Commits:** 4 commits ahead of master

## 🔴 CRITICAL BREAKING CHANGES

### 1. CLI Flags Changed
- `--unattended` → `--non-interactive` / `-n`
- `--prpc-public` → `--prpc-mode public`
- `--prpc-private` → `--prpc-mode private`
- `--debug` → REMOVED
- NEW: `--atlas-cluster` (required in non-interactive mode)
- NEW: `--default-keypair`
- NEW: `--log-path`

### 2. Installation Directory Changed
- OLD: `/root/xandminer` and `/root/xandminerd`
- NEW: `/opt/xandminer/xandminer` and `/opt/xandminer/xandminerd`

### 3. Service User Changed
- OLD: Services run as `root`
- NEW: Services run as `xand` (non-privileged user)

## ✅ Testing Steps

### Phase 1: Basic Functionality
- [ ] Test interactive installation (no flags)
- [ ] Test non-interactive installation with all required flags
- [ ] Test update functionality
- [ ] Verify services start correctly
- [ ] Verify services run as `xand` user

### Phase 2: CLI Compatibility
- [ ] Test old `--unattended` flag (should fail)
- [ ] Test new `--non-interactive` flag
- [ ] Test `--prpc-mode public`
- [ ] Test `--prpc-mode private`
- [ ] Test `--atlas-cluster` with trynet, devnet, mainnet-alpha
- [ ] Test `--default-keypair`
- [ ] Test `--log-path` with custom path

### Phase 3: Security Features
- [ ] Verify `xand` user is created
- [ ] Verify services run as `xand` user
- [ ] Verify keypair files have chmod 600
- [ ] Test input sanitization (malicious branch names/paths)
- [ ] Verify temp files are cleaned up
- [ ] Verify service files are generated inline (not downloaded)

### Phase 4: Path Changes
- [ ] Verify installation creates `/opt/xandminer`
- [ ] Verify repositories in `/opt/xandminer/xandminer` and `/opt/xandminer/xandminerd`
- [ ] Verify log files in `/opt/xandminer/pod-logs/pod.log`
- [ ] Verify service files reference correct paths

### Phase 5: New Features
- [ ] Test Atlas cluster selection (all three options)
- [ ] Test custom log path
- [ ] Verify logrotate configuration created
- [ ] Test dev mode with branch selection

### Phase 6: Backward Compatibility
- [ ] Test upgrade from existing `/root` installation
- [ ] Verify existing automation scripts break (expected)
- [ ] Document migration path for existing installations

## 🧪 Test Commands

### Test 1: Basic Non-Interactive Install
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode private \
  --atlas-cluster devnet
```

### Test 2: Public pRPC with Trynet
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode public \
  --atlas-cluster trynet
```

### Test 3: Custom Keypair and Log Path
```bash
sudo bash install.sh --non-interactive --install \
  --keypair-path /local/keypairs/test-keypair.json \
  --prpc-mode private \
  --atlas-cluster devnet \
  --log-path /var/log/xandminer/pod.log
```

### Test 4: Update Existing Installation
```bash
sudo bash install.sh --non-interactive --update \
  --atlas-cluster devnet
```

### Test 5: Interactive Mode (Should Still Work)
```bash
sudo bash install.sh
```

### Test 6: Verify Old Flags Fail
```bash
sudo bash install.sh --unattended --install
# Should show: "Unknown option: --unattended"
```

## 📋 Verification Commands

### Check Installation Directory
```bash
ls -la /opt/xandminer/
```

### Check Service User
```bash
id xand
ps aux | grep -E "xandminer|pod" | grep -v grep
```

### Check Service Status
```bash
systemctl status xandminer.service
systemctl status xandminerd.service
systemctl status pod.service
```

### Check File Permissions
```bash
ls -la /local/keypairs/pnode-keypair.json
# Should show: -rw------- (600) owned by xand:xand
```

### Check Log Files
```bash
ls -la /opt/xandminer/pod-logs/
tail -f /opt/xandminer/pod-logs/pod.log
```

### Check Logrotate Config
```bash
cat /etc/logrotate.d/xandeum-pod
```

## ⚠️ Known Issues to Watch For

1. **Existing installations in `/root`** - Will not be automatically migrated
2. **Automation scripts** - Will break if using old flags
3. **File permissions** - May need adjustment after migration
4. **Service restarts** - May fail if paths are hardcoded

## 📝 Migration Notes

If testing upgrade from existing installation:
1. Backup current installation
2. Stop services
3. Manually move directories (if needed)
4. Update service files
5. Update ownership

See `SECURITY_REVIEW_CHANGES.md` for detailed migration steps.

