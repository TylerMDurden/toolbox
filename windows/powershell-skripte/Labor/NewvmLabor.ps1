# Erstellen mehrerer Server/Router/Client VMs aus SysPrep (Massenproduktion)

# --- KONFIGURATION DER VMS ---
# Hier trägst du alle VMs ein, die erstellt werden sollen
$VMListe = @(
    # @{ Name = "DC-01";      OS = "Server"; Switch = "Intern-Netz"; CPU = 2 },
    # @{ Name = "Router-01";  OS = "Server"; Switch = "Intern-Netz"; CPU = 2 },
    # @{ Name = "Win11-Cli1"; OS = "Client"; Switch = "Intern-Netz"; CPU = 4 },
    @{ Name = "Test-Srv"; OS = "Server"; Switch = "A-Stadt"; CPU = 4 }
)

# --- sollen die erstellten VMs sofort gestarten werden ---

$vmStart = "nein"

# --- GLOBALE PFADE ---
$BaseDir = "C:\HyperV"
$VMPath = "$BaseDir\VM" 
$VHDXPath = "$BaseDir\VHDX"

# SysPrep-Quellen
$SourceClient = "C:\SysPrep\Win11-SysPrep.vhdx"
$SourceServer = "C:\SysPrep\S-2022-sysprep_10_07_2025.vhdx"

# --- Überprüfen, ob das Scrpt mit Admin-Rechten gestartet wurde ---
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)

if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Dieses Skript benötigt Administratorrechte zur Ausführung."
    Write-Warning "Bitte starten Sie die PowerShell-Konsole mit 'Als Administrator ausführen' und versuchen Sie es erneut."
    # Das Skript wird hier anhalten. In einer Konsole stoppt es, in der ISE kann es weiterlaufen, daher 'exit'.
    exit 1 # Beendet das Skript mit einem Fehlercode
}

# --- Wenn die Überprüfung erfolgreich war, geht es hier weiter ---
Write-Host "Adminrechte bestätigt. Skript wird ausgeführt..." -ForegroundColor Green



Clear-Host
Write-Host "Starte Massenerstellung von $($VMListe.Count) VMs..." -ForegroundColor Magenta
Write-Host "---------------------------------------------"

# --- GLOBALE CHECKS (Bevor es losgeht) ---
# Prüfen, ob die Ordner existieren
if (-not (Test-Path $VMPath)) { Write-Host "FEHLER: Ordner fehlt: $VMPath" -ForegroundColor Red; return }
if (-not (Test-Path $VHDXPath)) { Write-Host "FEHLER: Ordner fehlt: $VHDXPath" -ForegroundColor Red; return }

# Prüfen, ob die Images existieren
if (-not (Test-Path $SourceClient)) { Write-Host "FEHLER: Client-Image fehlt: $SourceClient" -ForegroundColor Red; return }
if (-not (Test-Path $SourceServer)) { Write-Host "FEHLER: Server-Image fehlt: $SourceServer" -ForegroundColor Red; return }


# --- HAUPTSCHLEIFE (Geht jede VM durch) ---

foreach ($VM in $VMListe) {
    
    # Werte aus der Liste in Variablen laden
    $VMName   = $VM.Name
    $OS       = $VM.OS
    $VMSwitch = $VM.Switch
    $CPUCount = $VM.CPU
    
    # Pfad für die neue Festplatte bauen
    $NewVHDXFile = "$VHDXPath\HDD-$VMName.vhdx"

    Write-Host "`nVerarbeite: $VMName ($OS)..." -ForegroundColor White

    # 1. Prüfen, ob VM schon existiert
    if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
        Write-Host "  -> ÜBERSPRUNGEN: VM '$VMName' existiert bereits." -ForegroundColor Yellow
        continue # Springt zur nächsten VM in der Liste
    }

    # 2. Prüfen, ob VHDX schon existiert
    if (Test-Path $NewVHDXFile) {
        Write-Host "  -> ÜBERSPRUNGEN: VHDX '$NewVHDXFile' existiert bereits." -ForegroundColor Yellow
        continue
    }

    # 3. Das richtige Image wählen
    if ($OS -eq "Client") { $ParentVHDX = $SourceClient }
    elseif ($OS -eq "Server") { $ParentVHDX = $SourceServer }
    else {
        Write-Host "  -> FEHLER: Unbekanntes OS '$OS' bei VM $VMName." -ForegroundColor Red
        continue
    }

    # 4. Switch prüfen/erstellen
    if (-not (Get-VMSwitch -Name $VMSwitch -ErrorAction SilentlyContinue)) {
        Write-Host "  -> Erstelle Switch '$VMSwitch' (Private)..." -ForegroundColor Cyan
        New-VMSwitch -Name $VMSwitch -SwitchType Private | Out-Null
    }

    # 5. Differenzierende Disk erstellen
    Write-Host "  -> Erstelle VHDX..." -ForegroundColor DarkGray
    New-VHD -ParentPath $ParentVHDX -Path $NewVHDXFile -Differencing | Out-Null

    # 6. VM erstellen
    Write-Host "  -> Erstelle VM..." -ForegroundColor DarkGray
    New-VM -Name $VMName -VHDPath $NewVHDXFile -Generation 2 -SwitchName $VMSwitch -Path $VMPath | Out-Null

    # 7. Hardware konfigurieren
    Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -StartupBytes 2GB
    Set-VMProcessor -VMName $VMName -Count $CPUCount
    Set-VM -Name $VMName -CheckpointType Disabled

    Write-Host "  -> ERFOLG: $VMName wurde erstellt." -ForegroundColor Green
    
    # Optional: Starten
    if($vmStart -eq "ja") {
        Start-VM -Name $VMName
        Write-Host "  -> Die VM $VMName wurde gestartet." -ForegroundColor Green
    }
}

# --- ABSCHLUSS ---
Write-Host "---------------------------------------------"
Write-Host "Alle Aufgaben erledigt." -ForegroundColor Cyan

# ----- Infos für Micha -----
Write-Host
Write-Host "So Micha..." -ForegroundColor Magenta
Write-Host "* Computernamen in den VMs ändern!" -ForegroundColor Magenta
Write-Host "* NIC umbennen!" -ForegroundColor Magenta
Write-Host "* evtl. weitere NICs hinzufügen und umbennen!" -ForegroundColor Magenta
Write-Host "Viel Erfolg und Spaß" -ForegroundColor Magenta