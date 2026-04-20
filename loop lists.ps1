# command prompt to run
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\loop lists.ps1"

# list items
$fruits = @("apple","pear")
$types = @("fruit","vegetable")

# log directory
$logFolder = "C:\Users\kelvi\Desktop"
$logFile = "log_tasks_xxx.txt"
$logFilePath = Join-Path -Path $logFolder -ChildPath $logFile

# get date
$currentDateTime = Get-Date -Format "dd-MM-yyyy_HH:mm:ss" # "yyyy-MM-dd_HH:mm:ss"
$currentDate = Get-Date -Format "dd-MM-yyyy" # "yyyy-MM-dd"

# check if log file exists
    if (Test-Path -Path $logFilePath -PathType Leaf) { # leaf means file container means folder
    # read file content if file exists
    Remove-Item -Path $logFilePath
}

# add datetime to log file
Add-Content -Path $logFilePath -Value "$currentDateTime"

try {
for ($i = 0; $i -lt $fruits.Count; $i++) {
for ($j = 0; $j -lt $types.Count; $j++) {
    # Access the item at index $i
    $item = $fruits[$i]
    $type = $types[$j]
    Add-Content -Path $logFilePath -Value " "
    Add-Content -Path $logFilePath -Value " item number is: $i and item is $item which is a $type and type number is: $j"
}
}
}
catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor -Red
    }
