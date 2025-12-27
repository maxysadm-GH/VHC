# ShipperHQ-Box Logic App

## Purpose
Determines optimal box size for orders based on ShipperHQ Insights data and ice pack requirements. Updates CF2 with box dimensions that account for both product size and cold chain needs.

## Trigger
- **Type:** Recurrence
- **Frequency:** Every 1 hour
- **Concurrency:** 1 run at a time

## Logic Flow
1. Initialize pagination variables
2. Define SKU → Box mapping (20 products with ice variations)
3. Define Base Box → Ice-Adjusted Box mapping (10 base sizes)
4. Loop through all order pages (500 per page)
5. Filter: VHC orders with empty CF2
6. For each order:
   - Extract Shopify Order ID from orderKey
   - Extract ice level from CF3 (ICE-120, ICE-140, ICE-160, ICE-180, or NOICE)
   - Extract first SKU for SKU-based lookup
   - Query ShipperHQ Insights API for packageName
   - Determine final box using priority:
     1. SKU-specific mapping (if SKU in lookup table)
     2. ShipperHQ box + ice adjustment
     3. Fallback to CUSTOM or CUSTOM (ND)
   - Update CF2 with formatted box code

## CF2 Output Format
```
BOX | 14x14x6 | ICE - 140
BOX | 10x10x10
BOX | CUSTOM (ND)
```

## SKU-Based Box Mapping (20 Products)
| SKU | NOICE | ICE-120 | ICE-140 | ICE-160 | ICE-180 |
|-----|-------|---------|---------|---------|---------|
| TC-WILD-H25 | 14x14x4 | 14x14x4 | 14x14x4 | 14x14x6 | 14x14x6 |
| GS-TOW-WILD | 14x14x4 | 14x14x6 | 14x14x6 | 18x12x8 | 18x12x8 |
| GS-TOW-GRA | 10x8x6 | 10x10x10 | 10x10x10 | 18x10x8 | 18x10x8 |
| GS-TOW-COM | 8x8x6 | 10x8x6 | 10x10x10 | 18x10x8 | 18x10x8 |
| GS-TOW-PET | 8x8x6 | 8x8x6 | 10x8x6 | 14x14x4 | 14x14x6 |
| TC-EXO-032 | 14x10x3 | 14x14x4 | 14x14x4 | 14x14x6 | 14x14x6 |
| ... | ... | ... | ... | ... | ... |

## Base Box → Ice-Adjusted Mapping (10 Sizes)
| Base Box | NOICE | ICE-120 | ICE-140 | ICE-160 | ICE-180 |
|----------|-------|---------|---------|---------|---------|
| 9x6x3 | 9x6x3 | 8x8x6 | 10x8x6 | 14x14x4 | 10x10x10 |
| 8x8x6 | 8x8x6 | 10x8x6 | 10x8x6 | 14x14x4 | 10x10x10 |
| 14x10x3 | 14x10x3 | 12x12x4 | 14x14x4 | 10x10x10 | 14x14x6 |
| 10x8x6 | 10x8x6 | 12x12x4 | 12x12x4 | 14x14x4 | 10x10x10 |
| 12x12x4 | 12x12x4 | 14x14x4 | 10x10x10 | 14x14x6 | 14x14x6 |
| 10x10x10 | 10x10x10 | 14x14x6 | 14x14x6 | 18x10x8 | 18x10x8 |
| 14x14x4 | 14x14x4 | 14x14x6 | 18x10x8 | 18x10x8 | 18x12x8 |
| 14x14x6 | 14x14x6 | 18x10x8 | 18x10x8 | 18x12x8 | 18x12x8 |
| 12x12x12 | 12x12x12 | 14x14x6 | 18x10x8 | 18x10x8 | 18x10x8 |
| 16x16x6 | 16x16x6 | 16x16x6 | 16x16x6 | 18x18x6 | 18x18x8 |

## Key Configuration
| Setting | Value |
|---------|-------|
| Store ID | 273669 (Shopify) |
| Page Size | 500 |
| Sort | ModifyDate DESC |
| Max Pages | 20 |
| Delay Between Updates | 1 second |
| Concurrency | 1 (sequential) |

## ShipperHQ Insights Query
```graphql
{
  viewOrder(orderNumber: "SHOPIFY_ORDER_ID") {
    shipments {
      carriers {
        packages {
          packageDetail {
            packageName
          }
        }
      }
    }
  }
}
```

## Fallback Logic
1. If SKU in SKU_Mapping → Use SKU-specific box
2. Else if ShipperHQ returns valid box → Apply ice adjustment
3. Else if ShipperHQ returns "SHQ_CUSTOM" or "CUSTOM" → Use "CUSTOM"
4. Else if ShipperHQ returns "NO-DATA" → Use "CUSTOM (ND)"
5. Else → Use raw ShipperHQ value

## Credentials Required
- `{{SHIPSTATION_AUTH}}` - Base64 encoded API key:secret
- `{{SHIPSTATION_XPARTNER}}` - Partner key for 100 RPM
- `{{SHIPPERHQ_ACCESS_TOKEN}}` - ShipperHQ API token

## Dependencies
- **CF3 must be populated first** - Ice level comes from weather-check Logic App
- ShipperHQ Insights API must have order data (syncs from Shopify)

## Notes
- Uses x-partner header for 100 RPM rate limit
- Sequential processing (concurrency: 1) to avoid race conditions
- Only processes VHC orders with empty CF2
- Preserves all existing custom fields (CF1, CF3)
