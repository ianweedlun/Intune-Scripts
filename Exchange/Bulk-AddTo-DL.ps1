Import-CSV C:\temp\123.csv | foreach {  
    $UPN = $_.UPN 
    Write-Progress -Activity "Adding $UPN to group…" 
    Add-DistributionGroupMember -Identity "plumbingdepartment@knottmechanical.com" -Member $UPN  
    If ($?) {  
        Write-Host $UPN Successfully added -ForegroundColor Green 
    }  
    Else {  
        Write-Host $UPN - Error occurred -ForegroundColor Red  
    }  
} 