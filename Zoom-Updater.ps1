If ((Test-Path "C:\Users\$Env:Username\AppData\Roaming\Zoom\bin\Zoom.exe") -Like 'False' -And (Test-Path "C:\Program Files (x86)\Zoom\bin\Zoom.exe") -Like 'False')
{
    Write-Host "Zoom is NOT Installed, Exiting...." -ForegroundColor Yellow
}
Else
{
    $InstalledZoomVersion = (Get-Item "C:\Users\$Env:Username\AppData\Roaming\Zoom\bin\Zoom.exe" -ErrorAction "Silent").VersionInfo.FileVersion
    $InstalledZoomVersionMSI = (Get-Item "C:\Program Files (x86)\Zoom\bin\Zoom.exe" -ErrorAction "Silent").VersionInfo.FileVersion
    Write-Host "Current Version Installed of Zoom is $InstalledZoomVersion $InstalledZoomVersionMSI" -ForegroundColor Yellow
If (($InstalledZoomVersion) -Or ($InstalledZoomVersionMSI) -lt "5,12,3,9638") 
{
    Write-Host "You are not running the latest version of Zoom, pushing latest update of Zoom Meetings" -ForegroundColor Yellow
    $LocalTempDir = $env:TEMP; 
    $ZoomInstaller = "ZoomInstallerFull.msi"; 
    (new-object System.Net.WebClient).DownloadFile('https://zoom.us/client/latest/ZoomInstallerFull.msi', "$LocalTempDir\$ZoomInstaller"); & "$LocalTempDir\$ZoomInstaller" /quiet; 
    $Process2Monitor =  "msiexec.exe"; Do { $ProcessesFound = Get-CimInstance Win32_Process -Filter "name = '$Process2Monitor'" | Where-Object CommandLine -CMatch ZoomInstallerFull.msi; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } 
    else 
    {
        Remove-Item "$LocalTempDir\$ZoomInstaller" -ErrorAction SilentlyContinue -Verbose
    } 
} Until (!$ProcessesFound)

} Else 
{
    Write-Host "This is the latest version that this updater supports, no action will be made" -ForegroundColor Green
}
}