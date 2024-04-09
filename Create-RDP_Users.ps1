# Remember to run this as Admin


$login_name = '' # put the LOGIN name for the user here. Example: rbernabe
$fullname = ''  # put the FULL NAME of the user here.Example: roman bernabe


# Add the assembly necessary to use the GeneratePassword .NET method
Add-Type -AssemblyName 'System.Web'
# Mega password length policies
$length = 15
$nonAlphaChars = 4
$password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars) 

$password | Set-Clipboard

$singleLineText = @(
    "The account password has been copied to the clipboard."
    "It's below too if you want to copy it manually."
    "Remember to store it safely in the Saint file:"
) -join "`r`n" 

Write-Host $singleLineText -BackgroundColor Black -ForegroundColor Yellow
Write-Host -Object $password -BackgroundColor Black -ForegroundColor Yellow

$sec_password = ConvertTo-SecureString -String $password -AsPlainText -Force


$params = @{ Name = $login_name;
             FullName = $fullname;
             Password = $sec_password;
             PasswordNeverExpires = $true;
             UserMayNotChangePassword = $true;
             AccountNeverExpires = $true;
             Description = 'Account for PS member';

            }

$user = New-LocalUser @params

$groups = @("Administrators", "Remote Desktop Users")


ForEach ($group in $groups) {

     $user | Add-LocalGroupMember -Group $group 

}


