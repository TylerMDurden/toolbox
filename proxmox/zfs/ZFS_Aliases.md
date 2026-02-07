Kopiere diesen Block einfach ans Ende deiner ~/.bashrc (sowohl auf Zion als auch in der TrueNAS-Shell):

```bash
# --- ZFS Aliases für Zion ---

# Status & Info
alias zps='zpool status -v'            # Ausführlicher Pool-Status
alias zpl='zpool list'               # Schnelle Pool-Übersicht
alias zfl='zfs list'                 # Alle Datasets anzeigen
alias zios='zpool iostat -v 5'       # Live-IO-Monitoring (alle 5 Sek.)

# Snapshot Management
alias zsnaps='zfs list -t snapshot'  # Alle Snapshots auflisten

# Hilfsfunktion für schnelle Snapshots
# Nutzung: zsnap poolname/dataset name_des_snapshots
zsnap() {
    if [ -z "$2" ]; then
        echo "Nutzung: zsnap <pool/dataset> <name>"
    else
        zfs snapshot "$1"@"$(date +%Y-%m-%d)"_"$2"
        echo "Snapshot $1@$(date +%Y-%m-%d)_$2 erstellt."
    fi
}

# Wartung
alias zscrub='zpool scrub'           # Nutzung: zscrub poolname
```

### So aktivierst du die Änderungen:

Nachdem du den Code in die Datei eingefügt hast, musst du die Konfiguration neu laden:
```bash
source ~/.bashrc
```
