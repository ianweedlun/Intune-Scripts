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
    }
    catch {
        return $false
    }
}

$key = 'HKLM:SOFTWARE\Microsoft\Enrollments\'
$keys = (Get-ChildItem $key)
foreach($subkey in $keys) {
    $children =(Get-ChildItem($key + $subkey.PSChildName))
    foreach($child in $children) {
    if($child.PSChildName -eq 'FirstSync')    {
        $location =($key + $subkey.PSChildName)
        }
    }
}

if(Test-RegistryValue -Path "$location\FirstSync" -value SkipUserStatusPage) {
    if((Get-ItemProperty -Path "$location\FirstSync" | Select-Object -ExpandProperty SkipUserStatusPage) -ne 0xffffffff) {
        Set-ItemProperty -path "$location\FirstSync" -name SkipUserStatusPage -value 0xffffffff
    }
}
else {    
    New-ItemProperty -Path "$location\FirstSync" -name SkipUserStatusPage -value 0xffffffff -PropertyType Dword
}

if(Test-RegistryValue -Path "$location\FirstSync" -value SkipDeviceStatusPage) {
    if((Get-ItemProperty -Path "$location\FirstSync" | Select-Object -ExpandProperty SkipDeviceStatusPage) -ne 0xffffffff) {
        Set-ItemProperty -path "$location\FirstSync" -name SkipDeviceStatusPage -value 0xffffffff
    }
}
else {    
    New-ItemProperty -Path "$location\FirstSync" -name SkipDeviceStatusPage -value 0xffffffff -PropertyType Dword
}