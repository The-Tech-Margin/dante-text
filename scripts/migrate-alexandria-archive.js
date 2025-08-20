#!/usr/bin/env node
/**
 * Alexandria Archive Migration to Supabase
 * Migrates historical commentary versions and related data from Alexandria-Archive
 */

const fs = require('fs').promises;
const path = require('path');
const { createClient } = require('@supabase/supabase-js');

// Supabase configuration
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

// Alexandria archive paths
const ALEXANDRIA_PATHS = {
  dante_commentaries: './Alexandria-Archive/dante/Commentaries',
  archives_1991: './Alexandria-Archive/dante/Archives/Commentaries.1991',
  archives_post1991: './Alexandria-Archive/dante/Archives/Commentaries.post1991',
  archives_main: './Alexandria-Archive/dante/Archives/Archives',
  bobh_data: './Alexandria-Archive/bobh',
  load_order: './Alexandria-Archive/dante/Commentaries/LoadOrder'
};

// Migration statistics
const stats = {
  commentary_versions: 0,
  historical_texts: 0,
  annotations: 0,
  relationships: 0,
  migration_logs: 0,
  errors: []
};

/**
 * Parse LoadOrder file to understand commentary metadata
 */
async function parseLoadOrder() {
  console.log('📋 Parsing LoadOrder file...');
  
  try {
    const loadOrderPath = ALEXANDRIA_PATHS.load_order;
    const content = await fs.readFile(loadOrderPath, 'utf-8');
    
    const commentaries = [];
    const lines = content.split('\n');
    
    for (const line of lines) {
      if (line.startsWith('COMM=') && !line.startsWith('\\\\')) {
        const match = line.match(/COMM=(\w+)\s+LANG=([ILE]+)\s+FILES="([^"]+)"/);
        if (match) {
          const [, comm_name, languages, files] = match;
          commentaries.push({
            comm_name,
            languages: languages.split(''),
            files: files.split(' '),
            source_line: line
          });
        }
      }
    }
    
    console.log(`   ✅ Parsed ${commentaries.length} commentary definitions`);
    return commentaries;
  } catch (error) {
    console.error('❌ Error parsing LoadOrder:', error.message);
    return [];
  }
}

/**
 * Analyze Alexandria archive structure and map to version sources
 */
async function analyzeArchiveStructure() {
  console.log('🔍 Analyzing Alexandria archive structure...');
  
  const structure = {
    current: { path: ALEXANDRIA_PATHS.dante_commentaries, commentaries: [] },
    archives_1991: { path: ALEXANDRIA_PATHS.archives_1991, commentaries: [] },
    archives_post1991: { path: ALEXANDRIA_PATHS.archives_post1991, commentaries: [] },
    archives_main: { path: ALEXANDRIA_PATHS.archives_main, commentaries: [] }
  };
  
  for (const [key, info] of Object.entries(structure)) {
    try {
      const exists = await fs.access(info.path).then(() => true).catch(() => false);
      if (exists) {
        const entries = await fs.readdir(info.path, { withFileTypes: true });
        info.commentaries = entries
          .filter(entry => entry.isDirectory())
          .map(entry => entry.name)
          .filter(name => !name.startsWith('.'));
        
        console.log(`   📁 ${key}: ${info.commentaries.length} commentaries`);
      } else {
        console.log(`   ⚠️  ${key}: Directory not found`);
      }
    } catch (error) {
      console.log(`   ❌ ${key}: Error accessing directory`);
    }
  }
  
  return structure;
}

/**
 * Get or create commentary version record
 */
async function getOrCreateCommentaryVersion(baseCommentaryId, versionIdentifier, versionSource, originalPath, metadata = {}) {
  try {
    // Check if version already exists
    const { data: existing } = await supabase
      .from('alex_commentary_versions')
      .select('id')
      .eq('base_commentary_id', baseCommentaryId)
      .eq('version_identifier', versionIdentifier)
      .single();
    
    if (existing) {
      return existing.id;
    }
    
    // Create new version record
    const { data: newVersion, error } = await supabase
      .from('alex_commentary_versions')
      .insert({
        base_commentary_id: baseCommentaryId,
        version_identifier: versionIdentifier,
        version_source: versionSource,
        file_path: originalPath,
        provenance_info: metadata,
        editorial_status: 'archived'
      })
      .select('id')
      .single();
    
    if (error) throw error;
    
    stats.commentary_versions++;
    return newVersion.id;
  } catch (error) {
    console.error(`❌ Error creating commentary version:`, error.message);
    throw error;
  }
}

/**
 * Parse commentary description file (desc.e)
 */
async function parseDescriptionFile(filePath) {
  try {
    const content = await fs.readFile(filePath, 'utf-8');
    
    // Extract metadata from description file
    const lines = content.split('\n');
    const metadata = {
      title: '',
      author: '',
      bibliography: content,
      notes: []
    };
    
    // Simple parsing - look for title/author patterns
    for (const line of lines) {
      if (line.includes('Author:') || line.includes('AUTHOR:')) {
        metadata.author = line.split(':')[1]?.trim() || '';
      }
      if (line.includes('Title:') || line.includes('TITLE:')) {
        metadata.title = line.split(':')[1]?.trim() || '';
      }
    }
    
    return metadata;
  } catch (error) {
    return { bibliography: '', notes: [`Error reading file: ${error.message}`] };
  }
}

/**
 * Parse text file and extract content segments
 */
async function parseTextFile(filePath, cantica, cantoId) {
  try {
    const content = await fs.readFile(filePath, 'utf-8');
    
    // Simple text segmentation - split by lines or paragraphs
    const segments = [];
    const paragraphs = content.split('\n\n').filter(p => p.trim());
    
    let currentLine = 1;
    for (let i = 0; i < paragraphs.length; i++) {
      const paragraph = paragraphs[i].trim();
      if (paragraph) {
        const lineCount = paragraph.split('\n').length;
        segments.push({
          content: paragraph,
          start_line: currentLine,
          end_line: currentLine + lineCount - 1,
          text_type: 'commentary',
          original_encoding: 'utf-8'
        });
        currentLine += lineCount;
      }
    }
    
    return segments;
  } catch (error) {
    console.error(`❌ Error parsing text file ${filePath}:`, error.message);
    return [];
  }
}

/**
 * Migrate single commentary from Alexandria archive
 */
async function migrateCommentary(commentaryName, versionSource, archivePath) {
  console.log(`   📚 Migrating ${commentaryName} (${versionSource})...`);
  
  try {
    // Find matching modern commentary
    const { data: modernCommentary } = await supabase
      .from('dde_commentaries')
      .select('id')
      .eq('comm_name', commentaryName)
      .single();
    
    if (!modernCommentary) {
      console.log(`   ⚠️  No modern commentary found for ${commentaryName}, skipping`);
      return;
    }
    
    const commentaryPath = path.join(archivePath, commentaryName);
    const versionIdentifier = `${commentaryName}_${versionSource}`;
    
    // Create version record
    const versionId = await getOrCreateCommentaryVersion(
      modernCommentary.id,
      versionIdentifier,
      versionSource,
      commentaryPath,
      { migrated_from: 'alexandria_archive', original_path: commentaryPath }
    );
    
    // Parse description file if exists
    const descPath = path.join(commentaryPath, 'desc.e');
    const descExists = await fs.access(descPath).then(() => true).catch(() => false);
    if (descExists) {
      const descMetadata = await parseDescriptionFile(descPath);
      
      // Update version with description metadata
      await supabase
        .from('alex_commentary_versions')
        .update({
          editor_notes: descMetadata.bibliography,
          provenance_info: {
            ...{ migrated_from: 'alexandria_archive', original_path: commentaryPath },
            description_metadata: descMetadata
          }
        })
        .eq('id', versionId);
    }
    
    // Migrate text files by cantica
    const canticas = ['inf', 'purg', 'para'];
    for (const cantica of canticas) {
      const canticaPath = path.join(commentaryPath, cantica);
      const canticaExists = await fs.access(canticaPath).then(() => true).catch(() => false);
      
      if (canticaExists) {
        const files = await fs.readdir(canticaPath);
        const textFiles = files.filter(f => f.endsWith('.e') && /^\d+\.e$/.test(f));
        
        for (const file of textFiles) {
          const cantoId = parseInt(file.split('.')[0]);
          const filePath = path.join(canticaPath, file);
          const segments = await parseTextFile(filePath, cantica, cantoId);
          
          // Insert historical text segments
          for (const segment of segments) {
            try {
              await supabase
                .from('alex_texts_historical')
                .insert({
                  commentary_version_id: versionId,
                  cantica: cantica === 'inf' ? 'inferno' : cantica === 'purg' ? 'purgatorio' : 'paradiso',
                  canto_id: cantoId,
                  start_line: segment.start_line,
                  end_line: segment.end_line,
                  content: segment.content,
                  text_type: segment.text_type,
                  original_encoding: segment.original_encoding
                });
              
              stats.historical_texts++;
            } catch (insertError) {
              console.error(`   ❌ Error inserting text segment:`, insertError.message);
              stats.errors.push(`${commentaryName}/${cantica}/${file}: ${insertError.message}`);
            }
          }
        }
      }
    }
    
    // Log migration
    await supabase
      .from('alex_migration_log')
      .insert({
        original_path: commentaryPath,
        migrated_to_table: 'alex_commentary_versions',
        migrated_record_id: versionId,
        migration_status: 'completed',
        metadata: { commentary_name: commentaryName, version_source: versionSource }
      });
    
    stats.migration_logs++;
    console.log(`   ✅ Completed ${commentaryName} (${stats.historical_texts} text segments)`);
    
  } catch (error) {
    console.error(`   ❌ Error migrating ${commentaryName}:`, error.message);
    stats.errors.push(`${commentaryName}: ${error.message}`);
    
    // Log error
    await supabase
      .from('alex_migration_log')
      .insert({
        original_path: path.join(archivePath, commentaryName),
        migration_status: 'error',
        error_message: error.message,
        metadata: { commentary_name: commentaryName, version_source: versionSource }
      });
  }
}

/**
 * Create commentary relationships based on chronological data
 */
async function createCommentaryRelationships(loadOrderCommentaries) {
  console.log('🔗 Creating commentary relationships...');
  
  try {
    const { data: allCommentaries } = await supabase
      .from('dde_commentaries')
      .select('id, comm_name, created_at');
    
    // Create chronological relationships
    for (let i = 0; i < loadOrderCommentaries.length - 1; i++) {
      const current = loadOrderCommentaries[i];
      const next = loadOrderCommentaries[i + 1];
      
      const currentComm = allCommentaries.find(c => c.comm_name === current.comm_name);
      const nextComm = allCommentaries.find(c => c.comm_name === next.comm_name);
      
      if (currentComm && nextComm) {
        await supabase
          .from('alex_commentary_relationships')
          .insert({
            source_commentary_id: currentComm.id,
            target_commentary_id: nextComm.id,
            relationship_type: 'chronological_precedence',
            evidence_description: 'Based on LoadOrder sequence in Alexandria archive',
            confidence_level: 3
          });
        
        stats.relationships++;
      }
    }
    
    console.log(`   ✅ Created ${stats.relationships} chronological relationships`);
  } catch (error) {
    console.error('❌ Error creating relationships:', error.message);
  }
}

/**
 * Main migration function
 */
async function migrateAlexandriaArchive() {
  console.log('🚀 Starting Alexandria Archive Migration to Supabase...');
  console.log('=' .repeat(60));
  
  try {
    // Step 1: Parse LoadOrder for commentary metadata
    const loadOrderCommentaries = await parseLoadOrder();
    
    // Step 2: Analyze archive structure
    const archiveStructure = await analyzeArchiveStructure();
    
    // Step 3: Migrate historical commentaries by version source
    const migrationSources = [
      { key: 'archives_1991', versionSource: 'original_1991' },
      { key: 'archives_post1991', versionSource: 'post_1991' },
      { key: 'current', versionSource: 'alexandria_archive' }
    ];
    
    for (const { key, versionSource } of migrationSources) {
      const structure = archiveStructure[key];
      if (structure.commentaries.length > 0) {
        console.log(`\n📦 Migrating ${versionSource} commentaries...`);
        
        for (const commentaryName of structure.commentaries) {
          await migrateCommentary(commentaryName, versionSource, structure.path);
        }
      }
    }
    
    // Step 4: Create commentary relationships
    await createCommentaryRelationships(loadOrderCommentaries);
    
    // Step 5: Migration summary
    console.log('\n' + '=' .repeat(60));
    console.log('📊 ALEXANDRIA MIGRATION SUMMARY');
    console.log('=' .repeat(60));
    console.log(`✅ Commentary versions: ${stats.commentary_versions}`);
    console.log(`✅ Historical text segments: ${stats.historical_texts}`);
    console.log(`✅ Commentary relationships: ${stats.relationships}`);
    console.log(`✅ Migration logs: ${stats.migration_logs}`);
    
    if (stats.errors.length > 0) {
      console.log(`❌ Errors: ${stats.errors.length}`);
      console.log('\n🚨 ERROR DETAILS:');
      stats.errors.forEach((error, i) => {
        console.log(`${i + 1}. ${error}`);
      });
    } else {
      console.log('🎉 Migration completed successfully with no errors!');
    }
    
  } catch (error) {
    console.error('💥 Fatal migration error:', error);
    process.exit(1);
  }
}

// Run migration if called directly
if (require.main === module) {
  migrateAlexandriaArchive()
    .then(() => {
      console.log('\n✅ Alexandria archive migration completed');
      process.exit(0);
    })
    .catch((error) => {
      console.error('\n💥 Migration failed:', error);
      process.exit(1);
    });
}

module.exports = {
  migrateAlexandriaArchive,
  parseLoadOrder,
  analyzeArchiveStructure
};
