# Builds a connection script to connect to the 'upload' Azule file share.
# To understand the query language, JMESPath, read:
# https://learn.microsoft.com/en-us/cli/azure/query-azure-cli?tabs=concepts%2Cbash


# Sets the console to hide warnings, which clutters the screen.
# https://learn.microsoft.com/en-us/cli/azure/azure-cli-configuration
az config set core.only_show_errors=true


# Invoke the browser for an interactive login. This is so no account keys are put here. 
# Azure uses this login session to automatically query keys if they aren't provided.
#az config set core.allow_broker=true #set to false if you want to disable
#az account clear
#az login


trigram="mee" # Put the customer's trigram here
echo "Starting to query the storage accounts for '${trigram}'..."

# Get customer's subscription display name
customerSubscription=$(
    az account subscription list \
    --query "[].{displayName:displayName} | [? contains(displayName,'${trigram^^}')]" --output tsv)

echo "A subscription with that trigram was found: '${customerSubscription}'."

#read -p "Is that the subscription you are looking for? [y/n] " answer
#if [[ "$answer" = "y" ]]  
#then 
    # Set the subscription as default for the script 
    az account set --subscription "$customerSubscription"

    echo "Select what storage account do you want to script from: "
    select sa in sa0 sa1
        do 
            echo "Selected account $sa"
            break
        done

    # Get customer's core resource group, where the storage accounts are located
    coreRG=$(
        az group list \
        --query "[].{Name:name} | [? contains(Name,'core')]" --output tsv)
    echo "The core RG is $coreRG"
    
    # In Mega, there's usually two storage accounts per customer: 'XXXsa0' and 'XXXsa1'.
    # SA0 usually holds the "upload" file share for Roman's customers; SA1 for anyone else. This is variable.
    storageAccount=$(
        az storage account list --resource-group "$coreRG" \
        --query "[].{Name:name} | [? contains(Name,'$sa')]" --output tsv) # using the 'contains' function
    
    echo "The source storage account is $storageAccount"
    

    # check if the "upload" share exists in SA
    doesUploadExist=$(az storage share exists --account-name "$storageAccount" \
                --name upload --output tsv)
    if "$doesUploadExist"
    then 
        echo "The upload file share in $storageAccount exists. Querying the account key... "
        storageAccountKey=$(az storage account keys list --account-name "$storageAccount" \
        --resource-group "$coreRG" --query "[?keyName=='key1'].{value:value}" --output tsv)

    echo "Building the mounting script for you, silly duck... "
    
    # To avoid making a mess of the 'script' string, it's better to separate strings and expand them later
    SAuser="localhost\\$storageAccount"
    SAurl="$storageAccount.file.core.windows.net"
    SAroot="\\\\$SAurl\upload"
    CMDcommand="cmdkey /add:$SAurl /user:$SAuser /pass:$storageAccountKey"
    

    # PowerShell script. Remember: '\' escapes the following character in Bash
    script="
    \$connectTestResult = Test-NetConnection -ComputerName $SAurl -Port 445
    if (\$connectTestResult.TcpTestSucceeded) {
    cmd.exe /C \"$CMDcommand\"

    New-PSDrive -Name Y -PSProvider FileSystem -Root "$SAroot" -Persist
    } else { Write-Error -Message \"lmao something is wrong with Azure\" }"

    # Output the script to clip.exe
    echo "$script" 
    echo "$script" | clip.exe
    echo "The script has been put on your clipboard, silly duck. Bye."

     
    else 
        echo "The upload file share DOESN'T exists in SA. Check if other storage accounts have it."
    fi
      
#else 
    #echo "Look for the correct trigram and try again, bozo."
#fi













