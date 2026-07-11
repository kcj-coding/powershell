# run as administrator

# command prompt to run
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\scheduled_task_user.ps1"

Write-Host "Time to complete: $($timer.Elapsed.TotalSeconds) seconds"


# list scheduled tasks that run under a system like account
try {
    Get-ScheduledTask |
    ForEach-Object {
        $task = $_
        info = Get-ScheduledTaskInfo -TaskName $task.TaskName -TaskPath $task.TaskPath
        foreach ($action in $task.Actions) {
            [PSCustomObject]@{
                TaskName = $task.TaskName
                TaskPath = $task.TaskPath
                State = $task.State
                RunAsUser = $task.Principal.UserId
            }
        }
    } |
    Where-Object {
        $_.RunAsUser -match 'SYSTEM|NT AUTHORITY\\SYSTEM|LOCAL SERVICE\NETWORK SERVICE'
     |
     Sort-Object TaskPath, TaskName |
     Format-Table -AutoSize

$timer.stop
Write-Host "Time to complete: $($timer.Elapsed.TotalSeconds) seconds"
}
catch {
    Write-Error "Error retrieving scheduled tasks: $_"
}