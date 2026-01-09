# Vosges B2B Pricing Tool v3.5

Single-file HTML pricing calculator for B2B chocolate pricing with cloud persistence.

## Features

- **Cloud Sync**: Supabase backend for persistent storage across devices
- **Smart Exports**: Generate client-facing HTML proposals with privacy controls
- **What-If Analysis**: Interactive pricing scenarios
- **Multiple Pricing Methods**: Markup vs Margin calculations
- **Ingredient Costing**: Plug values, BOM, or Flavor Studio integration

## Quick Start

1. Open `vosges_pricing_tool.html` in Chrome
2. The tool will attempt to sync with Supabase cloud
3. If offline, falls back to localStorage

## Supabase Setup

Run `supabase_schema.sql` in your Supabase SQL Editor to create required tables:
- `scenarios` - Pricing scenarios
- `clients` - B2B client accounts
- `ingredients` - Ingredient library
- `config` - Global settings
- `exports` - Export tracking

## Export Options

| Type | Description |
|------|-------------|
| Client HTML | Clean, read-only proposal for clients |
| Interactive HTML | Includes What-If calculator |
| Internal HTML | Full details including formulas |

### Privacy Controls
- Hide COGS breakdown
- Hide labor details
- Hide pricing formula

## Version History

- **v3.5** - Cloud sync, smart exports
- **v3.4** - LocalStorage persistence
- **v3.3** - Chat AI assistant
- **v3.2** - Duplicate/export scenarios
- **v3.1** - Goal solver, configs
- **v3.0** - Initial release
