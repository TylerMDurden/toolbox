#Erstellen einer Server/Router VM  oder Client VM aus einer SysPrep

# Name der neuen VM
$VMName = "TestSrv7"
$VMSwitch = "TestSrv7-Stadt"
$OS = "Server" # Client oder Server
$CPUCount = 4 # vCPU 2-4 Client

# Pfade
$BaseDir = "C:\HyperV"
$VMPath = "$BaseDir\VM" # optional
$VHDXPath = "$BaseDir\VHDX"
$NewVHDXFile = "$VHDXPath\HDD-$VMName.vhdx"

# SysPrep-Image (sollte schreibgeschützt sein)
$SourceClient = "C:\SysPrep\Win11-SysPrep.vhdx"# Client SysPrep
$SourceServer = "C:\SysPrep\S-2022-sysprep_10_07_2025.vhdx" # Server SysPrep

Clear-Host

# Entscheiden, welche SysPrep

if ($OS -eq "Client"){
        $ParentVHDX = $SourceClient
        Write-Host "Modus: CLIENT ausgewaehlt. Nutze Image: $ParentVHDX" -ForegroundColor Cyan
}
elseif ($OS -eq "Server"){
        $ParentVHDX = $SourceServer
        Write-Host "Modus: Server ausgewaehlt. Nutze Image: $ParentVHDX" -ForegroundColor Cyan
}
else {
    # Fängt Tippfehler ab (z.B. wenn $OS leer ist oder falsch geschrieben wurde)
    Write-Host "FEHLER: Die Variable `$OS` muss 'Client' oder 'Server' sein. Aktueller Wert: '$OS'" -ForegroundColor Red
    return
}


# Prüfen, ob die SysPrep existiert

if (-not (Test-Path $ParentVHDX)) {
    Write-Host "KRITISCHER FEHLER: Das Parent-Image fehlt: $ParentVHDX" -ForegroundColor Red
    return
}

# Prüfen, ob die Ordner existieren

if (-not (Test-Path $VMPath)) {
    Write-Host "KRITISCHER FEHLER: Der Ordner fehlt: $VMPath" -ForegroundColor Red
    return
}
if (-not (Test-Path $VHDXPath)) {
    Write-Host "KRITISCHER FEHLER: Der Ordner fehlt: $VHDXPath" -ForegroundColor Red
    return
}

# Prüfen, ob die VM schon existiert
if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    Write-Host "ABBRUCH: Die VM '$VMName' existiert bereits!" -ForegroundColor Red
    return
}

# Prüfen, ob die differenzierende Festplatte schon existiert
if (Test-Path $NewVHDXFile) {
    Write-Host "ABBRUCH: Die Datei '$NewVHDXFile' existiert bereits! Bitte löschen." -ForegroundColor Red
    return
}

# Prüfen, ob der Switch schon existiert
if (Get-VMSwitch -Name $VMSwitch -ErrorAction SilentlyContinue) {
    Write-Host "Switch '$VMSwitch' existiert bereits." -ForegroundColor Yellow
}
else {
    Write-Host "Erstelle Switch '$VMSwitch'..." -ForegroundColor Cyan
    
    New-VMSwitch -Name $VMSwitch -SwitchType Private | Out-Null
        
    Write-Host "Switch '$VMSwitch' erfolgreich erstellt!" -ForegroundColor Green
}


Write-Host "Erstelle differenzierende Festplatte..." -ForegroundColor Cyan 
New-VHD -ParentPath $ParentVHDX -Path $NewVHDXFile -Differencing | Out-Null

Write-Host "Erstelle Virtuelle Maschine '$VMName'..." -ForegroundColor Cyan
New-VM -Name $VMName -VHDPath $NewVHDXFile -Generation 2 -SwitchName $VMSwitch -Path $VMPath | Out-Null

# --- KONFIGURATION DER VM ---
Write-Host "Konfiguriere Hardware..." -ForegroundColor Cyan

Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -StartupBytes 2GB #-MinimumBytes 512MB -MaximumBytes 2GB
Set-VMProcessor -VMName $VMName -Count $CPUCount
Set-VM -Name $VMName -CheckpointType Disabled

Write-Host "VM '$VMName' ($OS) wurde erfolgreich erstellt." -ForegroundColor Green

# VM starten
# Start-VM -Name $VMName

# ----- Infos für Micha -----
Write-Host
Write-Host "So Micha..." -ForegroundColor Magenta
Write-Host "* Computernamen ändern!" -ForegroundColor Magenta
Write-Host "* NIC umbennen!" -ForegroundColor Magenta
Write-Host "* evtl. weitere NICs hinzufügen und umbennen!" -ForegroundColor Magenta
Write-Host "Viel Erfolg und Spaß" -ForegroundColor Magenta