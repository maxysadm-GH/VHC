# CLAUDE.md - Vosges Haut-Chocolat Development Guide

## Project Overview
This repository contains automation, integration, and tooling for Vosges Haut-Chocolat (VHC) and La Maison du Chocolat (LMH) operations.

## Key Systems & Integrations

### E-Commerce Stack
- **Shopify Plus**: Primary storefront (Store ID: 273669 for PROD, 219870 for Special BD)
- **ShipStation**: Order fulfillment and shipping management
- **Fishbowl**: Inventory management system
- **ShipperHQ**: Shipping rates and box size optimization

### Automation Stack
- **Azure Logic Apps**: Weather checks, order routing
- **Power Automate**: Webhooks, notifications, Teams integration
- **Azure Functions**: Custom API endpoints
- **PowerShell**: Reporting scripts, data processing

## Project Structure

```
VHC/
├── project-phoenix/       # Order fulfillment automation system
│   ├── logic-apps/        # Azure Logic App definitions
│   ├── power-automate/    # Power Automate flows
│   └── azure-functions/   # Azure Function code
├── shipstation/           # ShipStation customizations
│   ├── reports/           # EOD reports, dashboards
│   ├── packing-slips/     # Template versions (current: v3.34)
│   ├── box-code/          # Box Code 2.0 automation
│   └── gift-notes/        # Gift note cleanup
├── integrations/          # Third-party integrations
│   ├── shipperhq/         # ShipperHQ Insights API
│   ├── fishbowl/          # Inventory sync
│   └── shopify/           # Shopify webhooks/APIs
├── scripts/               # Standalone scripts
│   ├── powershell/        # PS1 scripts
│   └── python/            # Python utilities
├── tools/                 # Internal tools
│   └── pricing-tool/      # B2B Pricing Calculator v3.5
├── docs/                  # Documentation
└── templates/             # Reusable templates
```

## Coding Conventions

### PowerShell
- Use approved verbs (Get-, Set-, New-, etc.)
- Include comment-based help for functions
- Error handling with try/catch blocks
- Log to both console and file when appropriate

### API Integrations
- Store credentials in environment variables or Azure Key Vault
- Never commit API keys or secrets
- Use retry logic for transient failures
- Log API responses for debugging

### ShipStation Specifics
- Packing slip template: v3.34
- Barcode positioning: padding-left 170px, padding-top 1.15in, padding-right 20px
- Custom Field 2: Box code from ShipperHQ
- PROD Store ID: 273669

### Git Workflow
- Use conventional commits: feat:, fix:, docs:, refactor:
- Create feature branches from main
- Keep commits atomic and focused
- Write descriptive commit messages

## Common Tasks

### ShipStation EOD Report
Location: `scripts/powershell/` or `shipstation/reports/`
- Pulls daily shipping data via API
- Posts summary to Teams channel
- Includes: order volume, service breakdown, 72-hour forecast

### Weather Check Logic App
Location: `project-phoenix/logic-apps/`
- Processes orders for ice pack requirements
- Checks temperature forecasts along shipping routes
- Updates ShipStation custom fields

### Box Code 2.0
Location: `shipstation/box-code/`
- Integrates ShipperHQ Insights API
- Calculates optimal box sizes
- Writes to ShipStation Custom Field 2

### B2B Pricing Tool
Location: `tools/pricing-tool/`
- Single-file HTML calculator with Supabase cloud sync
- Smart HTML exports with privacy controls
- What-If analysis and Goal Solver
- Supports markup and margin pricing methods
- Supabase project: szjkulsdattjabyqtxip

## Environment Variables

Required for local development:
- `SHIPSTATION_API_KEY` - ShipStation API key
- `SHIPSTATION_API_SECRET` - ShipStation API secret  
- `SHIPPERHQ_API_KEY` - ShipperHQ Insights API key
- `TEAMS_WEBHOOK_URL` - Teams channel webhook

## Testing

- Test against staging/sandbox environments first
- Use sample order data for integration tests
- Verify packing slip changes in ShipStation preview

## Contacts & Resources

- ShipStation API: https://www.shipstation.com/docs/api/
- ShipperHQ Insights: https://docs.shipperhq.com/
- Shopify Admin API: https://shopify.dev/docs/api/admin-rest

## Notes for Claude Code

When working in this repository:
1. Check existing code patterns before creating new files
2. Preserve existing functionality when refactoring
3. Add inline comments for complex logic
4. Update this CLAUDE.md if adding new systems/patterns
5. Use the git-pushing skill for commits when changes are complete
