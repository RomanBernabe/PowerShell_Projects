# This script gets mailbox and group counts per type

#Define functions that count the mailboxes and groups by filtering them
function Count-Mailbox {

    #Get all mailboxes and save them in a variable
    $UnfilteredMailboxes = Get-Mailbox

    $FilteredMailboxes = [ordered]@{

        "Mailboxes" = $null
    
        <#Filter the mailbox type we want from the variable set at the beginning. Count the filtered with
        Measure-Object. Wrap it all around a parenthesis to feed the Count method to the hastable key.#>
        "User Mailboxes"             = 
        ($UnfilteredMailboxes |
        Where-Object {$_.RecipientTypeDetails -eq "UserMailbox"} | Measure-Object).Count;
        
        "Shared Mailboxes"           = 
        ($UnfilteredMailboxes |
        Where-Object {$_.RecipientTypeDetails -eq "SharedMailbox"} | Measure-Object).Count;
        
        "Room Mailboxes"             = 
        ($UnfilteredMailboxes |
        Where-Object {$_.RecipientTypeDetails -eq "RoomMailbox"} | Measure-Object).Count;
        
        "Equipment Mailboxes"        = 
        ($UnfilteredMailboxes |
        Where-Object {$_.RecipientTypeDetails -eq "EquipmentMailbox"} | Measure-Object).Count;
        
        "Discovery Mailboxes"        = 
        ($UnfilteredMailboxes |
        Where-Object {$_.RecipientTypeDetails -eq "DiscoveryMailbox"} | Measure-Object).Count;
    }

    #Create a Custom Object to display the info; use the created hashtables for the properties.
    New-Object -TypeName PSCustomObject -Property $FilteredMailboxes 

    #Display the total number of mailboxes
    Write-Host "Total Number of Mailboxes : $($UnfilteredMailboxes.Count)"
    Write-Host " " 

}

function Count-Groups{

    #Get all Distribution Groups and save them in a variable
    $UnfilteredDistributionGroups = Get-DistributionGroup
    $FilteredGroups = [ordered]@{
    
        "Groups" = $null
        
        #No need to filter from a variable if there's already an in-built command
        "O365 Groups"                =  (Get-UnifiedGroup).Count;
    
        <#Same process as with the mailboxes. Filter the groups using the previously set variable. 
        Count the filtered groups. Encase the process to be able to use the Count method, which will become
        the value of the corresponding hastable key#>
        "Distribution Lists"         =  
        ($UnfilteredDistributionGroups |
        Where-Object {$_.RecipientTypeDetails -eq "MailUniversalDistributionGroup"} |
        Measure-Object).Count;
        
        #No need to filter from a variable if there's already an in-built command
        "Dynamic Distribution Lists" =  (Get-DynamicDistributionGroup).Count;
    
        "Mail-Enabled Security Groups" =  
        ($UnfilteredDistributionGroups |
        Where-Object {$_.RecipientTypeDetails -eq "MailUniversalSecurityGroup"} |
        Measure-Object).Count        
        
    }

     #Create a Custom Object to display the info; use the created hashtables for the properties.
     New-Object -TypeName PSCustomObject -Property $FilteredGroups
     #Display the total number of groups by adding the hashtable's values with Measure-Object.
     Write-Host "Total Number of Groups       : $(($FilteredGroups.Values | 
     Measure-Object -Sum).Sum)" 

}

#Execute the script if there's a session; create one if not.  
if (!(Get-PSSession | 
    Where-Object {$_.Name -match 'ExchangeOnline' -and $_.Availability -eq 'Available'})) {
    
    Write-Host ""
    Write-Host "No Exchange session detected." -ForegroundColor 'Red' -BackgroundColor 'Black' -NoNewline
    Write-Host "Please connect to your tenant." -ForegroundColor 'Red' -BackgroundColor 'Black'
    Connect-ExchangeOnline
    
    #Check again if there's a session; if so, executes the script.
        if (Get-PSSession | 
        Where-Object {$_.Name -match 'ExchangeOnline' -and $_.Availability -eq 'Available'}) {

            #A pair of lines to inform the user what is this about.
            Write-Host " " # Blank line for formatting
            Write-Host "This script counts the total number of mailboxes and groups on your Exchange tenant."
            Write-Host " "

            Count-Mailbox
            Count-Groups       
            }
    } else {

    #A pair of lines to inform the user what is this about.
    Write-Host " " # Blank line for formatting
    Write-Host "This script counts the total number of mailboxes and groups on your Exchange tenant."
    Write-Host " "

    Count-Mailbox
    Count-Groups
}     

Read-Host -Prompt "Press Enter to exit"
