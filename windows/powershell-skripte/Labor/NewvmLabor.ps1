#Erstellen einer Server/Router VM  oder Client VM aus einer SysPrep

# Name der neuen VM
$VMName = "DHCP-2"
$VMSwitch = "A-Stadt"

# allgemeine Variablen
$VMPath = "C:\HyperV\VM" # optional
# $ParentVHDX = "C:\SysPrep\Win11-SysPrep.vhdx"# Client SysPrep
$ParentVHDX = "C:\SysPrep\S-2022-sysprep_10_07_2025.vhdx" # Server SysPrep
$NewVHDX = "C:\HyperV\VHDX\HDD-$VMName.vhdx"

# Neuen differenzierenden Datenträger aus SysPrep erstellen 
New-VHD -ParentPath $ParentVHDX -Path $NewVHDX -Differencing

# Neue VM erstellen und die zuvor erstellte VHDX zuweisen
New-VM -Name $VMName -VHDPath $NewVHDX -Generation 2 -SwitchName $VMSwitch -Path $VMPath

# Arbeitsspeicher konfigurieren
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -StartupBytes 2GB #-MinimumBytes 512MB -MaximumBytes 2GB

# Anzahl der virtuellen Prozessoren festlegen Standard ist 10
Set-VMProcessor -VMName $VMName -Count 2 # 2-4 sind ausreichend für einen Client

# Prüfpunkte deaktivieren
Set-VM -Name $VMName -CheckpointType Disabled

# VM starten
# Start-VM -Name $VMName
