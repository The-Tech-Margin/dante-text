# Supabase Migration for Dante Database

This branch contains the complete migration system to convert the Dartmouth Dante Project database from Oracle to Supabase.

## Quick Start

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

3. **Set up schema in Supabase:**
   - Open Supabase dashboard → SQL Editor
   - Run `supabase/migrations/001_create_schema.sql`

4. **Run migration:**
   ```bash
   npm run migrate:commentaries
   ```

5. **Validate results:**
   ```bash
   npm run validate
   ```

## Project Structure

```
lib/                 # Core utilities
├── supabase.js     # Supabase client
├── parsers.js      # Parse .e files
└── helpers.js      # Database helpers

scripts/             # Migration scripts
├── migrate-commentaries.js  # Main migration
├── setup-schema.js         # Schema setup
└── validate-data.js        # Validation

supabase/           # Database schema
└── migrations/
    └── 001_create_schema.sql
```

## Tables Created

- `dde_commentaries` - Commentary metadata with modern UUIDs
- `dde_texts` - Text content with full-text search capabilities

Both preserve original Oracle ID system for compatibility while adding modern PostgreSQL features.

See `MIGRATION_GUIDE.md` for detailed documentation.
