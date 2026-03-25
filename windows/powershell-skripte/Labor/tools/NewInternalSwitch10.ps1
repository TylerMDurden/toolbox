# Konfiguration Neuer Switch
$SwitchName = "Z-Stadt"

# Prüfen, ob der Switch schon existiert
if (Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue) {
    Write-Host "Switch '$SwitchName' existiert bereits." -ForegroundColor Yellow
}
else {
    Write-Host "Erstelle Switch '$SwitchName'..." -ForegroundColor Cyan
    
    New-VMSwitch -Name $SwitchName -SwitchType Private  | Out-Null
        
    Write-Host "Switch '$SwitchName' erfolgreich erstellt!" -ForegroundColor Green
}
