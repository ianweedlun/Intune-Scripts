$software = "Qualys Cloud Security Agent"
$installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -eq $software }) -ne $null


If(-Not $installed) {
        exit 1
} else {
        Write-Host "$software Successfully Installed!"
        exit 0
}