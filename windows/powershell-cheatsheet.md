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
```

## 📂 Dateisystem
Navigation wie im Explorer, nur schneller.

```powershell
# Liste alle Dateien auf (wie 'ls' oder 'dir')
Get-ChildItem

# Erstelle einen neuen Ordner
New-Item -Path "C:\Temp\NeuerOrdner" -ItemType Directory

# Dateiinhalt anzeigen (wie 'cat')
Get-Content -Path "C:\Logs\Error.log" -Tail 10  # Zeigt nur die letzten 10 Zeilen

# Datei kopieren
Copy-Item -Path "C:\Quelle\Datei.txt" -Destination "D:\Ziel\"

# Datei/Ordner löschen (Vorsicht! -Force erzwingt das Löschen)
Remove-Item -Path "C:\Temp\AlteDatei.txt" -Force

# Datei verschieben
Move-Item -Path "C:\Downloads\Bild.jpg" -Destination "C:\Bilder\"
```

## ⚙️ Dienste & Prozesse
Windows-Dienste steuern und hängende Programme beenden.

| Befehl | Beschreibung | Beispiel |
| :--- | :--- | :--- |
| `Get-Service` | Listet Dienste auf. | `Get-Service *Print*` |
| `Restart-Service` | Startet einen Dienst neu. | `Restart-Service -Name Spooler` |
| `Get-Process` | Zeigt laufende Prozesse an. | `Get-Process chrome` |
| `Stop-Process` | Beendet einen Prozess ("Task killen"). | `Stop-Process -Name notepad -Force` |

**Beispiel:** Einen Dienst finden und neustarten, wenn er gestoppt ist.
```powershell
Get-Service -Name wuauserv | Start-Service
```

**Aktivierung Hyper-V**

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

*Wichtig: Der Neustart*

Egal welche Methode du wählst: Du musst den PC neu starten. Hyper-V ist ein Typ-1-Hypervisor, der sich tief ins System gräbt; das wird erst nach dem Booten aktiv.
Nach dem Neustart findest du im Startmenü den Hyper-V-Manager, mit dem du deine VMs verwalten kannst.

## 🔧 Die Pipeline: Filtern, Sortieren & Ändern
Das Herzstück von PowerShell: Daten von links nach rechts weiterreichen (`|`).

```powershell
# Where-Object: Filtern (Zeige nur das, was wahr ist)
# Beispiel: Zeige alle Dienste, die gestoppt sind
Get-Service | Where-Object { $_.Status -eq 'Stopped' }

# Sort-Object: Sortieren
# Beispiel: Die Top 5 Prozesse mit der höchsten CPU-Last
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5

# ForEach-Object: Schleife für jedes Element
# Beispiel: Starte jeden gestoppten Dienst mit "XXbox" im Namen
Get-Service *Xbox* | Where-Object Status -eq 'Stopped' | ForEach-Object { Start-Service $_.Name }
```

## 💾 Export & Reporting
Ergebnisse nicht nur anzeigen, sondern speichern (CSV, Text, HTML).

```powershell
# Liste der Dienste in eine CSV-Datei exportieren (perfekt für Excel)
Get-Service | Export-Csv -Path "C:\Temp\Dienste.csv" -NoTypeInformation -Encoding UTF8

# Ergebnis in eine Textdatei schreiben
Get-IPConfiguration | Out-File "C:\Temp\NetzwerkConfig.txt"

# HTML-Report erstellen
Get-Process | Select-Object Name, Id, CPU | ConvertTo-Html | Out-File "ProcessReport.html"
```

## 🔐 Benutzerverwaltung (Active Directory)
*Hinweis: Benötigt installierte RSAT-Tools.*

```powershell
# Einen AD-Benutzer suchen
Get-ADUser -Identity "mmustermann" -Properties *

# Passwort eines Benutzers zurücksetzen
Set-ADAccountPassword -Identity "mmustermann" -Reset -NewPassword (ConvertTo-SecureString "NeuesPasswort123!" -AsPlainText -Force)

# Benutzer entsperren
Unlock-ADAccount -Identity "mmustermann"
```
