<#
.SYNOPSIS
New-WVDSessionHost.ps1 - Finish WVD VM configuration

.DESCRIPTION 
Performs the final prepartion for WVD VMs, after this script the new VMS can be used in a WVD Host Pool.
Information required for adding to wvd is the RegistrationToken

.OUTPUTS
Results are output to screen

.PARAMETER ProfilePath
Specify if the script will show the script output on screen

.PARAMETER RegistrationToken
Specify CustomerName, used for default naming convention and naming


.EXAMPLE
.\New-WVDSessionHost.ps1 -ProfilePath [FS Logix Profile Path] `
    -RegistrationToken [WVD registration token] 
Complete WVD VM configuration, install WVD Agent, WVD Bootloader, and FS Logix + FS Logix Keys


.LINK
n/a

.NOTES
Written by: Erik van der Plas

Find me on:

* LinkedIn:	https://www.linkedin.com/in/erikvdplas/
* Github:	https://github.com/evdp88


License:

The Sogeti License

Copyright (c) 2020 Erik van der Plas

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Change Log
V1.0, 09/15/2019 - Initial version by Dean Cefola
v1.1, 09/16/2019 - Add FSLogix installer
                   Add FSLogix Reg Keys
                   Add Input Parameters
                   Add TLS 1.2 settings
v1.2, 09/17/2019 - Change download locations to dynamic
                   Add code to disable IESEC for admins
v1.3, 10/01/2019 - Add all FSLogix Profile Container Reg entries for easier management
v1.4, 04/10/2020 - Changed FSLogix download URI
v1.5, 08/18/2020 - Start script changes by Sogeti/Erik van der Plas
                   Add WVD agent resources
v1.6, 08/20/2020 - Remove remained FSLogix components and add a Test-Path for log file
                   Add $LocalWVDpath\ before WVD bootloader and agent sources
v1.7, 09/08/2020 - Add FS Logix agent installation
v1.8, 09/16/2020 - Removed and changed some FS Logix registry key values
                   Removed complete FSLogix Office Profile Settings
v1.9, 09/17/2020 - Install FS Logix agent only if required
                   End script with removing temp\wvd folder

#>

##############################
#    WVD Script Parameters   #
##############################
Param (        
    [Parameter(Mandatory=$true)]
        [string]$ProfilePath,
    [Parameter(Mandatory=$true)]
        [string]$RegistrationToken
)


######################
#    WVD Variables   #
######################
$LocalWVDpath            = "c:\temp\wvd\"
$WVDBootURI              = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH'
$WVDAgentURI             = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv'
$FSLogixURI              = 'https://aka.ms/fslogix_download'
$FSInstaller             = 'FSLogixAppsSetup.zip'
$WVDAgentInstaller       = 'WVD-Agent.msi'
$WVDBootInstaller        = 'WVD-Bootloader.msi'


####################################
#    Test/Create Temp Directory    #
####################################
if((Test-Path c:\temp) -eq $false) {
    Add-Content -LiteralPath C:\New-WVDSessionHost.log "Create C:\temp Directory"
    Write-Host `
        -ForegroundColor Cyan `
        -BackgroundColor Black `
        "creating temp directory"
    New-Item -Path c:\temp -ItemType Directory
}
else {
    Add-Content -LiteralPath C:\New-WVDSessionHost.log "C:\temp Already Exists"
    Write-Host `
        -ForegroundColor Yellow `
        -BackgroundColor Black `
        "temp directory already exists"
}
if((Test-Path $LocalWVDpath) -eq $false) {
    Add-Content -LiteralPath C:\New-WVDSessionHost.log "Create C:\temp\WVD Directory"
    Write-Host `
        -ForegroundColor Cyan `
        -BackgroundColor Black `
        "creating c:\temp\wvd directory"
    New-Item -Path $LocalWVDpath -ItemType Directory
}
else {
    Add-Content -LiteralPath C:\New-WVDSessionHost.log "C:\temp\WVD Already Exists"
    Write-Host `
        -ForegroundColor Yellow `
        -BackgroundColor Black `
        "c:\temp\wvd directory already exists"
}
if((Test-Path c:\New-WVDSessionHost.log) -eq $false) {
    New-Item -Path c:\ -Name New-WVDSessionHost.log -ItemType File
    }
Add-Content `
-LiteralPath C:\New-WVDSessionHost.log `
"
ProfilePath       = $ProfilePath
RegistrationToken = $RegistrationToken
Optimize          = $Optimize
"


#################################
#    Download WVD Componants    #
#################################
Add-Content -LiteralPath C:\New-WVDSessionHost.log "Downloading WVD Agent"
    Invoke-WebRequest -Uri $WVDAgentURI -OutFile "$LocalWVDpath$WVDAgentInstaller"
Add-Content -LiteralPath C:\New-WVDSessionHost.log "Downloading WVD Boot Loader"
    Invoke-WebRequest -Uri $WVDBootURI -OutFile "$LocalWVDpath$WVDBootInstaller"
Add-Content -LiteralPath C:\New-WVDSessionHost.log "Downloading FSLogix"
    Invoke-WebRequest -Uri $FSLogixURI -OutFile "$LocalWVDpath$FSInstaller"


##############################
# Prep for FS Logix Install  #
##############################
Add-Content -LiteralPath C:\New-WVDSessionHost.log "Unzip FSLogix"
Expand-Archive `
    -LiteralPath "C:\temp\wvd\$FSInstaller" `
    -DestinationPath "$LocalWVDpath\FSLogix" `
    -Force `
    -Verbose
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
cd $LocalWVDpath 
Add-Content -LiteralPath C:\New-WVDSessionHost.log "UnZip FXLogix Complete"


################################
#    Install WVD Componants    #
################################
Add-Content -LiteralPath C:\New-WVDSessionHost.log "Installing WVD Bootloader"
$bootloader_deploy_status = Start-Process `
    -FilePath "msiexec.exe" `
    -ArgumentList "/i $LocalWVDpath\$WVDBootInstaller", `
        "/quiet", `
        "/qn", `
        "/norestart", `
        "/passive", `
        "/l* $LocalWVDpath\AgentBootLoaderInstall.txt" `
    -Wait `
    -Passthru
$sts = $bootloader_deploy_status.ExitCode
Add-Content -LiteralPath C:\New-WVDSessionHost.log "Installing WVD Bootloader Complete"
Write-Output "Installing RDAgentBootLoader on VM Complete. Exit code=$sts`n"
Wait-Event -Timeout 5
Add-Content -LiteralPath C:\New-WVDSessionHost.log "Installing WVD Agent"
Write-Output "Installing RD Infra Agent on VM $AgentInstaller`n"
$agent_deploy_status = Start-Process `
    -FilePath "msiexec.exe" `
    -ArgumentList "/i $LocalWVDpath\$WVDAgentInstaller", `
        "/quiet", `
        "/qn", `
        "/norestart", `
        "/passive", `
        "REGISTRATIONTOKEN=$RegistrationToken", "/l* $LocalWVDpath\AgentInstall.txt" `
    -Wait `
    -Passthru
Add-Content -LiteralPath C:\New-WVDSessionHost.log "WVD Agent Install Complete"
Wait-Event -Timeout 5


#########################
#    FSLogix Install    #
#########################
Add-Content -LiteralPath C:\New-WVDSessionHost.log "Installing FSLogix"
If (!(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where { $_.DisplayName -eq "Microsoft FSLogix Apps" }))
    {
    $fslogix_deploy_status = Start-Process `
        -FilePath "$LocalWVDpath\FSLogix\x64\Release\FSLogixAppsSetup.exe" `
        -ArgumentList "/install /quiet" `
        -Wait `
        -Passthru
    Add-Content -LiteralPath C:\New-WVDSessionHost.log "FS Logix Install Complete"
    }
Else {
    Add-Content -LiteralPath C:\New-WVDSessionHost.log "WVD Agent was already installed"
    }


#######################################
#    FSLogix User Profile Settings    #
#######################################
Push-Location 
Set-Location HKLM:\SOFTWARE\
New-Item `
    -Path HKLM:\SOFTWARE\FSLogix `
    -Name Profiles `
    -Value "" `
    -Force
New-Item `
    -Path HKLM:\Software\FSLogix\Profiles\ `
    -Name Apps `
    -Force
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "Enabled" `
    -Type "Dword" `
    -Value "1"
New-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "VHDLocations" `
    -Value $ProfilePath `
    -PropertyType MultiString `
    -Force
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "IsDynamic" `
    -Type "Dword" `
    -Value "1"
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "LockedRetryCount" `
    -Type "Dword" `
    -Value "24"
Set-ItemProperty `
    -Path HKLM:\Software\FSLogix\Profiles `
    -Name "LockedRetryInterval" `
    -Type "Dword" `
    -Value "5"
New-ItemProperty `
    -Path HKLM:\SOFTWARE\FSLogix\Profiles `
    -Name "RebootOnUserLogoff" `
    -PropertyType "DWord" `
    -Value 0
New-ItemProperty `
    -Path HKLM:\SOFTWARE\FSLogix\Profiles `
    -Name "ShutdownOnUserLogoff" `
    -PropertyType "DWord" `
    -Value 0
Pop-Location


############################
#    Clean temp folder     #
############################
Add-Content -LiteralPath C:\New-WVDSessionHost.log "Clean temp folder"
cd C:\
Remove-Item -Path $LocalWVDpath -Recurse
Add-Content -LiteralPath C:\New-WVDSessionHost.log "Clean temp folder Complete"


#############
#    END    #
#############
Restart-Computer -Force
