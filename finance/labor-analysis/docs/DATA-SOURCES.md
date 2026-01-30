# Data Sources

## Required Inputs

### 1. Payroll Data

**Source:** QBO or Gusto payroll export  
**Format:** CSV or Excel  
**Frequency:** Bi-weekly (align with pay periods)

**Required Fields:**
| Field | Description |
|-------|-------------|
| Pay_Date | Date of payroll (not pay period end) |
| Department | Department name as listed in payroll system |
| Total_Earnings | Gross pay (before deductions) |

**Export Path:** QBO > Reports > Payroll > Payroll Register > Export

---

### 2. Production Data (KPI)

**Primary Source:** ClickUp (June 2025+)  
**Legacy Source:** SmartSheet (Jan-May 2025)

**Required Fields:**
| Field | Description |
|-------|-------------|
| Date | Production date |
| Part_Num | Product part number |
| Product_Type | WIP or FG (derived from Part_Num prefix) |
| KPI_Units | Units produced |
| Source | ClickUp or Smartsheet |

**Part Number Classification:**
- `16xx` → WIP (truffles, bars, caramels)
- `18xx` → FG (boxed products)
- `15xx` → Raw Materials (excluded)

---

### 3. Fishbowl Inventory (Reference)

**Source:** Fishbowl > Reports > Manufacture Order - Production Report  
**Purpose:** Validate KPI unit counts against system of record

**Note:** Fishbowl is source of truth for unit counts. KPI data historically over-reports by ~40% due to:
- Duplicate logging (shift handoffs)
- Multi-stage processing logged multiple times
- Rework/re-run counted again

---

## Output Structure

### Tab 10: Raw CU (KPI Data)
| Column | Field | Description |
|--------|-------|-------------|
| A | Date | Production date |
| B | Part_Num | Product part number |
| C | Part_Prefix | First 2 digits of Part_Num |
| D | Product_Type | WIP or FG |
| E | KPI_Units | Units produced |
| F | Source | Data source |

### Tab 11: Raw Pay (Payroll Data)
| Column | Field | Description |
|--------|-------|-------------|
| A | Pay_Date | Payroll date |
| B | Department | Department name |
| C | Orig_4Cat | 4-Category classification |
| D | J_CostGroup | J's 3-Tier classification |
| E | J_SubDept | Sub-department |
| F | J_OpsType | Direct or Ops Overhead |
| G | Total_Earnings | Gross earnings |

---

## Data Quality Notes

### Known Issues
1. **May-June 2025 gap:** SmartSheet→ClickUp transition caused low KPI numbers
2. **FG over-counting:** Multi-line products logged at each stage
3. **Department name variations:** Must normalize before mapping (e.g., "Enrob 1" vs "Enrobing #1")

### Validation Checks
- [ ] Payroll total matches source system
- [ ] No unmapped departments
- [ ] Date range covers full period
- [ ] Part numbers properly classified
