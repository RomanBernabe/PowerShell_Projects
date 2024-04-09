<# 
This script configures Windows Updates using local Administrative Templates, a feature of Group Policy (gpedit).
It automates the step 2.27 on the 'V5 onwards - What to do after a deployment' manual. 

It uses a PowerShell module, PolicyFileEditor, to modify these templates via Windows registry:
https://github.com/dlwyatt/PolicyFileEditor 

The values on where and what to modify in the registry are well documented:
https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsUpdate::AutoUpdateCfg

#>


# Test if the script is being run as admin. If not, it launches a new child process as admin. 
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::
    GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){ 
  
  $arguments = "& '" +$MyInvocation.MyCommand.Definition + "'"

  Start-Process powershell -Verb runAs -ArgumentList $arguments
   
  Break
}


#TODO: import module or download it

#Set-Location C:\Users\RBE\Downloads
#Import-Module .\policyfileeditor.3.0.0\PolicyFileEditor.psd1

Write-host "Trusting PS Gallery"
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

Write-Host "Installing PolicyFileEditor V3"
Install-Module -Name PolicyFileEditor -RequiredVersion 3.0.0 -Scope CurrentUser -Force

# Find the Machine level Administrative Template
$MachineDir = "$env:windir\system32\GroupPolicy\Machine\Registry.pol"


# Registry path where the Windows Update policies are located 
$RegPath = 'Software\Policies\Microsoft\Windows\WindowsUpdate'
# Declare server active hours to avoid installing updates on that time
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'SetActiveHours' -Data 1 -Type 'DWord'
# From 8:00AM
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'ActiveHoursStart' -Data '8' -Type 'DWord' 
# To 8:00PM
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'ActiveHoursEnd' -Data '20' -Type 'Dword'


# Registry path where the Automatic Updates (AU) policies are located 
$RegPath_AU = 'Software\Policies\Microsoft\Windows\WindowsUpdate\AU'

# Enable Automatic Updates
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath_AU -ValueName 'NoAutoUpdate' -Data '0' -Type 'Dword'
# Set Auto download and schedule for the installations
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath_AU -ValueName 'AUOptions' -Data '4' -Type 'Dword'
# On Sunday
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath_AU -ValueName 'ScheduledInstallDay' -Data '1' -Type 'Dword'
# At 7:00AM
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath_AU -ValueName 'ScheduledInstallTime' -Data '7' -Type 'Dword'
# Every Week
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath_AU -ValueName 'ScheduledInstallEveryWeek' -Data '1' -Type 'Dword'
# Install updates from other MS products
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath_AU -ValueName 'AllowMUUpdateService' -Data '1' -Type 'Dword'


# Allow AUs inmediate installation
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath_AU -ValueName 'AutoInstallMinorUpdates' -Data '1' -Type 'Dword'
# Allow recommended updates
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath_AU -ValueName 'IncludeRecommendedUpdates' -Data '1' -Type 'Dword'

# Distrust PSGallery again to leave everything as it was
Unregister-PSRepository -Name PSGallery


# Run a new PS session to uninstall the module, since the current session will lock the module, denying the # uninstall  
Start-Process PowerShell -ArgumentList "Uninstall-Module -Name PolicyFileEditor -Force"

Exit 0


