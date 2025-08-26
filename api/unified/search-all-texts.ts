// Next.js API Route: /api/unified/search-all-texts
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';
import { withSecurity, sanitizeString } from '../../lib/security';

interface UnifiedSearchRequest {
  search_term: string;
  include_historical?: boolean;
  include_current?: boolean;
  commentary_filter?: string;
  result_limit?: number;
}

async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { 
    search_term, 
    include_historical = true,
    include_current = true,
    commentary_filter,
    result_limit = 50 
  }: UnifiedSearchRequest = req.body;

  // Input validation and sanitization
  if (!search_term || typeof search_term !== 'string' || search_term.trim().length === 0) {
    return res.status(400).json({ error: 'Search term is required and must be a non-empty string' });
  }

  if (result_limit && (typeof result_limit !== 'number' || result_limit < 1 || result_limit > 100)) {
    return res.status(400).json({ error: 'Result limit must be a number between 1 and 100' });
  }

  // Sanitize inputs
  const cleanSearchTerm = sanitizeString(search_term);
  const cleanCommentaryFilter = commentary_filter ? sanitizeString(commentary_filter) : null;

  if (cleanSearchTerm.length === 0) {
    return res.status(400).json({ error: 'Search term contains only invalid characters' });
  }

  const { data, error } = await supabase.rpc('unified_search_all_texts', {
    search_term: cleanSearchTerm,
    include_historical,
    include_current,
    commentary_filter: cleanCommentaryFilter,
    result_limit: Math.min(result_limit, 100) // Enforce max limit
  });

  if (error) {
    console.error('Supabase error:', error);
    return res.status(500).json({ error: 'Unified search failed', details: error.message });
  }

  const results = data || [];
  const historical_count = results.filter((r: any) => r.is_historical).length;
  const current_count = results.filter((r: any) => !r.is_historical).length;

  res.status(200).json({
    results,
    count: results.length,
    historical_count,
    current_count,
    query: cleanSearchTerm,
    filters: {
      include_historical,
      include_current,
      commentary_filter: cleanCommentaryFilter
    }
  });
}

export default withSecurity(handler);
