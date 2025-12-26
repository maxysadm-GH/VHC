# Environment Setup for VHC Development
# Run this once to set up your environment variables

Write-Host "VHC Environment Setup" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

# Prompt for credentials
$ssKey = Read-Host "Enter ShipStation API Key"
$ssSecret = Read-Host "Enter ShipStation API Secret"
$shqKey = Read-Host "Enter ShipperHQ API Key (or press Enter to skip)"
$teamsUrl = Read-Host "Enter Teams Webhook URL (or press Enter to skip)"

# Set user environment variables
[System.Environment]::SetEnvironmentVariable("SHIPSTATION_API_KEY", $ssKey, "User")
[System.Environment]::SetEnvironmentVariable("SHIPSTATION_API_SECRET", $ssSecret, "User")

if ($shqKey) {
    [System.Environment]::SetEnvironmentVariable("SHIPPERHQ_API_KEY", $shqKey, "User")
}

if ($teamsUrl) {
    [System.Environment]::SetEnvironmentVariable("TEAMS_WEBHOOK_URL", $teamsUrl, "User")
}

Write-Host ""
Write-Host "✅ Environment variables set!" -ForegroundColor Green
Write-Host ""
Write-Host "Restart your terminal or run:" -ForegroundColor Yellow
Write-Host '  $env:SHIPSTATION_API_KEY = [System.Environment]::GetEnvironmentVariable("SHIPSTATION_API_KEY","User")' -ForegroundColor Gray
Write-Host ""
