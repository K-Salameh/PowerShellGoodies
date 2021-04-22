## A Quick Script Useful for Updating Chrome on Machines that already have Chrome Installed
## Tested on Intune and Works Nicely, useful for updating computers quickly to the latest version of chrome using Intune Scripting
## Some scripts where copied from other authors and has been credited where credit is due
## You can replace chrome with other apps if you like, but tweaking across the script will be required

If ((Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe') -Like 'False')
{
    Write-Host "Google Chrome is Installed, No Action will be made" -ForegroundColor Yellow
    Write-Host "Exiting..." -ForegroundColor Yellow
}
Else
{
    ## Credit to this section goes to https://noirth.com/threads/check-latest-google-chrome-version-powershell.7874/ (Asphyxia) - this section gets the current stable release version number of chrome
    $GCVersionInfo = (Get-Item (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(Default)').VersionInfo
    $GCVersion = $GCVersionInfo.ProductVersion
    $j = Invoke-WebRequest 'https://omahaproxy.appspot.com/all.json' -UseBasicParsing | ConvertFrom-Json
    $stable = $j.versions | Where-Object { $_.channel -eq "stable" }
If ($GCVersion -eq $stable[6].current_version) 
{
    Write-Host "You Are Running the Latest Version of Google Chrome "$stable[6].current_version", No Need to Update" -ForegroundColor Green
} Else 
{
    Write-Host "You are not running the latest version of Google Chrome, pushing latest update "$stable[6].current_version"" -ForegroundColor Yellow
    ## Credit to this section goes to https://www.snel.com/support/install-chrome-in-windows-server/ - it installs chrome using the chrome installer
    $LocalTempDir = $env:TEMP; 
    $ChromeInstaller = "ChromeInstaller.exe"; 
    (new-object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install; 
    $Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } 
    else 
    {
        Remove-Item "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose
    } 
} Until (!$ProcessesFound)

}
}