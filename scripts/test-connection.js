#!/usr/bin/env node

const { supabase } = require('../lib/supabase');

async function testConnection() {
  console.log('🔗 Testing Supabase connection...');
  
  try {
    // Test basic connection with simple select
    const { data, error } = await supabase
      .from('dde_commentaries')
      .select('id')
      .limit(5);

    if (error) {
      console.error('❌ Connection failed:', error.message);
      
      if (error.message.includes('relation "dde_commentaries" does not exist')) {
        console.log('\n💡 The tables don\'t exist yet. You need to:');
        console.log('   1. Open your Supabase dashboard');
        console.log('   2. Go to SQL Editor');
        console.log('   3. Run the migration SQL from supabase/migrations/001_create_schema.sql');
        console.log('   4. Then run the migration again');
      }
      
      return false;
    } else {
      // Get count separately
      const { count: totalCount } = await supabase
        .from('dde_commentaries')
        .select('*', { count: 'exact', head: true });
        
      console.log('✅ Successfully connected to Supabase!');
      console.log(`📊 Found ${totalCount || 0} commentaries in database`);
      return true;
    }
    
  } catch (err) {
    console.error('❌ Connection error:', err.message);
    
    if (err.message.includes('fetch failed')) {
      console.log('\n💡 Check your environment variables:');
      console.log('   - SUPABASE_URL should be your project URL');
      console.log('   - SUPABASE_SERVICE_ROLE_KEY should be your service role key');
    }
    
    return false;
  }
}

if (require.main === module) {
  testConnection().then(success => {
    process.exit(success ? 0 : 1);
  });
}

module.exports = { testConnection };
