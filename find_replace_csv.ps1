# command prompt
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\test.ps1"

# read in file
$logFolder = "C:\Users\kelvi\Desktop\" # to store logs and search for files
$logFile = "Book1.csv"
$outputFile = "Book2.csv"

$Path = Join-Path -Path $logFolder -ChildPath $logFile
$PathOut = Join-Path -Path $logFolder -ChildPath $outputFile

# remove output file if it exists
# if output file exists remove it
if (Test-Path $PathOut) {
    Remove-Item $PathOut
}

# get content
#$csv = Import-Csv -Path $Path

# read txt file
$readContent = Get-Content -Path $Path

# exract and write header row first
$headers = $readContent | Select-Object -First 1 #| Set-Content -Path $PathOut
Add-Content -Path $PathOut -Value $headers

# for each line -replace skipping the header row

$results = $readContent | Select-Object -Skip 1 | ForEach-Object { # for each line
$_ -replace ",", ',""'}

# remove specific occurences
#$value = $value -replace 'abc', ''
#
# write to csv
#Export-Csv -Path $Path

# write data to file
Add-Content -Path $PathOut -Value $results