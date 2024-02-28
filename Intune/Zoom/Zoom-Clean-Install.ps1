if(!(Get-Process zoom -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath "CleanZoom.exe" /silent
    while (Get-Process CleanZoom -ErrorAction SilentlyContinue) {
        Start-Sleep 1
    }
    Start-Process "msiexec.exe" -ArgumentList "/i ZoomInstallerFull.msi /quiet /qn /norestart /log install.log ZoomAutoUpdate=1"
}
else {
    Write-Host "Zoom is currently running. Try installing later."
}