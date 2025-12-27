# GiftNote-Printer Logic App

## 🚧 PHASE 2 - Project Phoenix

This Logic App is part of **Phase 2** of Project Phoenix. It removes gift note collation from the picking/packing process and moves gift note printing to the END of the fulfillment flow.

### Phase 2 Vision
- **Current State:** Gift notes printed during collation, slowing down pickers
- **Future State:** Gift notes print AFTER shipping label, triggered by label webhook
- **Benefit:** Packers/shippers handle gift notes at final station, streamlining flow

## Purpose
Generates and prints gift note cards when triggered. Designed to be called via webhook when a shipping label is created, so gift notes print alongside labels at the packing/shipping station.

## Trigger
- **Type:** HTTP Request (Webhook)
- **Schema:** `{ "lpn": "string", "stationId": "string" }`
- **Required:** `lpn` (order number)
- **Future Integration:** Webhook from ShipStation label creation

## Logic Flow
1. Extract order number from webhook input (LPN)
2. Validate LPN is not empty
3. Fetch order from ShipStation API
4. Generate gift note HTML with:
   - Recipient name
   - Gift message
   - Styled 4x6 format for thermal printer
5. Send HTML to print server via Service Bus
6. Log print event to Supabase
7. Return success/failure response

## Gift Note HTML Template
```html
<!DOCTYPE html>
<html>
<head>
<style>
@page { size: 4in 6in; margin: 0.25in; }
body { width: 3.5in; font-family: Georgia, serif; font-size: 14px; }
.header { text-align: center; font-size: 20px; font-weight: bold; }
.message { font-size: 16px; line-height: 1.5; min-height: 2in; }
.footer { text-align: center; font-style: italic; }
</style>
</head>
<body>
<div class='header'>A Gift For You</div>
<div>Dear [Recipient Name],</div>
<div class='message'>[Gift Message]</div>
<div class='footer'>With warm wishes</div>
</body>
</html>
```

## API Endpoints Used
| Service | Endpoint | Purpose |
|---------|----------|---------|
| ShipStation | GET /orders?orderNumber=X | Fetch order details |
| Service Bus | POST /printserver | Send to printer |
| Supabase | POST /rest/v1/gift_notes | Log print event |

## Response Format
**Success (200):**
```json
{
  "success": true,
  "so": "VHC123456",
  "message": "Gift note printed successfully",
  "giftMessage": "Happy Birthday!"
}
```

**Error (400):**
```json
{
  "error": "Missing 'lpn' in request body"
}
```

## Supabase Logging
Table: `gift_notes`
| Field | Value |
|-------|-------|
| so | Order number |
| message | Gift message text |
| message_hash | Dedup hash |
| status | "printed" |
| printed_at | UTC timestamp |
| pdf_path | null (HTML direct print) |

## Credentials Required
- `{{SHIPSTATION_AUTH}}` - Base64 encoded API key:secret
- `{{SERVICEBUS_PRINTSERVER_URL}}` - Service Bus endpoint
- `{{SERVICEBUS_SAS}}` - Service Bus Shared Access Signature
- `{{SUPABASE_URL}}` - Supabase project URL
- `{{SUPABASE_SERVICE_ROLE_KEY}}` - Supabase service role key

## Hardware Integration
- **Trigger:** ShipStation label creation webhook (Phase 2)
- **Printer:** Thermal printer via Azure Service Bus relay
- **Format:** 4x6 thermal label stock
- **Location:** Packing/shipping station

## Phase 2 Implementation TODO
- [ ] Configure ShipStation webhook for label creation
- [ ] Map webhook payload to LPN format
- [ ] Test printer relay at shipping station
- [ ] Remove gift note from collation process
- [ ] Train packers on new workflow

## Related Apps
- **shipstation-shipby** - Populates giftMessage field from customerNotes
