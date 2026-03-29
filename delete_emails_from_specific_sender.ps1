# e.g. to run with command prompt
# powershell -noprofile -ExecutionPolicy Bypass -file "C:\Users\kelvi\Desktop\PowerShell\delete_emails_from_specific_sender.ps1"

# configure variables
$logFolder = "C:\Users\kelvi\Desktop"
$logFile = "emails_deleted.txt"
$logFilePath = Join-Path -Path $logFolder -ChildPath $logFile

# specify emails
$sender1 = "email1@email.com"
$sender2 = "email2@email.com"



#### clear console and begin ###
clear-host
echo "Deleting any found emails"

################################

$deleteLog = $logFilePath

# if output file exists remove it
if (Test-Path $deletelog) {
    Remove-Item $deleteLog
}

New-Item -Path $deleteLog -ItemType File
$logMessage = "Log entry created on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Content -Path $deleteLog -Value $logMessage

try {
    # create outlook com object
    $Outlook = New-Object -ComObject Outlook.Application
    $Namespace = $Outlook.GetNamespace("MAPI")

    # get the default deleted items folder
    $DeletedItems = $Namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderDeletedItems)

    $Items = $DeletedItems.Items
    $Count = $Items.Count
    Write-Host "Found $Count items in Deleted Items."

    # loop backwards to avoid index shifting when deleting
    for ($i = $count; $i -ge 1; $i--) {
        $Mail = $Items.Item($i)
        if ($Mail -and $Mail.Class -eq 43) { # 43 = MailItem
            if ($Mail.SenderEmailAddress -eq $sender1 -or $Mail.SenderEmailAddress -eq $sender2) {
                Add-Content -Path $deletelog -Value "INFO: Deleted e-mail $($Mail.Subject)"
                #write-host "Deleting: $($Mail.Subject)"
                $Mail.Delete()
            }
        }
    }

    Write-Host "Deletion complete."
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}