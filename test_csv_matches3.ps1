# command prompt to run
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\test_csv_matches2.ps1"

$column_1 = "username"

$column_2 = "Name"

# Path to your reference file
$referenceFile = "C:\Users\kelvi\Desktop\PowerShell\Output_Csv\file1.csv" # take column_1 argument

# Folder containing the other CSV files
$otherFilesFolder = "C:\Users\kelvi\Desktop\PowerShell\Input_Csv" # take column_2 argument

# Output file
$outputFile = "C:\Users\kelvi\Desktop\PowerShell\Output_Csv\JoinedOutput.csv" # user specified file name

# Extract reference filename
$referenceFileName = Split-Path $referenceFile -Leaf

# Import reference CSV
$ref = Import-Csv $referenceFile

# Collect results
$results = @()

# Loop through each CSV in the folder
Get-ChildItem -Path $otherFilesFolder -Filter *.csv | ForEach-Object {

    $other = Import-Csv $_.FullName
    $otherFileName = $_.Name

    foreach ($r in $ref) {

        $refUserLower = $r.$column_1.ToLower()

        # Find matching rows in the other file
        $matches = $other | Where-Object {
            $_.$column_2.ToLower() -eq $refUserLower
        }

        foreach ($m in $matches) {

            $row = [ordered]@{}
 # Add filenames 
$row["ReferenceFile"] = $referenceFileName 
$row["ComparedFile"] = $otherFileName 
# All columns from file1 
foreach ($col in $r.PSObject.Properties.Name) 
{ $row[$col] = $r.$col } 
# All columns from matching file, skipping duplicates 
foreach ($col in $m.PSObject.Properties.Name) 
{ if (-not $row.Contains($col)) 
{ $row[$col] = $m.$col
                }
            }

            # Add to results
            $results += New-Object PSObject -Property $row
        }
    }
}

# Export clean flattened CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation
