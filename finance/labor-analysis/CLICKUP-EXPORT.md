# WIP/FG Labor Analysis - ClickUp Project Export

**GitHub:** https://github.com/maxysadm-GH/VHC/tree/main/finance/labor-analysis

---

## Project Overview

| Field | Value |
|-------|-------|
| **Project Name** | WIP/FG Labor Analysis |
| **Owner** | Max Frank |
| **Status** | Active |
| **Cadence** | Monthly |
| **Stakeholders** | Jason Scher, Anant Gujrani, Elida Craven, Katreen Samaniego |

---

## Objective

Allocate $5.9M annual labor cost to WIP and FG inventory for month-end balance sheet valuation. Provide formula-based audit trail for CPA review.

---

## Key Deliverables

| Deliverable | Description | Status |
|-------------|-------------|--------|
| Formula workbook | Excel with SUMIF/SUMIFS formulas referencing raw data | ✅ Complete |
| Classification script | Python script to add J's 3-tier structure to payroll | ✅ Complete |
| Monthly process doc | Step-by-step checklist for monthly updates | ✅ Complete |
| Methodology doc | Department mapping and formula logic | ✅ Complete |

---

## Monthly Tasks (Recurring)

### Week 1 of Each Month

- [ ] **Export payroll** - QBO > Payroll Register > Prior month
- [ ] **Export production** - ClickUp > KPI Form > Prior month
- [ ] **Run classification** - `python classify-payroll.py`
- [ ] **Update workbook** - Paste data to Tab 10 & 11
- [ ] **Validate totals** - Check formulas calculate correctly
- [ ] **Share with Finance** - Email to J, Anant, Katreen

### Finance Tasks (Anant)

- [ ] **Reconcile to QBO** - Tab 11 total vs QBO payroll
- [ ] **Calculate inventory value** - Closing stock × $/unit
- [ ] **Prepare JE** - Post labor to inventory accounts

---

## Formula Reference

### Cost Group Totals
```excel
OPERATIONS: =SUMIF('11-Raw Pay'!$D$4:$D$END,"operations",'11-Raw Pay'!$G$4:$G$END)
SG&A:       =SUMIF('11-Raw Pay'!$D$4:$D$END,"sg&a",'11-Raw Pay'!$G$4:$G$END)
RETAIL:     =SUMIF('11-Raw Pay'!$D$4:$D$END,"retail",'11-Raw Pay'!$G$4:$G$END)
```

### WIP/FG Labor
```excel
WIP Labor:  =SUMIF('11-Raw Pay'!$C$4:$C$END,"Production",'11-Raw Pay'!$G$4:$G$END)
FG Labor:   =SUMIF('11-Raw Pay'!$C$4:$C$END,"Assembly",'11-Raw Pay'!$G$4:$G$END)
```

### Unit Counts
```excel
WIP Units:  =SUMIF('10-Raw CU'!$D$4:$D$END,"WIP",'10-Raw CU'!$E$4:$E$END)
FG Units:   =SUMIF('10-Raw CU'!$D$4:$D$END,"FG",'10-Raw CU'!$E$4:$E$END)
```

### Cost Per Unit
```excel
WIP $/Unit: =WIP_Labor/WIP_Units
FG $/Unit:  =FG_Labor/FG_Units
```

---

## Classification Structure

### J's 3-Tier (Column D: J_CostGroup)
| Cost Group | % of Total | Includes |
|------------|------------|----------|
| **operations** | 55.9% | Production lines, Assembly, Shipping, Warehouse, Maintenance, QC, Sanitation, R&D |
| **sg&a** | 34.1% | Executive, Marketing, Ecommerce, Wholesale, HR, Finance, Design |
| **retail** | 10.0% | RT1, RT3, RT5, Retail HQ, Oak Pop-Up |

### 4-Category (Column C: Orig_4Cat)
| Category | Labor $ | Inventory Impact |
|----------|---------|------------------|
| **Production** | $1,350,012 | → WIP |
| **Assembly** | $601,923 | → FG |
| **Fulfillment** | $850,640 | Period expense |
| **Overhead** | $3,131,612 | Period expense |

### Operations Breakdown (Column F: J_OpsType)
| Type | Labor $ | % of Ops |
|------|---------|----------|
| **Direct** | $1,562,295 | 47.1% |
| **Ops Overhead** | $1,755,603 | 52.9% |

---

## FY 2025 Baseline Metrics

| Metric | Value |
|--------|-------|
| Total Payroll | $5,934,187 |
| WIP Labor | $1,350,012 |
| FG Labor | $601,923 |
| WIP Units | 7,929,037 |
| FG Units | 2,372,818 |
| **WIP $/Unit** | **$0.1703** |
| **FG $/Unit** | **$0.2537** |

---

## File Locations

| File | Location |
|------|----------|
| Current workbook | OneDrive > Accounting > 2025 > Inventory_labour_cost |
| GitHub repo | https://github.com/maxysadm-GH/VHC/tree/main/finance/labor-analysis |
| Classification script | `VHC/finance/labor-analysis/scripts/classify-payroll.py` |
| Methodology docs | `VHC/finance/labor-analysis/docs/` |

---

## Data Sources

| Source | Data | Frequency |
|--------|------|-----------|
| QBO/Gusto | Payroll by department | Bi-weekly |
| ClickUp | Production units (KPI form) | Daily |
| SmartSheet | Legacy production (pre-June 2025) | Historical |
| Fishbowl | Inventory validation | Real-time |

---

## Known Issues / Improvements

| Issue | Status | Notes |
|-------|--------|-------|
| May-June data gap | Documented | SmartSheet→ClickUp transition |
| KPI over-reporting (~40%) | Documented | Multi-stage logging, shift handoffs |
| Per-unit vs per-lb costing | Deferred | J approved per-unit for now |
| Tab 3 Data Quality formulas | TODO | Currently static values |

---

## Contacts

| Role | Name | Email |
|------|------|-------|
| IT / Data | Max Frank | max@vosgeschocolate.com |
| Finance Lead | Jason Scher | jason@vosgeschocolate.com |
| CPA | Anant Gujrani | anant.g@rudderservices.com |
| Controller | Elida Craven | ecraven@vosgeschocolate.com |
| Accounting | Katreen Samaniego | katreen.s@rudderservices.com |
