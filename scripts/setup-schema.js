#!/usr/bin/env node

const fs = require('fs-extra');
const path = require('path');
const { supabase } = require('../lib/supabase');

async function setupSchema() {
  console.log('🗄️  Setting up Supabase schema for Dante database...');
  
  try {
    const migrationPath = path.join(__dirname, '../supabase/migrations/001_create_schema.sql');
    
    if (!fs.existsSync(migrationPath)) {
      throw new Error('Migration file not found. Please ensure 001_create_schema.sql exists.');
    }

    const migrationSQL = await fs.readFile(migrationPath, 'utf8');
    
    // Split SQL into individual statements
    const statements = migrationSQL
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));

    console.log(`📝 Executing ${statements.length} SQL statements...`);

    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i] + ';';
      
      try {
        const { error } = await supabase.rpc('exec_sql', { sql: statement });
        
        if (error) {
          console.log(`⚠️  Statement ${i + 1} may have failed (this might be expected):`, error.message);
        } else {
          console.log(`✅ Statement ${i + 1} executed successfully`);
        }
      } catch (err) {
        console.log(`⚠️  Statement ${i + 1} execution error:`, err.message);
      }
    }

    // Verify tables were created
    const { data: tables, error: tablesError } = await supabase
      .from('information_schema.tables')
      .select('table_name')
      .eq('table_schema', 'public')
      .in('table_name', ['commentaries', 'texts']);

    if (tablesError) {
      console.error('❌ Error checking tables:', tablesError.message);
    } else {
      console.log(`✅ Schema setup completed. Created ${tables.length} tables.`);
      tables.forEach(table => console.log(`  - ${table.table_name}`));
    }

  } catch (error) {
    console.error('💥 Schema setup failed:', error.message);
    process.exit(1);
  }
}

// Alternative method: Direct SQL execution function
async function executeSchemaDirectly() {
  console.log('🗄️  Setting up schema using direct SQL execution...');
  
  try {
    // Create extensions
    await supabase.rpc('exec_sql', { 
      sql: 'create extension if not exists "uuid-ossp";' 
    });

    // Create enums
    const enums = [
      "create type cantica_type as enum ('inferno', 'purgatorio', 'paradiso', 'general');",
      "create type language_type as enum ('latin', 'italian', 'english');",
      "create type text_type as enum ('commentary', 'poem', 'description', 'proemio', 'conclusione');"
    ];

    for (const enumSQL of enums) {
      const { error } = await supabase.rpc('exec_sql', { sql: enumSQL });
      if (error && !error.message.includes('already exists')) {
        console.error('Enum creation error:', error.message);
      }
    }

    console.log('✅ Extensions and enums created');

    // Note: For full schema setup, you may need to run the migration manually
    // in the Supabase dashboard or using the Supabase CLI
    console.log('📋 For complete schema setup, consider running the migration SQL manually in Supabase dashboard');

  } catch (error) {
    console.error('Schema setup error:', error.message);
  }
}

if (require.main === module) {
  setupSchema().catch(error => {
    console.error('Setup failed:', error);
    process.exit(1);
  });
}

module.exports = { setupSchema, executeSchemaDirectly };
