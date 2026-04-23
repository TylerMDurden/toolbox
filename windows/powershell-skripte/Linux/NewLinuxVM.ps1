#################################################
######   Linux VM für Fedora Workstation   ######
######               V 1.0                 ######
#################################################

# Variablen anpassen
$VMName   = "fedora43-ws"

# --- GLOBALE PFADE ---
$BaseDir  = "C:\HyperV"
$VMPath   = "$BaseDir\VM"
$VHDXPath  = "$VMPath\HDD-$VMName.vhdx"
$ISOPath  = "C:\HyperV\ISO\Fedora-Workstation-Live-43-1.6.x86_64.iso"
$Switch   = "Default Switch"                    # oder dein externer Switch

# VM erstellen (Gen 2, 4 GB dyn. Start, 60 GB dyn. VHDX)
New-VM -Name $VMName `
       -Path $VMPath `
       -Generation 2 `
       -MemoryStartupBytes 4GB `
       -NewVHDPath $VHDXPath `
       -NewVHDSizeBytes 60GB `
       -SwitchName $Switch

# CPU & RAM
Set-VMProcessor -VMName $VMName -Count 4
Set-VMMemory    -VMName $VMName -DynamicMemoryEnabled $false -StartupBytes 4GB
# Für Desktop-VMs dyn. RAM aus - GNOME läuft damit runder

# WICHTIG: Secure Boot Template auf MS UEFI CA umstellen (sonst bootet kein Linux)
Set-VMFirmware -VMName $VMName -SecureBootTemplate "MicrosoftUEFICertificateAuthority"

# ISO einlegen und Bootreihenfolge setzen
Add-VMDvdDrive -VMName $VMName -Path $ISOPath
$DVD = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $DVD

# Checkpoints auf Standard (für Desktop-VMs besser als Production)
Set-VM -Name $VMName -CheckpointType Standard

# Automatisch starten/stoppen deaktivieren (optional)
Set-VM -Name $VMName -AutomaticStartAction Nothing -AutomaticStopAction Save

# VM starten + Konsole öffnen
Start-VM $VMName
vmconnect localhost $VMName