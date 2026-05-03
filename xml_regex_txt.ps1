# command prompt to run
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\xml_regex_txt.ps1"

# configuration
$xmlFilePath = "C:\Windows\WinSxS\migration.xml"
$outputLog = "output.txt"
$outputLog1 = "output_raw.txt"
$outputFolder = "C:\Users\kelvi\Desktop\abc"

$outputLog = Join-Path -Path $outputFolder -ChildPath $outputLog

$outputLog1 = Join-Path -Path $outputFolder -ChildPath $outputLog1

# create output folder if not exist
if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# remove any files in output folder that are .txt files
Get-ChildItem -Path $outputFolder -Filter "*.txt" -File | Remove-Item -Force

#remove txt file
#if (Test-Path $outputLog) {
#    Remove-Item $outputLog
#}

try {
    # validate xml file
    if (-not (Test-Path $xmlFilePath)) {
        throw "Input xml not found: $xmlFilePath"
    }

    # read file content
    $xmlContent = Get-Content -Path $xmlFilePath -Raw # raw to read text

    # output txt file
    $xmlContent | Set-Content -Path $outputLog1 -Encoding UTF8 # encoding needed for set-content to keep spacing between letters

    # read txt file
    $xmlContent = Get-Content -Path $outputLog1

    # regex to match pattern
    $pattern = '<file>(.*?)</file>'

    # extract matches
    $matches = [regex]::Matches($xmlContent, $pattern, 'IgnoreCase') # also SingleLine

    # if condition
    if ($matches.Count -eq 0) {
        Write-Host "No <file> matches found in file."
    }
    else {
        $i = 0
        # process matches
        $cleaned = $matches | ForEach-Object {
            $i++
            $value = $_.Groups[1].Value.Trim()

            # remove specific occurences
            $value = $value -replace 'abc', ''

            # add blank line after each entry
            $value + "`r`n`r`n"

            # level of match
            $level_match = '(?<=/)\w\d(?=/){1}'
            $match = [regex]::Matches($value, $level_match, 'IgnoreCase') # also SingleLine

            # name match
            $sqlMatch = '(?<=/)(?!=/)(\w+\d+)[^-+]*.{1}'
            $match1 = [regex]::Matches($value, $sqlMatch, 'IgnoreCase') # also SingleLine
            $match1 = $match1 -replace '/', '_'

            # save to log file (individual matches o=in files)
            $logName = "$i sql $match $match1 file.txt"
            $logFilePath = Join-Path -Path $outputFolder -ChildPath $logName
            $value | Set-Content -Path $logFilePath -Encoding UTF8
        }

        # save all to one output file
        $cleaned | Set-Content -Path $outputLog -Encoding UTF8

        Write-Host "Extracted and cleaned $($matches.Count) <attribute> values to: $outputLog"
    }
# remove txt file
if (Test-Path $outputLog1) {
    Remove-Item $outputLog1
}
}
catch {
    Write-Error "Error: $_"
}

