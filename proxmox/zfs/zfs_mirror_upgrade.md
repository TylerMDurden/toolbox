# Guide: ZFS Mirror Upgrade auf Zion 🛠️

Dieser Guide beschreibt den Prozess, wie man eine zweite SSD (Samsung PM883) zu einem bestehenden Single-Disk Pool hinzufügt, um Redundanz (Mirror/RAID-1) zu schaffen.

---

## ⚠️ Wichtigster Unterschied: Attach vs. Add
Bevor du startest, musst du den Unterschied kennen. Ein Fehler hier kann das Setup ruinieren:
* **`zpool attach`**: Fügt eine Platte zu einer bestehenden hinzu -> **Mirror (Sicherheit)**. ✅ *Das ist unser Ziel.*
* **`zpool add`**: Fügt den Speicherplatz einfach hinzu -> **Stripe (Keine Sicherheit)**. ❌ *Datenverlust bei Ausfall einer Platte!00*

---

## Schritt 1: Identifikation der neuen Platte
ZFS sollte immer über die **Disk-ID** angesprochen werden, da sich `/dev/sdX` Bezeichnungen ändern können.

1. Liste alle IDs auf:
   ```bash
   ls -l /dev/disk/by-id/
   ```
2. Suche nach der neuen **Samsung PM883**. Kopiere dir die vollständige ID (z.B. `ata-SAMSUNG_MZ7LH960HAJR-00005_S4XXXXXXXXX`).

## Schritt 2: Aktuellen Pool-Status prüfen

Stelle sicher, wie der Pool und die vorhandene Disk heißen.

```bash
zpool status
```
*Notiere dir den Pool-Namen und die ID der vorhandenen Disk.*

## Schritt 3: Den Mirror erstellen

Führe den `attach` Befehl aus. Die Syntax lautet: `zpool attach [Pool] [Alte-ID] [Neue-ID]`
**Befehl:**
```bash
# Beispiel (IDs müssen angepasst werden!)
zpool attach vm-storage-pool ata-SAMSUNG_PM883_ALTE_ID ata-SAMSUNG_PM883_NEUE_ID
```
  *Hinweis: Falls die Platte vorher in einem anderen System war, nutze `-f` (force), um ZFS zu zwingen, die Platte zu überschreiben: `zpool attach -f [Pool] [Alte-ID] [Neue-ID]`*

## Schritt 4: Überwachung des Resilvering

ZFS kopiert nun alle Daten von der ersten auf die zweite SSD. Diesen Vorgang nennt man Resilvering.
* **Status prüfen:**
  ```bash
  zpool status
  ```
  Dort siehst du den Fortschritt in Prozent und die geschätzte Dauer.
* **IO-Last beobaschten:**
  ```bash
  zpool iostat -v 5
  ```
## Schritt 5: Abschluss-Check

Wenn das Resilvering abgeschlossen ist, sollte der Status auf `ONLINE` stehen und die Struktur so aussehen:
    
```plain
NAME                                     STATE     READ WRITE CKSUM
        vm-storage-pool                          ONLINE       0     0     0
          mirror-0                               ONLINE       0     0     0
            ata-SAMSUNG_PM883_ALTE_ID            ONLINE       0     0     0
            ata-SAMSUNG_PM883_NEUE_ID            ONLINE       0     0     0
```





     
