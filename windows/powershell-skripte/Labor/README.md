# VIT-Labor Automatisierung – Hyper-V VM Deployment

PowerShell-Script zur vollautomatischen Erstellung einer kompletten Laborumgebung in Hyper-V.  
Entwickelt im Rahmen der IT-Umschulung im Fach VIT.

---

## Was macht das Script?

Das Script erstellt aus SysPrep-Images per Massenproduktion beliebig viele VMs in einer konfigurierbaren Laborumgebung:

- **Windows 11 Clients** (z. B. für einzelne Standorte)
- **Windows Server 2022** (als Router, DHCP-Server, DNS-Server, Domain Controller)
- **Private virtuelle Switches** (automatisch erstellt falls nicht vorhanden)
- **Differenzierende VHDX-Disks** (spart Speicher, basiert auf SysPrep-Images)
- **Optionaler Auto-Start** der VMs nach Erstellung

---

## Voraussetzungen

- Windows mit aktiviertem **Hyper-V**
- **PowerShell als Administrator** ausführen
- SysPrep-Images vorhanden:
  - `C:\SysPrep\Win11-SysPrep.vhdx`
  - `C:\SysPrep\S-2022-sysprep_10_07_2025.vhdx`
- Ordner vorhanden:
  - `C:\HyperV\VM`
  - `C:\HyperV\VHDX`

---

## Konfiguration

Am Anfang des Scripts gibt es eine Konfigurationssektion, die du anpassen kannst:

```powershell
$VMListe = @(
    @{ Name = "CL-A-Stadt"; OS = "Client"; Switch = "A-Stadt"; CPU = 2; RAM = 2GB },
    @{ Name = "Router-A-Stadt"; OS = "Server"; Switch = "A-Stadt"; CPU = 4; RAM = 2GB },
    @{ Name = "DHCP-1"; OS = "Server"; Switch = "Backbone_one"; CPU = 4; RAM = 2GB }
    # beliebig viele weitere VMs...
)

$SwitchListe = @("Backbone_two")  # zusätzliche Switches ohne VM
$vmStart = "nein"                  # "ja" um VMs sofort zu starten
```

| Parameter | Bedeutung |
|-----------|-----------|
| `Name` | VM-Name in Hyper-V |
| `OS` | `"Client"` (Win11) oder `"Server"` (WS2022) |
| `Switch` | Virtueller Switch – wird automatisch erstellt |
| `CPU` | Anzahl vCPUs |
| `RAM` | Arbeitsspeicher (z. B. `2GB`, `4GB`) |

---

## Ausführung

```powershell
# PowerShell als Administrator öffnen
.\NewvmLabor.ps1
```

Das Script prüft automatisch:
- Admin-Rechte
- Ob alle Ordner und Images vorhanden sind
- Ob VMs oder VHDX-Dateien bereits existieren (überspringt Duplikate)

---

## Nach der Erstellung

Folgende Schritte sind nach dem Script noch manuell nötig:

- **Computernamen** in den VMs ändern
- **Netzwerkadapter umbenennen**
- Ggf. **weitere NICs hinzufügen** und umbenennen
- Rollen konfigurieren (DHCP, DNS, Routing etc.)

---

## Weitere Scripts (tools/)

Kleine Hilfsskripte für einzelne Aufgaben im Labor.

| Script | Beschreibung |
|--------|-------------|
| `NewHDDClient.ps1` | Erstellt eine einzelne differenzierende VHDX aus dem Win11-SysPrep-Image |
| `NewInternalSwitch.ps1` | Erstellt einen einzelnen privaten Switch – mit Prüfung ob er bereits existiert |
| `VMstart.ps1` | Startet alle Labor-VMs per Liste – erhöht sich automatisch auf Admin-Rechte |
| `VMstop.ps1` | Stoppt alle Labor-VMs per Liste |

> Die VM-Namen in `VMstart.ps1` und `VMstop.ps1` müssen an die eigene Laborumgebung angepasst werden.

---

## Versionsverlauf

| Version | Änderung |
|---------|----------|
| v1 | Einzelne VM aus bestehender VHDX erstellen |
| v2.0 | Umstieg auf SysPrep mit differenzierender Disk |
| v2.1 | VHDX-Pfad dynamisch aus VM-Name generiert |
| v2.2 | Fehlerprüfung für SysPrep, Ordner und Switch hinzugefügt |
| v2.3 | OS-Variable eingeführt, Client/Server-Auswahl, vollständige Validierung |
| v3.0 | Massenproduktion – Schleife für mehrere VMs gleichzeitig |
| v3.1 | Mehrere NICs pro VM mit individuellen Namen konfigurierbar |
| v3.2 | Experiment: NIC-Umbenennen im Gast via PowerShell Direct |
| v4.0 | Umbenennung – Script zu vollständigem Labor-Deployment zusammengeführt |
| v4.1 | `vmStart`-Variable – optionaler Auto-Start der VMs |
| v5.0 | Versionskopfzeile eingeführt, vollständige Labor-VM-Liste |
| v5.1 | RAM als konfigurierbare Variable pro VM |
| v5.11 | SysPrep-Pfad in BaseDir verschoben, Log-Ordner hinzugefügt |
| v5.3 | SwitchListe für zusätzliche Switches, Transcript-Logging |
| v5.4 | Zwei-Standort-Unterstützung (Haus A6/W10), NIC-Umbenennung per Passthru |
| v5.5 | Log-Ordner wird automatisch erstellt falls fehlend |
| **v5.6** | **Aktuelle Version** – SwitchListe ans Ende verschoben, produktionsreife VM-Liste |
