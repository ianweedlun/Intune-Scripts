$users = import-csv 'C:\temp\BFUsersAliases.csv'
foreach ($user in $users)
{
    Set-Mailbox $user.upn -EmailAddresses @{add=$user.alias}
 
    Write-Host "$($user.UPN) now has the alias of ($user.alias)"
}
$users = $null