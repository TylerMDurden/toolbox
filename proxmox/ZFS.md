# ZFS Cheat Sheet für Zion 🚀

Diese Übersicht enthält die wichtigsten ZFS-Befehle für die Verwaltung der Storage-Pools auf dem Proxmox-Knoten **Zion** und der **TrueNAS SCALE** VM.

---

## 1. Status & Integrität prüfen
*Regelmäßiger Check, um den Zustand der NVMe- und SATA-Pools zu überwachen.*

| Befehl | Beschreibung |
| :--- | :--- |
| `zpool status` | Detaillierter Status aller Pools (Fehler, Struktur, Resilver-Fortschritt). |
| `zpool list` | Schnelle Übersicht über Kapazität, Belegung und Fragmentierung. |
| `zfs list` | Auflistung aller Datasets inkl. Mountpoints und Kompressionsraten. |
| `zpool iostat -v 5` | Echtzeit-Statistik der Schreib-/Leselast pro Laufwerk (alle 5 Sek). |

---

## 2. Datasets & Snapshots
*Wichtig für Backups und die logische Trennung von VM-Daten.*

* **Dataset erstellen:**
  ```bash
  zfs create poolname/datasetname
  ```
* **Snapshot erstellen (vor Updates):**
  ```bash
  zfs snapshot poolname/datasetname@beschreibung_datum
  ```
* **Snapshots auflisten:**
  ```bash
  zfs list -t snapshot
  ```
* **Rollback durchführen:**
  ```bash
  zfs rollback poolname/datasetname@zeitstempel
  ```
  *> Hinweis: Ein Rollback löscht alle Daten, die nach dem Snapshot geschrieben wurden.*
  
## 3. Wartung & Performance
*Optimierung für die Samsung SSDs und die IronWolf HDDs.*
* **ZFS Scrub (Datenprüfung): Stellt die Integrität sicher, indem Prüfsummen verglichen werden.**
  ```bash
  zpool scrub poolname
  ```
* **TRIM für SSDs: Wichtig für die Langlebigkeit der Samsung 980 Pro und PM883.**
  ```bash
  zpool set autotrim=on poolname
  ```
* **ARC (Cache) Status:**
  ```bash
  arcstat
  ```
## 4. Hardware-Tausch (HDD/SSD Failure)
*Vorgehen bei einem Defekt im ZFS Mirror.*
1. Defekte Platte offline nehmen:
   ```bash
   zpool offline poolname gerätename
   ```
2. Platte physisch tauschen.
3. Platte im Pool ersetzen:
   ```bash
   zpool replace poolname alte_id neue_id
   ```

---

### 💡 Wichtiger Hinweis für Zion

Da der LSI HBA per Passthrough direkt an die TrueNAS SCALE VM durchgereicht wird:
* Befehle für die 6TB IronWolf-Platten direkt in der TrueNAS-Shell ausführen.
* Befehle für den Host-OS Pool (NVMe) und den VM-Storage (PM883) direkt in der Proxmox-Shell ausführen.











