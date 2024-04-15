$Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
$Name = "HiberbootEnabled"
$Value = "0"
Set-ItemProperty -path $Path -name $Name -value $Value -Type "DWord" -Force -Confirm:$False