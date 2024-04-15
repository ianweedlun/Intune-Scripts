$path = "C:\Program Files\Clearview IT Support\"
If ((Test-Path $path) -eq $false){
    New-Item -ItemType Directory -Path $path
}

Set-location -Path $PSScriptRoot
Copy-Item "Register-NotificationApp.ps1" -Destination $path
Copy-Item "Restart-Reminder.ps1" -Destination $path
Copy-Item "logo.png" -Destination $path
Copy-Item "Restart-Reminder.xml" -Destination $path
Copy-Item "Uninstall-Notification.ps1" -Destination $path
Copy-Item "run-hidden.exe" -Destination $path # Source https://github.com/stax76/run-hidden

& "$PSScriptRoot/Register-NotificationApp.ps1"

Register-ScheduledTask -xml (Get-Content $path\Restart-Reminder.xml | Out-String) -TaskName Restart-Reminder -TaskPath "\" -Force