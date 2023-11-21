$TenantID = "YOURTENANTID"
$SubscriptionID = "YOURSUBSCRIPTIONID"
$ResourceGroup = "YOURRESOURCEGROUP"
$DCRName = "YOURDCRNAME"

Connect-AzAccount -Tenant $TenantID
Select-AzSubscription -SubscriptionId $SubscriptionID

$user = Get-AzADUser -UserPrincipalName (Get-AzContext).Account
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id

$auth = Get-AzAccessToken

$AuthenticationHeader = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer " + $auth.Token
}

$newguid = (New-Guid).Guid
$UserObjectID = $user.Id

$body = @"
{
    "properties": {
        "roleDefinitionId":"/providers/Microsoft.Authorization/roleDefinitions/56be40e24db14ccf93c37e44c597135b",
        "principalId": `"$UserObjectID`"
    }
}
"@

$request = "https://management.azure.com/providers/microsoft.insights/providers/microsoft.authorization/roleassignments/$newguid`?api-version=2021-04-01-preview"

Invoke-RestMethod -Uri $request -Headers $AuthenticationHeader -Method PUT -Body $body

$request = "https://management.azure.com/providers/Microsoft.Insights/monitoredObjects/$TenantID`?api-version=2021-09-01-preview"
$body = @'
{
    "properties":{
        "location":"eastus"
    }
}
'@

$Respond = Invoke-RestMethod -Uri $request -Headers $AuthenticationHeader -Method PUT -Body $body -Verbose
$RespondID = $Respond.id

$request = "https://management.azure.com$RespondId/providers/microsoft.insights/datacollectionruleassociations/assoc?api-version=2021-04-01"
$body = @"
{
    "properties": {
        "dataCollectionRuleId": "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroup/providers/Microsoft.Insights/dataCollectionRules/$DCRName"
    }
}

"@

Invoke-RestMethod -Uri $request -Headers $AuthenticationHeader -Method PUT -Body $body