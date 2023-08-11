# Define the URL of the MSI file
$msiUrl = "https://example.com/path/to/your.msi"

# Define the path to the Windows temp folder
$tempFolder = [System.IO.Path]::GetTempPath()

# Define the path for saving the downloaded MSI file
$msiPath = Join-Path -Path $tempFolder -ChildPath "installer.msi"

# Create a WebClient object for downloading the file
$webClient = New-Object System.Net.WebClient

# Download the MSI file
$webClient.DownloadFile($msiUrl, $msiPath)

# Install the MSI file silently
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /qn" -Wait

# Clean up the downloaded MSI file
Remove-Item -Path $msiPath