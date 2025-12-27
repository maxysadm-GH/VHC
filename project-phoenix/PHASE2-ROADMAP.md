# Project Phoenix - Phase 2 Roadmap

## Overview
Phase 2 focuses on **proactive fulfillment control** - catching issues before customers complain and optimizing the end-of-line experience.

---

## 🎯 Phase 2 Features

### 1. FedEx API Integration - Time in Transit (TIT)
**Problem:** Weather check uses estimated transit days based on service type, not actual FedEx routing.

**Solution:** Query FedEx TIT API for accurate delivery dates based on:
- Origin ZIP (distribution hub)
- Destination ZIP
- Service type
- Ship date

**Benefits:**
- More accurate ice pack determination
- Accounts for FedEx service disruptions
- Handles holiday schedule adjustments
- Reduces over-icing (cost savings) and under-icing (melt risk)

**Integration Points:**
- `shipstation-weather-check` Logic App
- Replace hardcoded transit estimates with FedEx TIT response
- Cache TIT data to reduce API calls

**FedEx APIs Needed:**
| API | Purpose |
|-----|---------|
| Transit Times | Get delivery date for origin/dest/service |
| Service Availability | Validate service available for route |
| Track | Get actual movement data |

---

### 2. Stale Shipment Alerts - Teams Integration
**Problem:** Labels created but packages not moving = customer complaints days later.

**Solution:** Automated monitoring that alerts ops team when shipments go stale.

**Logic:**
```
IF label_created > X days ago
AND no FedEx scan events
AND order not delivered
THEN alert Teams channel
```

**Alert Thresholds:**
| Service Type | Alert After |
|--------------|-------------|
| Overnight | 1 day no movement |
| 2Day | 2 days no movement |
| Ground/Home | 3 days no movement |

**Teams Message Format:**
```
🚨 STALE SHIPMENT ALERT

Order: VHC123456
Label Created: Dec 26, 2025
Service: FedEx 2Day
Days Without Movement: 3

Ship To: John Smith, Chicago IL
Tracking: 794644790335

Action Required: Verify package was tendered to FedEx
```

**Benefits:**
- Proactive vs reactive customer service
- Catch carrier pickup failures
- Identify warehouse handoff issues
- Reduce "where's my package" calls

---

### 3. Gift Note Printer - End of Flow
**Problem:** Gift notes printed during collation slow down pickers.

**Solution:** Move gift note printing to shipping station, triggered by label creation.

**Trigger Options:**
| Option | Pros | Cons |
|--------|------|------|
| ShipStation Webhook | Native, reliable | May need custom endpoint |
| FedEx Label Event | Confirms label exists | Additional API integration |
| Polling | Simple | Delay, extra API calls |

**Flow:**
```
Shipping Label Created
    ↓
Webhook fires to giftnote-printer
    ↓
Gift note prints at shipping station
    ↓
Packer includes in box
```

**Hardware:**
- Thermal printer at shipping station
- Azure Service Bus relay for print queue
- 4x6 gift note stock

---

## 📊 Phase 2 Architecture

```
                    ┌─────────────────┐
                    │   FedEx API     │
                    │  (TIT + Track)  │
                    └────────┬────────┘
                             │
    ┌────────────────────────┼────────────────────────┐
    │                        │                        │
    ▼                        ▼                        ▼
┌─────────┐          ┌──────────────┐         ┌────────────┐
│ Weather │          │    Stale     │         │  GiftNote  │
│  Check  │          │   Monitor    │         │  Printer   │
│ (TIT)   │          │  (Alerts)    │         │ (Webhook)  │
└─────────┘          └──────┬───────┘         └────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │ Teams Channel │
                    │   #alerts    │
                    └──────────────┘
```

---

## 🔧 Implementation Priority

| Priority | Feature | Effort | Impact |
|----------|---------|--------|--------|
| **P1** | Stale Shipment Alerts | Medium | High - Proactive CS |
| **P2** | FedEx TIT Integration | High | Medium - Accuracy |
| **P3** | Gift Note End-of-Flow | Low | Medium - Efficiency |

---

## 📋 Technical Requirements

### FedEx API Credentials Needed
```
FEDEX_API_KEY=
FEDEX_SECRET_KEY=
FEDEX_ACCOUNT_NUMBER=
FEDEX_METER_NUMBER=
```

### Teams Webhook
```
TEAMS_WEBHOOK_URL=https://outlook.office.com/webhook/...
```

### New Logic Apps to Build
1. `fedex-tit-service` - Caches transit time lookups
2. `stale-shipment-monitor` - Hourly scan for stuck packages
3. Update `shipstation-weather-check` - Use TIT data
4. Update `giftnote-printer` - ShipStation webhook trigger

---

## 📅 Phase 2 Timeline (TBD)

| Milestone | Target | Status |
|-----------|--------|--------|
| FedEx API credentials | - | ⏳ Pending |
| TIT service prototype | - | ⏳ Not started |
| Stale monitor v1 | - | ⏳ Not started |
| Teams webhook setup | - | ⏳ Not started |
| Gift note webhook | - | ⏳ Not started |
| Production rollout | - | ⏳ Not started |

---

## 🔗 Related Phase 1 Apps
- `shipstation-shipby` - Ship By Date + Gift Message
- `shipstation-weather-check` - Ice pack determination (to be enhanced)
- `shipperhq-box` - Box dimensions
- `giftnote-printer` - Gift note printing (to be webhook-triggered)

---

*Last Updated: December 2025*
