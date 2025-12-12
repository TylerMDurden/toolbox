# 💻 PowerShell Cheatsheet

Eine Sammlung der wichtigsten Befehle für die Systemadministration.

## 🆘 Hilfe & Entdecken
Der wichtigste Befehl überhaupt: Wenn du nicht weiterweißt, frag das System.

| Befehl | Beschreibung | Beispiel |
| :--- | :--- | :--- |
| `Get-Help` | Zeigt Hilfe zu einem Befehl an (wie `man` in Linux). | `Get-Help Get-Service -Full` |
| `Get-Command` | Findet Befehle anhand des Namens. | `Get-Command *Network*` |
| `Get-Member` | **Super wichtig!** Zeigt an, welche Eigenschaften/Methoden ein Objekt hat. | `Get-Date | Get-Member` |
| `Select-Object` | Wählt nur bestimmte Eigenschaften aus (filtert die Ausgabe). | `Get-Service | Select-Object Name, Status` |

## 🌐 Netzwerk & Troubleshooting
Besser als ping: Echte Port-Tests.

```powershell
# Prüfen, ob ein Server auf einem bestimmten Port antwortet (z.B. RDP Port 3389)
Test-NetConnection -ComputerName 192.168.178.1 -Port 3389

# Die eigene IP-Konfiguration anzeigen (besser als ipconfig)
Get-NetIPConfiguration

# DNS-Cache am Client löschen
Clear-DnsClientCache

### 📂 Dateisystem

Navigation wie im Explorer, nur schneller.

# Liste alle Dateien auf (wie 'ls' oder 'dir')
Get-ChildItem

# Erstelle einen neuen Ordner
New-Item -Path "C:\Temp\NeuerOrdner" -ItemType Directory

# Dateiinhalt anzeigen (wie 'cat')
Get-Content -Path "C:\Logs\Error.log" -Tail 10  # Zeigt nur die letzten 10 Zeilen
