# DSN Skills

Claude Code plugin providing managed services skills for Proxmox infrastructure operations.

## Overview

This plugin provides specialized skills for DSN managed service operations including:

- **Backup and Recovery**: PBS backup, restore, and disaster recovery procedures
- **Proxmox Operations**: VM/CT management, cluster operations (coming soon)

## Installation

### Via Claude Code CLI

```bash
claude-code plugin install github:MrBloodrune/DSN-Skills
```

### Manual Installation

1. Clone the repository:
   ```bash
   git clone git@github.com:MrBloodrune/DSN-Skills.git ~/.claude/plugins/dsn-skills
   ```

2. Enable in Claude Code settings

## Skills

### backup-recovery

Comprehensive Proxmox Backup Server operations for VM/CT backup and disaster recovery.

**Triggers:**
- "backup a VM"
- "restore a container"
- "check backup status"
- "run host backup"
- "list backups"
- "recover from PBS"

**Features:**
- Real-world command examples with actual output
- Multi-cluster configuration (LTRKAR02-CL01, FUSE-CL01)
- Host configuration backup/restore
- Scheduled backup job management
- Troubleshooting procedures

## Supported Infrastructure

### PBS Server

| Property | Value |
|----------|-------|
| Server | LTRKAR02-PBS01 |
| Address | 10.101.1.250:8007 |
| Datastore | HDD-BACKUP (32.7 TB) |

### Connected Clusters

| Cluster | Namespace | Purpose |
|---------|-----------|---------|
| LTRKAR02-CL01 | DSN | DSN core services |
| FUSE-CL01 | Fuse | Managed customer |

## Usage Examples

### Quick Backup

```
User: Backup VM 1001 on LTRKAR02
Claude: [Uses backup-recovery skill to provide vzdump command with correct storage and notes template]
```

### Restore Procedure

```
User: How do I restore container 101 on FUSE?
Claude: [Uses backup-recovery skill to provide pct restore procedure with correct PBS storage]
```

### Check Backup Status

```
User: List recent backups for VM 1001
Claude: [Uses backup-recovery skill to provide pvesm list command]
```

## Development

### Structure

```
DSN-Skills/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── skills/
│   └── backup-recovery/
│       ├── SKILL.md          # Main skill definition
│       ├── references/       # Configuration references
│       ├── examples/         # Command examples
│       └── scripts/          # Utility scripts
└── README.md
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Add/update skills following the existing structure
4. Test with Claude Code
5. Submit a pull request

## License

MIT License - See LICENSE file for details.

## Author

DSN Network - admin@dsn.network
