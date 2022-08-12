function Test-RegistryValue {
    param (
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
    
    [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value
    )
    
    try {
        Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
        return $true
    }catch {
        return $false
    }
}

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion"
$showTaskViewButton = "ShowTaskViewButton"
$showWidgets = "TaskbarDa"
$showSearch = "SearchboxTaskbarMode"
$showChat = "TaskbarMn"


if(Test-RegistryValue -Path "$regPath\Explorer\Advanced" -Value $showTaskViewButton){
    if((Get-ItemProperty -Path "$regPath\Explorer\Advanced" | Select-Object -ExpandProperty $showTaskViewButton) -ne 0){
        Write-Host "Show Task View Button is active"
        exit 1
    }
}
else {
    Write-Host "Show Task View Button is active"
    exit 1
}

if(Test-RegistryValue -Path "$regPath\Explorer\Advanced" -Value $showWidgets){
    if((Get-ItemProperty -Path "$regPath\Explorer\Advanced" | Select-Object -ExpandProperty $showWidgets) -ne 0){
        Write-Host "Show Widgets is active"
        exit 1
    }
}
else {
    Write-Host "Show Widgets is active"
    exit 1    
}

if(Test-RegistryValue -Path "$regPath\Search" -Value $showSearch){
    if((Get-ItemProperty -Path "$regPath\Search" | Select-Object -ExpandProperty $showSearch) -ne 0){
        Write-Host "Show Search Button is active"
        exit 1
    }
}
else {
    Write-Host "Show Search Button is active"
    exit 1   
}

if(Test-RegistryValue -Path "$regPath\Search" -Value $showSearch){
    if((Get-ItemProperty -Path "$regPath\Search" | Select-Object -ExpandProperty $showSearch) -ne 0){
        Write-Host "Show Search Button is active"
        exit 1
    }
}
else {
    Write-Host "Show Search Button is active"
    exit 1   
}

if(Test-RegistryValue -Path "$regPath\Explorer\Advanced" -Value $showChat){
    if((Get-ItemProperty -Path "$regPath\Explorer\Advanced" | Select-Object -ExpandProperty $showChat) -ne 0){
        Write-Host "Show Chat Button is active"
        exit 1
    }
}
else {
    Write-Host "Show Chat Button is active"
    exit 1
}

exit 0