# ShipStation & VHC Integration Skill

## Overview
This skill contains hard-won lessons learned from months of ShipStation API integration work for Vosges Haut-Chocolat (VHC). Use this to avoid re-learning painful API quirks and to maintain consistency across Logic Apps, Power Automate, and PowerShell scripts.

---

## CREDENTIALS REFERENCE

**All credentials stored in environment variables or Azure Key Vault. See local `.env` file or contact admin.**

### ShipStation Store IDs
| Store ID | Name | Use |
|----------|------|-----|
| 273669 | Shopify Store | **PROD - Primary VHC orders** |
| 219870 | Special BD | BD/Corporate orders |
| 2971165 | Manual Orders | Testing/manual entry |
| 2973455 | DEV Store | Development testing |

### Environment Variables Required
```
SHIPSTATION_API_KEY
SHIPSTATION_API_SECRET
SHIPSTATION_XPARTNER_KEY
SHOPIFY_ADMIN_TOKEN
SHOPIFY_STORE_URL
SUPABASE_URL
SUPABASE_ANON_KEY
WEATHER_API_KEY
```

---

## SHIPSTATION API - CRITICAL LESSONS LEARNED

### ⚠️ SORTING DOES NOT WORK AS EXPECTED

**BROKEN:** `sortBy=OrderDate&sortDir=DESC` - Returns orders in unpredictable order
**BROKEN:** `sortBy=CreateDate&sortDir=DESC` - Same issue
**BROKEN:** `sortBy=OrderNumber` - Not a valid sort field

**ONLY VALID:** `sortBy=ModifyDate` - The ONLY sortBy that actually works consistently

```
# DON'T USE:
/orders?sortBy=OrderDate&sortDir=DESC  ❌

# USE:
/orders?sortBy=ModifyDate&sortDir=DESC  ✅
```

### ⚠️ DATE FILTERS ON /orders ARE BROKEN

The `shipDateStart` and `shipDateEnd` parameters return ALL orders, not filtered results.

```
# BROKEN - Returns all orders, not just Dec 26:
/orders?orderStatus=shipped&shipDateStart=2025-12-26&shipDateEnd=2025-12-26  ❌

# SOLUTION - Use /shipments endpoint for shipped orders:
/shipments?shipDateStart=2025-12-26&shipDateEnd=2025-12-26  ✅
```

### ⚠️ PAGINATION RULES
- **Max pageSize:** 500 (hard limit)
- **Default pageSize:** 100
- **Always paginate:** Large order sets require looping through all pages
- **Response includes:** `{ "orders": [...], "total": N, "page": X, "pages": Y }`

### ⚠️ RATE LIMITING
| Scenario | Rate Limit |
|----------|------------|
| Without x-partner header | 40 RPM |
| With x-partner header | 100 RPM |

**Always include x-partner header** (stored in `SHIPSTATION_XPARTNER_KEY` env var)

---

## AZURE LOGIC APP PATTERNS

### Proper Pagination Loop Structure
```json
{
    "Page_Loop": {
        "type": "Until",
        "expression": "@greater(variables('currentPage'), variables('totalPages'))",
        "limit": { "count": 50, "timeout": "PT2H" },
        "actions": {
            "Get_Orders": {
                "uri": "https://ssapi.shipstation.com/orders?pageSize=500&page=@{variables('currentPage')}"
            },
            "Increment_Page": {
                "runAfter": { "For_each": ["Succeeded", "Failed", "Skipped"] }
            }
        }
    }
}
```

### ⚠️ CRITICAL: runAfter Must Include "Failed"
If `Increment_Page` only runs on "Succeeded", ANY order failure stops pagination forever:
```json
// WRONG - Flow gets stuck on page 1 forever if any order fails:
"runAfter": { "For_Each": ["Succeeded"] }  ❌

// CORRECT - Continues to next page even if some orders fail:
"runAfter": { "For_Each": ["Succeeded", "Failed", "Skipped"] }  ✅
```

---

## CUSTOM FIELDS MAPPING

| Field | Use | Format |
|-------|-----|--------|
| customField1 | Dispatch Date (from Shopify tags) | `MM-DD-YYYY` |
| customField2 | Box Code (from ShipperHQ) | `BOX \| 14x14x6 \| ICE - 140` |
| customField3 | Weather Check Result | `ICE-120 \| 10/27 53.6F` or `NO ICE \| CHI 72F` |

---

## COMMON PITFALLS & SOLUTIONS

### 1. Orders Not Found After Import
**Problem:** Orders exist in Shopify but search returns empty
**Cause:** Wrong storeId or searching before sync completes
**Solution:** Always include `storeId=273669` for Shopify orders

### 2. CF1 Empty Despite Mapping
**Problem:** Shopify tags mapped but CF1 stays empty
**Cause:** Mapping only applies to NEW orders, not existing
**Solution:** Build Logic App to backfill CF1 from Shopify tags

### 3. Logic App Stuck on Page 1
**Problem:** Loop processes same 500 orders repeatedly
**Cause:** `Increment_Page` only runs on "Succeeded"
**Solution:** Add "Failed" and "Skipped" to runAfter

### 4. Wrong Order Counts
**Problem:** /orders with date filter returns all orders
**Cause:** shipDateStart/End filters are broken on /orders
**Solution:** Use /shipments endpoint for shipped order counts

### 5. Rate Limiting (429 Errors)
**Problem:** Frequent 429 responses
**Cause:** Missing x-partner header (stuck at 40 RPM)
**Solution:** Add x-partner header for 100 RPM


### 6. Sort Not Working
**Problem:** Orders not in expected order
**Cause:** Only `sortBy=ModifyDate` actually works
**Solution:** Don't rely on sort; filter client-side if needed

---

## WEATHER CHECK ICE PACK LOGIC

| Condition | Ice Pack | CF3 Format |
|-----------|----------|------------|
| Chicago local (<80°F) | None | `NO ICE \| CHI 72F` |
| Route max >85°F | ICE-160 (4 packs) | `ICE-160 \| 12/28 87.2F` |
| Route max >75°F | ICE-140 (3 packs) | `ICE-140 \| 12/28 78.5F` |
| Route max >65°F | ICE-120 (2 packs) | `ICE-120 \| 12/28 68.1F` |
| Route max ≤65°F | None | `NO ICE \| 12/28 62.3F` |
| API failure | N/A | `WC-FAILED` |

### Distribution Hubs
- Chicago (CHI) - Primary
- Memphis (MEM)
- Miami (MIA)
- Fort Worth (DFW)
- Oakland (OAK)

---

## PACKING SLIP TEMPLATE

**Current Version:** v3.34

**Barcode Positioning:**
```css
padding-left: 170px;
padding-top: 1.15in;
padding-right: 20px;
```

---

## QUICK REFERENCE

### API Endpoints
| Endpoint | Use |
|----------|-----|
| GET /orders | Fetch orders (paginate!) |
| GET /shipments | Shipped orders with working date filters |
| POST /orders/createorder | Create OR update orders |
| GET /stores | List connected stores |

### Store ID Quick Reference
- **273669** = Shopify PROD (VHC orders)
- **219870** = Special BD

---

## THINGS THAT DON'T WORK (DON'T WASTE TIME)

1. ❌ `sortBy=OrderDate` - Doesn't sort properly
2. ❌ `sortBy=CreateDate` - Doesn't sort properly  
3. ❌ `sortBy=OrderNumber` - Invalid field
4. ❌ `/orders?shipDateStart=X` - Returns all orders
5. ❌ Updating shipped/cancelled orders - API rejects
6. ❌ pageSize > 500 - Hard limit

## THINGS THAT WORK

1. ✅ `sortBy=ModifyDate` - Only working sort
2. ✅ `/shipments?shipDateStart=X` - Accurate date filtering
3. ✅ `x-partner` header - 100 RPM vs 40 RPM
4. ✅ pageSize=500 - Max efficiency
5. ✅ POST /orders/createorder - Works for updates too
6. ✅ `storeId=273669` filter - Shopify orders only

---

*Last Updated: December 2025*
*Source: Compiled from months of VHC integration work*
