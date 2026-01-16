# Restore Procedure Examples

## Scenario 1: Restore VM to New VMID (Testing/Staging)

**Use case:** Test a restore or create a staging copy without affecting production.

```bash
# 1. List available backups
pvesm list PBS-DSN --content backup | grep "vm/1001"

# Output:
# PBS-DSN:backup/vm/1001/2026-01-16T08:00:17Z  pbs-vm  backup  60G  1001

# 2. Restore to new VMID (9001)
qmrestore PBS-DSN:backup/vm/1001/2026-01-16T08:00:17Z 9001 --storage local-lvm

# 3. Rename to indicate staging
qm set 9001 --name bastion-staging

# 4. Start and verify
qm start 9001

# 5. Clean up when done
qm stop 9001 && qm destroy 9001
```

## Scenario 2: Disaster Recovery - Replace Production VM

**Use case:** Production VM corrupted/failed, need to restore from backup.

```bash
# 1. Confirm current VM status
qm status 1001

# 2. Stop the failed VM (if running)
qm stop 1001

# 3. List available backups, pick most recent good state
pvesm list PBS-DSN --content backup | grep "vm/1001" | tail -5

# 4. Restore with force (overwrites existing)
qmrestore PBS-DSN:backup/vm/1001/2026-01-16T08:00:17Z 1001 --force

# 5. Start restored VM
qm start 1001

# 6. Verify services
# SSH to VM and check critical services
```

## Scenario 3: Container Restore

**Use case:** Restore a container from PBS backup.

```bash
# FUSE-CL01 example

# 1. List container backups
pvesm list pbs-dsn --content backup | grep "ct/101"

# Output:
# pbs-dsn:backup/ct/101/2026-01-16T02:00:02Z pbs-ct backup 2411732154 101

# 2. Stop container
pct stop 101

# 3. Restore
pct restore 101 pbs-dsn:backup/ct/101/2026-01-16T02:00:02Z \
  --storage local-lvm --force

# 4. Start container
pct start 101

# 5. Verify
pct exec 101 -- systemctl status
```

## Scenario 4: Restore Host Configuration

**Use case:** Host config was modified incorrectly, need to restore specific files.

```bash
# 1. Set PBS credentials
export PBS_REPOSITORY="dsn-backup@pam@10.101.1.250:HDD-BACKUP"
export PBS_PASSWORD="<password>"
export PBS_FINGERPRINT="1d:f6:06:b2:b7:8b:6e:74:1c:c5:17:56:89:b7:d2:dd:9e:c2:e8:33:8f:03:01:57:63:19:71:f2:0f:02:fe:66"

# 2. List available host backups
proxmox-backup-client snapshot list \
  --group host/LTRKAR02-PV01 \
  --ns DSN

# 3. Restore /etc to temp directory
mkdir -p /tmp/restore
proxmox-backup-client restore \
  host/LTRKAR02-PV01/2026-01-08T18:04:52Z \
  etc.pxar /tmp/restore \
  --ns DSN

# 4. Compare and copy specific files
diff /tmp/restore/network/interfaces /etc/network/interfaces
cp /tmp/restore/network/interfaces /etc/network/interfaces

# 5. Apply changes if needed
ifreload -a  # For network changes

# 6. Cleanup
rm -rf /tmp/restore
```

## Scenario 5: File-Level Restore (PBS Web UI)

**Use case:** Need to restore specific files without full VM restore.

1. Access PBS Web UI: https://10.101.1.250:8007
2. Navigate: Datastore → HDD-BACKUP → Content
3. Select namespace (DSN or Fuse)
4. Find the backup snapshot
5. Click on the snapshot to expand
6. Use "File Browser" to navigate
7. Download specific files

## Scenario 6: Restore Test Container from PBS

**Use case:** Restore the load test container (CT 110) for future testing.

```bash
# FUSE-CL01 - pre-built test container with dnsperf + perfdhcp

# 1. List available backups
pvesm list pbs-dsn --content backup | grep "ct/110"

# 2. Restore
pct restore 110 pbs-dsn:backup/ct/110/2026-01-15T22:10:01Z \
  --storage local-lvm --start 1

# 3. Verify tools
pct exec 110 -- /usr/sbin/perfdhcp -v
pct exec 110 -- dnsperf -v
```

## Common Restore Flags

| Flag | Purpose |
|------|---------|
| `--force` | Overwrite existing VM/CT |
| `--storage <name>` | Target storage for disks |
| `--unique` | Auto-generate new MAC addresses |
| `--pool <name>` | Add to resource pool |
| `--bwlimit <kbps>` | Throttle restore speed |
