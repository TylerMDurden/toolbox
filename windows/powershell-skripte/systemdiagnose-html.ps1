# Pfad für den Bericht (Desktop)
$Path = "$([Environment]::GetFolderPath('Desktop'))\SystemBericht.html"

# CSS Styling für eine schöne Optik
$Style = @"
<style>
    body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
    h1 { color: #005a9e; border-bottom: 2px solid #005a9e; }
    h2 { color: #333; margin-top: 30px; }
    table { border-collapse: collapse; width: 100%; background: white; margin-bottom: 20px; }
    th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
    th { background-color: #005a9e; color: white; }
    tr:nth-child(even) { background-color: #f2f2f2; }
</style>
"@

# Daten sammeln
$SystemInfo = Get-ComputerInfo -Property WindowsProductName, WindowsVersion, OsBuildNumber | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber
$Services   = Get-Service | Where-Object { $_.Status -eq "Running" } | Select-Object DisplayName, Status -First 10
$Processes  = Get-Process | Sort-Object CPU -Descending | Select-Object Name, CPU -First 10
$Volumes    = Get-Volume | Select-Object DriveLetter, FriendlyName, 
                @{Name="Frei(GB)"; Expression={[Math]::Round($_.SizeRemaining / 1GB, 2)}}, 
                @{Name="Gesamt(GB)"; Expression={[Math]::Round($_.Size / 1GB, 2)}}

# HTML zusammenstellen
$HtmlOutput = "<h1>Systemdiagnose Bericht - $(Get-Date)</h1>"
$HtmlOutput += "<h2>Systeminformationen</h2>" + ($SystemInfo | ConvertTo-Html -Fragment)
$HtmlOutput += "<h2>Aktive Dienste (Top 10)</h2>" + ($Services | ConvertTo-Html -Fragment)
$HtmlOutput += "<h2>Top Prozesse (CPU Last)</h2>" + ($Processes | ConvertTo-Html -Fragment)
$HtmlOutput += "<h2>Speicherplatz</h2>" + ($Volumes | ConvertTo-Html -Fragment)

# Datei speichern
ConvertTo-Html -Head $Style -Body $HtmlOutput | Out-File $Path

Write-Host "Der Bericht wurde erfolgreich unter $Path gespeichert!" -ForegroundColor Green
