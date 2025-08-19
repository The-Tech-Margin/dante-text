#!/usr/bin/env node

const fs = require('fs-extra');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const { supabase } = require('../lib/supabase');
const { 
  parseDescFile, 
  parseTextFile, 
  mapLanguage, 
  mapCantica 
} = require('../lib/parsers');

require('dotenv').config();

const DANTE_DATA_PATH = process.env.DANTE_DATA_PATH;

async function migrateCommentaries() {
  console.log('🚀 Starting Dante Commentaries migration to Supabase...');
  
  if (!DANTE_DATA_PATH || !fs.existsSync(DANTE_DATA_PATH)) {
    throw new Error(`Invalid DANTE_DATA_PATH: ${DANTE_DATA_PATH}`);
  }

  try {
    // Get all commentary directories
    const commentaryDirs = await getCommentaryDirectories();
    console.log(`📚 Found ${commentaryDirs.length} commentaries to migrate`);

    let processedCount = 0;
    let errorCount = 0;

    for (const commDir of commentaryDirs) {
      try {
        console.log(`\n📖 Processing ${commDir}...`);
        await processCommentary(commDir);
        processedCount++;
        console.log(`✅ Successfully processed ${commDir}`);
      } catch (error) {
        console.error(`❌ Error processing ${commDir}:`, error.message);
        errorCount++;
      }
    }

    console.log(`\n🎉 Migration completed!`);
    console.log(`✅ Successfully processed: ${processedCount}`);
    console.log(`❌ Errors: ${errorCount}`);

  } catch (error) {
    console.error('💥 Migration failed:', error);
    process.exit(1);
  }
}

async function getCommentaryDirectories() {
  const entries = await fs.readdir(DANTE_DATA_PATH, { withFileTypes: true });
  return entries
    .filter(entry => entry.isDirectory() && !entry.name.startsWith('.'))
    .map(entry => entry.name)
    .sort();
}

async function processCommentary(commName) {
  const commPath = path.join(DANTE_DATA_PATH, commName);
  const descPath = path.join(commPath, 'desc.e');
  
  // Parse commentary metadata
  if (!fs.existsSync(descPath)) {
    throw new Error(`Missing desc.e file for ${commName}`);
  }
  
  const metadata = parseDescFile(descPath);
  if (!metadata) {
    throw new Error(`Failed to parse desc.e for ${commName}`);
  }

  // Generate commentary ID (using publication year + tie-breaker)
  const commId = generateCommId(metadata.pubd || '1300');
  
  // Create commentary record
  const commentary = {
    comm_id: commId,
    comm_name: commName,
    comm_author: metadata.auth || 'Unknown',
    comm_lang: mapLanguage(metadata.lang),
    comm_pub_year: metadata.pubd || null,
    comm_biblio: metadata.publ || null,
    comm_editor: metadata.edtr || null,
    comm_copyright: metadata.copyright === 'Y',
    comm_data_entry: metadata.dent || null
  };

  // Insert commentary into database
  const { data: insertedCommentary, error: commError } = await supabase
    .from('dde_commentaries')
    .insert(commentary)
    .select()
    .single();

  if (commError) {
    throw new Error(`Failed to insert commentary: ${commError.message}`);
  }

  console.log(`  💾 Inserted commentary metadata for ${commName}`);

  // Process text files for each cantica
  const canticas = ['inf', 'purg', 'para'];
  let textCount = 0;

  for (const cantica of canticas) {
    const canticaPath = path.join(commPath, cantica);
    if (fs.existsSync(canticaPath)) {
      const count = await processCantica(canticaPath, insertedCommentary.id, commId, cantica);
      textCount += count;
    }
  }

  console.log(`  📝 Processed ${textCount} text segments`);
}

async function processCantica(canticaPath, commentaryId, commId, cantica) {
  const files = await fs.readdir(canticaPath);
  const textFiles = files.filter(file => file.endsWith('.e') && file !== 'desc.e');
  
  let segmentCount = 0;
  const batchSize = 50;
  let batch = [];

  for (const file of textFiles) {
    const filePath = path.join(canticaPath, file);
    const cantoNum = path.basename(file, '.e');
    
    const segments = parseTextFile(filePath, commId, cantica, cantoNum);
    
    for (const segment of segments) {
      const textRecord = {
        doc_id: segment.docId,
        commentary_id: commentaryId,
        cantica: segment.cantica,
        canto_id: segment.cantoId,
        start_line: segment.startLine,
        end_line: segment.endLine,
        text_language: mapLanguage('latin'), // Most commentaries are in Latin
        text_type: segment.textType,
        source_path: `${cantica}/${file}`,
        content: segment.content
      };

      batch.push(textRecord);
      segmentCount++;

      // Insert in batches for performance
      if (batch.length >= batchSize) {
        await insertTextBatch(batch);
        batch = [];
      }
    }
  }

  // Insert remaining batch
  if (batch.length > 0) {
    await insertTextBatch(batch);
  }

  return segmentCount;
}

async function insertTextBatch(batch) {
  const { error } = await supabase
    .from('dde_texts')
    .insert(batch);

  if (error) {
    console.error('Batch insert error:', error);
    // Try individual inserts for debugging
    for (const record of batch) {
      const { error: individualError } = await supabase
        .from('dde_texts')
        .insert(record);
      
      if (individualError) {
        console.error(`Failed to insert text record ${record.doc_id}:`, individualError.message);
      }
    }
  }
}

function generateCommId(pubYear) {
  // Extract year from publication string
  const yearMatch = pubYear.match(/(\d{4})/);
  const year = yearMatch ? yearMatch[1] : '1300';
  
  // Use default tie-breaker of 5
  return year + '5';
}

// Run migration if called directly
if (require.main === module) {
  migrateCommentaries().catch(error => {
    console.error('Migration failed:', error);
    process.exit(1);
  });
}

module.exports = { migrateCommentaries };
