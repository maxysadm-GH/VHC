# Shipstation-ShipBy Logic App

## Purpose
**Two-in-one automation:**
1. **Ship By Date:** Maps CF1 dispatch date (MM-DD-YYYY) to ShipStation's native `shipByDate` field for Fishbowl fulfillment integration
2. **Gift Message:** Copies `customerNotes` (Note from Buyer) to `giftMessage` field when no gift message exists

## Trigger
- **Type:** Recurrence
- **Frequency:** Every 30 minutes

## Logic Flow
1. Fetch awaiting_shipment orders from Shopify store (273669)
2. Filter orders where:
   - Order number starts with "VHC"
   - CF1 has valid MM-DD-YYYY format (checks positions 2 and 5 for "-")
   - shipByDate is null or empty
3. Parse CF1 date and convert to ISO format (YYYY-MM-DDTHH:mm:ss)
4. Update order with:
   - `shipByDate` from CF1
   - `giftMessage` from existing giftMessage OR customerNotes (fallback)
5. Track processed vs skipped counts

## Key Features

### Ship By Date Mapping
```
CF1 Input:  12-28-2025 (MM-DD-YYYY)
shipByDate: 2025-12-28T00:00:00.0000000 (ISO)
```

### Gift Message Logic
```javascript
giftMessage = 
  if (giftMessage exists) → keep giftMessage
  else if (customerNotes exists) → copy customerNotes to giftMessage
  else → null
```

This ensures "Note from Buyer" content appears in the Gift Message field for packing slips.

## Key Configuration
| Setting | Value |
|---------|-------|
| Store ID | 273669 (Shopify) |
| Page Size | 500 |
| Sort | ModifyDate DESC |
| Delay Between Updates | 3 seconds |
| Concurrency | 1 (sequential) |

## Validation Checks
- `startsWith(orderNumber, 'VHC')` - Only Shopify orders
- `length(CF1) >= 10` - Has enough characters
- `substring(CF1, 2, 1) == '-'` - Position 2 is dash
- `substring(CF1, 5, 1) == '-'` - Position 5 is dash
- `shipByDate == null or ''` - Not already set

## Credentials Required
- `{{SHIPSTATION_AUTH}}` - Base64 encoded API key:secret

## Notes
- Does NOT use x-partner header (older implementation, 40 RPM)
- 3-second delay prevents rate limiting
- Gift message preservation: copies from giftMessage OR customerNotes
- Does NOT set `gift: true` flag (could be added in future)

## Related Apps
- **giftnote-printer** (Phase 2) - Prints gift notes at end of fulfillment flow
