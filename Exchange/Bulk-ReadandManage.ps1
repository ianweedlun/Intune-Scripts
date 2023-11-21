Connect-ExchangeOnline

# Specify the CSV file path
$CSVFilePath = "C:\temp\mailboxes.csv"

# Read the CSV file
$MailboxList = Import-Csv $CSVFilePath

# Loop through each mailbox in the CSV and grant permissions
foreach ($Mailbox in $MailboxList) {
    $MailboxName = $Mailbox.MailboxName  # Replace with the actual column name in your CSV containing mailbox names
    $UserToAdd = "cviewadmin@sunrolloff.com"      # Replace with the user to grant permissions

    Add-MailboxPermission -Identity $MailboxName -User $UserToAdd -AccessRights FullAccess
    Write-Host "Granted full access to $UserToAdd on mailbox $MailboxName"    
}

# Disconnect from Exchange Online
Remove-PSSession $Session