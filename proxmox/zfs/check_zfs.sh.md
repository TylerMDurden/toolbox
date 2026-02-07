Hier ist ein kompaktes Skript, das du direkt in deine `.bashrc` oder als eigene Datei unter `/usr/local/bin/check_zfs.sh` ablegen kannst. Es prüft bei jedem Login, ob alle Pools gesund sind, und gibt nur dann eine Warnung aus, wenn etwas nicht stimmt.

### Einbau in deine Umgebung
1. Öffne deine `.bashrc`: `nano ~/.bashrc`
2. Füge das Skript am Ende ein.
3. Speichere mit `Strg+O`, `Enter` und schließe mit `Strg+X`.
