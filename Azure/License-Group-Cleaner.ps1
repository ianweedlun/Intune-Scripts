function GroupAddBySKU {
    param(
        [Parameter (Mandatory = $true)] [String]$skuId,
        [Parameter (Mandatory = $true)] [String]$groupName
    )

    $allUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($skuId) )" # Get all users with SKU

    $groupId = (Get-MgGroup | Where-Object { $_.DisplayName -eq $groupName }).Id # Find group ID

    Write-Host "Checking that all users assigned" $skuId "`nare members of" $groupName"."

    ForEach ($user in $allUsers) {
        $groups = Get-MgUserMemberOf -UserId $user.Id
        if ($groups.Id -notcontains $groupId) {
            New-MgGroupMember -Group $groupId -DirectoryObjectId $user.Id # Try to add the user to the group
            Write-Host $user.UserPrincipalName "has been added to" $groupName
        }
    }
}

function RemoveDirectLicenseAssignments {
    param(
        [Parameter (Mandatory = $true)] [String]$skuId
    )

    # Get all users with SKU
    $users = Get-MgUser -All -Property AssignedLicenses, LicenseAssignmentStates, DisplayName, Id | Select-Object DisplayName, AssignedLicenses, Id -ExpandProperty LicenseAssignmentStates | Select-Object DisplayName, AssignedByGroup, Id, SkuId | Where-Object { $_.SkuId -eq $skuId } | Where-Object { $_.AssignedByGroup -eq $null }

    Write-Host "Checking for SKU" $skuId "directly assigned to users."

    foreach ($user in $users) {
        Set-MgUserLicense -UserId $user.Id -RemoveLicenses @($skuId) -AddLicenses @{} | Out-Null
        Write-Host "Removing" $skuId "from" $user.DisplayName
    }
}

Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All, Group.ReadWrite.All -NoWelcome # Connect to MS Graph with required permissions

<# Define table of products and their corresponding group name.
Get-MgSubscribedSku | Select -Property Sku*, ConsumedUnits -ExpandProperty PrepaidUnits | Format-List #>

$products = @{
    VISIOCLIENT              = "M365 License - Visio Plan 2"
    EXCHANGEENTERPRISE       = "M365 License - Exchange P2"
    SPB                      = "M365 License - Business Premium"
    O365_BUSINESS_PREMIUM    = "M365 License - Business Standard"
    O365_BUSINESS_ESSENTIALS = "M365 License - Business Basic"
    EXCHANGESTANDARD         = "M365 License - Exchange P1"
    SPE_F1                   = "M365 License - F3"
    PROJECTPROFESSIONAL      = "M365 License - Project Plan 3"
    MCOTEAMS_ESSENTIALS      = "M365 License - Business Premium + Teams Phone with Calling Plan (country zone 1 - US)"
    MCOPSTN9                 = "M365 License - Business Premium + Microsoft Teams International Calling Plan (for SMB)"
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
        # Add all licensees to the proper corresponding group
        GroupAddBySKU -skuId $SKU -groupName $group
        Write-Host "Group memberships corrected, moving onto removing direct assignments."
        # Remove same license if directly assigned to users
        RemoveDirectLicenseAssignments -skuId $SKU
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