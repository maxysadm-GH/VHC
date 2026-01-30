#!/usr/bin/env python3
"""
classify-payroll.py
Adds J's 3-tier classification to payroll data

Usage:
    python classify-payroll.py --input payroll.csv --output payroll-classified.csv
"""

import pandas as pd
import argparse
from datetime import datetime

# Department to Classification Mapping
DEPARTMENT_MAPPING = {
    # OPERATIONS - Direct
    'ASSEMBLY': {'CostGroup': 'operations', 'SubDept': 'assembly', 'OpsType': 'Direct', 'Orig4Cat': 'Assembly'},
    'Knobel': {'CostGroup': 'operations', 'SubDept': 'production', 'OpsType': 'Direct', 'Orig4Cat': 'Production'},
    'Enrobing #1': {'CostGroup': 'operations', 'SubDept': 'production', 'OpsType': 'Direct', 'Orig4Cat': 'Production'},
    'Enrobing #2': {'CostGroup': 'operations', 'SubDept': 'production', 'OpsType': 'Direct', 'Orig4Cat': 'Production'},
    'Kitchen': {'CostGroup': 'operations', 'SubDept': 'production', 'OpsType': 'Direct', 'Orig4Cat': 'Production'},
    'Buhler': {'CostGroup': 'operations', 'SubDept': 'production', 'OpsType': 'Direct', 'Orig4Cat': 'Production'},
    'Delta': {'CostGroup': 'operations', 'SubDept': 'production', 'OpsType': 'Direct', 'Orig4Cat': 'Production'},
    'PMI': {'CostGroup': 'operations', 'SubDept': 'production', 'OpsType': 'Direct', 'Orig4Cat': 'Production'},
    'Ilapak': {'CostGroup': 'operations', 'SubDept': 'production', 'OpsType': 'Direct', 'Orig4Cat': 'Production'},
    'Shipping': {'CostGroup': 'operations', 'SubDept': 'fulfillment', 'OpsType': 'Direct', 'Orig4Cat': 'Fulfillment'},
    'Warehouse': {'CostGroup': 'operations', 'SubDept': 'fulfillment', 'OpsType': 'Direct', 'Orig4Cat': 'Fulfillment'},
    'Receiving': {'CostGroup': 'operations', 'SubDept': 'fulfillment', 'OpsType': 'Direct', 'Orig4Cat': 'Fulfillment'},
    
    # OPERATIONS - Ops Overhead
    'Maintenance': {'CostGroup': 'operations', 'SubDept': 'maintenance', 'OpsType': 'Ops Overhead', 'Orig4Cat': 'Overhead'},
    'QC': {'CostGroup': 'operations', 'SubDept': 'qc', 'OpsType': 'Ops Overhead', 'Orig4Cat': 'Overhead'},
    'Quality Control': {'CostGroup': 'operations', 'SubDept': 'qc', 'OpsType': 'Ops Overhead', 'Orig4Cat': 'Overhead'},
    'Sanitation': {'CostGroup': 'operations', 'SubDept': 'sanitation', 'OpsType': 'Ops Overhead', 'Orig4Cat': 'Overhead'},
    'R&D': {'CostGroup': 'operations', 'SubDept': 'rd', 'OpsType': 'Ops Overhead', 'Orig4Cat': 'Overhead'},
    'Inventory': {'CostGroup': 'operations', 'SubDept': 'inventory', 'OpsType': 'Ops Overhead', 'Orig4Cat': 'Overhead'},
    'Freezer': {'CostGroup': 'operations', 'SubDept': 'freezer', 'OpsType': 'Ops Overhead', 'Orig4Cat': 'Overhead'},
    
    # SG&A
    'Executive': {'CostGroup': 'sg&a', 'SubDept': 'executive', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'Marketing': {'CostGroup': 'sg&a', 'SubDept': 'marketing', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'Ecommerce': {'CostGroup': 'sg&a', 'SubDept': 'ecommerce', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'Wholesale': {'CostGroup': 'sg&a', 'SubDept': 'wholesale', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'Corporate Sales': {'CostGroup': 'sg&a', 'SubDept': 'corporate_sales', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'HR': {'CostGroup': 'sg&a', 'SubDept': 'hr', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'Human Resources': {'CostGroup': 'sg&a', 'SubDept': 'hr', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'Finance': {'CostGroup': 'sg&a', 'SubDept': 'finance', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'Accounting': {'CostGroup': 'sg&a', 'SubDept': 'finance', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'Design': {'CostGroup': 'sg&a', 'SubDept': 'design', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    
    # RETAIL
    'RT1': {'CostGroup': 'retail', 'SubDept': 'rt1_union', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'RT3': {'CostGroup': 'retail', 'SubDept': 'rt3_ohare', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'RT5': {'CostGroup': 'retail', 'SubDept': 'rt5_intl', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'Retail': {'CostGroup': 'retail', 'SubDept': 'retail_hq', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'Retail HQ': {'CostGroup': 'retail', 'SubDept': 'retail_hq', 'OpsType': None, 'Orig4Cat': 'Overhead'},
    'Oak Pop-Up': {'CostGroup': 'retail', 'SubDept': 'oak_popup', 'OpsType': None, 'Orig4Cat': 'Overhead'},
}


def normalize_department(dept_name):
    """Normalize department name for matching"""
    if pd.isna(dept_name):
        return None
    
    name = str(dept_name).strip().upper()
    
    # Common variations
    variations = {
        'ENROB 1': 'Enrobing #1',
        'ENROB 2': 'Enrobing #2',
        'ENROBING 1': 'Enrobing #1',
        'ENROBING 2': 'Enrobing #2',
        'QUALITY CONTROL': 'QC',
        'HUMAN RESOURCES': 'HR',
        'R AND D': 'R&D',
        'RESEARCH AND DEVELOPMENT': 'R&D',
    }
    
    if name in variations:
        return variations[name]
    
    # Try exact match (case-insensitive)
    for key in DEPARTMENT_MAPPING:
        if name == key.upper():
            return key
    
    return dept_name


def classify_payroll(input_file, output_file):
    """Add classification columns to payroll data"""
    
    # Read input
    df = pd.read_csv(input_file)
    print(f"Loaded {len(df)} records from {input_file}")
    
    # Identify department column
    dept_col = None
    for col in ['Department', 'Dept', 'department', 'dept']:
        if col in df.columns:
            dept_col = col
            break
    
    if dept_col is None:
        raise ValueError("No department column found. Expected: Department or Dept")
    
    # Identify earnings column
    earnings_col = None
    for col in ['Total_Earnings', 'Total Earnings', 'Gross Pay', 'Amount', 'Earnings']:
        if col in df.columns:
            earnings_col = col
            break
    
    if earnings_col is None:
        raise ValueError("No earnings column found")
    
    # Normalize departments
    df['Department_Normalized'] = df[dept_col].apply(normalize_department)
    
    # Apply classification
    df['Orig_4Cat'] = df['Department_Normalized'].apply(
        lambda x: DEPARTMENT_MAPPING.get(x, {}).get('Orig4Cat', 'UNMAPPED')
    )
    df['J_CostGroup'] = df['Department_Normalized'].apply(
        lambda x: DEPARTMENT_MAPPING.get(x, {}).get('CostGroup', 'UNMAPPED')
    )
    df['J_SubDept'] = df['Department_Normalized'].apply(
        lambda x: DEPARTMENT_MAPPING.get(x, {}).get('SubDept', 'UNMAPPED')
    )
    df['J_OpsType'] = df['Department_Normalized'].apply(
        lambda x: DEPARTMENT_MAPPING.get(x, {}).get('OpsType')
    )
    
    # Check for unmapped
    unmapped = df[df['J_CostGroup'] == 'UNMAPPED'][dept_col].unique()
    if len(unmapped) > 0:
        print(f"\n⚠️  WARNING: {len(unmapped)} unmapped departments:")
        for dept in unmapped:
            print(f"   - {dept}")
        print("\nAdd these to DEPARTMENT_MAPPING in classify-payroll.py\n")
    
    # Summary
    print("\nClassification Summary:")
    print("-" * 40)
    by_cg = df.groupby('J_CostGroup')[earnings_col].sum()
    total = by_cg.sum()
    for cg, amt in by_cg.items():
        pct = (amt / total) * 100
        print(f"  {cg}: ${amt:,.0f} ({pct:.1f}%)")
    print(f"  TOTAL: ${total:,.0f}")
    
    # Output columns
    output_cols = ['Pay_Date', 'Department', 'Orig_4Cat', 'J_CostGroup', 'J_SubDept', 'J_OpsType', 'Total_Earnings']
    
    # Rename columns to standard names
    df_out = df.rename(columns={
        dept_col: 'Department',
        earnings_col: 'Total_Earnings'
    })
    
    # Find date column
    for col in ['Pay Date', 'Pay_Date', 'Date', 'date']:
        if col in df.columns:
            df_out = df_out.rename(columns={col: 'Pay_Date'})
            break
    
    # Select output columns that exist
    final_cols = [c for c in output_cols if c in df_out.columns]
    df_out = df_out[final_cols]
    
    # Save
    df_out.to_csv(output_file, index=False)
    print(f"\n✓ Saved classified data to {output_file}")
    
    return df_out


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Classify payroll data')
    parser.add_argument('--input', '-i', required=True, help='Input CSV file')
    parser.add_argument('--output', '-o', required=True, help='Output CSV file')
    
    args = parser.parse_args()
    classify_payroll(args.input, args.output)
