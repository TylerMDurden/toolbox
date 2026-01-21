# PowerShell-Referenz: Windows 11 VM-Management

Diese Sammlung konzentriert sich auf die Wartung, Benutzerverwaltung und Systemdiagnose von Windows 11 in einer virtualisierten Umgebung.

## 1. Windows Updates via CLI

Da Windows 11 in der Standardinstallation kein natives PowerShell-Modul für Updates besitzt, wird das bewährte Modul `PSWindowsUpdate verwendet.

### Modul installieren und vorbereiten
```powershell
# Installation des Moduls (einmalig erforderlich)
Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck

# Importieren des Moduls
Import-Module PSWindowsUpdate
```

### Updates suchen und installieren
```powershell
# Liste aller verfügbaren Updates anzeigen
Get-WindowsUpdate

# Alle verfügbaren Updates installieren und ggf. automatisch neu starten
Install-WindowsUpdate -AcceptAll -AutoReboot
```

## 2. Lokale Benutzerverwaltung

Besonders nützlich für VMs, die nicht in einer Domäne (Active Directory) eingebunden sind.

### Neuen lokalen Benutzer anlegen
```powershell
$password = Read-Host -AsSecureString
New-LocalUser -Name "Admin_Micha" -Password $password -FullName "Michael" -Description "Lokaler Administrator"
```

### Benutzer einer Gruppe hinzufügen (z. B. Administratoren)
```powershell
Add-LocalGroupMember -Group "Administratoren" -Member "Admin_Micha"
```

## 3. Systemdiagnose und Ressourcen

Befehle zur Überprüfung der VM-Gesundheit direkt aus der Shell.
| Befehl | Zweck |
| :--- | :--- |
| `Get-ComputerInfo` | Detaillierte Systeminformationen (OS-Version, Build, etc.) |
| `Get-Service` | `Where-Object {$_.Status -eq "Running"}` |
| `Get-Process` | `Sort-Object CPU -Descending` |
| `Get-Volume` | Übersicht über alle Partitionen und deren Füllstand |

## 4. Remote Management (WinRM)

Damit die VM bequem von einem anderen Rechner verwaltet werden kann (ähnlich wie SSH unter Linux).

### WinRM aktivieren
```powershell
# Aktiviert Windows Remote Management und öffnet die Firewall-Ports
Enable-PSRemoting -Force
```
### Remote-Verbindung testen
```powershell
# Prüfen, ob die VM für Remote-Verbindungen erreichbar ist
Test-WSMan -ComputerName "VM-IP-Adresse"
```

## 5. VM-spezifische Optimierungsbefehle

### Speicherplatz freigeben (Komponentenstore bereinigen)

Nach großen Updates belegen alte Versionen oft Gigabytes an Platz auf der virtuellen Disk.
```powershell
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
```

### Zeit-Synchronisation erzwingen

Wichtig, damit die VM-Uhrzeit nicht vom Proxmox-Host abweicht (wichtig für Logfiles und Protokolle).
```powershell
w32tm /resync
```


