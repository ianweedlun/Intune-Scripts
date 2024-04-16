# Source: https://www.reddit.com/r/PowerShell/comments/nrjesd/reboot_notification/

$path = "C:\Program Files\Clearview IT Support\"

Import-Module -Name 'BurntToast'

$LastBoot = ((Get-WinEvent -ProviderName 'Microsoft-Windows-Kernel-Boot' | where { $_.ID -eq 27 -and $_.message -like "*0x0*" } -ea silentlycontinue)[0]).TimeCreated # Checking for full shutdown or reboot, NOT fast boot
$days = ((get-date) - $lastboot).Days

if ($days -ge 0) {
 # Reboot once days since last boot is greater than or equal to 6
	# create text objects for the message content
	$text1 = New-BTText -Style Title -Content 'Restart Recommended'
	$text2 = New-BTText -Style Body -Content "It's been $days days since your computer was rebooted. For the best experience, Clearview IT Support recommends rebooting once weekly."

	
	# play default Windows notification sound
	$audio1 = New-BTAudio -Path 'C:\Windows\media\notify.wav'
	
	# hero image idea from: https://www.systanddeploy.com/2022/02/a-toast-notification-to-display-warning.html
	$image1 = New-BTImage -Source $PSScriptRoot\restart.gif -HeroImage

	# assemble the notification object
	$binding1 = New-BTBinding -Children $text1, $text2 -HeroImage $image1
	$visual1 = New-BTVisual -BindingGeneric $binding1
	$content1 = New-BTContent -Visual $visual1 -Audio $audio1 -Scenario IncomingCall
	
	# submit the notification object to be displayed
	$appId = "clearview.it"
	Submit-BTNotification -Content $content1 -UniqueIdentifier "ClearviewRestart" -AppId $appId
}