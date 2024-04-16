if (!(Get-Module -ListAvailable -Name 'BurntToast')) {
    Install-Module -Name BurntToast -Scope AllUsers -Force
}

$path = "C:\Program Files\Clearview IT Support\"
If ((Test-Path $path) -eq $false) {
    New-Item -ItemType Directory -Path $path
}

Set-Location -Path $PSScriptRoot
Copy-Item "Restart-Reminder.ps1" -Destination $path
Copy-Item "logo.png" -Destination $path
Copy-Item "restart.gif" -Destination $path
Copy-Item "run-hidden.exe" -Destination $path # Source https://github.com/stax76/run-hidden

& "$PSScriptRoot/Register-NotificationApp.ps1"

Register-ScheduledTask -xml (Get-Content $PSScriptRoot\Restart-Reminder.xml | Out-String) -TaskName Restart-Reminder -TaskPath "\" -Force