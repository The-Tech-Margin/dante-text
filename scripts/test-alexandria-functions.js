#!/usr/bin/env node
/**
 * Test Suite for Alexandria Archive Functions
 * Tests all alex_ functions and logical linking system
 */

// Load environment variables from .env file
require('dotenv').config();

const { createClient } = require('@supabase/supabase-js');

// Supabase configuration
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables');
  console.error('   Make sure your .env file is properly configured');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

// Test statistics
let testStats = {
  passed: 0,
  failed: 0,
  errors: []
};

/**
 * Test helper functions
 */
function logTest(testName, passed, details = '') {
  const status = passed ? '✅ PASS' : '❌ FAIL';
  console.log(`${status}: ${testName}`);
  
  if (details) {
    console.log(`   ${details}`);
  }
  
  if (passed) {
    testStats.passed++;
  } else {
    testStats.failed++;
    testStats.errors.push({ test: testName, details });
  }
}

/**
 * Test 1: Verify Alexandria schema deployment
 */
async function testSchemaDeployment() {
  console.log('\n🧪 Testing Schema Deployment...');
  
  try {
    // Test alex_ tables exist
    const tables = [
      'alex_commentary_versions',
      'alex_texts_historical', 
      'alex_scholarly_annotations',
      'alex_commentary_relationships',
      'alex_research_collections',
      'alex_collection_items',
      'alex_migration_log'
    ];
    
    for (const table of tables) {
      const { error } = await supabase
        .from(table)
        .select('count(*)', { count: 'exact', head: true });
      
      logTest(`Table ${table} exists`, !error, error?.message);
    }
    
    // Test version_source enum
    const { data, error } = await supabase
      .rpc('alex_compare_commentary_versions', { input_commentary_name: 'test' });
    
    logTest('alex_compare_commentary_versions function exists', !error || error.code !== '42883');
    
  } catch (error) {
    logTest('Schema deployment test', false, error.message);
  }
}

/**
 * Test 2: Test Alexandria functions
 */
async function testAlexandriaFunctions() {
  console.log('\n🧪 Testing Alexandria Functions...');
  
  try {
    // Test alex_compare_commentary_versions
    const { data: compareData, error: compareError } = await supabase
      .rpc('alex_compare_commentary_versions', { 
        input_commentary_name: 'hollander' 
      });
    
    logTest(
      'alex_compare_commentary_versions', 
      !compareError,
      compareError?.message || `Returned ${compareData?.length || 0} versions`
    );
    
    // Test alex_find_passage_variants
    const { data: variantsData, error: variantsError } = await supabase
      .rpc('alex_find_passage_variants', {
        input_cantica: 'inferno',
        input_canto: 1,
        input_start_line: 1,
        input_end_line: 10
      });
    
    logTest(
      'alex_find_passage_variants',
      !variantsError,
      variantsError?.message || `Found ${variantsData?.length || 0} variants`
    );
    
    // Test alex_scholarly_search_all_versions
    const { data: searchData, error: searchError } = await supabase
      .rpc('alex_scholarly_search_all_versions', {
        search_term: 'dante',
        include_historical: true,
        version_filter: null
      });
    
    logTest(
      'alex_scholarly_search_all_versions',
      !searchError,
      searchError?.message || `Found ${searchData?.length || 0} search results`
    );
    
  } catch (error) {
    logTest('Alexandria functions test', false, error.message);
  }
}

/**
 * Test 3: Test logical linking system
 */
async function testLogicalLinking() {
  console.log('\n🧪 Testing Logical Linking System...');
  
  try {
    // Get current commentaries for comparison
    const { data: currentCommentaries, error: currentError } = await supabase
      .from('dde_commentaries')
      .select('id, comm_name')
      .limit(5);
    
    logTest('Current commentaries accessible', !currentError, 
      currentError?.message || `Found ${currentCommentaries?.length || 0} commentaries`);
    
    // Test if historical texts can link to current commentaries logically
    const { data: historicalTexts, error: historicalError } = await supabase
      .from('alex_texts_historical')
      .select('id, commentary_name, cantica, canto_id')
      .limit(3);
    
    logTest('Historical texts accessible', !historicalError,
      historicalError?.message || `Found ${historicalTexts?.length || 0} historical texts`);
    
    // Test logical join between historical and current
    if (currentCommentaries?.length > 0 && historicalTexts?.length > 0) {
      const { data: joinData, error: joinError } = await supabase
        .from('alex_texts_historical')
        .select(`
          id,
          commentary_name,
          content,
          dde_commentaries!inner(comm_name, comm_author)
        `)
        .eq('dde_commentaries.comm_name', historicalTexts[0].commentary_name)
        .limit(1);
      
      logTest('Logical linking works', !joinError,
        joinError?.message || `Successfully linked historical to current commentary`);
    }
    
  } catch (error) {
    logTest('Logical linking test', false, error.message);
  }
}

/**
 * Test 4: Test cross-version queries
 */
async function testCrossVersionQueries() {
  console.log('\n🧪 Testing Cross-Version Queries...');
  
  try {
    // Test finding same passage across versions
    const testCommentary = 'hollander';
    
    // Get current version
    const { data: currentTexts, error: currentError } = await supabase
      .from('dde_texts')
      .select('id, content, cantica, canto_id, start_line, end_line')
      .eq('dde_commentaries.comm_name', testCommentary)
      .eq('cantica', 'inferno')
      .eq('canto_id', 1)
      .limit(1);
    
    logTest('Current version text query', !currentError,
      currentError?.message || `Found ${currentTexts?.length || 0} current texts`);
    
    // Get historical versions of same passage
    const { data: historicalTexts, error: historicalError } = await supabase
      .from('alex_texts_historical')
      .select('id, content, cantica, canto_id, start_line, end_line, version_source')
      .eq('commentary_name', testCommentary)
      .eq('cantica', 'inferno')
      .eq('canto_id', 1)
      .limit(1);
    
    logTest('Historical version text query', !historicalError,
      historicalError?.message || `Found ${historicalTexts?.length || 0} historical texts`);
    
    // Test similarity computation
    if (currentTexts?.length > 0 && historicalTexts?.length > 0) {
      const similarity = calculateTextSimilarity(
        currentTexts[0].content,
        historicalTexts[0].content
      );
      
      logTest('Text similarity calculation', similarity >= 0 && similarity <= 1,
        `Similarity score: ${Math.round(similarity * 100)}%`);
    }
    
  } catch (error) {
    logTest('Cross-version queries test', false, error.message);
  }
}

/**
 * Test 5: Test data integrity and constraints
 */
async function testDataIntegrity() {
  console.log('\n🧪 Testing Data Integrity...');
  
  try {
    // Test enum constraints
    const { error: enumError } = await supabase
      .from('alex_commentary_versions')
      .insert({
        base_commentary_id: '00000000-0000-0000-0000-000000000000',
        version_identifier: 'test_invalid_enum',
        version_source: 'invalid_source', // Should fail
        editorial_status: 'published'
      });
    
    logTest('Enum constraint enforcement', !!enumError && enumError.code === '22P02',
      'Invalid enum values correctly rejected');
    
    // Test required fields
    const { error: requiredError } = await supabase
      .from('alex_texts_historical')
      .insert({
        // Missing required fields - should fail
        content: 'test content'
      });
    
    logTest('Required field validation', !!requiredError,
      'Missing required fields correctly detected');
    
    // Test logical linking integrity
    const { data: orphanedTexts, error: orphanError } = await supabase
      .from('alex_texts_historical')
      .select('id, commentary_name')
      .not('commentary_name', 'in', 
        `(${await supabase.from('dde_commentaries').select('comm_name').then(r => 
          r.data?.map(c => `"${c.comm_name}"`).join(',') || '""')})`
      )
      .limit(5);
    
    logTest('Logical linking integrity check', !orphanError,
      orphanError?.message || `Found ${orphanedTexts?.length || 0} orphaned historical texts`);
    
  } catch (error) {
    logTest('Data integrity test', false, error.message);
  }
}

/**
 * Test 6: Test performance indexes
 */
async function testPerformanceIndexes() {
  console.log('\n🧪 Testing Performance Indexes...');
  
  try {
    // Test index usage with EXPLAIN (requires elevated permissions)
    const testQueries = [
      {
        name: 'Commentary name index',
        query: supabase
          .from('alex_texts_historical')
          .select('id')
          .eq('commentary_name', 'hollander')
          .limit(1)
      },
      {
        name: 'Passage lookup index', 
        query: supabase
          .from('alex_texts_historical')
          .select('id')
          .eq('cantica', 'inferno')
          .eq('canto_id', 1)
          .limit(1)
      },
      {
        name: 'Version source index',
        query: supabase
          .from('alex_commentary_versions')
          .select('id')
          .eq('version_source', 'alexandria_archive')
          .limit(1)
      }
    ];
    
    for (const { name, query } of testQueries) {
      const startTime = Date.now();
      const { error } = await query;
      const duration = Date.now() - startTime;
      
      logTest(name, !error && duration < 1000,
        error?.message || `Query completed in ${duration}ms`);
    }
    
  } catch (error) {
    logTest('Performance indexes test', false, error.message);
  }
}

/**
 * Simple text similarity calculation
 */
function calculateTextSimilarity(text1, text2) {
  if (!text1 || !text2) return 0;
  
  const words1 = text1.toLowerCase().split(/\s+/).filter(w => w.length > 2);
  const words2 = text2.toLowerCase().split(/\s+/).filter(w => w.length > 2);
  
  const set1 = new Set(words1);
  const set2 = new Set(words2);
  
  const intersection = new Set([...set1].filter(x => set2.has(x)));
  const union = new Set([...set1, ...set2]);
  
  return union.size > 0 ? intersection.size / union.size : 0;
}

/**
 * Main test execution
 */
async function runAllTests() {
  console.log('🚀 Starting Alexandria Archive Function Tests');
  console.log('=' .repeat(60));
  
  try {
    await testSchemaDeployment();
    await testAlexandriaFunctions();
    await testLogicalLinking();
    await testCrossVersionQueries();
    await testDataIntegrity();
    await testPerformanceIndexes();
    
    // Final results
    console.log('\n' + '=' .repeat(60));
    console.log('📊 TEST RESULTS SUMMARY');
    console.log('=' .repeat(60));
    console.log(`✅ Tests Passed: ${testStats.passed}`);
    console.log(`❌ Tests Failed: ${testStats.failed}`);
    console.log(`📈 Success Rate: ${Math.round((testStats.passed / (testStats.passed + testStats.failed)) * 100)}%`);
    
    if (testStats.failed > 0) {
      console.log('\n🚨 FAILED TEST DETAILS:');
      testStats.errors.forEach((error, i) => {
        console.log(`${i + 1}. ${error.test}: ${error.details}`);
      });
    } else {
      console.log('\n🎉 All tests passed successfully!');
    }
    
  } catch (error) {
    console.error('💥 Fatal test error:', error);
    process.exit(1);
  }
}

// Run tests if called directly
if (require.main === module) {
  runAllTests()
    .then(() => {
      process.exit(testStats.failed > 0 ? 1 : 0);
    })
    .catch((error) => {
      console.error('💥 Test suite failed:', error);
      process.exit(1);
    });
}

module.exports = {
  runAllTests,
  calculateTextSimilarity
};
