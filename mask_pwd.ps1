# from https://stackoverflow.com/questions/42098521/enter-password-with-masking

# command prompt to run
# powershell -noprofile -executionpolicy bypass -file "C:\Users\kelvi\Desktop\PowerShell\mask_pwd.ps1"

$password = Read-Host "Enter Your Password" -AsSecureString

$Newpass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# write output to txt file

$deleteLog = "C:\pwd.txt"

# if output file exists remove it
if (Test-Path $deletelog) {
    Remove-Item $deleteLog
}

New-Item -Path $deleteLog -ItemType File
$logMessage = "Log entry created on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Content -Path $deleteLog -Value $logMessage
Add-Content -Path $deleteLog -Value $Newpass