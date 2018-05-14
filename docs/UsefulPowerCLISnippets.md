# Useful PowerCLI Snippets

After not using PowerCLI for a while, I forget the various commands that are provided in the module. This is a file of useful PowerCLI code snippets that can be used on the fly.

### Power off all VMs that match a search term

```
$vms = Get-VM -Name *Assignment1*
ForEach ($vm in $vms) {
    $power_state = $vm.PowerState
    if ($power_state -eq "PoweredOff")
    {
        Write-Host ">>> Processing VM: $vm"
        Write-Host "  > Current power state: $power_state"
    }
}

