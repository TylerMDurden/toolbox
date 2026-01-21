# Definition der Farben für die Ausgabe
$HeaderColor = "Cyan"

Clear-Host

Write-Host "--- SYSTEM-DIAGNOSE-BERICHT ---" -ForegroundColor $HeaderColor

# 1. Systeminformationen (Get-ComputerInfo)
$info = Get-ComputerInfo -Property WindowsProductName, WindowsVersion, OsBuildNumber
Write-Host "`n[1] System-Basisdaten:" -FontWeight Bold
Write-Host "OS: $($info.WindowsProductName)"
Write-Host "Version: $($info.WindowsVersion) (Build: $($info.OsBuildNumber))"

# 2. Aktive Dienste (Get-Service + Filter)
Write-Host "`n[2] Aktive Dienste (Top 5 Beispiele):" -FontWeight Bold
Get-Service | Where-Object { $_.Status -eq "Running" } | Select-Object -First 5 DisplayName, Status | Format-Table -AutoSize

# 3. CPU-Auslastung (Get-Process + Sortierung)
Write-Host "[3] Top 5 Prozesse nach CPU-Last:" -FontWeight Bold
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, CPU | Format-Table -AutoSize

# 4. Speicherplatz (Get-Volume)
Write-Host "[4] Festplattenbelegung:" -FontWeight Bold
Get-Volume | Select-Object DriveLetter, FriendlyName, 
    @{Name="Frei(GB)"; Expression={[Math]::Round($_.SizeRemaining / 1GB, 2)}}, 
    @{Name="Gesamt(GB)"; Expression={[Math]::Round($_.Size / 1GB, 2)}} | Format-Table -AutoSize

Write-Host "--- Bericht Ende ---" -ForegroundColor $HeaderColor
