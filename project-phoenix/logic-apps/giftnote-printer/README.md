# GiftNote-Printer Logic App

## ⚠️ NOTE: This is the Gift Note PRINTER, NOT the Gift Note Cleanup App
This Logic App prints gift notes when triggered by a warehouse scanner. It does NOT clean up "Dispatch Date:" metadata pollution from gift messages.

## Purpose
Generates and prints gift note cards when warehouse staff scan an order's LPN (License Plate Number / Order Number). Triggered via HTTP webhook from handheld scanners.

## Trigger
- **Type:** HTTP Request (Webhook)
- **Schema:** `{ "lpn": "string", "stationId": "string" }`
- **Required:** `lpn` (order number)

## Logic Flow
1. Extract order number from scanner input (LPN)
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
- `{{SERVICEBUS_SAS}}` - Service Bus Shared Access Signature
- `{{SUPABASE_SERVICE_ROLE_KEY}}` - Supabase service role key (not anon)

## Hardware Integration
- **Scanner:** Sends HTTP POST with order number as LPN
- **Printer:** Receives HTML via Azure Service Bus relay
- **Format:** 4x6 thermal label stock

## Notes
- Uses Service Bus for reliable printer communication
- Logs to Supabase even if print fails (runAfter: Succeeded, Failed)
- Recipient name falls back to "Friend" if not available
- Gift message pulled from ShipStation giftMessage field
