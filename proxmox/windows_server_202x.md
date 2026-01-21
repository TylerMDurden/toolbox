# Dokumentation: Windows Server 2022/2025 unter Proxmox VE

Diese Dokumentation beschreibt die optimale Konfiguration, Installation und Sicherung von Windows Server 2022 oder 2025 als virtuelle Maschine (VM).

---

## 1. Systemvoraussetzungen (Sizing)

Für einen stabilen Betrieb sollten folgende Ressourcen bereitgestellt werden:

| Komponente       | Empfehlung (Standard) | Minimum (Test) |
| :--------------- | :-------------------- | :------------- |
| **vCPU Kerne** | 4 Kerne (Type: Host)  | 2 Kerne        |
| **Arbeitsspeicher**| 8 GB - 16 GB          | 4 GB           |
| **Systemdisk (C:)**| 100 GB - 150 GB       | 64 GB          |
| **Disk-Interface**| VirtIO SCSI single    | VirtIO SCSI    |

---

## 2. Vorbereitung

Folgende ISO-Dateien müssen im Proxmox-Speicher bereitstehen:
1. **Windows Server ISO** (2022 oder 2025).
2. **VirtIO-Win ISO** (Aktuelle Stable-Version für Treiber).

---

## 3. VM-Konfiguration in Proxmox

Beim Erstellen der VM sind folgende Einstellungen unter den jeweiligen Reitern zu wählen:

### System
- **Machine:** `q35`
- **BIOS:** `OVMF (UEFI)`
- **Add EFI Disk:** Ja (Speicherort wählen)
- **Add TPM:** Ja (Zwingend erforderlich für Server 2025)

### Disks
- **Bus/Device:** `SCSI`
- **Controller:** `VirtIO SCSI single`
- **Caching:** `Write back` (Optimale Performance für SSD/NVMe)
- **Discard:** Aktivieren (TRIM-Support)
- **SSD Emulation:** Aktivieren



### CPU
- **Type:** `host` (Reicht CPU-Befehlssätze für maximale Performance durch)

### Network
- **Model:** `VirtIO (paravirtualized)`

---

## 4. Installationsvorgang

1. VM starten und das Windows-Setup aufrufen.
2. Wenn kein Ziellaufwerk angezeigt wird: **"Treiber laden" (Load Driver)** wählen.
3. Pfad auf der VirtIO-ISO auswählen: `vioscsi\2k22\amd64` (kompatibel mit 2022/2025).
4. Nach Erkennung der Festplatte die Installation wie gewohnt abschließen.



---

## 5. Post-Installation & Treiber

Nach dem ersten Windows-Login müssen die restlichen Treiber installiert werden:

1. **VirtIO Tools:** Die Datei `virtio-win-gt-x64.msi` auf der VirtIO-ISO ausführen. Dies installiert Netzwerk-, Grafiktreiber und den **QEMU Guest Agent**.
2. **Guest Agent:** In Proxmox unter **Options** -> **QEMU Guest Agent** auf `Enabled` stellen (VM danach neu starten).
3. **Optimierung:** Windows-Energiesparplan auf "Höchstleistung" setzen.

---
## 6. Erweiterte Netzwerkkonfiguration

### 6.1 VLAN-Konfiguration (Proxmox-Ebene)
Um die VM in ein spezifisches VLAN zu hängen, wird dies direkt in den Hardware-Einstellungen der VM in Proxmox definiert:

1. Gehen Sie zu **Hardware** -> **Network Device**.
2. Geben Sie im Feld **VLAN Tag** die entsprechende ID ein (z. B. `10`).
3. Stellen Sie sicher, dass die Bridge (meist `vmbr0`) als **VLAN aware** markiert ist (unter System -> Network).



### 6.2 Statische IP-Adresse via PowerShell
Nachdem die VirtIO-Netzwerktreiber installiert sind, kann die IP-Konfiguration effizient über die PowerShell vorgenommen werden. Öffnen Sie die PowerShell als Administrator:

#### 1. Interface-Namen ermitteln:
```powershell
Get-NetAdapter
```

#### 2. IP-Adresse, Gateway und DNS setzen: (Ersetzen Sie "Ethernet" durch den Namen aus Schritt 1)
```powershell
# IP und Gateway setzen
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.10.50 -PrefixLength 24 -DefaultGateway 192.168.10.1

# DNS-Server konfigurieren
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("192.168.10.1", "8.8.8.8")
```

---
## 7. Automatisierte Backup-Strategie

Um die VM konsistent im laufenden Betrieb zu sichern, wird folgende Konfiguration empfohlen:

### Backup-Job erstellen (Datacenter -> Backup)
- **Mode:** `Snapshot` (Erfordert installierten QEMU Guest Agent für VSS-Konsistenz).
- **Compression:** `ZSTD` (Hohe Geschwindigkeit, gute Kompression).
- **Schedule:** Täglich (z.B. nachts um 02:00 Uhr).

### Retention (Aufbewahrung)
- **Keep last:** 7 (Behält die Sicherungen der letzten 7 Tage).
- **Keep weekly:** 4 (Behält eine Sicherung pro Woche für einen Monat).

> **Hinweis:** Ein Backup im Modus "Snapshot" friert das Dateisystem kurzzeitig über den VSS-Dienst ein, sodass auch Datenbanken (z.B. Active Directory oder SQL) konsistent gesichert werden.

## 8. Performance-Optimierung (Zusammenfassung)

- Energiesparplan: In Windows auf "Höchstleistung" stellen
- Trim/Discard: Sicherstellen, dass Windows die Festplatte als SSD erkennt (`Optimize-Volume -DriveLetter C -ReTrim`)
- QEMU Guest Agent: Erforderlich für sauberes Herunterfahren und konsistente Snapshots

