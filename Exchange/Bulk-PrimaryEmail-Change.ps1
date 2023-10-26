Import-Csv 'C:\temp\BFUsersUPNChange.csv' | ForEach-Object {
    Set-Mailbox $_."UserPrincipalName" -WindowsEmailAddress $_."NewEmailAddress" -MicrosoftOnlineServicesID $_."NewEmailAddress"
}