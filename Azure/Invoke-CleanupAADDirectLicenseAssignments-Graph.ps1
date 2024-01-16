# Requires -Module Microsoft.Graph

Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All, Group.Read.All

$busbasicSKU = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'O365_BUSINESS_ESSENTIALS'
$skuId = $busbasicSKU.SkuId

# Get all users with SKU

$allUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($skuId) )"

foreach ($user in $allUsers) {
    
    $assignedLicenses = Get-MgUserLicenseDetail -UserId $user.Id

    foreach ($license in $assignedLicenses.skuId) {              
        
        if ($license -eq $skuId) {           

            try {
                Set-MgUserLicense -UserId $user.Id -RemoveLicenses @($license) -AddLicenses @{} -ErrorAction stop

                [PSCustomObject]@{
                    UserPrincipalName = $user.UserPrincipalName
                    DirectRemoved     = $true
                }
            }
            catch {
                [PSCustomObject]@{
                    UserPrincipalName = $user.UserPrincipalName
                    DirectRemoved     = $false
                }
            }
        }
    }
}

Disconnect-MgGraph