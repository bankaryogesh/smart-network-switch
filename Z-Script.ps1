# Path to Desktop
$DesktopPath = [Environment]::GetFolderPath("Desktop")

# Define your target script
$ScriptName = "Smart-NetworkSwitch.ps1"
$ScriptPath = Join-Path $DesktopPath $ScriptName

# Define the shortcut path
$ShortcutName = "Smart-NetworkSwitch.lnk"
$ShortcutPath = Join-Path $DesktopPath $ShortcutName

# Check if script exists
if (-not (Test-Path $ScriptPath)) {
    Write-Host "❌ Smart-NetworkSwitch.ps1 not found on Desktop!" -ForegroundColor Red
    exit
}

# Create shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -NoLogo -File `"$ScriptPath`""
$Shortcut.WorkingDirectory = $DesktopPath
$Shortcut.IconLocation = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe,0"
$Shortcut.Save()

# --- Make the shortcut "Run as Administrator" ---
try {
    $bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)

    # Bitmask for "RunAs" flag is 0x20 at byte offset 0x15 in the .lnk header
    # So we set bit 6 of that byte to enable RunAs flag.
    $bytes[0x15] = $bytes[0x15] -bor 0x20

    [System.IO.File]::WriteAllBytes($ShortcutPath, $bytes)
    Write-Host "✅ Shortcut set to run as Administrator."
} catch {
    Write-Host "⚠️ Failed to set Run as Administrator: $($_.Exception.Message)" -ForegroundColor Yellow
}

# --- Hide the original Smart-NetworkSwitch.ps1 file ---
try {
    $file = Get-Item $ScriptPath
    $file.Attributes = $file.Attributes -bor [System.IO.FileAttributes]::Hidden
    Write-Host "✅ Smart-NetworkSwitch.ps1 has been hidden."
} catch {
    Write-Host "⚠️ Could not hide Smart-NetworkSwitch.ps1: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "✅ Shortcut created successfully at: $ShortcutPath"
Write-Host "`nYou can now double-click the shortcut to run Smart-NetworkSwitch as Administrator."
