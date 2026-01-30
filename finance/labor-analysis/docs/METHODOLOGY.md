# Labor Analysis Methodology

## Overview

This document explains how labor costs are classified and allocated to inventory.

---

## Dual Classification System

Every payroll record gets TWO classifications:

### 1. Original 4-Category (Column C: `Orig_4Cat`)
Used for WIP/FG labor costing:
- **Production** → Allocated to WIP inventory
- **Assembly** → Allocated to FG inventory  
- **Fulfillment** → Period expense (not inventoried)
- **Overhead** → Period expense (not inventoried)

### 2. J's 3-Tier Structure (Column D: `J_CostGroup`)
Used for P&L alignment and reporting:
- **operations** → Direct + Ops Overhead
- **sg&a** → Sales, General & Administrative
- **retail** → Retail store operations

---

## Department Mapping

### OPERATIONS (55.9% of payroll)

**Direct Labor ($1,562,295):**
| Department | 4-Category |
|------------|------------|
| ASSEMBLY | Assembly |
| Knobel | Production |
| Enrobing #1 | Production |
| Enrobing #2 | Production |
| Kitchen | Production |
| Buhler | Production |
| Delta | Production |
| PMI | Production |
| Ilapak | Production |
| Shipping | Fulfillment |
| Warehouse | Fulfillment |
| Receiving | Fulfillment |

**Ops Overhead ($1,755,603):**
| Department | 4-Category |
|------------|------------|
| Maintenance | Overhead |
| QC | Overhead |
| Sanitation | Overhead |
| R&D | Overhead |
| Inventory | Overhead |
| Freezer | Overhead |

### SG&A (34.1% of payroll)
| Department | 4-Category |
|------------|------------|
| Executive | Overhead |
| Marketing | Overhead |
| Ecommerce | Overhead |
| Wholesale | Overhead |
| Corporate Sales | Overhead |
| HR | Overhead |
| Finance | Overhead |
| Design | Overhead |

### RETAIL (10.0% of payroll)
| Department | 4-Category |
|------------|------------|
| RT1 (Union Station) | Overhead |
| RT3 (O'Hare) | Overhead |
| RT5 (International) | Overhead |
| Retail HQ | Overhead |
| Oak Pop-Up | Overhead |

---

## Labor Cost Allocation

### WIP (Work-in-Process)
- **Source:** Production department labor
- **Part Numbers:** 16xx prefix
- **Calculation:** Total Production Labor ÷ Total WIP Units = $/Unit

### FG (Finished Goods)
- **Source:** Assembly department labor
- **Part Numbers:** 18xx prefix
- **Calculation:** Total Assembly Labor ÷ Total FG Units = $/Unit

### Month-End Valuation
```
WIP Inventory Value = Closing WIP Units × WIP $/Unit
FG Inventory Value = Closing FG Units × FG $/Unit
```

---

## Formula Patterns

### SUMIF (Single Condition)
```excel
=SUMIF(criteria_range, criteria, sum_range)
```
Example:
```excel
=SUMIF('11-Raw Pay'!$D$4:$D$2827,"operations",'11-Raw Pay'!$G$4:$G$2827)
```

### SUMIFS (Multiple Conditions)
```excel
=SUMIFS(sum_range, criteria_range1, criteria1, criteria_range2, criteria2, ...)
```
Example (monthly by cost group):
```excel
=SUMIFS('11-Raw Pay'!$G$4:$G$2827,
        '11-Raw Pay'!$A$4:$A$2827,">="&DATE(2025,1,1),
        '11-Raw Pay'!$A$4:$A$2827,"<"&DATE(2025,2,1),
        '11-Raw Pay'!$D$4:$D$2827,"operations")
```

### Division with Protection
```excel
=IF(Units>0, LaborCost/Units, 0)
```

---

## Data Validation

Before each monthly run, verify:
1. Payroll total matches QBO/Gusto export
2. All departments have valid J_CostGroup mapping
3. Production units are classified as WIP or FG
4. Date ranges align with period being analyzed
