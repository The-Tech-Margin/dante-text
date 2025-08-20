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
 * Create or get commentary version record
 */
async function getOrCreateCommentaryVersion(commentaryName, versionIdentifier, versionSource) {
  try {
    // First find the base commentary by name (logical linking)
    const { data: baseCommentary, error: baseError } = await supabase
      .from('dde_commentaries')
      .select('id, comm_name')
      .eq('comm_name', commentaryName)
      .single();

    if (baseError || !baseCommentary) {
      console.warn(`⚠️  Base commentary not found: ${commentaryName}`);
      return null;
    }

    // Check if version already exists
    const { data: existingVersion } = await supabase
      .from('alex_commentary_versions')
      .select('id')
      .eq('base_commentary_id', baseCommentary.id)
      .eq('version_identifier', versionIdentifier)
      .single();

    if (existingVersion) {
      return existingVersion.id;
    }

    // Create new version record
    const { data: newVersion, error: insertError } = await supabase
      .from('alex_commentary_versions')
      .insert({
        base_commentary_id: baseCommentary.id,
        version_identifier: versionIdentifier,
        version_source: versionSource,
        editorial_status: 'archived',
        editor_notes: `Migrated from Alexandria Archive: ${versionIdentifier}`,
        date_created: new Date().toISOString()
      })
      .select('id')
      .single();

    if (insertError) {
      console.error(`❌ Error creating commentary version: ${insertError.message}`);
      return null;
    }

    console.log(`✅ Created commentary version: ${versionIdentifier}`);
    return newVersion.id;

  } catch (error) {
    console.error(`❌ Error in getOrCreateCommentaryVersion: ${error.message}`);
    return null;
  }
}

/**
 * Process historical text segments using logical linking
 */
async function processHistoricalTexts(commentaryVersionId, commentaryName, textFiles, basePath) {
  let processedCount = 0;
  const errors = [];

  for (const fileName of textFiles) {
    try {
      const filePath = path.join(basePath, fileName);
      const content = await fs.readFile(filePath, 'utf8');
      
      // Parse DDP format
      const segments = parseDDPContent(content, fileName);
      
      for (const segment of segments) {
        // Use logical linking instead of foreign key constraints
        const { error: insertError } = await supabase
          .from('alex_texts_historical')
          .insert({
            commentary_version_id: commentaryVersionId,
            commentary_name: commentaryName, // Logical link to dde_commentaries.comm_name
            cantica: segment.cantica,
            canto_id: segment.canto_id,
            start_line: segment.start_line,
            end_line: segment.end_line,
            content: segment.content,
            text_type: segment.text_type,
            text_language: segment.language || 'italian',
            original_file_path: `${basePath}/${fileName}`,
            variant_notes: segment.notes || null,
            editorial_changes: segment.editorialChanges || {},
            modern_equivalent_found: false, // Will be computed later
            similarity_score: null // Will be computed later
          });

        if (insertError) {
          errors.push(`${fileName}: ${insertError.message}`);
          continue;
        }

        processedCount++;
      }

    } catch (error) {
      errors.push(`${fileName}: ${error.message}`);
    }
  }

  return { processedCount, errors };
}

/**
 * Compute modern text equivalents and similarities (post-migration)
 */
async function computeModernEquivalents() {
  console.log('\n📊 Computing modern text equivalents and similarities...');
  
  try {
    // Get all historical texts without modern equivalents
    const { data: historicalTexts } = await supabase
      .from('alex_texts_historical')
      .select('id, commentary_name, cantica, canto_id, start_line, end_line, content')
      .eq('modern_equivalent_found', false);

    if (!historicalTexts?.length) {
      console.log('No historical texts to process for modern equivalents');
      return;
    }

    let matchedCount = 0;

    for (const historical of historicalTexts) {
      // Find potential modern equivalents using logical linking
      const { data: modernTexts } = await supabase
        .from('dde_texts')
        .select('id, content')
        .eq('cantica', historical.cantica)
        .eq('canto_id', historical.canto_id)
        .gte('start_line', historical.start_line - 2) // Allow some line number drift
        .lte('end_line', historical.end_line + 2)
        .eq('dde_commentaries.comm_name', historical.commentary_name);

      if (modernTexts?.length > 0) {
        // Find best match using simple content similarity
        let bestMatch = null;
        let bestSimilarity = 0;

        for (const modern of modernTexts) {
          const similarity = calculateContentSimilarity(historical.content, modern.content);
          if (similarity > bestSimilarity) {
            bestSimilarity = similarity;
            bestMatch = modern;
          }
        }

        // Update historical text with modern equivalent info
        if (bestMatch && bestSimilarity > 0.3) { // 30% similarity threshold
          await supabase
            .from('alex_texts_historical')
            .update({
              modern_equivalent_found: true,
              similarity_score: Math.round(bestSimilarity * 100) / 100
            })
            .eq('id', historical.id);

          matchedCount++;
        }
      }
    }

    console.log(`✅ Matched ${matchedCount}/${historicalTexts.length} historical texts with modern equivalents`);

  } catch (error) {
    console.error(`❌ Error computing modern equivalents: ${error.message}`);
  }
}

/**
 * Simple content similarity calculation
 */
function calculateContentSimilarity(text1, text2) {
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
      commentaryName,
      versionIdentifier,
      versionSource
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
                  commentary_name: commentaryName, // Logical link to dde_commentaries.comm_name
                  cantica: cantica === 'inf' ? 'inferno' : cantica === 'purg' ? 'purgatorio' : 'paradiso',
                  canto_id: cantoId,
                  start_line: segment.start_line,
                  end_line: segment.end_line,
                  content: segment.content,
                  text_type: segment.text_type,
                  text_language: segment.language || 'italian',
                  original_file_path: `${canticaPath}/${file}`,
                  variant_notes: segment.notes || null,
                  editorial_changes: segment.editorialChanges || {},
                  modern_equivalent_found: false, // Will be computed later
                  similarity_score: null // Will be computed later
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
