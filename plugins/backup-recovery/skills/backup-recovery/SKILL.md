---
name: Backup and Recovery
description: Proxmox Backup Server (PBS) operations for VM/CT backup, restore, and disaster recovery. Use when asked to "backup a VM", "restore a container", "check backup status", "run host backup", "list backups", or "recover from PBS".
version: 1.0.0
---

# Backup and Recovery Operations

Comprehensive procedures for Proxmox Backup Server operations across DSN managed clusters.

## Infrastructure Reference

| Property | Value |
|----------|-------|
| PBS Server | LTRKAR02-PBS01 (10.101.1.250:8007) |
| Datastore | HDD-BACKUP (32.7 TB RAID-10) |
| Fingerprint | `1d:f6:06:b2:b7:8b:6e:74:1c:c5:17:56:89:b7:d2:dd:9e:c2:e8:33:8f:03:01:57:63:19:71:f2:0f:02:fe:66` |

### Cluster Connections

| Cluster | Namespace | Storage ID | User | Network Path |
|---------|-----------|------------|------|--------------|
| LTRKAR02-CL01 | DSN | PBS-DSN | dsn-backup@pam | L2 direct (VLAN 101) |
| FUSE-CL01 | Fuse | pbs-dsn | fuse-backup@pam | FuseRural tunnel |

## Quick Reference

### Backup Commands

```bash
# VM backup (snapshot mode)
vzdump <vmid> --storage PBS-DSN --mode snapshot --compress zstd \
  --notes-template '{{guestname}} - CLUSTER-NAME'

# Container backup
vzdump <ctid> --storage pbs-dsn --mode snapshot --compress zstd \
  --notes-template '{{guestname}} - CLUSTER-NAME'

# Large VM (>500GB) - throttled to prevent PBS overload
vzdump <vmid> --storage PBS-DSN --mode snapshot --bwlimit 102400 \
  --notes-template '{{guestname}} - CLUSTER-NAME'

# All guests on node
vzdump --all --storage PBS-DSN --mode snapshot --compress zstd
```

### Restore Commands

```bash
# List available backups
pvesm list PBS-DSN --content backup | grep "vm/<vmid>"
pvesm list pbs-dsn --content backup | grep "ct/<ctid>"

# Restore VM to new VMID
qmrestore PBS-DSN:backup/vm/<vmid>/<timestamp>Z <new-vmid> --storage local-lvm

# Restore VM to original (overwrites!)
qmrestore PBS-DSN:backup/vm/<vmid>/<timestamp>Z <vmid> --force

# Restore container
pct restore <ctid> pbs-dsn:backup/ct/<ctid>/<timestamp>Z --storage local-lvm
```

## Procedures

### 1. Manual VM Backup

Execute backup with full output capture:

```bash
vzdump 1001 --storage PBS-DSN --mode snapshot --compress zstd \
  --notes-template '{{guestname}} - LTRKAR02-CL01'
```

**Expected output (incremental backup):**
```
INFO: starting new backup job: vzdump 1001 --notes-template '{{guestname}} - LTRKAR02-CL01' --compress zstd --storage PBS-DSN --mode snapshot
INFO: Starting Backup of VM 1001 (qemu)
INFO: Backup started at 2026-01-16 10:26:33
INFO: status = running
INFO: VM Name: bastion-pa-vm101
INFO: include disk 'virtio0' 'SSD-VMs:vm-1001-disk-0' 60G
INFO: backup mode: snapshot
INFO: ionice priority: 7
INFO: creating Proxmox Backup Server archive 'vm/1001/2026-01-16T16:26:33Z'
INFO: started backup task '03e47266-6866-4ff0-b8fc-cb7a69ab4f44'
INFO: virtio0: dirty-bitmap status: OK (628.0 MiB of 60.0 GiB dirty)
INFO: using fast incremental mode (dirty-bitmap), 628.0 MiB dirty of 60.0 GiB total
INFO: 100% (628.0 MiB of 628.0 MiB) in 3s, read: 209.3 MiB/s, write: 209.3 MiB/s
INFO: backup was done incrementally, reused 59.39 GiB (98%)
INFO: transferred 628.00 MiB in 4 seconds (157.0 MiB/s)
INFO: Finished Backup of VM 1001 (00:00:05)
INFO: Backup job finished successfully
```

**Key metrics to verify:**
- `dirty-bitmap status: OK` - Incremental working
- `reused XX%` - Higher = better deduplication
- Transfer speed matches expected (~100-200 MB/s for PBS)

### 2. Container Backup

```bash
vzdump 101 --storage pbs-dsn --mode snapshot --compress zstd \
  --notes-template '{{guestname}} - FUSE-CL01'
```

**Expected output:**
```
INFO: Starting Backup of VM 101 (lxc)
INFO: CT Name: dhcp-ct101
INFO: including mount point rootfs ('/') in backup
INFO: backup mode: snapshot
INFO: create storage snapshot 'vzdump'
INFO: creating Proxmox Backup Server archive 'ct/101/2026-01-16T02:00:02Z'
INFO: Starting backup: [Fuse]:ct/101/2026-01-16T02:00:02Z
INFO: Downloading previous manifest (Thu Jan 15 02:00:00 2026)
INFO: root.pxar: had to backup 479.821 MiB of 2.246 GiB (compressed 120.488 MiB)
INFO: root.pxar: backup was done incrementally, reused 1.777 GiB (79.1%)
INFO: Duration: 52.48s
INFO: cleanup temporary 'vzdump' snapshot
INFO: Finished Backup of VM 101 (00:00:55)
```

### 3. List Backups

**Via Proxmox storage:**
```bash
# List all backups in storage
pvesm list PBS-DSN --content backup

# Filter by VMID
pvesm list PBS-DSN --content backup | grep "vm/1001"
pvesm list pbs-dsn --content backup | grep "ct/101"
```

**Via proxmox-backup-client (detailed):**
```bash
# Set credentials
export PBS_PASSWORD="<password>"
export PBS_FINGERPRINT="1d:f6:06:b2:b7:8b:6e:74:1c:c5:17:56:89:b7:d2:dd:9e:c2:e8:33:8f:03:01:57:63:19:71:f2:0f:02:fe:66"

# List snapshots for a group
proxmox-backup-client snapshot list \
  --group vm/1001 \
  --repository dsn-backup@pam@10.101.1.250:HDD-BACKUP \
  --ns DSN
```

### 4. Restore Operations

**Restore VM to new VMID:**
```bash
qmrestore PBS-DSN:backup/vm/1001/2026-01-16T08:00:17Z 9001 --storage local-lvm
```

**Restore VM to original (destructive):**
```bash
qm stop 1001
qmrestore PBS-DSN:backup/vm/1001/2026-01-16T08:00:17Z 1001 --force
qm start 1001
```

**Restore container:**
```bash
pct stop 101
pct restore 101 pbs-dsn:backup/ct/101/2026-01-16T02:00:02Z --storage local-lvm --force
pct start 101
```

### 5. Host Configuration Backup

Host configs (/etc, /root) backed up via cron.daily script.

**Manual execution:**
```bash
/etc/cron.daily/pbs-host-backup
```

**Check logs:**
```bash
journalctl -t pbs-host-backup --since today
```

### 6. Restore Host Files

```bash
export PBS_REPOSITORY="dsn-backup@pam@10.101.1.250:HDD-BACKUP"
export PBS_PASSWORD="<password>"
export PBS_FINGERPRINT="1d:f6:..."

# Restore to temp directory
proxmox-backup-client restore \
  host/LTRKAR02-PV01/2026-01-08T18:04:52Z \
  etc.pxar /tmp/restore \
  --ns DSN

# Copy specific files
cp /tmp/restore/network/interfaces /etc/network/interfaces
```

## Scheduled Backup Jobs

### Create New Backup Job (CLI)

```bash
pvesh create /cluster/backup \
  --id fuse-daily \
  --storage pbs-dsn \
  --schedule "02:00" \
  --all 1 \
  --mode snapshot \
  --compress zstd \
  --mailnotification failure \
  --notes-template '{{guestname}} - FUSE-CL01'
```

## Retention Policy

| keep-last | keep-daily | keep-weekly | keep-monthly | keep-yearly |
|-----------|------------|-------------|--------------|-------------|
| 3 | 7 | 4 | 6 | 1 |

## Troubleshooting

### Backup Fails to Connect

```bash
curl -sk https://10.101.1.250:8007/api2/json/version
timeout 5 bash -c 'echo > /dev/tcp/10.101.1.250/8007' && echo "OK"
```

### Dirty Bitmap Missing

If backup shows full transfer instead of incremental, the next backup will restore incremental mode.

### fs-freeze Warning

Non-fatal - backup completes via live mode. Install qemu-guest-agent for cleaner snapshots.

## Verification Checklist

- [ ] Verify backup in PBS storage: `pvesm list PBS-DSN | grep <vmid>`
- [ ] Check backup size is reasonable
- [ ] Verify notes contain cluster identifier
- [ ] For critical VMs: Periodically test restore to staging
