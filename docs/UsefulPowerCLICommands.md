# Useful PowerCLI Commands

After not using PowerCLI for a while, I forget the various commands that are provided in the module. This is a code snippet file of useful one-line PowerCLI commands that can be used, provided with accompanying examples.

### Disconnect from a vSphere Server

`Disconnect-VIServer -Server "contoso.com" -Confirm:$false`

NOTE: `-Confirm:$false` removes the prompt to disconnect

