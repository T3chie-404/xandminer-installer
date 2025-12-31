# Logrotate Security Enhancement

## Summary

Made automatic log rotation **optional** with user consent, addressing security and compliance concerns.

---

## Changes Made

### 1. New Command-Line Flags

```bash
--enable-logrotate       # Enable automatic log rotation (default: disabled)
--log-retention-days N   # Number of days to keep logs (default: 7)
```

### 2. Interactive Mode Prompt

When installing interactively, users now see:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Automatic Log Rotation Setup (Optional)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Would you like to enable automatic log rotation for pod logs?

📋 How it works:
  • Runs automatically via system cron (daily)
  • Rotates logs at midnight each day
  • Compresses old logs to save disk space
  • Deletes logs older than retention period
  • Creates new log files with proper permissions

✅ Benefits:
  • Prevents disk space exhaustion
  • Maintains system performance
  • Automatic maintenance (no manual intervention)

⚠️  Important:
  • Logs older than retention period will be PERMANENTLY DELETED
  • Default retention: 7 days (configurable)
  • Consider compliance/audit requirements before enabling

Enable automatic log rotation? (y/N):
```

If user chooses "yes", they can also specify retention period:
```
Log retention period in days [7]:
```

### 3. Non-Interactive Mode Behavior

**Default:** Log rotation is **DISABLED**

To enable:
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode private \
  --atlas-cluster devnet \
  --enable-logrotate \
  --log-retention-days 14
```

Without `--enable-logrotate`, user sees:
```
ℹ️  Log rotation disabled (use --enable-logrotate to enable)
```

### 4. Enhanced Configuration Output

When enabled, users see detailed summary:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Setting up Logrotate for Pod Logs
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Logrotate configuration created at: /etc/logrotate.d/xandeum-pod

📋 Configuration Summary:
  • Log file: /opt/xandminer/pod-logs/pod.log
  • Rotation: Daily at midnight
  • Retention: 14 days
  • Compression: Yes (gzip)
  • Old logs: pod.log.1.gz, pod.log.2.gz, etc.
  • Execution: Automatic via /etc/cron.daily/logrotate

ℹ️  Logs older than 14 days will be automatically deleted
```

---

## Security Benefits

### ✅ Informed Consent
- Users explicitly choose to enable log rotation
- Clear explanation of what will happen
- Warning about permanent deletion

### ✅ Compliance Friendly
- Users can disable if they have retention requirements
- Configurable retention period
- No surprise log deletion

### ✅ Transparency
- Clear documentation of how it works
- Detailed configuration summary
- No hidden behavior

### ✅ Flexibility
- Works in both interactive and non-interactive modes
- Customizable retention period
- Easy to enable/disable

---

## Usage Examples

### Example 1: Interactive Installation
```bash
sudo bash install.sh
# User will be prompted about log rotation
# Can choose yes/no and set retention period
```

### Example 2: Non-Interactive with Log Rotation
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode private \
  --atlas-cluster devnet \
  --enable-logrotate \
  --log-retention-days 30
```

### Example 3: Non-Interactive without Log Rotation (Default)
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode private \
  --atlas-cluster devnet
# Log rotation will NOT be configured
```

### Example 4: Different Retention Periods

**7 days (default):**
```bash
--enable-logrotate
```

**30 days (for compliance):**
```bash
--enable-logrotate --log-retention-days 30
```

**90 days (for audit requirements):**
```bash
--enable-logrotate --log-retention-days 90
```

---

## Technical Details

### Logrotate Configuration File
Location: `/etc/logrotate.d/xandeum-pod`

```
# Xandeum Pod Log Rotation Configuration
# Managed by xandminer-installer
# Log file: /opt/xandminer/pod-logs/pod.log
# Retention: 7 days

/opt/xandminer/pod-logs/pod.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 xand xand
    sharedscripts
    postrotate
        systemctl reload pod.service > /dev/null 2>&1 || true
    endscript
}
```

### How It Works

1. **Daily Execution**
   - System cron runs `/etc/cron.daily/logrotate` every day at midnight
   - Logrotate reads all configs in `/etc/logrotate.d/`

2. **Rotation Process**
   - Renames current log: `pod.log` → `pod.log.1`
   - Compresses previous logs: `pod.log.1` → `pod.log.1.gz`
   - Creates new `pod.log` owned by `xand:xand`
   - Reloads pod service to use new file

3. **Retention Management**
   - Keeps N days of logs (where N = retention period)
   - Deletes logs older than N days
   - Example with 7 days: keeps `pod.log`, `pod.log.1.gz` through `pod.log.7.gz`

4. **Permissions**
   - Logrotate runs as root (has permission to rotate)
   - New logs created with `0644` permissions
   - Owned by `xand:xand` so service can write

---

## Migration from Previous Version

### Old Behavior (Before This Change)
- Log rotation was **automatically enabled** without asking
- No way to disable it
- Fixed 7-day retention
- No warning about log deletion

### New Behavior (After This Change)
- Log rotation is **disabled by default**
- User must explicitly enable it
- Configurable retention period
- Clear warnings about log deletion

### For Existing Installations
If you previously installed with automatic log rotation:
- The config file at `/etc/logrotate.d/xandeum-pod` still exists
- It will continue to work
- To change retention period, re-run installer with `--enable-logrotate --log-retention-days N`
- To disable, remove the file: `sudo rm /etc/logrotate.d/xandeum-pod`

---

## Compliance Considerations

### Common Retention Requirements

| Compliance Standard | Typical Retention | Recommendation |
|---------------------|-------------------|----------------|
| SOC 2 | 90+ days | `--log-retention-days 90` |
| HIPAA | 6 years | Don't use logrotate, archive logs |
| PCI-DSS | 90+ days | `--log-retention-days 90` |
| GDPR | Varies | Check your requirements |
| General Security | 30-90 days | `--log-retention-days 30` |

### When NOT to Use Logrotate

❌ Don't enable if:
- You need logs for longer than 90 days
- You have legal/compliance requirements for log retention
- You need immutable audit trails
- You're required to archive logs to external storage

✅ Instead, consider:
- Centralized logging (syslog, ELK stack, Splunk)
- Log shipping to S3/cloud storage
- Dedicated log management solutions
- Manual archival processes

---

## Testing

### Test Interactive Prompt
```bash
sudo bash install.sh
# Follow prompts, select log rotation option
```

### Test Non-Interactive Enabled
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode private \
  --atlas-cluster devnet \
  --enable-logrotate \
  --log-retention-days 14
```

### Test Non-Interactive Disabled (Default)
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode private \
  --atlas-cluster devnet
# Should show: "Log rotation disabled"
```

### Verify Configuration
```bash
# Check if config was created
cat /etc/logrotate.d/xandeum-pod

# Test logrotate manually
sudo logrotate -d /etc/logrotate.d/xandeum-pod  # Dry run
sudo logrotate -f /etc/logrotate.d/xandeum-pod  # Force rotation
```

---

## Summary of Changes

| Aspect | Before | After |
|--------|--------|-------|
| Default Behavior | Enabled | Disabled |
| User Consent | None | Required |
| Retention Period | Fixed (7 days) | Configurable |
| Warning | None | Clear warning |
| Interactive Prompt | No | Yes |
| Non-Interactive Flag | N/A | `--enable-logrotate` |
| Transparency | Low | High |
| Compliance Friendly | No | Yes |

---

**Result:** Log rotation is now a user-controlled, transparent, and compliance-friendly feature that respects user autonomy and security requirements.

