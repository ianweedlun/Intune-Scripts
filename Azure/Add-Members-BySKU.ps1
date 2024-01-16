#Requires -Module MSOnline
[CmdletBinding(SupportsShouldProcess)]
param (
    # Saves the report to the script location
    [Parameter()]
    [switch]
    $SaveReport
)

# Connect-MsolService
<# Get-MsolAccountSku - Lists all of the SKUs in use by tenant. Be sure to match usage counts to determine accurate name mapping.
Some licenses have SKU names that don't match their product name (e.g. M365 Business Standard is "O365_BUSINESS_PREMIUM")
#>

# Get all users with SKU
$msolUsers = Get-MsolUser -All | Where-Object {($_.licenses).AccountSkuId -like '*O365_BUSINESS_ESSENTIALS'} | Select DisplayName,UserPrincipalName,ObjectId

# Get the Group Id of your new Group. Change searchString to your new group name
$groupId = Get-MsolGroup -SearchString "M365 License - Business Basic" | select ObjectId

ForEach ($user in $msolUsers) {
  try {
    # Try to add the user to the new group
    Add-MsolGroupMember -GroupObjectId $groupId.ObjectId -GroupMemberType User -GroupMemberObjectId $user.ObjectId -ErrorAction stop

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