
<# This script creates Desktop shortcuts of the Office365 web apps. Why?
For a project, we had to downgrade the Office 365 licenses for 50 users, 
from E3 to E1. We still had to provide a way to easily access those resources. #>


# Find the Desktop and Downloads folders path of the computer, regardless of who is using it.
$desktop_path =  [Environment]::GetFolderPath("Desktop")
$downloads_folder = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path

#Declare the icons source as variables. The source is Microsoft, so it's trustable. 
$word_icon    =  'https://c1-word-view-15.cdn.office.net/wv/resources/1033/FavIcon_Word.ico'
$excel_icon   =  'https://c1-excel-15.cdn.office.net/x/_layouts/resources/FavIcon_Excel.ico'
$outlook_icon =  'https://outlook.office.com/mail/favicon.ico'


#To create and modify a Desktop shortcut, we need to create a specific Object.
$ShellW = New-Object -ComObject ("WScript.Shell")
<#Insert the shortcut path and name with the help of this object's method.
Save it all on a new variable to be able to modify its properties later.#>
$Word = $ShellW.CreateShortcut($desktop_path + '\Word.url')
<#Modify the target property of this shortcut to tell it where it's going to lead us
when we click on it#>
$Word.TargetPath = 'https://www.office.com/launch/word'
#Save the changes.
$Word.Save()

# Download the Word icon to the user's Downloads folder.
Start-BitsTransfer -Source $word_icon -Destination ($downloads_folder + '\word_icon.ico') 

# Add the icon as a property of the previously created shortcut
Add-Content -Value ('IconFile=' + $downloads_folder + '\word_icon.ico'),
'IconIndex=0' -Path $Word.FullName 
$Word.Save()


# Create an Excel shortcut. Same steps as with the Word one. 
$ShellE = New-Object -ComObject ("WScript.Shell")
$Excel = $ShellE.CreateShortcut($desktop_path + '\Excel.url')
$Excel.TargetPath = 'https://www.office.com/launch/excel'
$Excel.Save()

Start-BitsTransfer -Source $excel_icon -Destination ($downloads_folder + '\excel_icon.ico') 

Add-Content -Value ('IconFile=' + $downloads_folder + '\excel_icon.ico'),
'IconIndex=0' -Path $Excel.FullName 
$Excel.Save()

# Create an Outlook shortcut
$ShellO = New-Object -ComObject ("WScript.Shell")
$Outlook = $ShellO.CreateShortcut($desktop_path + '\Outlook.url')
$Outlook.TargetPath = 'https://outlook.office.com/mail'
$Outlook.Save()

Start-BitsTransfer -Source $outlook_icon -Destination ($downloads_folder + '\outlook_icon.ico') 

Add-Content -Value ('IconFile=' + $downloads_folder + '\outlook_icon.ico'),
'IconIndex=0' -Path $Outlook.FullName 
$Outlook.Save()
