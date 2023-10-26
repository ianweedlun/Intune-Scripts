Get-EXOMailbox -ResultSize Unlimited |
Select-Object DisplayName,PrimarySmtpAddress, @{Name="AliasSmtpAddresses";Expression={($_.EmailAddresses | Where-Object {$_ -clike "smtp:*"} | ForEach-Object {$_ -replace "smtp:",""}) -join "," }}  |
Export-Csv "C:\temp\Email-Addresses.csv" -NoTypeInformation -Encoding UTF8
