# Source: https://www.reddit.com/r/PowerShell/comments/nrjesd/reboot_notification/

if (Get-Module -ListAvailable -Name 'BurntToast')
{
	Import-Module -Name 'BurntToast'    
}
else
{
	return $false
}


$os = Get-WmiObject -Namespace 'root\cimv2' -Class 'win32_OperatingSystem'
$LastBoot = $os.converttodatetime($os.lastbootuptime)
$days = ((get-date) - $lastboot).Days

$appId = "clearview.it"

# Find way to add priority to override do not disturb

if ($days -ge 6) # Reboot once days since last boot is greater than or equal to 6
{
	# create text objects for the message content
	$text1 = New-BTText -Content 'Restart Recommended'
	$text2 = New-BTText -Content "It's been $days days since your PC was rebooted. For best performance, Clearview Support recommends rebooting weekly."

	
	# select the audio tone that should be played when the notification displays
	$audio1 = New-BTAudio -Path 'C:\Windows\media\notify.wav'
	
	# assemble the notification object
	$binding1 = New-BTBinding -Children $text1, $text2
	$visual1 = New-BTVisual -BindingGeneric $binding1
	$content1 = New-BTContent -Visual $visual1 -Audio $audio1 -Scenario IncomingCall
	
	# submit the notification object to be displayed
	Submit-BTNotification -Content $content1 -UniqueIdentifier "ClearviewRestart" -AppId $appId
}

return $true


$script:ExitCode = 0 #Set the exit code for the Packager