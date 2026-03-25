###  wollte hier automatisch die nic bei der gast vm umbenennen
###  ist aber nicht so einfach möglich

# --- Globale Variablen ---
$VMPath     = "C:\HyperV\VM" 
$ParentVHDX = "C:\SysPrep\Win11-SysPrep.vhdx" 
$VHDXFolder = "C:\HyperV\VHDX"
# Admin-Credentials für das Gast-OS (Nötig für das Umbenennen im Gast)
$GuestCreds = Get-Credential -Message "Bitte Admin-Login für die VMS eingeben"

# --- Liste der VMs ---
$VMList = @(
    @{ 
        VMName  = "Test-D"; 
        Switch1 = "D-Stadt";     NetName1 = "LAN-Intern";
        Switch2 = "Backbone_one"; NetName2 = "Backbone_one";
        Switch3 = "Backbone_two";  NetName3 = "Backbone_two"
    }
    # Weitere VMs hier...
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

    # 1. Disk & VM erstellen (wie gehabt)
    if (!(Test-Path $NewVHDX)) { New-VHD -ParentPath $ParentVHDX -Path $NewVHDX -Differencing | Out-Null }
    
    if (!(Get-VM -Name $Name -ErrorAction SilentlyContinue)) {
        New-VM -Name $Name -VHDPath $NewVHDX -Generation 2 -Path $VMPath | Out-Null
        
        # 2. Netzwerkkarten hinzufügen & DeviceNaming aktivieren
        # Das Feature "-DeviceNaming On" schreibt den Namen in ein spezielles Register der virtuellen Karte
        if ($Item.Switch1) { Add-VMNetworkAdapter -VMName $Name -SwitchName $Item.Switch1 -Name $Item.NetName1 -DeviceNaming On }
        if ($Item.Switch2) { Add-VMNetworkAdapter -VMName $Name -SwitchName $Item.Switch2 -Name $Item.NetName2 -DeviceNaming On }
        if ($Item.Switch3) { Add-VMNetworkAdapter -VMName $Name -SwitchName $Item.Switch3 -Name $Item.NetName3 -DeviceNaming On }

        # Hardware
        Set-VMMemory -VMName $Name -DynamicMemoryEnabled $true -StartupBytes 2GB -MaximumBytes 4GB
        Set-VMProcessor -VMName $Name -Count 4
        Set-VM -Name $Name -CheckpointType Disabled
        # Enable-VMTPM -VMName $Name # Wichtig für Win11
        
        Write-Host " -> VM erstellt und konfiguriert." -ForegroundColor Green
    }

    # 3. VM Starten & Karten im Gast umbenennen
    if ((Get-VM -Name $Name).State -ne 'Running') {
        Start-VM -Name $Name
        Write-Host " -> VM gestartet. Warte auf Boot..." -ForegroundColor Yellow
        
        # Warten bis PowerShell im Gast bereit ist (kann bei sysprep 1-2 Min dauern)
        # Wir prüfen in einer Schleife, ob der Gast erreichbar ist
        do { Start-Sleep -Seconds 5 } until (Get-VM -Name $Name | Where-Object { $_.State -eq 'Running' -and $_.Uptime.TotalSeconds -gt 10 })
    }

    Write-Host " -> Versuche Netzwerkkarten im Gast umzubenennen..." -ForegroundColor Cyan
    
    # Dieser Block wird IM GAST ausgeführt (PowerShell Direct)
    Invoke-Command -VMName $Name -Credential $GuestCreds -ScriptBlock {
        # Holt sich alle Adapter im Gast
        $Adapters = Get-NetAdapter
        
        foreach ($Nic in $Adapters) {
            # Liest den "DeviceNaming" Namen aus, den wir am Host gesetzt haben
            # Die Property heißt im Treiber "Hyper-V Network Adapter Name"
            $HostName = ($Nic | Get-NetAdapterAdvancedProperty -RegistryKeyword "HyperVNetworkAdapterName" -ErrorAction SilentlyContinue).DisplayValue
            
            if ($HostName -and $HostName -ne $Nic.Name) {
                Rename-NetAdapter -Name $Nic.Name -NewName $HostName -Confirm:$false
                Write-Output "Gast-NIC '$($Nic.Name)' umbenannt in '$HostName'"
            }
        }
    } -ErrorAction SilentlyContinue

    Write-Host " -> Fertig." -ForegroundColor Green
}