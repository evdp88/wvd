<#Author       : Thanks to Dean Cefola
# Creation Date: 08-06-2020
# Usage        : Windows Virtual Desktop Optimization Script
# All code that this script executes is created and provided by THE VDI GUYS
# You can download the code here  --  https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool
#********************************************************************************
# Date                         Version      Changes
#------------------------------------------------------------------------
# 07/09/2020                     1.0        Intial Version
# 08/06/2020                     1.1        Changed version

#*********************************************************************************
#
#>


################################
#    Download WVD Optimizer    #
################################
New-Item -Path C:\ -Name Optimize -ItemType Directory -ErrorAction SilentlyContinue
$LocalPath = "C:\Optimize\"
$WVDOptimizeURL = 'https://github.com/evdp88/wvd/archive/WVD-optimize-tool.zip'
$WVDOptimizeInstaller = "WVD-optimize-tool.zip"
Invoke-WebRequest `
    -Uri $WVDOptimizeURL `
    -OutFile "$Localpath$WVDOptimizeInstaller"


###############################
#    Prep for WVD Optimize    #
###############################
Expand-Archive `
    -LiteralPath "C:\Optimize\WVD-optimize-tool.zip" `
    -DestinationPath "$Localpath" `
    -Force `
    -Verbose
Set-Location -Path C:\Optimize\wvd-WVD-optimize-tool


#################################
#    Run WVD Optimize Script    #
#################################
New-Item -Path C:\Optimize\ -Name install.log -ItemType File -Force
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -Verbose
add-content c:\Optimize\install.log "Starting Optimizations"  
.\Win10_VirtualDesktop_Optimize.ps1 -WindowsVersion 2004 -Restart -Verbose
