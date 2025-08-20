const { supabase } = require('../lib/supabase');

async function testAllFunctions() {
  console.log('🧪 Testing all Supabase functions...\n');

  const results = {
    passed: 0,
    failed: 0,
    errors: []
  };

  // Test 1: Search commentaries ranked
  try {
    console.log('\n1️⃣ Testing search_commentaries_ranked...');
    
    // First check total commentaries in database
    const { count, error: countError } = await supabase
      .from('dde_commentaries')
      .select('*', { count: 'exact', head: true });
    
    if (!countError && count !== null) {
      console.log(`   📊 Total commentaries in database: ${count}`);
    }
    
    const { data, error } = await supabase.rpc('search_commentaries_ranked', {
      search_term: 'dante',
      lang_filter: null,
      limit_count: 20  // Increased limit to see more results
    });

    if (error) {
      throw error;
    }

    console.log(`   ✅ Found ${data?.length || 0} commentaries matching 'dante'`);
    if (data && data.length > 0) {
      console.log(`   📋 Sample: ${data[0].comm_name} by ${data[0].comm_author}`);
    }
    results.passed++;
  } catch (error) {
    console.log(`   ❌ Error: ${error.message}`);
    results.failed++;
    results.errors.push({ function: 'search_commentaries_ranked', error: error.message });
  }

  // Test 2: Search texts with context
  try {
    console.log('\n2️⃣ Testing search_texts_with_context...');
    const { data, error } = await supabase.rpc('search_texts_with_context', {
      search_term: 'beatrice',
      commentary_ids: null,
      cantica_filter: null,
      limit_count: 3
    });

    if (error) {
      throw error;
    }

    console.log(`   ✅ Found ${data?.length || 0} text results`);
    if (data && data.length > 0) {
      console.log(`   📋 Sample: ${data[0].commentary_name} - ${data[0].cantica} ${data[0].canto_id}`);
    }
    results.passed++;
  } catch (error) {
    console.log(`   ❌ Error: ${error.message}`);
    results.failed++;
    results.errors.push({ function: 'search_texts_with_context', error: error.message });
  }

  // Test 3: Search with highlights
  try {
    console.log('\n3️⃣ Testing search_with_highlights...');
    const { data, error } = await supabase.rpc('search_with_highlights', {
      search_term: 'divine',
      commentary_filter: null,
      limit_count: 3
    });

    if (error) {
      throw error;
    }

    console.log(`   ✅ Found ${data?.length || 0} highlighted results`);
    if (data && data.length > 0) {
      console.log(`   📋 Sample highlights in ${data[0].commentary_name}`);
    }
    results.passed++;
  } catch (error) {
    console.log(`   ❌ Error: ${error.message}`);
    results.failed++;
    results.errors.push({ function: 'search_with_highlights', error: error.message });
  }

  // Test 4: Get commentary stats (need to find a valid UUID commentary ID first)
  let validCommId = null;
  try {
    const { data: commentaries } = await supabase
      .from('dde_commentaries')
      .select('id, comm_name')
      .limit(1);
    
    if (commentaries && commentaries.length > 0) {
      validCommId = commentaries[0].id;  // Use UUID id, not comm_id string
    }
  } catch (error) {
    console.log(`   ⚠️ Warning: Could not find valid commentary ID: ${error.message}`);
  }

  if (validCommId) {
    try {
      console.log('\n4️⃣ Testing get_commentary_stats...');
      const { data, error } = await supabase.rpc('get_commentary_stats', {
        input_commentary_id: validCommId
      });

      if (error) {
        throw error;
      }

      console.log(`   ✅ Got stats for commentary ${validCommId}`);
      if (data && data.length > 0) {
        console.log(`   📊 Total texts: ${data[0].total_texts || 'N/A'}`);
      }
      results.passed++;
    } catch (error) {
      console.log(`   ❌ Error: ${error.message}`);
      results.failed++;
      results.errors.push({ function: 'get_commentary_stats', error: error.message });
    }
  } else {
    console.log('\n4️⃣ Skipping get_commentary_stats - no valid commentary ID found');
    results.errors.push({ function: 'get_commentary_stats', error: 'No valid commentary ID found' });
  }

  // Test 5: Compare commentaries by passage
  try {
    console.log('\n5️⃣ Testing compare_commentaries_by_passage...');
    const { data, error } = await supabase.rpc('compare_commentaries_by_passage', {
      input_cantica: 'inferno',
      input_canto: 1,
      input_start_line: 1,
      input_end_line: 10
    });

    if (error) {
      throw error;
    }

    console.log(`   ✅ Found ${data?.length || 0} commentary comparisons`);
    if (data && data.length > 0) {
      console.log(`   📋 Sample: ${data[0].commentary_name || 'Unknown'} commentary`);
    }
    results.passed++;
  } catch (error) {
    console.log(`   ❌ Error: ${error.message}`);
    results.failed++;
    results.errors.push({ function: 'compare_commentaries_by_passage', error: error.message });
  }

  // Test 6: Get navigation tree
  if (validCommId) {
    try {
      console.log('\n6️⃣ Testing get_navigation_tree...');
      const { data, error } = await supabase.rpc('get_navigation_tree', {
        commentary_id: validCommId  // Correct parameter name
      });

      if (error) {
        throw error;
      }

      console.log(`   ✅ Got navigation tree for commentary ${validCommId}`);
      if (data && data.length > 0) {
        console.log(`   🌳 Found ${data.length} navigation nodes`);
      }
      results.passed++;
    } catch (error) {
      console.log(`   ❌ Error: ${error.message}`);
      results.failed++;
      results.errors.push({ function: 'get_navigation_tree', error: error.message });
    }
  } else {
    console.log('\n6️⃣ Skipping get_navigation_tree - no valid commentary ID found');
    results.errors.push({ function: 'get_navigation_tree', error: 'No valid commentary ID found' });
  }

  // Summary
  console.log('\n' + '='.repeat(50));
  console.log('📊 TEST SUMMARY');
  console.log('='.repeat(50));
  console.log(`✅ Passed: ${results.passed}`);
  console.log(`❌ Failed: ${results.failed}`);
  console.log(`📊 Total: ${results.passed + results.failed}`);

  if (results.errors.length > 0) {
    console.log('\n🚨 ERRORS:');
    results.errors.forEach((err, index) => {
      console.log(`${index + 1}. ${err.function}: ${err.error}`);
    });
  }

  if (results.failed === 0) {
    console.log('\n🎉 All functions are working correctly!');
  } else {
    console.log('\n⚠️ Some functions need attention.');
  }

  return results;
}

// Database connection test
async function testConnection() {
  try {
    console.log('🔌 Testing database connection...');
    const { data, error } = await supabase
      .from('dde_commentaries')
      .select('count')
      .limit(1);

    if (error) {
      throw error;
    }

    console.log('✅ Database connection successful');
    return true;
  } catch (error) {
    console.log(`❌ Database connection failed: ${error.message}`);
    return false;
  }
}

// Main execution
async function main() {
  console.log('🚀 Starting Supabase function tests...\n');

  // Test connection first
  const connected = await testConnection();
  if (!connected) {
    console.log('❌ Cannot proceed without database connection.');
    process.exit(1);
  }

  console.log('');

  // Run all function tests
  const results = await testAllFunctions();

  // Exit with appropriate code
  process.exit(results.failed > 0 ? 1 : 0);
}

// Run if called directly
if (require.main === module) {
  main().catch(console.error);
}

module.exports = { testAllFunctions, testConnection };
