function Uninstall-Notification {

    Unregister-ScheduledTask -TaskName Restart-Reminder -Confirm:$False
}

Uninstall-Notification