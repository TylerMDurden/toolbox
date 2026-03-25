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
.\NewvmallV56.ps1
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

## Versionsverlauf

| Version | Änderung |
|---------|----------|
| V 1.x | Grundversion, manuelle Einzelerstellung |
| ... | ... |
| V 5.6 | Aktuelle Version – vollautomatisches Deployment mit Switch-Liste, Log-Ordner, Admin-Check |
