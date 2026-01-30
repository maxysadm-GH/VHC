# Monthly Labor Analysis Process

## Timeline

| Day | Task |
|-----|------|
| 1st of month | Export prior month payroll from QBO |
| 1st of month | Export prior month production from ClickUp |
| 2nd of month | Run classification script |
| 2nd of month | Update workbook raw data tabs |
| 3rd of month | Verify totals, share with Finance |
| 5th of month | Finance prepares JE for inventory valuation |

---

## Step-by-Step Process

### 1. Export Payroll Data

```
QBO > Reports > Employees > Payroll Register
- Date Range: First to last day of prior month
- Export as CSV
- Save to: Downloads\payroll-YYYY-MM.csv
```

**Verify:** Total matches expected payroll for period

---

### 2. Export Production Data

```
ClickUp > KPI Production Form > Export
- Date Range: First to last day of prior month
- Export as CSV
- Save to: Downloads\kpi-YYYY-MM.csv
```

**Verify:** Data includes all production lines

---

### 3. Run Classification Script

```powershell
cd C:\Users\maxys\Projects\vosges\VHC\finance\labor-analysis\scripts
python classify-payroll.py --input Downloads\payroll-YYYY-MM.csv --output payroll-classified.csv
```

**Output:** Payroll with J_CostGroup, J_SubDept, J_OpsType columns added

---

### 4. Update Workbook

1. Open `WIP_FG_Labor_Analysis_2025_v2_6_FORMULAS.xlsx`
2. Go to Tab 11 (Raw Pay)
3. Delete existing data rows (keep headers)
4. Paste classified payroll data
5. Go to Tab 10 (Raw CU)
6. Delete existing data rows (keep headers)
7. Paste production data
8. Verify formulas auto-calculate

---

### 5. Validate Results

**Tab 1 Checks:**
- [ ] OPERATIONS + SG&A + RETAIL = Total Payroll
- [ ] Direct + Ops Overhead = OPERATIONS
- [ ] Percentages sum to 100%

**Tab 2 Checks:**
- [ ] WIP Units > 0
- [ ] FG Units > 0
- [ ] $/Unit is reasonable ($0.15-$0.30 range)

**Tab 4 Checks:**
- [ ] Production + Assembly + Fulfillment + Overhead = Total
- [ ] All four categories have values

---

### 6. Share with Finance

**Email Template:**
```
To: Jason Scher, Anant Gujrani, Katreen Samaniego
Subject: [Month] Labor Analysis - Ready for Review

Attached is the labor analysis for [Month Year].

Summary:
- Total Payroll: $X,XXX,XXX
- WIP $/Unit: $X.XXXX
- FG $/Unit: $X.XXXX

Please review and let me know if you need any adjustments.
```

---

### 7. Finance JE (Anant's Process)

Anant uses the $/unit rates to value closing inventory:

```
WIP Inventory Value = Closing WIP Stock × WIP $/Unit
FG Inventory Value = Closing FG Stock × FG $/Unit
```

---

## Troubleshooting

### Formulas showing $0 or #REF
- Check that raw data tabs have data starting at row 4
- Verify column headers match expected names
- Ensure dates are Excel date format (not text)

### Department not mapped
- Add new department to `classify-payroll.py` mapping dictionary
- Re-run classification

### Payroll total mismatch
- Check for excluded pay types (bonuses, adjustments)
- Verify date range alignment with pay periods vs calendar month

---

## Archive

After Finance confirms JE is posted:
1. Save final workbook as `WIP_FG_Labor_Analysis_YYYY-MM_FINAL.xlsx`
2. Move to archive folder: `OneDrive > Accounting > Labor Analysis > Archive`
