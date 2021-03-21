## Created by Khaled Salameh
## a Small "Not so smart but functional" Script that Generates a Selfsigned SSL and adds it to the local trusted root CAs
Write-Host  ""
## Elevate the permissions to Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Write-Host  "--->>  Admin Permissions Required  <<---" -ForegroundColor Yellow
  pause
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}
If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	Write-Host "Script Executed as Administrator....Proceeding!" -ForegroundColor Green
	Write-Host ""
}
Write-Host "Please write the FQDN of the SSL" -ForegroundColor Yellow
$SSLFQDN = Read-Host "Input FQDN =>"
Write-Host ""
Write-Host "Chosen FQDN:{ $SSLFQDN }" -ForegroundColor Green
Write-Host ""
$SSLFriendlyName = Read-Host "Type the SSL Friendly Name"
Write-Host  "This Script will provision an SSL Certificate with the $SSLFQDN" -ForegroundColor Yellow
Write-Host  "and will add the SSL to the Trusted Root Certification Authorities" -ForegroundColor Yellow
Write-Host  ""
## Request Certificate
Write-Host "Generating SSL" -ForegroundColor Green
$Certificate = New-SelfSignedCertificate -DnsName @("$SSLFQDN") -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddMonths(60)
## Bind the Thumbprint
Write-Host "Binding Thumbprint" -ForegroundColor Green
$CertificateThumb = $Certificate.Thumbprint
## Import the SSL to LocalMachine Store
Write-Host "Importing SSL to Trusted Root Store" -ForegroundColor Green
$CertificateImport = Get-ChildItem -Path cert:\LocalMachine\My\$CertificateThumb
## Create Temp Folder
mkdir c:\TempSSLStore > $null
## Export the public key to the temp location for trust
Export-Certificate -Cert $CertificateImport -FilePath c:\TempSSLStore\TempSSL.cer > $null
## Import the Public key into the Trusted Root CA Location
Import-Certificate -FilePath "c:\TempSSLStore\TempSSL.cer" -CertStoreLocation cert:\LocalMachine\Root > $null
## Cleanup Temp Folder
Write-Host "Cleaning Up..." -ForegroundColor Green
Remove-Item C:\TempSSLStore\ -Force -Recurse > $null
## Change SSL Friendly Name to SSL Name defined by user Selfsigned SSL
Write-Host "Setting SSL Friendly Name to $SSLFriendlyName" -ForegroundColor Green
(Get-ChildItem -Path Cert:\LocalMachine\My\$CertificateThumb).FriendlyName = "$SSLFriendlyName"
Write-Host "Done..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Testing SSL Existence..." -ForegroundColor Yellow
Write-Host "SSL Name Retrieved is:" -ForegroundColor Cyan (Get-ChildItem -Path Cert:\LocalMachine\My\$CertificateThumb).FriendlyName
Write-Host "Subject:" -ForegroundColor Cyan (Get-ChildItem -Path Cert:\LocalMachine\My\$CertificateThumb).Subject
Write-Host "" 
Write-Host "SSL Generated Successfully!" -ForegroundColor Green
Write-Host ""
Read-Host "Press enter to exit"

