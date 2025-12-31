# CLI Migration Guide: Master → Security Review Branch

Quick reference for updating command-line invocations.

## Command Mapping

### Installation Commands

#### Fresh Install (Old → New)

**OLD (master):**
```bash
sudo bash install.sh --unattended --install
```

**NEW (security-review):**
```bash
sudo bash install.sh --non-interactive --install --default-keypair --prpc-mode private --atlas-cluster devnet
```

---

#### Update (Old → New)

**OLD (master):**
```bash
sudo bash install.sh -u --update
```

**NEW (security-review):**
```bash
sudo bash install.sh --non-interactive --update --atlas-cluster devnet
```

---

#### Custom Keypair (Old → New)

**OLD (master):**
```bash
sudo bash install.sh --unattended --install --keypair-path /root/my-keypair.json --prpc-public
```

**NEW (security-review):**
```bash
sudo bash install.sh --non-interactive --install --keypair-path /local/keypairs/my-keypair.json --prpc-mode public --atlas-cluster devnet
```

---

#### Private pRPC (Old → New)

**OLD (master):**
```bash
sudo bash install.sh -u --update --prpc-private
```

**NEW (security-review):**
```bash
sudo bash install.sh --non-interactive --update --prpc-mode private --atlas-cluster devnet
```

---

#### Dev Mode (Old → New)

**OLD (master):**
```bash
sudo bash install.sh -d -u --update --prpc-private
```

**NEW (security-review):**
```bash
sudo bash install.sh --non-interactive --update --dev --prpc-mode private --atlas-cluster devnet
```

---

## Flag Reference

### Removed Flags ❌
- `--unattended` / `-u`
- `--prpc-public`
- `--prpc-private`
- `--debug`

### New Flags ✅

| Flag | Values | Required | Default | Description |
|------|--------|----------|---------|-------------|
| `--non-interactive` / `-n` | - | Yes (for non-interactive) | - | Run without prompts |
| `--prpc-mode` | `public`, `private` | Yes (non-interactive) | - | pRPC access mode |
| `--atlas-cluster` | `trynet`, `devnet`, `mainnet-alpha` | Yes (non-interactive) | `devnet` | Atlas cluster selection |
| `--default-keypair` | - | No | - | Use default keypair path |
| `--log-path` | Any path | No | `/opt/xandminer/pod-logs/pod.log` | Custom log file path |

### Preserved Flags ✅
- `--install`
- `--update`
- `--dev` / `-d`
- `--keypair-path PATH`
- `--help` / `-h`

---

## Common Use Cases

### 1. Standard Installation (Trynet)
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode public \
  --atlas-cluster trynet
```

### 2. Standard Installation (Devnet)
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode private \
  --atlas-cluster devnet
```

### 3. Standard Installation (Mainnet)
```bash
sudo bash install.sh --non-interactive --install \
  --keypair-path /local/keypairs/my-keypair.json \
  --prpc-mode private \
  --atlas-cluster mainnet-alpha
```

### 4. Update Existing Installation
```bash
sudo bash install.sh --non-interactive --update \
  --atlas-cluster devnet
```

### 5. Dev Mode Installation
```bash
sudo bash install.sh --non-interactive --install \
  --dev \
  --default-keypair \
  --prpc-mode public \
  --atlas-cluster devnet
```

### 6. Custom Log Path
```bash
sudo bash install.sh --non-interactive --install \
  --default-keypair \
  --prpc-mode private \
  --atlas-cluster devnet \
  --log-path /var/log/xandminer/pod.log
```

---

## Error Messages

If you use old flags, you'll see:
```
Unknown option: --unattended
```

Solution: Replace with `--non-interactive`

---

If you forget required flags in non-interactive mode:
```
Error: --prpc-mode must be 'public' or 'private'
```

Solution: Add `--prpc-mode public` or `--prpc-mode private`

---

If you forget atlas cluster:
```
Error: --atlas-cluster must be 'trynet', 'devnet', or 'mainnet-alpha'
```

Solution: Add `--atlas-cluster devnet` (or trynet/mainnet-alpha)

---

## Interactive Mode (Unchanged)

Interactive mode still works the same:
```bash
sudo bash install.sh
```

No flags needed - script will prompt for all options.

