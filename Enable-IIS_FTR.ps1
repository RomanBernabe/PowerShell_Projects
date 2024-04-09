# Test if the script is run as Admin. If not, it launches a new child process as Admin. 

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::
    GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  

{ 
  # The '&' operator tells PowerShell to run a script.
  # The $MyInvocation automatic variable contains the file path to this script.  
  $arguments = "& '" +$MyInvocation.MyCommand.Definition + "'"

  # The below command result is something like 'powershell & c:\users\xxx\script'
  Start-Process powershell -Verb runAs -ArgumentList $arguments
   
  Break
}


# Get system32 folder
$env:SystemDirectory = [Environment]::SystemDirectory

# Complete the path to Appcmd, a manager for IIS via console
$IIS_Manager = "$env:SystemDirectory" + "\inetsrv\Appcmd.exe"

# Pass to the manager the "configure trace" parameters. They create and enable the Failure Request Tracing
"$IIS_Manager configure trace /enable /path:* /statuscodes:502" | Invoke-Expression

"$IIS_Manager configure trace 'Default Web Site' /enablesite" | Invoke-Expression