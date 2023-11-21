#Parameters
$CSVFilePath = "C:\Temp\NewDistributionLists.csv"
 
Try {
    #Connect to Exchange Online
    Connect-ExchangeOnline -ShowBanner:$False
 
    #Get Data from CSV and Create Distribution List
    Import-CSV $CSVFilePath | ForEach {
        New-DistributionGroup -Name $_.Name -PrimarySmtpAddress $_.Email -Type $_.Type -RequireSenderAuthenticationEnabled $false -Members $_.Members.split(",")
        Write-host -f Green "Created Distribution List:"$_.Name
    }
}
Catch {
    write-host -f Red "Error:" $_.Exception.Message
}