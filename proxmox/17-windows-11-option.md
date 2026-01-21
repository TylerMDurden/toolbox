# Dokumentation: Windows 11 unter Proxmox VE

Diese Anleitung beschreibt die spezifischen Hardware-Anforderungen, den Bypass des Microsoft-Konto-Zwangs sowie die anschließende Optimierung des Systems für den Betrieb als virtuelle Maschine.

---

## 1. Spezifische Hardware-Anforderungen (Proxmox)

Windows 11 stellt im Vergleich zu Windows Server striktere Anforderungen an die virtuelle Hardware. Diese müssen im Reiter **System** bei der Erstellung der VM zwingend gesetzt werden:

| Einstellung        | Anforderung             | Umsetzung in Proxmox                      |
| :----------------- | :---------------------- | :---------------------------------------- |
| **BIOS** | UEFI (zwingend)         | `OVMF (UEFI)`                             |
| **Machine** | Moderner Chipsatz       | `q35`                                     |
| **TPM** | Version 2.0             | Häkchen bei `Add TPM` setzen (v2.0)       |
| **EFI Storage** | Speicher für UEFI-Vars  | Wird bei Wahl von OVMF automatisch angelegt|
| **CPU Type** | Kompatibilität          | `host` (für volle Featuresätze)           |
| **Disk-Controller**| Performance             | `VirtIO SCSI single`                      |

---

## 2. Bypass: Microsoft-Konto & Internetzwang

Um Windows 11 mit einem lokalen Benutzerkonto ohne Internetverbindung und ohne Microsoft-Konto zu installieren, kann während des Setups der OOBE-Bypass genutzt werden.

#### Vorgehensweise:
1. Das Setup bis zur Sprachauswahl/Region durchlaufen lassen
2. Sobald die Aufforderung zur Internetverbindung erscheint: `Shift + F10` drücken (öffnet die Eingabeaufforderung)
3. Folgenden Befehl eingeben und mit Enter bestätigen:
   ```cmd
   OOBE\BYPASSNRO
   ```
4. Die VM startet automatisch neu
5. Im erneuten Setup-Prozess erscheint nun die Option **"Ich habe kein Internet"**
6. Anschließend auf **"Mit eingeschränktem Setup fortfahren"** klicken, um ein lokales Konto zu erstellen

## 3. Nachträgliche Optimierung (Post-Install)

Um die Ressourcenbelastung auf dem Proxmox-Node zu minimieren, sollten folgende Schritte durchgeführt werden

### 3.1 Automatisches Debloating

Verwendung des Chris Titus Tech Windows Utility, um Telemetrie zu deaktivieren und unnötige Apps zu entfernen
1. PowerShell als Administrator starten
2. Befehl ausführen:
   ```powershell
   irm christitus.com/win | iex
   ```
3. Im Bereich `"Tweaks"` die Option `"Desktop"` wählen und `"Run Tweaks"` klicken

#### 3.1.1 Essential Tweaks (Empfohlen für VMs)

Diese Tweaks reduzieren die Hintergrundlast und Telemetrie:
- **Disable Telemetry:** Verhindert das Senden von Diagnosedaten an Microsoft
- **Disable Activity History:** Schaltet die Protokollierung von Nutzeraktivitäten ab
- **Disable Location Tracking:** Deaktiviert Standortdienste
- **Disable GameDVR:** Schaltet Hintergrund-Aufnahmefunktionen ab (spart CPU)
- **Set Services to Manual:** Setzt nicht kritische Dienste auf manuellen Start

#### 3.1.2 Advanced Tweaks (Vorsicht geboten)

Für eine maximale Entschlackung der VM auf Proxmox:
- **Disable Background Apps:** Verhindert, dass Microsoft-Store-Apps im Hintergrund laufen
- **Disable Microsoft Copilot:** Entfernt die KI-Integration (spart Ressourcen)
- **Disable Edge:** Optional, wenn ein anderer Browser bevorzugt wird
- **Remove All MS Store Apps:** Nur empfohlen, wenn eine extrem schlanke Umgebung ohne Store-Funktionalität benötigt wird

#### 3.1.3 Customize Preferences

Hier können visuelle und funktionale Anpassungen vorgenommen werden:
- **Dark Theme:** Reduziert die Helligkeit (angenehmer in Konsolen-Fenstern)
- **Bing Search in Start Menu:** Deaktivieren, um lokale Suchen schneller und ohne Web-Abfragen zu machen
- **Taskbar Alignment:** Umstellen auf "Links" (Classic), falls gewünscht

## 4. Speicher-Optimierung (TRIM/Discard)

Damit gelöschter Speicherplatz innerhalb der VM auch auf dem Proxmox-Host freigegeben wird:
1. **Discard:** Stellen Sie sicher, dass in den Proxmox-Hardware-Optionen der Disk `Discard` aktiviert ist.
2. **Disk Timeout:** Erhöhen Sie den Timeout in der Registry, um Verzögerungen bei Host-Backups abzufangen:
   ```powershell
   Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\disk" -Name "TimeOutValue" -Value 60
   ```
4. **Manueller TRIM:** Führen Sie in Windows gelegentlich folgenden Befehl aus:
   ```powershell
   # Manuelles TRIM der Systempartition
   Optimize-Volume -DriveLetter C -ReTrim -Verbose
   ```

## 5. QEMU Guest Agent

Stellen Sie sicher, dass nach der Installation der VirtIO-Treiber der QEMU-Gast-Agent aktiv ist:
- In Windows: Dienst `QEMU Guest Agent` muss laufen
- In Proxmox: `Options` -> `QEMU Guest Agent` -> `Enabled`












