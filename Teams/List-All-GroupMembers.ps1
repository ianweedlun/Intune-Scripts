#Get all Members of Office 365 Group and export to CSV
Get-UnifiedGroup -Identity "factory15u@factoryathletics.com" | Get-UnifiedGroupLinks -LinkType Member `
      | Select DisplayName,PrimarySmtpAddress | Export-CSV "C:\Temp\GroupMembers.csv" -NoTypeInformation