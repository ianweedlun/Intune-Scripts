# ~~~~~~ SETTINGS YOU NEED TO CHANGE ~~~~~

# Full path to the PFX certificate file. This is the Central Certificate Store
# location that you gave when the certificate was created.
$certFile = 'C:\win-acme\ccs\wyeriver-azure.knottmechanical.com.pfx'

# This is the location of the registry key that contains the thumbprint of the
# certificate that SQL Server is currently using. This path will change slightly
# depending on which version of SQL Server you are using and the name of the instance.
$regpath = 'Registry::\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQLServer\SuperSocketNetLib'

$subjectName = 'wyeriver-azure.knottmechanical.com'

# The SQL Server service account that will need permissions on the certificate
$sqlServerServiceAccount = "NT Service\MSSQLSERVER"

# The names of the services that will be restarted after a new certificate is installed. These
# can be found in the services config window.
$sqlServerServiceName = "MSSQLSERVER"
$sqlServerAgentServiceName = "SQLSERVERAGENT"
$sleepTime = 10

# The certificate store location - you probably don't need to touch this
$certStoreLocation = "/LocalMachine/My"

# ~~~~~~ DON'T TOUCH ~~~~~

# The thumbprint of the certificate SQL Server is currently using.
$currCertThumb = (Get-Itemproperty -Path $regpath).Certificate

# The thumbprint for the certificate we're testing. This magic dot notation was explained here:
# https://stackoverflow.com/questions/22408150/get-thumbprint-of-a-certificate
$newCertThumb = (Get-PfxCertificate -FilePath $certFile).Thumbprint.toLower()

Write-Host "Current Certificate Thumprint (from SQL Server): $($currCertThumb)"
Write-Host "New Certificate Thumbprint: $($newCertThumb)"

if ( $currCertThumb -ne $newCertThumb ) {
	Write-Host "Certificate has changed - updating"

	# Used to check for the presence of the current and new certificates in the store. Depending on what
	# state the system is currently in one or other of the certificates might be missing or already
	# installed.
	$currCertificate = Get-ChildItem cert:$certStoreLocation | Where thumbprint -eq $currCertThumb
	$newCertificate = Get-ChildItem cert:$certStoreLocation | Where thumbprint -eq $newCertThumb

	
	# Remove the current certificate if it's available (covers the case where it was removed manually)
	if ( $currCertificate -ne $null ) {
		Write-Host "Removing current certificate"
		Get-ChildItem Cert:$certStoreLocation/$currCertThumb | Remove-Item
	}
 else {
		Write-Host "The current certificate was not found in the store!" -ForegroundColor red
	}
	
	# Import the new certificate into the certificate store if it's not already there.
	if ( $newCertificate -eq $null ) {
		Write-Host "Installing new certificate"
		Import-PfxCertificate -CertStoreLocation cert:$certStoreLocation -Exportable -FilePath Filesystem::$certFile
	}
 else {
		Write-Host "A certificate with the same thumbprint as the new certificate already exists. Skipping installation." -ForegroundColor red
	}
	
	# Get the new certificate
	$newCertificate = Get-ChildItem cert:$certStoreLocation | Where thumbprint -eq $newCertThumb
	
	# Find the file that holds the private key.
	$rsaCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($newCertificate)
	$fileName = $rsaCert.key.UniqueName
	$path = "$env:ALLUSERSPROFILE\Microsoft\Crypto\Keys\$fileName"
	Write-Host "Private Key Path: $($path)"
	
	# Get the existing permissions for the private key and then create a new access rule and assign it.
	# Note, this doesn't appear to give permissions in the same way as a doing it manually through the MMC
	# using All Tasks > Manage Private Keys... - the permissions don't show up.
	$permissions = Get-Acl -Path $path
	$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $sqlServerServiceAccount, fullcontrol, allow
	$permissions.AddAccessRule($accessRule)
	Set-Acl -Path $path -AclObject $permissions
	
	# Update the registry entry to reflect the new thumbprint.
	Set-ItemProperty -Path $regpath -Name 'Certificate' -Value $newCertThumb
	
	# When the certificate is updated the SQL Server needs to be restarted.
	# If the SQL Server Agent is running it needs to be stopped first and then restarted.
	Stop-Service $sqlServerAgentServiceName
	sleep $sleepTime
	Restart-Service $sqlServerServiceName
	sleep $sleepTime
	Start-Service $sqlServerAgentServiceName
}
else {
	Write-Host "Certificate matched - exiting"
}