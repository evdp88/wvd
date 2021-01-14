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
# 01/14/2021                     1.2        Changed version support W10 2009 (20H2)

#*********************************************************************************
#
#>


################################
#    Download WVD Optimizer    #
################################
New-Item -Path C:\ -Name Optimize -ItemType Directory -ErrorAction SilentlyContinue
$LocalPath = "C:\Optimize\"
$WVDOptimizeURL = 'https://github.com/evdp88/wvd/archive/opt_dev.zip'
$WVDOptimizeInstaller = "WVD-optimize-tool_011421.zip"
Invoke-WebRequest `
    -Uri $WVDOptimizeURL `
    -OutFile "$Localpath$WVDOptimizeInstaller"


###############################
#    Prep for WVD Optimize    #
###############################
Expand-Archive `
    -LiteralPath "$LocalPath\WVD-optimize-tool_011421.zip" `
    -DestinationPath "$LocalPath" `
    -Force `
    -Verbose
Set-Location -Path $LocalPath\wvd-opt_dev


#################################
#    Run WVD Optimize Script    #
#################################
New-Item -Path $LocalPath -Name install.log -ItemType File -Force
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -Verbose
add-content $LocalPath\install.log "Starting Optimizations"  
.\Win10_VirtualDesktop_Optimize.ps1 -Restart -Verbose
