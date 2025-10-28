<#
Smart-NetworkSwitch.ps1
Automatically switches between Ethernet and Wi-Fi
Now modified to disable adapters even when they are disconnected
#>

# --- Force Administrator Elevation ---
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator access..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Write-Host "Running with administrator privileges." -ForegroundColor Green

# --- Adapter Names (change if your system uses custom names) ---
$ethernet = "Ethernet"
$wifi = "Wi-Fi"

# --- Fetch adapter objects ---
$ethAdapter = Get-NetAdapter -Name $ethernet -ErrorAction SilentlyContinue
$wifiAdapter = Get-NetAdapter -Name $wifi -ErrorAction SilentlyContinue

if (-not $ethAdapter -and -not $wifiAdapter) {
    Write-Host "❌ Neither Ethernet nor Wi-Fi adapters found. Exiting..." -ForegroundColor Red
    exit
}

# --- Status check ---
$ethStatus = if ($ethAdapter) { $ethAdapter.Status } else { "NotFound" }
$wifiStatus = if ($wifiAdapter) { $wifiAdapter.Status } else { "NotFound" }

Write-Host "`nEthernet Status : $ethStatus"
Write-Host "Wi-Fi Status     : $wifiStatus`n"

# --- Decision Logic ---
if ($ethAdapter -and ($ethStatus -eq "Up" -or $ethStatus -eq "Disconnected")) {
    Write-Host "🔁 Ethernet detected (active or disconnected). Switching to Wi-Fi..." -ForegroundColor Yellow
    Disable-NetAdapter -Name $ethernet -Confirm:$false
    Start-Sleep -Seconds 3

    if ($wifiAdapter) {
        Write-Host "Enabling Wi-Fi adapter..." -ForegroundColor Cyan
        Enable-NetAdapter -Name $wifi -Confirm:$false
        Start-Sleep -Seconds 3
        Write-Host "✅ Switched to Wi-Fi successfully." -ForegroundColor Green
    } else {
        Write-Host "⚠️ Wi-Fi adapter not found!" -ForegroundColor Red
    }

} elseif ($wifiAdapter -and ($wifiStatus -eq "Up" -or $wifiStatus -eq "Disconnected")) {
    Write-Host "🔁 Wi-Fi detected (active or disconnected). Switching to Ethernet..." -ForegroundColor Yellow
    Disable-NetAdapter -Name $wifi -Confirm:$false
    Start-Sleep -Seconds 3

    if ($ethAdapter) {
        Write-Host "Enabling Ethernet adapter..." -ForegroundColor Cyan
        Enable-NetAdapter -Name $ethernet -Confirm:$false
        Start-Sleep -Seconds 3
        Write-Host "✅ Switched to Ethernet successfully." -ForegroundColor Green
    } else {
        Write-Host "⚠️ Ethernet adapter not found!" -ForegroundColor Red
    }

} else {
    Write-Host "⚠️ Both adapters appear disabled or not found. Enabling Ethernet by default..." -ForegroundColor Yellow
    if ($ethAdapter) {
        Enable-NetAdapter -Name $ethernet -Confirm:$false
        Start-Sleep -Seconds 3
        Write-Host "✅ Ethernet enabled." -ForegroundColor Green
    } else {
        Write-Host "⚠️ Ethernet adapter not found!" -ForegroundColor Red
    }
}

Write-Host "

[ Developed by YOGESH BANKAR — Smart Network Switch operation completed. ]" -ForegroundColor Cyan
Pause
