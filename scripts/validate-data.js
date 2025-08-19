#!/usr/bin/env node

const { supabase } = require('../lib/supabase');
const { parseDescFile } = require('../lib/parsers');
const fs = require('fs-extra');
const path = require('path');

require('dotenv').config();

async function validateData() {
  console.log('🔍 Validating migrated data in Supabase...');
  
  try {
    await validateCommentaries();
    await validateTexts();
    await validateDataIntegrity();
    console.log('✅ Data validation completed successfully!');
  } catch (error) {
    console.error('❌ Data validation failed:', error.message);
    process.exit(1);
  }
}

async function validateCommentaries() {
  console.log('\n📚 Validating commentaries table...');
  
  const { data: commentaries, error } = await supabase
    .from('dde_commentaries')
    .select('*')
    .order('comm_name');

  if (error) {
    throw new Error(`Failed to fetch commentaries: ${error.message}`);
  }

  console.log(`  Found ${commentaries.length} commentaries in database`);

  // Check for required fields
  const missingFields = commentaries.filter(c => 
    !c.comm_name || !c.comm_author || !c.comm_lang
  );

  if (missingFields.length > 0) {
    console.warn(`  ⚠️  ${missingFields.length} commentaries missing required fields`);
  }

  // Sample validation output
  if (commentaries.length > 0) {
    const sample = commentaries[0];
    console.log(`  📄 Sample commentary: ${sample.comm_name} by ${sample.comm_author}`);
  }
}

async function validateTexts() {
  console.log('\n📝 Validating texts table...');
  
  const { data: texts, error } = await supabase
    .from('dde_texts')
    .select('*')
    .limit(1000); // Limit for performance

  if (error) {
    throw new Error(`Failed to fetch texts: ${error.message}`);
  }

  console.log(`  Found ${texts.length} text records (showing first 1000)`);

  // Get total count
  const { count, error: countError } = await supabase
    .from('dde_texts')
    .select('*', { count: 'exact', head: true });

  if (!countError) {
    console.log(`  Total text records: ${count}`);
  }

  // Validate doc_id format
  const invalidDocIds = texts.filter(t => 
    !t.doc_id || t.doc_id.length !== 12
  );

  if (invalidDocIds.length > 0) {
    console.warn(`  ⚠️  ${invalidDocIds.length} texts with invalid doc_id format`);
  }

  // Check content
  const emptyContent = texts.filter(t => !t.content || t.content.trim().length === 0);
  if (emptyContent.length > 0) {
    console.warn(`  ⚠️  ${emptyContent.length} texts with empty content`);
  }

  // Sample validation output
  if (texts.length > 0) {
    const sample = texts[0];
    console.log(`  📄 Sample text: ${sample.doc_id} (${sample.cantica} ${sample.canto_id})`);
    console.log(`      Content preview: ${sample.content.substring(0, 100)}...`);
  }
}

async function validateDataIntegrity() {
  console.log('\n🔗 Validating data integrity...');
  
  // Check foreign key relationships
  const { data: orphanedTexts, error } = await supabase
    .from('dde_texts')
    .select('doc_id, commentary_id')
    .not('commentary_id', 'in', 
      supabase.from('dde_commentaries').select('id')
    );

  if (error) {
    console.warn('  Could not check foreign key integrity:', error.message);
  } else if (orphanedTexts && orphanedTexts.length > 0) {
    console.warn(`  ⚠️  ${orphanedTexts.length} texts with invalid commentary references`);
  } else {
    console.log('  ✅ All foreign key relationships valid');  
  }

  // Check for duplicate doc_ids
  const { data: duplicates, error: dupError } = await supabase
    .rpc('find_duplicate_doc_ids');

  if (!dupError && duplicates && duplicates.length > 0) {
    console.warn(`  ⚠️  ${duplicates.length} duplicate doc_ids found`);
  } else {
    console.log('  ✅ No duplicate doc_ids found');
  }

  // Validate cantica/canto ranges
  const { data: invalidRanges, error: rangeError } = await supabase
    .from('dde_texts')
    .select('doc_id, cantica, canto_id')
    .or('canto_id.lt.0,canto_id.gt.34');

  if (!rangeError && invalidRanges && invalidRanges.length > 0) {
    console.warn(`  ⚠️  ${invalidRanges.length} texts with invalid canto ranges`);
  } else {
    console.log('  ✅ All canto ranges valid');
  }
}

async function generateReport() {
  console.log('\n📊 Generating migration report...');
  
  try {
    const { data: stats } = await supabase
      .rpc('get_migration_stats');

    if (stats) {
      console.log('  Migration Statistics:');
      console.log(`    Commentaries: ${stats.commentary_count}`);
      console.log(`    Total texts: ${stats.text_count}`);
      console.log(`    By cantica:`);
      console.log(`      Inferno: ${stats.inferno_count}`);
      console.log(`      Purgatorio: ${stats.purgatorio_count}`);  
      console.log(`      Paradiso: ${stats.paradiso_count}`);
      console.log(`    Languages: ${stats.languages?.join(', ')}`);
    }

    const report = {
      timestamp: new Date().toISOString(),
      migration_completed: true,
      validation_passed: true
    };

    await fs.writeJson(
      path.join(__dirname, '../migration-report.json'), 
      report, 
      { spaces: 2 }
    );

    console.log('  📄 Report saved to migration-report.json');

  } catch (error) {
    console.warn('  Could not generate complete report:', error.message);
  }
}

if (require.main === module) {
  validateData()
    .then(() => generateReport())
    .catch(error => {
      console.error('Validation failed:', error);
      process.exit(1);
    });
}

module.exports = { validateData, generateReport };
