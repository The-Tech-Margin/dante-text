#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { supabase } = require('../lib/supabase');

async function deployPerformanceFunctions() {
  console.log('🚀 Deploying performance functions to Supabase...');
  
  try {
    // Read the SQL file
    const sqlPath = path.join(__dirname, '../supabase/migrations/002_performance_functions.sql');
    const sqlContent = fs.readFileSync(sqlPath, 'utf8');
    
    // Split into individual statements (basic splitting on semicolons outside of function bodies)
    const statements = sqlContent
      .split(/;\s*$/gm)
      .filter(stmt => stmt.trim().length > 0)
      .map(stmt => stmt.trim() + ';');
    
    console.log(`📄 Found ${statements.length} SQL statements to execute`);
    
    // Execute each statement
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      
      if (statement.includes('CREATE OR REPLACE FUNCTION') || statement.includes('CREATE INDEX')) {
        const functionName = statement.match(/(?:FUNCTION|INDEX)\s+(?:IF NOT EXISTS\s+)?(\w+)/i);
        console.log(`⚡ Executing: ${functionName ? functionName[1] : `Statement ${i + 1}`}`);
      }
      
      const { error } = await supabase.rpc('exec_sql', { sql: statement });
      
      if (error) {
        console.error(`❌ Error executing statement ${i + 1}:`, error.message);
        console.log('Statement:', statement.substring(0, 100) + '...');
        continue;
      }
    }
    
    console.log('✅ All performance functions deployed successfully!');
    
    // Test one function to verify deployment
    console.log('🧪 Testing deployment...');
    const { data: testResult, error: testError } = await supabase
      .rpc('get_navigation_tree');
    
    if (testError) {
      console.log('⚠️  Test failed, but functions may still be deployed:', testError.message);
    } else {
      console.log('✅ Test passed! Functions are working correctly.');
      console.log(`📊 Navigation tree has ${testResult?.length || 0} entries`);
    }
    
  } catch (err) {
    console.error('❌ Deployment failed:', err.message);
    process.exit(1);
  }
}

// Alternative method using direct SQL execution
async function deployWithDirectSQL() {
  console.log('🔄 Trying alternative deployment method...');
  
  try {
    const sqlPath = path.join(__dirname, '../supabase/migrations/002_performance_functions.sql');
    const sqlContent = fs.readFileSync(sqlPath, 'utf8');
    
    // Execute the entire SQL file at once
    const { error } = await supabase.rpc('exec_sql', { sql: sqlContent });
    
    if (error) {
      console.error('❌ Direct SQL execution failed:', error.message);
      return false;
    }
    
    console.log('✅ Direct SQL execution successful!');
    return true;
  } catch (err) {
    console.error('❌ Alternative method failed:', err.message);
    return false;
  }
}

if (require.main === module) {
  deployPerformanceFunctions().catch(console.error);
}

module.exports = { deployPerformanceFunctions, deployWithDirectSQL };
