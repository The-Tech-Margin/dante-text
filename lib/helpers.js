const { supabase } = require('./supabase');

/**
 * Get commentary by name or ID
 * @param {string} identifier - Commentary name or comm_id
 * @returns {Object|null} Commentary data
 */
async function getCommentary(identifier) {
  const { data, error } = await supabase
    .from('dde_commentaries')
    .select('*')
    .or(`comm_name.eq.${identifier},comm_id.eq.${identifier}`)
    .single();

  if (error) {
    console.error('Error fetching commentary:', error.message);
    return null;
  }

  return data;
}

/**
 * Get texts for a specific commentary and cantica
 * @param {string} commentaryId - Commentary UUID
 * @param {string} cantica - Cantica name (optional)
 * @param {number} canto - Canto number (optional)
 * @returns {Array} Array of text records
 */
async function getTexts(commentaryId, cantica = null, canto = null) {
  let query = supabase
    .from('dde_texts')
    .select('*')
    .eq('commentary_id', commentaryId)
    .order('doc_id');

  if (cantica) {
    query = query.eq('cantica', cantica);
  }

  if (canto !== null) {
    query = query.eq('canto_id', canto);
  }

  const { data, error } = await query;

  if (error) {
    console.error('Error fetching texts:', error.message);
    return [];
  }

  return data || [];
}

/**
 * Search texts by content
 * @param {string} searchTerm - Search term
 * @param {Object} filters - Optional filters (cantica, commentary_id, etc.)
 * @returns {Array} Array of matching text records
 */
async function searchTexts(searchTerm, filters = {}) {
  let query = supabase
    .from('dde_texts')
    .select(`
      *,
      dde_commentaries!inner(comm_name, comm_author)
    `)
    .textSearch('content', searchTerm)
    .order('doc_id');

  // Apply filters
  if (filters.cantica) {
    query = query.eq('cantica', filters.cantica);
  }
  if (filters.commentary_id) {
    query = query.eq('commentary_id', filters.commentary_id);
  }
  if (filters.canto_id) {
    query = query.eq('canto_id', filters.canto_id);
  }

  const { data, error } = await query;

  if (error) {
    console.error('Error searching texts:', error.message);
    return [];
  }

  return data || [];
}

/**
 * Get database statistics
 * @returns {Object} Database statistics
 */
async function getStats() {
  const stats = {};

  // Commentary count
  const { count: commentaryCount } = await supabase
    .from('dde_commentaries')
    .select('*', { count: 'exact', head: true });

  // Text count
  const { count: textCount } = await supabase
    .from('dde_texts')
    .select('*', { count: 'exact', head: true });

  // Cantica distribution
  const { data: canticaCounts } = await supabase
    .from('dde_texts')
    .select('cantica')
    .group('cantica');

  stats.commentaries = commentaryCount || 0;
  stats.texts = textCount || 0;
  stats.canticas = canticaCounts || [];

  return stats;
}

/**
 * Clean up duplicate or invalid records
 * @returns {Object} Cleanup results
 */
async function cleanupData() {
  const results = {
    duplicatesRemoved: 0,
    invalidRecordsFixed: 0,
    errors: []
  };

  try {
    // Find and remove duplicate doc_ids (keep first occurrence)
    const { data: duplicates } = await supabase
      .rpc('find_and_remove_duplicates');

    if (duplicates) {
      results.duplicatesRemoved = duplicates.length;
    }

    // Fix invalid line ranges (where end_line < start_line)
    const { data: invalidRanges } = await supabase
      .from('dde_texts')
      .select('id, start_line, end_line')
      .filter('end_line', 'lt', 'start_line');

    if (invalidRanges && invalidRanges.length > 0) {
      for (const record of invalidRanges) {
        await supabase
          .from('dde_texts')
          .update({ end_line: record.start_line })
          .eq('id', record.id);
      }
      results.invalidRecordsFixed = invalidRanges.length;
    }

  } catch (error) {
    results.errors.push(error.message);
  }

  return results;
}

/**
 * Export commentary data as JSON
 * @param {string} commentaryName - Commentary name to export
 * @returns {Object} Exported data
 */
async function exportCommentary(commentaryName) {
  const commentary = await getCommentary(commentaryName);
  if (!commentary) {
    throw new Error(`Commentary "${commentaryName}" not found`);
  }

  const texts = await getTexts(commentary.id);

  return {
    commentary,
    texts,
    exported_at: new Date().toISOString(),
    total_texts: texts.length
  };
}

/**
 * Batch update text records
 * @param {Array} updates - Array of {id, updates} objects
 * @returns {Array} Results of updates
 */
async function batchUpdateTexts(updates) {
  const results = [];

  for (const update of updates) {
    const { error } = await supabase
      .from('dde_texts')
      .update(update.updates)
      .eq('id', update.id);

    results.push({
      id: update.id,
      success: !error,
      error: error?.message
    });
  }

  return results;
}

module.exports = {
  getCommentary,
  getTexts,
  searchTexts,
  getStats,
  cleanupData,
  exportCommentary,
  batchUpdateTexts
};
