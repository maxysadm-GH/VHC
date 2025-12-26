# ShipStation 72-Hour Forecast & Backlog Report
# Credentials: Set SHIPSTATION_API_KEY and SHIPSTATION_API_SECRET environment variables

$apiKey = $env:SHIPSTATION_API_KEY
$apiSecret = $env:SHIPSTATION_API_SECRET

if (-not $apiKey -or -not $apiSecret) {
    Write-Host "ERROR: Set SHIPSTATION_API_KEY and SHIPSTATION_API_SECRET environment variables" -ForegroundColor Red
    exit 1
}

$baseUrl = "https://ssapi.shipstation.com"

$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${apiKey}:${apiSecret}"))
$headers = @{
    "Authorization" = "Basic $auth"
    "Content-Type" = "application/json"
}

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  SHIPSTATION 72-HOUR FORECAST AND BACKLOG REPORT" -ForegroundColor Cyan
Write-Host "  Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$now = Get-Date
$todayStart = $now.Date
$next72Hours = $now.AddHours(72)

Write-Host "TODAY: $($todayStart.ToString('yyyy-MM-dd'))" -ForegroundColor Yellow
Write-Host "72-HR CUTOFF: $($next72Hours.ToString('yyyy-MM-dd HH:mm'))`n" -ForegroundColor Yellow
$allOrders = @()
$page = 1
$pageSize = 500

Write-Host "Fetching awaiting_shipment orders..." -ForegroundColor Gray
do {
    $url = "${baseUrl}/orders?orderStatus=awaiting_shipment&pageSize=${pageSize}&page=${page}"
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
    $allOrders += $response.orders
    Write-Host "  Page ${page}: $($response.orders.Count) orders" -ForegroundColor DarkGray
    $hasMore = $response.orders.Count -eq $pageSize
    $page++
    Start-Sleep -Milliseconds 200
} while ($hasMore)

Write-Host "`nTotal awaiting_shipment: $($allOrders.Count) orders`n" -ForegroundColor Green

$todayBacklog = @()
$next72HourOrders = @()
$beyondOrders = @()

foreach ($order in $allOrders) {
    $orderDate = [DateTime]$order.orderDate
    $shipByDate = if ($order.shipByDate) { [DateTime]$order.shipByDate } else { $null }
    
    if ($orderDate.Date -lt $todayStart -and -not $shipByDate) {
        $todayBacklog += $order
    }
    elseif ($shipByDate -and $shipByDate.Date -lt $todayStart) {
        $todayBacklog += $order
    }
    elseif (($shipByDate -and $shipByDate -le $next72Hours) -or ($orderDate -le $next72Hours -and -not $shipByDate)) {
        $next72HourOrders += $order
    }
    else {
        $beyondOrders += $order
    }
}

Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "  BACKLOG REPORT - Orders Not Processed from Today" -ForegroundColor Red
Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Red

if ($todayBacklog.Count -eq 0) {
    Write-Host "`n✅ NO BACKLOG - All caught up!`n" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  BACKLOG COUNT: $($todayBacklog.Count) orders`n" -ForegroundColor Red
    
    $backlogByService = $todayBacklog | Group-Object -Property requestedShippingService | 
        Select-Object Name, Count | Sort-Object Count -Descending
    
    Write-Host "Backlog by Service:" -ForegroundColor Yellow
    foreach ($service in $backlogByService) {
        Write-Host "  $($service.Name): $($service.Count)" -ForegroundColor White
    }
    
    Write-Host "`nOldest 5 Backlog Orders:" -ForegroundColor Yellow
    $todayBacklog | Sort-Object orderDate | Select-Object -First 5 | ForEach-Object {
        $age = ($now - [DateTime]$_.orderDate).Days
        Write-Host "  Order #$($_.orderNumber) - ${age} days old - $($_.requestedShippingService)" -ForegroundColor White
    }
    Write-Host ""
}

Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  72-HOUR FORECAST - Orders to Process" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Cyan

Write-Host "`nTotal Orders Next 72 Hours: $($next72HourOrders.Count)`n" -ForegroundColor Green

$serviceBreakdown = $next72HourOrders | Group-Object -Property requestedShippingService | 
    Select-Object Name, Count | Sort-Object Count -Descending

Write-Host "Breakdown by Service:" -ForegroundColor Yellow
foreach ($service in $serviceBreakdown) {
    $serviceName = if ($service.Name) { $service.Name } else { "(No Service Specified)" }
    Write-Host "  ${serviceName}: $($service.Count)" -ForegroundColor White
}

Write-Host "`nDaily Breakdown (next 72 hours):" -ForegroundColor Yellow
$dailyGroups = $next72HourOrders | Group-Object -Property { 
    if ($_.shipByDate) { 
        ([DateTime]$_.shipByDate).Date.ToString('yyyy-MM-dd')
    } else { 
        ([DateTime]$_.orderDate).Date.ToString('yyyy-MM-dd')
    }
} | Sort-Object Name

foreach ($day in $dailyGroups) {
    Write-Host "  $($day.Name): $($day.Count) orders" -ForegroundColor White
}

Write-Host "`nBeyond 72 Hours: $($beyondOrders.Count) orders" -ForegroundColor Gray

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Report Complete" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
