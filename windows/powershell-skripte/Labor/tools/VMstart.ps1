# Skript zur Selbst-Erhöhung in den Administratormodus
If (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "Du hast dieses Skript nicht als Administrator ausgeführt. Dieses Skript wird sich selbst erhöhen, um als Administrator ausgeführt zu werden und fortzufahren."
    Start-Sleep 1
    Write-Host " Starte im Admin-Modus" -f DarkRed
    $pwshexe = (Get-Command 'powershell.exe').Source
    Start-Process $pwshexe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
    }



# Namen der VMs
$vmNames = @('Router-A-Stadt', 'Router-B-Stadt', 'Router-C-Stadt', 'Router-D-Stadt', 'CL-A-Stadt', 'CL-B-Stadt', 'CL-C-Stadt', 'CL-D-Stadt')

# VMs starten
Write-Host "Starte VMs..."
foreach ($vm in $vmNames) {
    Start-VM -Name $vm
}
Pause