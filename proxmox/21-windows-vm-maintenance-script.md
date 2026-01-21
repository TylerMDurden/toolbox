Dieses Wartungsskript automatisiert die wichtigsten Aufgaben, um eine Windows 11 oder Windows Server VM auf Proxmox performant und aktuell zu halten. Es kombiniert die Bereinigung des Speichers, die Optimierung der virtuellen Disk und die Installation von Sicherheitsupdates.

## 1. Das Wartungsskript (`Maintenance.ps1`)

Kopieren Sie diesen Code in eine Textdatei und speichern Sie diese als `Maintenance.ps1` (z. B. unter `C:\Scripts\`).

```powershell
# ==============================================================================
# Automatisches Wartungsskript für Windows-VMs unter Proxmox
# Aufgaben: Zeit-Sync, Updates, Cleanup, TRIM
# ==============================================================================

$LogFile = "C:\Scripts\Maintenance_Log.txt"
"--- Wartung gestartet am: $(Get-Date) ---" | Out-File $LogFile -Append

# 1. Zeitsynchronisation mit dem Host/Internet erzwingen
try {
    w32tm /resync /rediscover | Out-File $LogFile -Append
} catch {
    "Zeitsync fehlgeschlagen" | Out-File $LogFile -Append
}

# 2. Windows Updates suchen und installieren (erfordert Modul PSWindowsUpdate)
if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
    "Suche nach Updates..." | Out-File $LogFile -Append
    Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot | Out-File $LogFile -Append
} else {
    "Fehler: Modul PSWindowsUpdate nicht installiert." | Out-File $LogFile -Append
}

# 3. Systembereinigung (Alte Update-Dateien entfernen)
"Starte Systembereinigung (DISM)..." | Out-File $LogFile -Append
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-File $LogFile -Append

# 4. SSD-Optimierung (TRIM)
# Wichtig für Proxmox, um belegten Speicherplatz auf dem Host freizugeben
"Starte TRIM auf Laufwerk C:..." | Out-File $LogFile -Append
Optimize-Volume -DriveLetter C -ReTrim -Verbose 2>&1 | Out-File $LogFile -Append

"--- Wartung abgeschlossen am: $(Get-Date) ---" | Out-File $LogFile -Append
```

## 2. Automatisierung via Aufgabenplanung (Task Scheduler)

Damit das Skript regelmäßig ohne manuelles Eingreifen läuft, muss es in der Windows-Aufgabenplanung hinterlegt werden.

1. Öffnen Sie die Aufgabenplanung (Task Scheduler).
2. Klicken Sie auf „Einfache Aufgabe erstellen“ (Create Basic Task).
   - **Name:** `System_Maintenance`
   - **Trigger:** Wöchentlich (z. B. Sonntag, 03:00 Uhr).
3. **Aktion:** „Programm starten“
   - **Programm/Skript:** `powershell.exe`
   - **Argumente hinzufügen:** `-ExecutionPolicy Bypass -File "C:\Scripts\Maintenance.ps1"`
   - **Wichtig:** Öffnen Sie nach dem Erstellen die Eigenschaften der Aufgabe und aktivieren Sie **„Mit höchsten Privilegien ausführen“**, da DISM und Windows Updates Administratorrechte benötigen.

## 3. Vorteile dieses Setups
- **Host-Speicherschonung:** Durch den `ReTrim`-Befehl und die DISM-Bereinigung wird sichergestellt, dass die virtuelle Disk (`.qcow2` oder ZFS-Volume) auf dem Proxmox-Host nicht unnötig anwächst.
- **Performance:** Die VM bleibt durch das Entfernen von Systemballast reaktionsschnell.
- **Sicherheit:** Sicherheitsupdates werden automatisch eingespielt, ohne dass eine manuelle Anmeldung erforderlich ist.




