# Mehrere Clients aus der Sysprep mit differenzierender HDD erstellen

# --- Globale Variablen (bleiben für alle gleich) ---
$VMPath     = "C:\HyperV\VM" 
$ParentVHDX = "C:\SysPrep\Win11-SysPrep.vhdx" # Win 11 Clients
$VHDXFolder = "C:\HyperV\VHDX"

# --- Die Liste der zu erstellenden VMs ---
# Hier definieren Sie Name und Switch. Sie können beliebig viele Zeilen hinzufügen.
$VMList = @(
    @{ Name = "CL-E-Stadt"; Switch = "E-Stadt" },
    @{ Name = "CL-F-Stadt"; Switch = "F-Stadt" },
    @{ Name = "CL-G-Stadt"; Switch = "G-Stadt" },
    @{ Name = "CL-H-Stadt"; Switch = "H-Stadt" }
)

# --- Ordner-Check (nur einmalig nötig) ---
if (!(Test-Path $VHDXFolder)) { New-Item -ItemType Directory -Force -Path $VHDXFolder | Out-Null }
if (!(Test-Path $VMPath))     { New-Item -ItemType Directory -Force -Path $VMPath | Out-Null }

# --- SCHLEIFE: Geht jeden Eintrag in der Liste durch ---
foreach ($Item in $VMList) {
    
    $CurrentName   = $Item.Name
    $CurrentSwitch = $Item.Switch
    
    # Dynamischer VHDX Name: z.B. "HDD-CL-A-Stadt.vhdx"
    $CurrentVHDX   = "$VHDXFolder\HDD-$CurrentName.vhdx"

    Write-Host "---------------------------------------------"
    Write-Host "Verarbeite: $CurrentName an Switch $CurrentSwitch" -ForegroundColor Cyan

    # 1. Prüfen, ob VM schon existiert (verhindert Fehler beim mehrmaligen Ausführen)
    if (Get-VM -Name $CurrentName -ErrorAction SilentlyContinue) {
        Write-Host "ACHTUNG: VM '$CurrentName' existiert bereits. Überspringe..." -ForegroundColor Yellow
        continue # Springt zum nächsten Eintrag in der Liste
    }

    # 2. Differenzierende Disk erstellen
    # Prüfen ob Disk schon existiert
    if (!(Test-Path $CurrentVHDX)) {
        New-VHD -ParentPath $ParentVHDX -Path $CurrentVHDX -Differencing | Out-Null
        Write-Host " -> VHDX erstellt." -ForegroundColor Green
    } else {
        Write-Host " -> VHDX existiert bereits, nutze vorhandene." -ForegroundColor Yellow
    }

    # 3. VM erstellen
    # Hinweis: Wir fangen Fehler ab, falls der Switch nicht existiert
    try {
        New-VM -Name $CurrentName -VHDPath $CurrentVHDX -Generation 2 -SwitchName $CurrentSwitch -Path $VMPath -ErrorAction Stop | Out-Null
        Write-Host " -> VM Container erstellt." -ForegroundColor Green
    }
    catch {
        Write-Host "FEHLER: Konnte VM nicht erstellen. Existiert der Switch '$CurrentSwitch'?" -ForegroundColor Red
        continue # Abbruch für diese VM, weiter zur nächsten
    }

    # 4. Hardware konfigurieren
    Set-VMMemory -VMName $CurrentName -DynamicMemoryEnabled $true -StartupBytes 2GB -MinimumBytes 512MB -MaximumBytes 4GB
    Set-VMProcessor -VMName $CurrentName -Count 10
    Set-VM -Name $CurrentName -CheckpointType Disabled

    Write-Host " -> Konfiguration abgeschlossen." -ForegroundColor Green
    
    # Optional: Starten
    # Start-VM -Name $CurrentName
}

Write-Host "---------------------------------------------"
Write-Host "Alle Aufgaben erledigt." -ForegroundColor Green