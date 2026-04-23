#################################################
######   Linux VM für Fedora Workstation   ######
######               V 1.1                 ######
#################################################

# ---Erstellen einer Linux VM mit einer BootCD und bestimmten Optionen

# --- KONFIGURATION DER LINUX-VM ---
$VMName   = "fedora43-ws"

# --- GLOBALE PFADE ---
$BaseDir  = "C:\HyperV"
$VMPath   = "$BaseDir\VM"
$VHDXPath  = "$VMPath\HDD-$VMName.vhdx"
$ISOPath  = "C:\HyperV\ISO\Fedora-Workstation-Live-43-1.6.x86_64.iso"
$Switch   = "Default Switch"                    # oder dein externer Switch

Clear-Host
Write-Host "Starte Erstellung Linux VM - $VMName" -ForegroundColor Magenta
Write-Host "---------------------------------------------"

# 1. --- VM erstellen ---
Write-Host "  -> Erstelle VM..." -ForegroundColor DarkGray
New-VM -Name $VMName `
       -Path $VMPath `
       -Generation 2 `
       -MemoryStartupBytes 4GB `
       -NewVHDPath $VHDXPath `
       -NewVHDSizeBytes 60GB `
       -SwitchName $Switch

# 2. --- Hardware konfigurieren ---
#    --- Für Desktop-VMs dyn. RAM aus - GNOME läuft damit runder
Write-Host "  -> Konfiguriere Hardware..." -ForegroundColor DarkGray
Set-VMProcessor -VMName $VMName -Count 4
Set-VMMemory    -VMName $VMName -DynamicMemoryEnabled $false -StartupBytes 4GB
#    --- WICHTIG: Secure Boot Template auf MS UEFI CA umstellen (sonst bootet kein Linux)
Set-VMFirmware -VMName $VMName -SecureBootTemplate "MicrosoftUEFICertificateAuthority"

# 3. --- ISO einlegen und Bootreihenfolge setzen ---
Add-VMDvdDrive -VMName $VMName -Path $ISOPath
$DVD = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $DVD

# Checkpoints auf Standard (für Desktop-VMs besser als Production)
Set-VM -Name $VMName -CheckpointType Standard

# Automatisch starten/stoppen deaktivieren (optional)
Set-VM -Name $VMName -AutomaticStartAction Nothing -AutomaticStopAction Save

Write-Host "  -> ERFOLG: $VMName wurde erstellt." -ForegroundColor Green

# VM starten + Konsole öffnen
Start-VM $VMName
vmconnect localhost $VMName
Write-Host "  -> Die VM $VMName wurde gestartet." -ForegroundColor Green

Write-Host "---------------------------------------------"