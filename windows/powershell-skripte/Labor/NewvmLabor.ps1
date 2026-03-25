# --- Globale Variablen ---
$VMPath     = "C:\HyperV\VM" 
$ParentVHDX = "C:\SysPrep\Win11-SysPrep.vhdx" 
$VHDXFolder = "C:\HyperV\VHDX"

# --- Liste der VMs mit benannten Netzwerkkarten ---
$VMList = @(
    @{ 
        VMName  = "Test-A"; 
        # Karte 1
        Switch1 = "A-Stadt";     NetName1 = "A-Stadt";
        # Karte 2
        Switch2 = "Backup_one"; NetName2 = "Backbone_one";
        # Karte 3
        Switch3 = "Backbone_two";  NetName3 = "Backbone_two"
    },
    @{ 
        VMName  = "Test-B"; 
        Switch1 = "B-Stadt";     NetName1 = "LAN-Intern";
        Switch2 = "Backbone_one";    NetName2 = "Backbone_one";
        Switch3 = "";            NetName3 = "" # Hat nur 2 Karten
    }
)

# --- Ordner-Check ---
if (!(Test-Path $VHDXFolder)) { New-Item -ItemType Directory -Force -Path $VHDXFolder | Out-Null }
if (!(Test-Path $VMPath))     { New-Item -ItemType Directory -Force -Path $VMPath | Out-Null }

# --- SCHLEIFE ---
foreach ($Item in $VMList) {
    
    $Name = $Item.VMName
    $NewVHDX = "$VHDXFolder\HDD-$Name.vhdx"

    Write-Host "---------------------------------------------"
    Write-Host "Verarbeite: $Name" -ForegroundColor Cyan

    # 1. Check ob VM existiert
    if (Get-VM -Name $Name -ErrorAction SilentlyContinue) {
        Write-Host "VM '$Name' existiert bereits." -ForegroundColor Yellow
        continue
    }

    # 2. Disk erstellen
    if (!(Test-Path $NewVHDX)) {
        New-VHD -ParentPath $ParentVHDX -Path $NewVHDX -Differencing | Out-Null
    }

    # 3. VM erstellen (OHNE Switch, damit wir Namen sauber setzen können)
    try {
        New-VM -Name $Name -VHDPath $NewVHDX -Generation 2 -Path $VMPath -ErrorAction Stop | Out-Null
        Write-Host " -> VM Container erstellt." -ForegroundColor Green
    }
    catch {
        Write-Host "FEHLER beim Erstellen der VM '$Name'." -ForegroundColor Red
        continue
    }

    # 4. Netzwerkkarten hinzufügen und benennen

    # --- Karte 1 ---
    if ($Item.Switch1) {
        Add-VMNetworkAdapter -VMName $Name -SwitchName $Item.Switch1 -Name $Item.NetName1
        Write-Host " -> NIC '$($Item.NetName1)' an Switch '$($Item.Switch1)' hinzugefügt." -ForegroundColor Green
    }

    # --- Karte 2 ---
    if ($Item.Switch2) {
        Add-VMNetworkAdapter -VMName $Name -SwitchName $Item.Switch2 -Name $Item.NetName2
        Write-Host " -> NIC '$($Item.NetName2)' an Switch '$($Item.Switch2)' hinzugefügt." -ForegroundColor Green
    }

    # --- Karte 3 ---
    if ($Item.Switch3) {
        Add-VMNetworkAdapter -VMName $Name -SwitchName $Item.Switch3 -Name $Item.NetName3
        Write-Host " -> NIC '$($Item.NetName3)' an Switch '$($Item.Switch3)' hinzugefügt." -ForegroundColor Green
    }

    # 5. Hardware & TPM konfigurieren
    Set-VMMemory -VMName $Name -DynamicMemoryEnabled $true -StartupBytes 2GB -MinimumBytes 512MB -MaximumBytes 4GB
    Set-VMProcessor -VMName $Name -Count 4 # Angepasst auf 4 Kerne (realistischer)
    Set-VM -Name $Name -CheckpointType Disabled
    
    # Optional: DeviceNaming aktivieren (hilft manchmal, die Namen ins Windows-Gast-OS durchzureichen)
    # Set-VMNetworkAdapter -VMName $Name -DeviceNaming On

    Write-Host " -> Fertig." -ForegroundColor Green
}