# e.g. to run with command prompt
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\open_excel_email_distribution_and_send_outlook.ps1"

# Load Excel COM object
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$workbook = $excel.Workbooks.Open("C:\Path\To\Your\File.xlsx")
$sheet = $workbook.Sheets.Item(1)

# Get last row with data
$lastRow = $sheet.UsedRange.Rows.Count

# Loop through rows
for ($i = 1; $i -le $lastRow; $i++) {
    $fromEmail = $sheet.Cells.Item($i, 1).Text
    $attachmentPath = $sheet.Cells.Item($i, 2).Text
    $toEmail = $sheet.Cells.Item($i, 3).Text

    # Create Outlook email
    $outlook = New-Object -ComObject Outlook.Application
    $mail = $outlook.CreateItem(0)
    $mail.Subject = "Automated Email"
    $mail.Body = "abc"
    $mail.To = $toEmail
    $mail.SentOnBehalfOfName = $fromEmail

    # Add attachment if it exists
    if (Test-Path $attachmentPath) {
        $mail.Attachments.Add($attachmentPath)
    }

    # Send email
    $mail.Save()
    #$mail.Send()
}

# Clean up
$workbook.Close($false)
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
