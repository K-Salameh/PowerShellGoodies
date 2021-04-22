## A Quick Script Useful for Updating Git on Machines that already have Git Installed
## Tested on Intune and Works Nicely, useful for updating computers quickly to the latest version of Git using Intune Scripting
## Some scripts where copied from other authors and has been credited where credit is due
## You can replace git with other apps if you like, but tweaking across the script will be required

If ((Test-Path 'HKLM:\SOFTWARE\GitForWindows') -Like 'False')
{
    Write-Host "Git is NOT Installed, No Action Will Be Made" -ForegroundColor Yellow
    Write-Host "Exiting..." -ForegroundColor Yellow
}
Else
{
    $InstalledGitVersion = (Get-ItemProperty "HKLM:\SOFTWARE\GitForWindows").CurrentVersion
    Write-Host "Current Version Installed of Git is $InstalledGitVersion" -ForegroundColor Yellow
If (($InstalledGitVersion) -lt "2.31.1") 
{
    Write-Host "You are not running the latest version of Git, pushing latest update of Git" -ForegroundColor Yellow
    $LocalTempDir = $env:TEMP; 
    $GitInstaller = "Git-2.31.1-64-bit.exe"; 
    (new-object System.Net.WebClient).DownloadFile('https://github.com/git-for-windows/git/releases/download/v2.31.1.windows.1/Git-2.31.1-64-bit.exe', "$LocalTempDir\$GitInstaller"); & "$LocalTempDir\$GitInstaller" /norestart /verysilent; 
    $Process2Monitor =  "Git-2.31.1-64-bit"; Do { $ProcessesFound = Get-Process | Where-Object {$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } 
    else 
    {
        Remove-Item "$LocalTempDir\$GitInstaller" -ErrorAction SilentlyContinue -Verbose
    } 
} Until (!$ProcessesFound)

} Else 
{
    Write-Host "This is the latest version that this updater supports, no action will be made" -ForegroundColor Green
}
}