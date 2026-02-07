# ZFS Pool Health Check für Zion
check_zfs_health() {
    # Suche nach Pools, die nicht "ONLINE" sind
    FAILED_POOLS=$(zpool list -H -o name,health | grep -v "ONLINE")

    if [ -n "$FAILED_POOLS" ]; then
        echo -e "\n\e[1;31m[ACHTUNG] ZFS Pool Warnung auf Zion:\e[0m"
        echo -e "\e[31mFolgende Pools sind nicht im Zustand ONLINE:\e[0m"
        echo "$FAILED_POOLS"
        echo -e "\e[1;33mPrüfe den Status sofort mit: zpool status\e[0m\n"
    else
        # Optional: Kurze Erfolgsmeldung (kannst du auch auskommentieren)
        echo -e "\e[32m✔ Alle ZFS Pools auf Zion sind ONLINE.\e[0m"
    fi
}

# Skript ausführen
check_zfs_health
