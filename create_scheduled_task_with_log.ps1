# execute via command prompt - run as administrator
# powershell -noprofile -executionpolicy bypass -File "C:\Users\kelvi\Desktop\PowerShell\create_scheduled_task_with_log.ps1"

# Define task parameters
$taskName = "MyScheduledTask"
$taskDescription = "Runs daily at 7am and logs task creation"
$actionScript = "powershell.exe"
$actionArgs = "-noprofile -executionpolicy bypass -File ""C:\Users\kelvin\Desktop\PowerShell\run_script_xyz_log.ps1""

$timer = [System.Diagnostics.Stopwatch]::StartNew()

# Create the action
$action = New-ScheduledTaskAction -Execute $actionScript -Argument $actionArgs

# Create the trigger for 7:00 AM daily
$trigger = New-ScheduledTaskTrigger -Daily -At 7am

# Register the scheduled task
Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Description $taskDescription -User "SYSTEM" -RunLevel Highest -Force

# Log task creation
Add-Content -Path "C:\ScheduledTaskLog.txt" -Value "Scheduled task '$taskName' created successfully at $(Get-Date)"

$timer.stop
Add-Content -Path "C:\ScheduledTaskLog.txt" -Value "Time to complete: $($timer.Elapsed.TotalSeconds) seconds"
