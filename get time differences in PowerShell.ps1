# get time differences in PowerShell

# you can use date objects (not in string format)
$t1 = (get-date)
$t2 = (get-date)
$tdiff = $t2-$t1

$tdiff # details all time options
$mins = $tdiff.minutes
Write-Output "Time in minutes is: $mins"
echo "Time in minutes is: $mins"
Write-Output "Time in hours is:  $tdiff.hours" # does not work as function not variable
echo ("Time in hours is: " + $tdiff.Totalhours) # gives TotalHours


# or can use stopwatch
$timer = [System.Diagnostics.Stopwatch]::StartNew()

$timer.Stop()

#get timespan
"Time elapsed: "
$timer.Elapsed

# to stop closing automatically
Pause
# No Exit