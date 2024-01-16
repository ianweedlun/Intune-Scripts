function GroupAddBySKU {
    param(
        [Parameter (Mandatory = $true)] [String]$skuId,
        [Parameter (Mandatory = $true)] [String]$groupName
    )

    # Get all users with SKU

    $allUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($skuId) )"

    # Find group ID

    $groupId = Get-MgGroup -Filter "DisplayName eq '$groupName'" | select Id

    Write-Host "Checking that all users assigned" $skuId "are members of" $groupName"."

    ForEach ($user in $allUsers) {
        try {
            # Try to add the user to the new group      
            New-MgGroupMember -Group $groupId.Id -DirectoryObjectId $user.Id -ErrorAction stop  
            Write-Host $user.UserPrincipalName "has been added to " $groupName                
        }
        catch {            
        }
    }
}

function RemoveDirectLicenseAssignments {
    param(
        [Parameter (Mandatory = $true)] [String]$skuId        
    )

    # Get all users with SKU

    $allUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($skuId) )"

    Write-Host "Checking for SKU" $skuId "directly assigned to users."

    foreach ($user in $allUsers) {
    
        $assignedLicenses = Get-MgUserLicenseDetail -UserId $user.Id

        foreach ($license in $assignedLicenses.skuId) {              
        
            if ($license -eq $skuId) {           

                try {                    
                    Set-MgUserLicense -UserId $user.Id -RemoveLicenses @($license) -AddLicenses @{} -ErrorAction stop
                    Write-Host $user.UserPrincipalName "has had" $skuId "removed."
                }
                catch {                    
                }
            }
        }
    }
}

# Connect to MS Graph with required permissions

Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All, Group.ReadWrite.All -NoWelcome

# Define table of products and their corresponding group name.

# Get-MgSubscribedSku | Select -Property Sku*, ConsumedUnits -ExpandProperty PrepaidUnits | Format-List

$products = @{
    SPB                      = "M365 License - Business Premium"
    O365_BUSINESS_PREMIUM    = "M365 License - Business Standard"
    O365_BUSINESS_ESSENTIALS = "M365 License - Business Basic"
    EXCHANGESTANDARD         = "M365 License - Exchange P1"
    EXCHANGEENTERPRISE       = "M365 License - Exchange P2"
    SPE_F1                   = "M365 License - F3"
    VISIOCLIENT              = "M365 License - Visio Plan 2"
    PROJECTPROFESSIONAL      = "M365 License - Project Plan 3"
}

foreach ($product in $products.keys) {

    # Find license SKU

    Write-Host "Searching for" $product"."
    
    $SKU = Get-MgSubscribedSku -All | Where SkuPartNumber -eq $product

    if ($SKU) {    
        $SKU = $SKU.skuId    
        $group = $products[$product]
        # Add all licensees to the proper corresponding group        
        GroupAddBySKU -skuId $SKU -groupName $group    
        Write-Host "Group memberships corrected, moving onto removing direct assignments."
        Sleep 3
        # Remove same license if directly assigned to users
        RemoveDirectLicenseAssignments -skuId $SKU  
    }
    else {
        Write-Host $product "not found."
    }    
}

Disconnect-MgGraph