#Erstellen einer VM mit einer bestehenden HDD

# Variablen für die neue VM
$VMName = "CL-G-Stadt"
$VMSwitch = "G-Stadt" # z.B. "External"
$VMPath = "C:\HyperV\Test"

$NewVHDX = "C:\HyperV\VHDX\HDD-CL-G-Stadt.vhdx" # übernommen aus dem anderen Script

# Neue VM erstellen und die zuvor erstellte VHDX zuweisen
New-VM -Name $VMName -VHDPath $NewVHDX -Generation 2 -SwitchName $VMSwitch #-Path $VMPath

# Arbeitsspeicher konfigurieren (optional)
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -StartupBytes 2GB #-MinimumBytes 512MB -MaximumBytes 2GB

# Prüfpunkte deaktivieren
Set-VM -Name $VMName -CheckpointType Disabled

# VM starten
# Start-VM -Name $VMName