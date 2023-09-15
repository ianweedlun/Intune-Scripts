$Path1 = "HKCU:\SOFTWARE\Microsoft\GameBar"
$Name1 = "AllowAutoGameMode"
$Type1 = "REG_DWORD"
$Value = "0"

$Path2 = "HKCU:\SOFTWARE\Microsoft\GameBar"
$Name2 = "AutoGameModeEnabled"
$Type2 = "REG_DWORD"

$Path3 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
$Name3 = "AppCaptureEnabled"
$Type3 = "REG_DWORD"

$Path4 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
$Name4 = "HistoricalCaptureEnabled"
$Type4 = "REG_DWORD"



Try {
    $Registry1 = Get-ItemProperty -Path $Path1 -Name $Name1 -ErrorAction Stop | Select-Object -ExpandProperty $Name1
    $Registry2 = Get-ItemProperty -Path $Path2 -Name $Name2 -ErrorAction Stop | Select-Object -ExpandProperty $Name2
    $Registry3 = Get-ItemProperty -Path $Path3 -Name $Name3 -ErrorAction Stop | Select-Object -ExpandProperty $Name3
    $Registry4 = Get-ItemProperty -Path $Path4 -Name $Name4 -ErrorAction Stop | Select-Object -ExpandProperty $Name4
    If ($Registry1 -eq $Value -and $Registry2 -eq $Value -and $Registry3 -eq $Value -and $Registry4 -eq $Value){
        Write-Output "Detected"
        Exit 0
    } 
   Exit 1
}
 
Catch {
    Exit 1
}