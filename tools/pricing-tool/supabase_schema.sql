-- ═══════════════════════════════════════════════════════════════════════════════
-- VOSGES PRICING TOOL - SUPABASE SCHEMA
-- Run this in your Supabase SQL Editor: https://szjkulsdattjabyqtxip.supabase.co
-- ═══════════════════════════════════════════════════════════════════════════════

-- Scenarios table (main pricing data)
CREATE TABLE IF NOT EXISTS scenarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_code TEXT UNIQUE NOT NULL,  -- 'CHW', 'LSL', etc.
    name TEXT NOT NULL,
    type TEXT CHECK (type IN ('tray', 'sup', 'bulk')),
    production JSONB,
    units JSONB,
    labor JSONB,
    packaging JSONB,
    ingredient_method TEXT,
    ingredient_data JSONB,  -- { plug, bom, note }
    pricing_method TEXT,
    pricing_factor DECIMAL(5,4),
    pricing_formula TEXT,
    minor_materials JSONB,
    minor_materials_per_pallet DECIMAL(10,6),
    minor_materials_per_piece DECIMAL(10,6),
    minor_materials_added BOOLEAN DEFAULT false,
    pallet_config JSONB,
    customer_pricing JSONB,
    final_price DECIMAL(10,6),
    price_note TEXT,
    is_template BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Clients table (B2B accounts for future portal)
CREATE TABLE IF NOT EXISTS clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,  -- 'CHW', 'TJ', etc.
    name TEXT NOT NULL,
    contact_email TEXT,
    portal_enabled BOOLEAN DEFAULT false,
    portal_token TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Ingredients library
CREATE TABLE IF NOT EXISTS ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    cost_per_lb DECIMAL(10,4),
    uom TEXT DEFAULT 'lb',
    source TEXT,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Config (global settings)
CREATE TABLE IF NOT EXISTS config (
    key TEXT PRIMARY KEY,
    value JSONB,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Exports tracking (for smart HTML exports)
CREATE TABLE IF NOT EXISTS exports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_id UUID REFERENCES scenarios(id) ON DELETE CASCADE,
    scenario_code TEXT,
    export_type TEXT,  -- 'client', 'interactive', 'internal'
    access_token TEXT UNIQUE,
    access_count INTEGER DEFAULT 0,
    options JSONB,  -- { hideCogs, hideLabor, etc. }
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- INDEXES
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_scenarios_code ON scenarios(scenario_code);
CREATE INDEX IF NOT EXISTS idx_scenarios_updated ON scenarios(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_exports_token ON exports(access_token);
CREATE INDEX IF NOT EXISTS idx_exports_scenario ON exports(scenario_id);

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Enable RLS on all tables
ALTER TABLE scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE config ENABLE ROW LEVEL SECURITY;
ALTER TABLE exports ENABLE ROW LEVEL SECURITY;

-- Staff access policy (using x-vhc-staff header)
-- For now, allow all access with the anon key (open access for staff tool)
CREATE POLICY "Allow all for scenarios" ON scenarios FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for clients" ON clients FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for ingredients" ON ingredients FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for config" ON config FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for exports" ON exports FOR ALL USING (true) WITH CHECK (true);

-- ═══════════════════════════════════════════════════════════════════════════════
-- UPSERT SUPPORT (for scenario_code conflict resolution)
-- ═══════════════════════════════════════════════════════════════════════════════

-- The Prefer: resolution=merge-duplicates header with POST will handle upserts
-- based on the UNIQUE constraint on scenario_code

-- ═══════════════════════════════════════════════════════════════════════════════
-- SAMPLE DATA (optional - uncomment to seed)
-- ═══════════════════════════════════════════════════════════════════════════════

-- INSERT INTO config (key, value) VALUES
--     ('laborRates', '{"default": 26, "supervisor": 35}'::jsonb),
--     ('version', '"3.5"'::jsonb)
-- ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = now();
