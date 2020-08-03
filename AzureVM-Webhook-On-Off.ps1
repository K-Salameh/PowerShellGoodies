### Script to Control Virtual Machines on Azure using Webhooks "Requires Azure Automation Account and "Start Azure V2 VMs / Stop Azure V2 VMs Gallery Scripts", also, the validation of VM Status uses a public port for the VM, it doesn't use Azure APIs or Azure Shell###
### Written By Khaled Salameh - https://github.com/K-Salameh/PowerShellGoodies ###

Clear-Host

### Define Variables
$StartURL = 'URL GOES HERE' #WebHook URL to Start the VM
$StopURL = 'URL GOES HERE' #WebHook URL to Stop the VM
$VMDNSName = 'VM FULL DNS NAME GOES HERE' #Destination Host to Test for online status
$VMName = 'DISPLAY NAME FOR THE VM, NOT USED IN CODE PROCESSING' #Virtual Machine Name
$Port = 'PORT NUMBER GOES HERE' #Port to Test
$YourName = 'YOUR NAME GOES HERE' #Displayed under the ASCII Art and Not Processed by Code

### Initial Load

Write-Host '
  ___                       _____           _ 
 / _ \                     |_   _|         | |
/ /_\ \_____   _ _ __ ___    | | ___   ___ | |
|  _  |_  / | | | '__/ _ \   | |/ _ \ / _ \| |
| | | |/ /| |_| | | |  __/   | | (_) | (_) | |
\_| |_/___|\__,_|_|  \___|   \_/\___/ \___/|_|
                                              
' -ForegroundColor Green #ASCII ART, Generate yours from "http://patorjk.com/software/taag"
Write-Host "Virtual Machine Webhook Trigger Tool - By $YourName" -ForegroundColor 'Yellow'
Write-Host ''
Write-Host "This tool will check if the $VMName is up or not and based on that ask you to turn it ON or OFF" -ForegroundColor Yellow
Write-Host ''

### Processing Animation the fliping column --> |/-\| <-- Animation

function ProcessingAnimation($scriptBlock) {
    $cursorTop = [Console]::CursorTop
    
    try {
        [Console]::CursorVisible = $false
        
        $counter = 0
        $frames = '|', '/', '-', '\' 
        $jobName = Start-Job -ScriptBlock $scriptBlock
    
        while($jobName.JobStateInfo.State -eq "Running") {
            $frame = $frames[$counter % $frames.Length]
            
            Write-Host "$frame" -NoNewLine
            [Console]::SetCursorPosition(0, $cursorTop)
            
            $counter += 1
            Start-Sleep -Milliseconds 125
        }
        Write-Host ($frames[0] -replace '[^\s+]', ' ') -NoNewline
    }
    finally {
        [Console]::SetCursorPosition(0, $cursorTop)
        [Console]::CursorVisible = $true
    }
}

## ProcessingAnimation { Start-Sleep 5 } <-- Add this line whenever you want a loading animation, adjust the number for the time period in seconds


### Menu Configuration
function Show-Menu
{
     param (
           [string]$Title = 'Virtual Machine Power Control'
     )
     Write-Host "================ $Title ================"
    
     Write-Host "1: Press '1' to Start The $VMName"
     Write-Host "2: Press '2' to Shutdown the $VMName"
     Write-Host "3: Press '3' to Check $VMName Up Status"
     Write-Host "Q: Press 'Q' to Exit"
     Write-Host '========================================'
}

### Do Menu Actions Based on Option
do
{
     Show-Menu
     $input = Read-Host 'Please make a selection'
     switch ($input)
     {
             '1' {
                ### Startup Script
                ### Check if VM is up or not
                Write-Host ''
                Write-Host "You have chosen to START the $VMName, Checking $VMName Availability Status..." -ForegroundColor Yellow
                ProcessingAnimation { Start-Sleep 2 }
                Write-Host 'Checking... This may take a moment'
                $ProgressPreference = "SilentlyContinue"
                $status = (Test-NetConnection $VMDNSName -Port $Port -WarningAction SilentlyContinue).TcpTestSucceeded
                    if ($status -eq "$True") {
                Write-Host ''
                Write-Host "$VMName is:" -ForegroundColor Yellow -NoNewLine ; Write-Host ' ||| ONLINE |||' -ForegroundColor Green
                Write-Host ''
                $ProgressPreference = "Continue"
                    } else {
                ### Start VM 
                Write-Host "$VMName is" -NoNewLine; Write-Host  ' ||| Offline ||| ' -ForegroundColor Red -NoNewLine; Write-Host 'Sending Startup Signal....' -ForegroundColor Yellow
                Start-Sleep 1
                $ProgressPreference = "SilentlyContinue"
                try { $Response = Invoke-WebRequest -Method POST $StartURL -UseBasicParsing} catch {}
                $ProgressPreference = "Continue"
                ## Wait 30 Seconds after Startup Signal
                For ($i=30; $i -gt 1; $i--) {  
                    Write-Progress -Activity "Waiting 30 Seconds for $VMName to return online status..." -SecondsRemaining $i -PercentComplete (3.3*$i)
                    ProcessingAnimation { Start-Sleep 1 }
                        }
                Write-Host "Checking if $VMName is now Online... This may take a moment"
                while ( (Test-NetConnection $VMDNSName -Port $Port -WarningAction SilentlyContinue).TcpTestSucceeded -ne "$True") {
                For ($i=30; $i -gt 1; $i--) {  
                Write-Progress -Activity "Waiting 30 Seconds for $VMName to return online status..." -SecondsRemaining $i -PercentComplete (3.3*$i)
                ProcessingAnimation { Start-Sleep 1 }
                    }
                 }
                Write-Host ''
                Write-Host ''
                ProcessingAnimation { Start-Sleep 2 }
                Write-Host "$VMName is now" -NoNewLine; Write-Host ' ||| Online ||| ' -ForegroundColor Green
                Write-Host ''
                    }         
           } '2' {
                ### Shutdown Script
                ### Check if VM is up or not
                Write-Host ''
                Write-Host ''
                Write-Host "You have chosen to STOP the $VMName, Checking $VMName Uptime Status" -ForegroundColor Yellow
                ProcessingAnimation { Start-Sleep 2 }
                $ProgressPreference = "SilentlyContinue"
                $status = (Test-NetConnection $VMDNSName -Port $Port -WarningAction SilentlyContinue).TcpTestSucceeded
                    if ($status -eq "$True") {
                Write-Host "$VMName is" -NoNewLine; Write-Host ' ||| Online ||| ' -ForegroundColor 'Green' -NoNewLine; Write-Host 'Sending Shutdown Signal...' -ForegroundColor Yellow
                ProcessingAnimation { Start-Sleep 2 }
                Write-Host ''
                $ProgressPreference = "SilentlyContinue"
                try { $Response = Invoke-WebRequest -Method POST $StopURL -UseBasicParsing} catch {}
                $ProgressPreference = "Continue"
                while ( (Test-NetConnection $VMDNSName -Port $Port -WarningAction SilentlyContinue).TcpTestSucceeded -eq "$True") {
                    For ($i=10; $i -gt 1; $i--) {  
                Write-Progress -Activity "Waiting 10 Seconds for $VMName to Turn Off..." -SecondsRemaining $i -PercentComplete (10*$i)
                ProcessingAnimation { Start-Sleep 1 }
                    }
                }
                Write-Host ''
                Write-Host "$VMName is now" -NoNewLine; Write-Host ' ||| OFFLINE ||| ' -ForegroundColor Red 
                ProcessingAnimation { Start-Sleep 1 }
                Write-Host ''
                    } else {
                Write-Host ''        
                Write-Host "$VMName is already" -NoNewLine; Write-Host ' ||| OFFLINE ||| ' -ForegroundColor Red
                Write-Host ''
                ProcessingAnimation { Start-Sleep 1 }
                 }
           } '3' {
                Write-Host "You have chosen to check the $VMName Status" -ForegroundColor Yellow
                $ProgressPreference = "SilentlyContinue"
                $status = (Test-NetConnection $VMDNSName -Port $Port -WarningAction SilentlyContinue).TcpTestSucceeded
                if ($status -eq "$True") {
                Write-Host ''
                Write-Host "$VMName is" -NoNewLine; Write-Host ' ||| ONLINE ||| ' -ForegroundColor Green
                Write-Host '' 
                $ProgressPreference = "Continue"
                }
                else {
                Write-Host '' 
                Write-Host "$VMName is" -NoNewLine; Write-Host ' ||| OFFLINE ||| ' -ForegroundColor Red
                Write-Host '' 
                    }
                }
                'q' {
                Write-Host = 'You have selected to exit the tool... Goodbye!' -ForegroundColor Yellow
                return
            }
        }
     
}
until ($input -eq 'q')
