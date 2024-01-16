# Requires -Module Microsoft.Graph

Connect-MgGraph -Scopes User.Read.All, Organization.Read.All, Group.ReadWrite.All

# Find license SKU

$busbasicSKU = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'O365_BUSINESS_ESSENTIALS'
$skuId = $busbasicSKU.SkuId
$groupName = "M365 License - Business Basic"

# Get all users with SKU

$allUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($skuId) )"

$groupId = Get-MgGroup -Filter "DisplayName eq '$groupName'" | select Id

ForEach ($user in $allUsers) {
    try {
        # Try to add the user to the new group      
        New-MgGroupMember -Group $groupId.Id -DirectoryObjectId $user.Id -ErrorAction stop
  
        [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            Migrated          = $true
        }
    }
    catch {
        [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            Migrated          = $false
        }
    }
}

Disconnect-MgGraph