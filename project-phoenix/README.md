# Project Phoenix

Order fulfillment automation system for Vosges Haut-Chocolat. Handles weather-sensitive chocolate shipping with automated ice pack determination, box sizing, and dispatch date management.

---

## Phase 1 - Live ✅

### Logic Apps
| App | Purpose | Schedule |
|-----|---------|----------|
| [shipstation-shipby](logic-apps/shipstation-shipby/) | CF1 → shipByDate + Gift Message | Every 30 min |
| [shipstation-weather-check](logic-apps/shipstation-weather-check/) | Ice pack determination → CF3 | Hourly |
| [shipperhq-box](logic-apps/shipperhq-box/) | Box dimensions → CF2 | Hourly |

### Order Flow
```
Shopify Order Import
    ↓
[shipstation-shipby] 
    → CF1 dispatch date → shipByDate
    → customerNotes → giftMessage
    ↓
[shipstation-weather-check]
    → Weather API for route temps
    → CF3: "ICE-140 | 12/28 72F"
    ↓
[shipperhq-box]
    → ShipperHQ Insights for dimensions
    → CF2: "BOX | 14x14x6 | ICE - 140"
    ↓
Ready for Fishbowl Fulfillment
```

---

## Phase 2 - Planned 🚧

See [PHASE2-ROADMAP.md](PHASE2-ROADMAP.md) for details.

| Feature | Purpose | Priority |
|---------|---------|----------|
| **Stale Shipment Alerts** | Teams alerts for labels not moving | P1 |
| **FedEx TIT Integration** | Accurate transit times for weather check | P2 |
| **Gift Note End-of-Flow** | Print gift notes at shipping station | P3 |

---

## Custom Fields Mapping

| Field | Content | Format |
|-------|---------|--------|
| CF1 | Dispatch Date | `MM-DD-YYYY` |
| CF2 | Box Code | `BOX \| 14x14x6 \| ICE - 140` |
| CF3 | Weather Check | `ICE-140 \| 12/28 72F` |

---

## Store IDs
- **273669** - Shopify Store (PROD)
- **219870** - Special BD

---

## Documentation
- [SHIPSTATION-SKILL.md](../docs/SHIPSTATION-SKILL.md) - API quirks, credentials, patterns
- [PHASE2-ROADMAP.md](PHASE2-ROADMAP.md) - Future enhancements

---

*Vosges Haut-Chocolat | Operations & Fulfillment*
