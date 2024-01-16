function GroupAddBySKU {
    param(
        [Parameter (Mandatory = $true)] [String]$skuId,
        [Parameter (Mandatory = $true)] [String]$groupName
    )

    # Get all users with SKU

    $allUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($skuId) )"

    # Find group ID

    $groupId = Get-MgGroup -Filter "DisplayName eq '$groupName'" | select Id

    Write-Host "Checking that all users assigned " $skuId " are members of " $groupName "."

    ForEach ($user in $allUsers) {
        try {
            # Try to add the user to the new group      
            New-MgGroupMember -Group $groupId.Id -DirectoryObjectId $user.Id -ErrorAction stop  
            Write-Host $user.UserPrincipalName "has been added to " $groupName                
        }
        catch {
            Write-Host $user.UserPrincipalName "has not been changed."
        }
    }
}

function RemoveDirectLicenseAssignments {
    param(
        [Parameter (Mandatory = $true)] [String]$skuId        
    )

    # Get all users with SKU

    $allUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($skuId) )"

    Write-Host "Checking for SKU" $skuId " directly assigned to users."

    foreach ($user in $allUsers) {
    
        $assignedLicenses = Get-MgUserLicenseDetail -UserId $user.Id

        foreach ($license in $assignedLicenses.skuId) {              
        
            if ($license -eq $skuId) {           

                try {                    
                    Set-MgUserLicense -UserId $user.Id -RemoveLicenses @($license) -AddLicenses @{} -ErrorAction stop
                    Write-Host $user.UserPrincipalName "has had" $skuId "removed."
                }
                catch {
                    Write-Host $user.UserPrincipalName "has not been changed."
                }
            }
        }
    }
}

# Connect to MS Graph with required permissions

Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All, Group.ReadWrite.All

# Define table of products and their corresponding group name.

$products = @{
    O365_BUSINESS_ESSENTIALS = 'M365 License - Business Basic'
}

foreach ($product in $products.keys) {

    # Find license SKU  

    $SKU = Get-MgSubscribedSku -All | Where SkuPartNumber -eq $product
    $SKU = $SKU.skuId

    # Find group name

    $group = $products[$product]

    # Add all licensees to the proper corresponding group

    GroupAddBySKU -skuId $SKU -groupName $group
    Write-Host "Group memberships corrected, moving onto removing direct assignments."

    Sleep 3

    # Remove same license if directly assigned to users

    RemoveDirectLicenseAssignments -skuId $SKU

}

Disconnect-MgGraph