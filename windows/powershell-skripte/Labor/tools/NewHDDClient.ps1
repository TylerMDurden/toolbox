# neu HDD für einen Client mittels SysPrep

# Variablen definieren
$ParentVHDX = "C:\SysPrep\Win11-SysPrep.vhdx" # Client SysPrep
$NewVHDX = "C:\HyperV\VHDX\HDD-CL-G-Stadt.vhdx"

# Neuen differenzierenden Datenträger erstellen
New-VHD -ParentPath $ParentVHDX -Path $NewVHDX -Differencing