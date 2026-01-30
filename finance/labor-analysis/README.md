# WIP/FG Labor Analysis Project

**Owner:** Max Frank  
**Stakeholders:** Jason Scher (Finance), Anant Gujrani (CPA), Elida Craven, Katreen Marie Samaniego  
**Cadence:** Monthly  
**GitHub:** https://github.com/maxysadm-GH/VHC/tree/main/finance/labor-analysis

---

## Purpose

Allocate labor costs to WIP and FG inventory for month-end valuation. This enables Finance to:
- Calculate inventory labor burden for balance sheet
- Apply $/unit rates to closing stock (WIP × $0.17, FG × $0.25)
- Maintain audit trail with formula-based traceability

---

## Quick Start

1. Export payroll from QBO/Gusto for the period
2. Export production data from ClickUp/SmartSheet
3. Run classification script (assigns departments to cost groups)
4. Update raw data tabs in workbook
5. Formulas auto-calculate all summary metrics
6. Share with Finance for JE preparation

---

## File Structure

```
finance/labor-analysis/
├── README.md                    # This file
├── docs/
│   ├── METHODOLOGY.md          # Classification logic & formulas
│   ├── DATA-SOURCES.md         # Where data comes from
│   └── MONTHLY-PROCESS.md      # Step-by-step monthly checklist
├── scripts/
│   ├── classify-payroll.py     # Adds J's 3-tier classification
│   └── generate-workbook.py    # Rebuilds Excel with formulas
└── templates/
    └── WIP_FG_Labor_Analysis_TEMPLATE.xlsx
```

---

## Key Metrics (FY 2025)

| Metric | Value |
|--------|-------|
| Total Payroll | $5,934,187 |
| OPERATIONS | $3,317,898 (55.9%) |
| SG&A | $2,021,248 (34.1%) |
| RETAIL | $595,041 (10.0%) |
| WIP Labor | $1,350,012 |
| FG Labor | $601,923 |
| WIP $/Unit | $0.1703 |
| FG $/Unit | $0.2537 |

---

## Classification Structure

### J's 3-Tier (P&L Alignment)
- **OPERATIONS:** Production lines, Assembly, Shipping, Warehouse, Maintenance, QC, Sanitation, R&D
- **SG&A:** Executive, Marketing, Ecommerce, Wholesale, HR, Finance, Design
- **RETAIL:** RT1 (Union Station), RT3 (O'Hare), RT5 (International), Retail HQ

### 4-Category (WIP/FG Costing)
- **Production:** Knobel, Enrobing, Kitchen, Buhler, Delta, PMI → WIP labor
- **Assembly:** Assembly dept → FG labor
- **Fulfillment:** Shipping, Warehouse, Receiving
- **Overhead:** All other operational overhead

---

## Formula Reference

All formulas use SUMIF/SUMIFS referencing raw data tabs:

| Purpose | Formula Pattern |
|---------|-----------------|
| Cost Group Total | `=SUMIF('11-Raw Pay'!$D$4:$D$END,"operations",'11-Raw Pay'!$G$4:$G$END)` |
| 4-Category Total | `=SUMIF('11-Raw Pay'!$C$4:$C$END,"Production",'11-Raw Pay'!$G$4:$G$END)` |
| WIP Units | `=SUMIF('10-Raw CU'!$D$4:$D$END,"WIP",'10-Raw CU'!$E$4:$E$END)` |
| Monthly by Group | `=SUMIFS(Earnings, Date, ">="&DATE(y,m,1), Date, "<"&DATE(y,m+1,1), CostGroup, "operations")` |
| Cost per Unit | `=LaborCost/Units` |

---

## Data Sources

| Source | Contains | Update Frequency |
|--------|----------|------------------|
| QBO/Gusto | Payroll by department | Bi-weekly |
| ClickUp | Production units by line | Daily |
| SmartSheet | Legacy production data (pre-June 2025) | Historical |
| Fishbowl | Inventory units (WO completion) | Real-time |

---

## Contact

Questions about methodology: Max Frank (max@vosgeschocolate.com)  
Questions about JE/valuation: Jason Scher, Anant Gujrani
