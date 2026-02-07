# ZFS Pool Health Check & Logging für Zion
check_zfs_health() {
    LOG_FILE="/var/log/zfs_monitor.log"
    # Suche nach Pools, die nicht "ONLINE" sind
    FAILED_POOLS=$(zpool list -H -o name,health | grep -v "ONLINE")

    if [ -n "$FAILED_POOLS" ]; then
        TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
        
        # Fehlermeldung für die Shell
        echo -e "\n\e[1;31m[ACHTUNG] ZFS Pool Fehler erkannt!\e[0m"
        echo "$FAILED_POOLS"
        
        # In Log-Datei schreiben (falls Schreibrechte vorhanden)
        # Wir nutzen 'sudo tee -a', falls das Skript mal ohne Root-Rechte läuft
        echo "[$TIMESTAMP] KRITISCH: Pools nicht ONLINE: $FAILED_POOLS" | sudo tee -a "$LOG_FILE" > /dev/null
        
        echo -e "\e[1;33mDetails wurden in $LOG_FILE geloggt.\e[0m\n"
    else
        echo -e "\e[32m✔ ZFS Status OK\e[0m"
    fi
}

check_zfs_health
