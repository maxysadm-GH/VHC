# Shipstation-Weather-Check Logic App

## Purpose
Determines ice pack requirements for temperature-sensitive chocolate shipments based on weather forecasts along the shipping route. Updates CF3 with ice pack recommendation.

## Trigger
- **Type:** Recurrence
- **Frequency:** Every 1 hour
- **Concurrency:** 1 run at a time

## Logic Flow
1. Initialize pagination variables (currentPage, totalPages)
2. Set cutoff time (24 hours ago for re-checking existing orders)
3. Fetch weather forecasts for all 5 distribution hubs
4. Loop through all order pages (500 per page)
5. Split orders into two groups:
   - **Empty CF3:** New orders needing weather check
   - **Has CF3:** Existing orders that may need refresh (>24h old)
6. For each order:
   - Determine destination ZIP and route
   - Get destination weather forecast
   - Calculate max temperature (hub vs destination)
   - Determine ice pack level
   - Update CF3 in ShipStation
   - Log to Supabase

## Distribution Hubs
| Hub | ZIP | Route Coverage |
|-----|-----|----------------|
| Chicago | 60618 | Default (MW, STD) |
| Memphis | 38118 | Southeast |
| Miami | 33142 | Florida (32x, 33x, 34x) |
| Fort Worth | 76177 | Southwest (7xx) |
| Oakland | 94621 | West Coast (9xx) |

## Route Determination
```javascript
if (ZIP3 starts with 32, 33, 34) → FL (Miami hub)
else if (ZIP1 == 9) → WC (Oakland hub)
else if (ZIP1 == 7) → SW (Fort Worth hub)
else if (ZIP1 == 5 or 6) → MW (Chicago hub)
else → STD (Chicago hub)
```

## Transit Time Estimation
| Service | Days |
|---------|------|
| Overnight | 1 |
| 2Day | 2 |
| Ground | 5 |
| Default | 3 |

## Ice Pack Thresholds
| Max Route Temp | Ice Pack | CF3 Format |
|----------------|----------|------------|
| < 65°F | None | `NO ICE \| MM/DD XXF` |
| 65-74°F | ICE-120 | `ICE-120 \| MM/DD XXF` |
| 75-84°F | ICE-140 | `ICE-140 \| MM/DD XXF` |
| 85-93°F | ICE-160 | `ICE-160 \| MM/DD XXF` |
| > 93°F | ICE-180 | `ICE-180 \| MM/DD XXF` |

## Key Configuration
| Setting | Value |
|---------|-------|
| Store ID | 273669 (Shopify) |
| Page Size | 500 |
| Sort | CreateDate DESC |
| Concurrency | 20 parallel order processing |
| Re-check Interval | 24 hours |
| Max Pages | 10 |

## Credentials Required
- `{{SHIPSTATION_AUTH}}` - Base64 encoded API key:secret
- `{{SHIPSTATION_XPARTNER}}` - Partner key for 100 RPM
- `{{WEATHER_API_KEY}}` - WeatherAPI.com key
- `{{SUPABASE_ANON_KEY}}` - Supabase anonymous key

## Supabase Integration
Logs each weather check to `orders` table:
- shipstation_order_id
- order_number
- route_max_temp
- ice_pack_type
- last_weather_check

## Notes
- Uses x-partner header for 100 RPM rate limit
- Pagination with runAfter: ["Succeeded", "Failed"] to prevent infinite loops
- Falls back to 50°F if weather API fails
- Re-checks orders with CF3 if last check was >24 hours ago
