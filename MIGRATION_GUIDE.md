# Dante Database Migration Guide

This guide walks you through migrating the Dartmouth Dante Project database from Oracle to Supabase.

## Prerequisites

1. **Supabase Project**: Create a new project at [supabase.com](https://supabase.com)
2. **Node.js**: Version 16 or higher
3. **Access to Dante Data**: Path to the original commentary files

## Setup Instructions

### 1. Install Dependencies
```bash
cd /Users/soniacookbroen/CascadeProjects/dante-supabase-migration
npm install
```

### 2. Configure Environment
```bash
cp .env.example .env
```

Edit `.env` with your Supabase credentials:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
DANTE_DATA_PATH=/Users/soniacookbroen/Development/dante_data/dante-text/Commentaries
```

### 3. Set Up Database Schema

**Option A: Manual Setup (Recommended)**
1. Open your Supabase project dashboard
2. Go to SQL Editor
3. Copy and paste the contents of `supabase/migrations/001_create_schema.sql`
4. Execute the migration

**Option B: Script Setup**
```bash
npm run setup:schema
```

## Running the Migration

### 1. Migrate Commentary Data
```bash
npm run migrate:commentaries
```

This will:
- Parse all `desc.e` files for commentary metadata
- Process text files from `inf/`, `purg/`, and `para/` directories
- Convert to modern Supabase format while preserving original doc_id system
- Insert data in batches for performance

### 2. Validate Migration
```bash
npm run validate
```

This performs:
- Data integrity checks
- Foreign key validation
- Content verification
- Statistical analysis

## Schema Overview

### Tables Created

**commentaries**
- Modern UUID primary keys
- Preserves original `comm_id` for compatibility
- Normalized language and metadata fields

**texts**
- Links to commentaries via foreign key
- Maintains original 12-character `doc_id` system
- Full-text search capabilities
- Proper indexing for performance

### Key Improvements

1. **Modern Types**: Uses PostgreSQL enums for canticas, languages, text types
2. **Better Indexing**: GIN indexes for full-text search
3. **Data Integrity**: Foreign key constraints and check constraints
4. **Timestamps**: Automatic created_at/updated_at tracking
5. **Security**: Row Level Security enabled

## Data Structure Mapping

### Original Oracle → Supabase

| Oracle | Supabase | Notes |
|--------|----------|-------|
| `ddp_comm_tab` | `commentaries` | Added UUIDs, normalized enums |
| `ddp_text_tab` | `texts` | Added text_type, improved indexing |
| `CLOB` | `text` | PostgreSQL text type |
| `CHAR(5)` comm_id | `varchar(5)` | Preserved for compatibility |
| `CHAR(12)` doc_id | `varchar(12)` | Preserved original format |

### Doc ID Format Preserved
```
cccccannlllt
├─5─┤│││││└── tie-breaker (0-9)
     │││└─3─┘─ line number (000-999)  
     ││└2┘──── canto number (00-34)
     │└1┘───── cantica (0=general, 1=inf, 2=purg, 3=para)
     └──────── commentary ID
```

## Migration Statistics

After migration, you can expect:
- **~80 Commentaries**: Historical Dante commentaries
- **~50,000+ Text Segments**: Commentary text and poem references
- **3 Canticas**: Inferno, Purgatorio, Paradiso
- **Multiple Languages**: Latin, Italian, English

## Troubleshooting

### Common Issues

**1. Missing Environment Variables**
```
Error: Missing Supabase environment variables
```
Solution: Check your `.env` file configuration

**2. Schema Creation Errors**
```
Error: relation "commentaries" does not exist
```
Solution: Run the schema migration manually in Supabase dashboard

**3. Data Path Issues**
```
Error: Invalid DANTE_DATA_PATH
```
Solution: Verify the path to your Commentaries directory

**4. Permission Errors**
```
Error: insufficient_privilege
```
Solution: Use SERVICE_ROLE_KEY instead of ANON_KEY for migrations

### Performance Optimization

- Migration processes data in batches of 50 records
- Uses prepared statements for efficiency
- Indexes are created after bulk inserts
- Consider increasing Supabase database resources for large imports

## API Usage Examples

### Query Commentaries
```javascript
const { data } = await supabase
  .from('commentaries')
  .select('*')
  .eq('comm_lang', 'latin');
```

### Search Commentary Text
```javascript
const { data } = await supabase
  .from('texts')
  .select(`
    *,
    commentaries(comm_author, comm_name)
  `)
  .textSearch('content', 'dante inferno')
  .eq('cantica', 'inferno');
```

### Get Canto Commentary
```javascript
const { data } = await supabase
  .from('texts')
  .select('*')
  .eq('cantica', 'inferno')
  .eq('canto_id', 1)
  .order('start_line');
```

## Next Steps

1. **Deploy Frontend**: Build a web interface for browsing commentaries
2. **Add Search**: Implement advanced search with filters
3. **API Integration**: Create REST/GraphQL endpoints
4. **Performance**: Monitor and optimize query performance
5. **Backup**: Set up regular database backups

## Support

For issues with the migration:
1. Check the `migration-report.json` file generated after validation
2. Review Supabase logs in the dashboard
3. Verify original data file integrity
4. Test with a smaller subset first

The migration preserves the scholarly integrity of the original database while modernizing the infrastructure for better performance and maintainability.
