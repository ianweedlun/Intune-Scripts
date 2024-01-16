#Requires -Module AzureAD
[CmdletBinding(SupportsShouldProcess)]
param (
    # Saves the report to the script location
    [Parameter()]
    [switch]
    $SaveReport
)

# Connect-AzureAD
<# Get-MsolAccountSku - Lists all of the SKUs in use by tenant. Be sure to match usage counts to determine accurate name mapping.
Some licenses have SKU names that don't match their product name (e.g. M365 Business Standard is "O365_BUSINESS_PREMIUM")
#>

# Fetch all users with specific license
# $allUsers = Get-MsolUser -All | Where-Object {($_.licenses).AccountSkuId -like '*O365_BUSINESS_ESSENTIALS'}
$allusers = Get-AzureADUser -All $true | Where-Object {$_.AssignedLicenses.SkuId -eq '3b555118-da6a-4418-894f-7df1e2096870'}

# little report
$directLicenseAssignmentReport = @()
$directLicenseAssignmentCount = 0

$Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

foreach ($user in $allUsers){
    # processing all licenses per user
    foreach ($license in $user.AssignedLicenses.SkuId){              
        
        if ($license -eq '3b555118-da6a-4418-894f-7df1e2096870') {
        
            $directLicenseAssignmentCount++
            Write-Verbose "User $($user.UserPrincipalName) ($($user.ObjectId)) has direct license assignment for sku '$($license)')"
            
            # add details to the report
            $directLicenseAssignmentReport += [PSCustomObject]@{
                UserPrincipalName = $user.UserPrincipalName
                ObjectId = $user.ObjectId
                AccountSkuId = $license
                DirectAssignment = $true
            }        

            if($PSCmdlet.ShouldProcess($user.UserPrincipalName,"Remove license assignment for sku '$($license)'")){
                Write-Warning "Removing license assignment for sku '$($license) on target '$($user.UserPrincipalName)'"                
                $Licenses.RemoveLicenses = $license                
                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $Licenses
            }
        }
    }
}


if ($directLicenseAssignmentCount -gt 0){
    Write-Output "`nFound $directLicenseAssignmentCount direct assigned license(s):"
    Write-Output $directLicenseAssignmentReport

    if ($SaveReport.IsPresent){
        $exportPath = Join-Path $PSScriptRoot "AADDirectLicenseAssignments.csv"
        $directLicenseAssignmentReport | Export-Csv -Path $exportPath -Encoding "utf8" -NoTypeInformation -WhatIf:$false
        Write-Output "`nSaved report to: '$exportPath'"
    }

}else {
    Write-Output "No direct license assignments found"
}