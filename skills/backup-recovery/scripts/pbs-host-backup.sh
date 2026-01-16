#!/bin/bash
# PBS Host Backup Script
# Backs up critical host configuration to Proxmox Backup Server
#
# Installation:
#   1. Copy to /etc/cron.daily/pbs-host-backup
#   2. chmod +x /etc/cron.daily/pbs-host-backup
#   3. Update credentials for your cluster
#
# Usage:
#   Manual: /etc/cron.daily/pbs-host-backup
#   Logs:   journalctl -t pbs-host-backup --since today

set -e

# =============================================================================
# CONFIGURATION - Update for your cluster
# =============================================================================

# LTRKAR02-CL01 Configuration
# PBS_REPOSITORY="dsn-backup@pam@10.101.1.250:HDD-BACKUP"
# PBS_PASSWORD="<dsn-backup-password>"
# PBS_NAMESPACE="DSN"

# FUSE-CL01 Configuration
# PBS_REPOSITORY="fuse-backup@pam@10.101.1.250:HDD-BACKUP"
# PBS_PASSWORD="<fuse-backup-password>"
# PBS_NAMESPACE="Fuse"

# Common settings
PBS_FINGERPRINT="1d:f6:06:b2:b7:8b:6e:74:1c:c5:17:56:89:b7:d2:dd:9e:c2:e8:33:8f:03:01:57:63:19:71:f2:0f:02:fe:66"

# =============================================================================
# SCRIPT - Do not modify below
# =============================================================================

export PBS_REPOSITORY PBS_PASSWORD PBS_FINGERPRINT

HOSTNAME=$(hostname)
LOG_TAG="pbs-host-backup"

log() {
    echo "$1" | logger -t "$LOG_TAG"
    echo "$1"
}

log "Starting host backup for $HOSTNAME"

# Backup /etc and /root
proxmox-backup-client backup \
    etc.pxar:/etc \
    root.pxar:/root \
    --ns "$PBS_NAMESPACE" \
    --backup-id "$HOSTNAME" \
    --crypt-mode none \
    2>&1 | logger -t "$LOG_TAG"

RESULT=$?

if [ $RESULT -eq 0 ]; then
    log "Host backup completed successfully: $HOSTNAME"
else
    log "ERROR: Host backup failed with exit code $RESULT"
    exit $RESULT
fi
