#Erstellen einer Server/Router VM  oder Client VM aus einer SysPrep

# Name der neuen VM
$VMName = "Test"
$VMSwitch = "A-Stadt"

# allgemeine Variablen
$VMPath = "C:\HyperV\VM" # optional
# $ParentVHDX = "C:\SysPrep\Win11-SysPrep.vhdx"# Client SysPrep
$ParentVHDX = "C:\SysPrep\S-2022-sysprep_10_07_2025.vhdx" # Server SysPrep
$NewVHDX = "C:\HyperV\VHDX\HDD-$VMName.vhdx"

Clear-Host

# Überprüfen, ob die SysPrep existiert

if (-not (Test-Path $ParentVHDX)) {
    Write-Host "KRITISCHER FEHLER: Das Parent-Image fehlt: $ParentVHDX" -ForegroundColor Red
    return
}

# Überprüfen, ob die Ordner existieren

if (-not (Test-Path $VMConfigPath)) {
    Write-Host "KRITISCHER FEHLER: Das Parent-Image fehlt: $ParentVHDX" -ForegroundColor Red
}

if (-not (Test-Path $VHDXPath)) {
    Write-Host "KRITISCHER FEHLER: Das Parent-Image fehlt: $ParentVHDX" -ForegroundColor Red
}

# Konfiguration Neuer Switch ###########################
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


##########################################################


# Neuen differenzierenden Datenträger aus SysPrep erstellen 
New-VHD -ParentPath $ParentVHDX -Path $NewVHDX -Differencing

# Neue VM erstellen und die zuvor erstellte VHDX zuweisen
New-VM -Name $VMName -VHDPath $NewVHDX -Generation 2 -SwitchName $VMSwitch -Path $VMPath

# Arbeitsspeicher konfigurieren
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -StartupBytes 2GB #-MinimumBytes 512MB -MaximumBytes 2GB

# Anzahl der virtuellen Prozessoren festlegen
Set-VMProcessor -VMName $VMName -Count 2 # 2-4 sind ausreichend für einen Client, 10 für Server

# Prüfpunkte deaktivieren
Set-VM -Name $VMName -CheckpointType Disabled

# VM starten
# Start-VM -Name $VMName


