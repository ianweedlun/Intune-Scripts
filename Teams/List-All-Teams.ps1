$AllTeams = (Get-Team).GroupID
$TeamList = @()

Foreach ($Team in $AllTeams)
{       
        $TeamGUID = $Team.ToString()
        $TeamName = (Get-Team | ?{$_.GroupID -eq $Team}).DisplayName
        $TeamUPN = (Get-Team | ?{$_.GroupID -eq $Team}).PrimarySMTPAddress
        $TeamOwner = (Get-TeamUser -GroupId $Team | ?{$_.Role -eq 'Owner'}).Name
        $TeamMember = (Get-TeamUser -GroupId $Team | ?{$_.Role -eq 'Member'}).Name

        $TeamList = $TeamList + [PSCustomObject]@{TeamName = $TeamName; TeamUPN = $TeamUPN; TeamObjectID = $TeamGUID; TeamOwners = $TeamOwner -join ', '; TeamMembers = $TeamMember -join ', '}
}

$TeamList | export-csv c:\temp\TeamsData.csv -NoTypeInformation 