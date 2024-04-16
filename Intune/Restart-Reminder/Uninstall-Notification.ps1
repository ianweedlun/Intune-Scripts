$path = "C:\Program Files\Clearview IT Support\"
Unregister-ScheduledTask -TaskName Restart-Reminder -Confirm:$False
Remove-Item "$path\Restart-Reminder.ps1"