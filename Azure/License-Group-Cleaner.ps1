function GroupAddBySKU {
    param(
        [Parameter (Mandatory = $true)] [String]$skuId,
        [Parameter (Mandatory = $true)] [String]$groupName
    )

    $allUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($skuId) )" # Get all users with SKU

    $groupId = (Get-MgGroup | Where-Object { $_.DisplayName -eq $groupName }).Id # Find group ID

    if (!$groupId) {
        $groupId = (Get-MgGroup -Filter "DisplayName eq '$groupName'").Id # Fallback method if first lookup fails to find group
    }

    Write-Host "Checking that all users assigned" $skuId "are `nmembers of" $groupName"."

    ForEach ($user in $allUsers) {
        $groups = Get-MgUserMemberOf -UserId $user.Id
        if ($groups.Id -notcontains $groupId) {
            Write-Host "Adding" $user.UserPrincipalName "to" $groupName
            New-MgGroupMember -Group $groupId -DirectoryObjectId $user.Id -ErrorAction Stop | Out-Null # Try to add the user to the group
            $groups = Get-MgUserMemberOf -UserId $user.Id
            if ($groups.Id -contains $groupId) { # Check if adding to group was successful
                Write-Host "Successful!"
                Invoke-MgLicenseUser -UserId $user.Id -ErrorAction Stop | Out-Null # Process licensing assignment by group
            }
            else {
                Write-Host "Failed to add" $user.UserPrincipalName "to" $groupName
                Disconnect-MgGraph
                Exit
            }
        }
    }
}

function RemoveDirectLicenseAssignments {
    param(
        [Parameter (Mandatory = $true)] [String]$skuId
    )

    # Get all users with SKU directly assigned
    $users = Get-MgUser -All -Property AssignedLicenses, LicenseAssignmentStates, UserPrincipalName, Id | Select-Object UserPrincipalName, AssignedLicenses, Id -ExpandProperty LicenseAssignmentStates | Select-Object UserPrincipalName, AssignedByGroup, Id, SkuId | Where-Object { $_.SkuId -eq $skuId } | Where-Object { $_.AssignedByGroup -eq $null }

    Write-Host "Checking for SKU" $skuId "directly assigned to users."

    foreach ($user in $users) {
        Write-Host "Removing" $skuId "from" $user.UserPrincipalName
        Set-MgUserLicense -UserId $user.Id -RemoveLicenses @($skuId) -AddLicenses @{} -ErrorAction Stop | Out-Null # Try to remove the directly assigned license
        # if Get-MgUser -All -Property AssignedLicenses, LicenseAssignmentStates, UserPrincipalName, Id | Select-Object UserPrincipalName, AssignedLicenses, Id -ExpandProperty LicenseAssignmentStates | Select-Object UserPrincipalName, AssignedByGroup, Id, SkuId | Where-Object { $_.SkuId -eq $skuId } | Where-Object { $_.AssignedByGroup -eq $null }
        # no longer contains $user, successful
        Write-Host $skuId "removed from" $user.UserPrincipalName
    }
}

Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All, Group.ReadWrite.All -NoWelcome # Connect to MS Graph with required permissions

<# Define table of products and their corresponding group name.
Get-MgSubscribedSku | Select -Property Sku*, ConsumedUnits -ExpandProperty PrepaidUnits | Format-List #>

$products = @{
    O365_BUSINESS_ESSENTIALS = "M365 License - Business Basic"
    O365_BUSINESS_PREMIUM    = "M365 License - Business Standard"
    SPB                      = "M365 License - Business Premium"
    EXCHANGESTANDARD         = "M365 License - Exchange P1"
    EXCHANGEENTERPRISE       = "M365 License - Exchange P2"
    SPE_F1                   = "M365 License - F3"
    ATP_ENTERPRISE           = "M365 License - Defender for O365 P1"
    PROJECTPROFESSIONAL      = "M365 License - Project Plan 3"
    VISIOCLIENT              = "M365 License - Visio Plan 2"
    #MCOTEAMS_ESSENTIALS      = "M365 License - Business Premium + Teams Phone with Calling Plan (country zone 1 - US)"
    #MCOPSTN9                 = "M365 License - Business Premium + Microsoft Teams International Calling Plan (for SMB)"
}

Write-Host "Launching M365 license group organizer`n" -ForegroundColor Green

foreach ($product in $products.keys) {

    # Find license SKU

    "-" * 80 | Write-Host -ForegroundColor Green
    Write-Host "Searching for" $products[$product]

    $SKU = Get-MgSubscribedSku -All | Where SkuPartNumber -eq $product

    if ($SKU) {
        $SKU = $SKU.skuId
        $group = $products[$product]
        GroupAddBySKU -skuId $SKU -groupName $group # Add all licensees to the proper license group
        Write-Host "`nGroup memberships corrected, moving onto removing direct assignments."
        RemoveDirectLicenseAssignments -skuId $SKU # Remove same license if directly assigned to users
        "-" * 80 | Write-Host -ForegroundColor Green
        Write-Host "`n"
    }
    else {
        Write-Host $product "subscription not found in this tenant" -ForegroundColor Red
        "-" * 80 | Write-Host -ForegroundColor Green
        Write-Host "`n"
    }
}

Disconnect-MgGraph