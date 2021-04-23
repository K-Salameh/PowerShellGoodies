## A Quick Script Useful for Updating NodeJS on Machines that already have NodeJS Installed
## Tested on Intune and Works Nicely, useful for updating computers quickly to the latest version of NodeJS using Intune Scripting
## You can replace NodeJS with other apps if you like, but tweaking across the script will be required

If ((Test-Path 'HKLM:\SOFTWARE\Node.js') -Like 'False')
{
    Write-Host "NodeJS is NOT Installed, No Action Will Be Made" -ForegroundColor Yellow
    Write-Host "Exiting..." -ForegroundColor Yellow
}
Else
{
    $InstalledNodeJSVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Node.js").Version
    Write-Host "Current Version Installed of NodeJS is $InstalledNodeJSVersion" -ForegroundColor Yellow
If (($InstalledNodeJSVersion) -lt "14.16.1") 
{
    Write-Host "You are not running the latest version of NodeJS, pushing latest update of NodeJS" -ForegroundColor Yellow
    $LocalTempDir = $env:TEMP; 
    $NodeJSInstaller = "node-v14.16.1-x64.msi"; 
    (new-object System.Net.WebClient).DownloadFile('https://nodejs.org/dist/v14.16.1/node-v14.16.1-x64.msi', "$LocalTempDir\$NodeJSInstaller"); & "$LocalTempDir\$NodeJSInstaller" /quiet; 
    $Process2Monitor =  "msiexec.exe"; Do { $ProcessesFound = Get-CimInstance Win32_Process -Filter "name = '$Process2Monitor'" | Where-Object CommandLine -CMatch node-v14.16.1-x64.msi; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } 
    else 
    {
        Remove-Item "$LocalTempDir\$NodeJSInstaller" -ErrorAction SilentlyContinue -Verbose
    } 
} Until (!$ProcessesFound)

} Else 
{
    Write-Host "This is the latest version that this updater supports, no action will be made" -ForegroundColor Green
}
}