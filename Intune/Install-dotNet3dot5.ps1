Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Install", "Uninstall")]
    [String[]]
    $Mode
)
 
If ($Mode -eq "Install") {
    Enable-WindowsOptionalFeature -Online -FeatureName 'NetFx3' -NoRestart
}
 
If ($Mode -eq "Uninstall") { 
    Disable-WindowsOptionalFeature -Online -FeatureName 'NetFx3' -Remove -NoRestart 
}