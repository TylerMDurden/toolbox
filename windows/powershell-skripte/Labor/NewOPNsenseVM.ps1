#################################################
######             OPNsense VM             ######
######                V 1.                ######
#################################################
# weitere Variablen eingefügt und Abfrage ob Admin Rechte

# --- Erstellen einer OPNsense-VM für Testlabor Küstenblick
# --- auf einem Hyper-V Host

# --- GLOBALE PFADE ---
$BaseDir   = "C:\Hyper-V"
$VMPath    = "$BaseDir\VM"
$ISOPath   = "$BaseDir\ISO"
$VHDXPath  = "$BaseDir\VHDX\HDD-$VMName.vhdx"

# --- KONFIGURATION DER OPNsense-VM ---
$ISO       = "$ISOPath\Fedora-Workstation-Live-43-1.6.x86_64.iso"
$VMName    = "RTR01"
$CPUCount  = 2
$RAMSize   = 2GB
$VHDXSize  = 20GB
$vmStart   = $false
$Switch    = "Default Switch"                    # oder dein externer Switch

Clear-Host

# --- Überprüfung der  Admin-Rechten ---
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

Write-Host "Übersicht der Einstellungen der OPNsense-VM - $VMName" -ForegroundColor Magenta

Write-Host "Starte Erstellung OPNsense-VM - $VMName" -ForegroundColor Magenta
Write-Host "---------------------------------------------"

# 1. --- VM erstellen ---
Write-Host "  -> Erstelle VM..." -ForegroundColor DarkGray
New-VM -Name $VMName `
       -Path $VMPath `
       -Generation 2 `
       -NewVHDPath $VHDXPath `
       -NewVHDSizeBytes $VHDXSize `
       -SwitchName $Switch

# 2. --- Hardware konfigurieren ---
#    --- Für Desktop-VMs dyn. RAM aus - GNOME läuft damit runder
Write-Host "  -> Konfiguriere Hardware..." -ForegroundColor DarkGray
Set-VMProcessor -VMName $VMName -Count $CPUCount
Set-VMMemory    -VMName $VMName -DynamicMemoryEnabled $false -StartupBytes $RAMSize # DynamicRAM false bei Linux empfohlen

Set-VMFirmware -VMName $VMName -EnableSecureBoot Off

# 3. --- ISO einlegen und Bootreihenfolge setzen ---
Add-VMDvdDrive -VMName $VMName -Path $ISOPath
$DVD = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $DVD

# Checkpoints auf Standard (für Desktop-VMs besser als Production)
Set-VM -Name $VMName -CheckpointType Standard

# Automatisch starten/stoppen deaktivieren (optional)
Set-VM -Name $VMName -AutomaticStartAction Start

Write-Host "  -> ERFOLG: $VMName wurde erstellt." -ForegroundColor Green

# Optional: VM starten + Konsole öffnen
if($vmStart) {
	Start-VM -Name $VMName
    Write-Host "  -> Die VM $VMName wurde gestartet." -ForegroundColor Green
}

Write-Host "---------------------------------------------"