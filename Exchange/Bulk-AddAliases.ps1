$users = Import-csv 'C:\temp\BFUsersAliases.csv'
foreach($user in $users)
{
Set-Mailbox "$($user.Mailbox)" -EmailAddresses @{add="$($user.NewEmailAddress)"}
}