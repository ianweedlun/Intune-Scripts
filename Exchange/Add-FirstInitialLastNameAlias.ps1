# Install and connect to Exchange Online PowerShell module if not already installed
# Install-Module -Name ExchangeOnlineManagement
# Connect-ExchangeOnline -UserPrincipalName <your admin account>

# Get all mailboxes
$mailboxes = Get-Mailbox -ResultSize Unlimited

foreach ($mailbox in $mailboxes) {
    # Extract first initial and last name from the display name
    $displayName = $mailbox.DisplayName
    $firstNameInitial = $displayName[0]
    $lastName = ($displayName -split ' ', 2)[1]  # Split the display name into two parts at the first space
    $PrimaryEmail = $mailbox.PrimarySmtpAddress
    $domain = ($PrimaryEmail -split '@', 2)[1]    

    # Generate the new alias
    $newAlias = $firstNameInitial + $lastName + "@" + $domain    

    # Check if the alias already exists, and if not, add it to the mailbox
    if (-not (Get-Mailbox -Identity $newAlias -ErrorAction SilentlyContinue)) {
        Set-Mailbox -Identity $mailbox.Identity -EmailAddresses @{add="$($newAlias)"}
        Write-Host "Alias added for $($mailbox.UserPrincipalName): $newAlias"
    } else {
     #   Write-Host "Alias already exists for $($mailbox.UserPrincipalName): $newAlias"
    }
}

# Disconnect from Exchange Online
# Disconnect-ExchangeOnline -Confirm:$false
