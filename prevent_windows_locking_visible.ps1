# command prompt
# powershell -noprofile -ExecutionPolicy Bypass -file "C:\Users\kelvi\Desktop\PowerShell\prevent_windows_locking_visible.ps1"

# keep windows awake by opening and closing start menu

# load .net
Add-Type -AssemblyName System.Windows.Forms

# interval in minutes between actions
$intervalMins = 1

#Write-Host "Start menu activity script running use Ctrl+C to stop"
echo "Start menu activity script running use Ctrl+C to stop"

try {
    while ($true) {
        # open start menu (Ctrl+Esc)
        [System.Windows.Forms.SendKeys]::sendWait("^{ESC}")
        Start-Sleep -Milliseconds 500 # wait half a second

        # close start menu (Esc)
        [System.Windows.Forms.SendKeys]::sendWait("{ESC}")

        # wait before repeating
        Start-Sleep -Seconds($intervalMins * 60)

    }
}
catch {
    Write-Host "Script stopped: $($_.Exception.Message)"
}
