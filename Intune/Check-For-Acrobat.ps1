# Define the paths to check
$adobePath32bit = "C:\Program Files\Adobe\Acrobat DC"
$adobePath64bit = "C:\Program Files (x86)\Adobe\Acrobat DC"

# Check if the 32-bit path exists
if ((Test-Path $adobePath32bit) -or (Test-Path $adobePath64bit)) {
    Write-Host "Adobe Acrobat DC found"
    exit 0
} else {
    Write-Host "Adobe Acrobat DC not found"
    exit 1
}