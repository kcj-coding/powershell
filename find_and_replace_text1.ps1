# command prompt to run
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\find_and_replace_text1.ps1"

# configuration
$inputFolder = "C:\Users\kelvi\Desktop\tst"
$inputText = "abc.txt"
$outputText = "output.txt"
$outputFolder = "C:\Users\kelvi\Desktop\tst\outputs"

$inputFile = Join-Path -Path $inputFolder -ChildPath $inputText
$outputFile = Join-Path -Path $outputFolder -ChildPath $outputText

$timer = [System.Diagnostics.Stopwatch]::StartNew()

$folderList = @($inputFolder, $outputFolder)

# create folder if not exist
foreach ($folder in $folderList) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    } else {
        Write-Host "$folder found" -ForegroundColor Green
    }
}

# remove any files in output folder that are .txt files
Get-ChildItem -Path $outputFolder -Filter "*.txt" -File | Remove-Item -Force

#remove txt file
#if (Test-Path $outputLog) {
#    Remove-Item $outputLog
#}

#Get-Content "original.txt" | ForEach-Object { $_ -replace "oldText", "newText" } | Set-Content "newFile.txt"


try {
    # validate txt file
    if (-not (Test-Path $inputFile)) {
        throw "Input file not found: $inputFile"
    }

    # read txt file
    $fileContent = Get-Content -Path $inputFile

    #$changed = ForEach($line in $fileContent) {
    $changed = $fileContent | ForEach-Object {
           $line = $_#.Groups[1].Value.Trim()
           $line = $line -replace 'abc', 'def'
           $line
         }

   # output
   $changed | Set-Content -Path $outputFile -Encoding UTF8

   Write-Host "Written values to: $outputFile"
   $timer.stop
   Write-Host "Time to complete: $($timer.Elapsed.TotalSeconds) seconds"
    

}
catch {
    Write-Error "Error: $_"
}

  