# Namen der VMs
$vmNames = @('Router-A-Stadt', 'Router-B-Stadt', 'Router-C-Stadt', 'Router-D-Stadt', 'CL-A-Stadt', 'CL-B-Stadt', 'CL-C-Stadt', 'CL-D-Stadt')

# VMs starten
Write-Host "Stoppe VMs..."
foreach ($vm in $vmNames) {
    Stop-VM -Name $vm
}
Pause