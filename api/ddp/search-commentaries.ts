// Next.js API Route: /api/ddp/search-commentaries
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';
import { withSecurity, sanitizeString, validateCantica } from '../../lib/security';

interface DDPSearchRequest {
  search_term: string;
  commentary_filter?: string;
  cantica_filter?: 'inferno' | 'purgatorio' | 'paradiso' | 'general';
  result_limit?: number;
}

async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { 
    search_term, 
    commentary_filter,
    cantica_filter,
    result_limit = 20 
  }: DDPSearchRequest = req.body;

  // Input validation and sanitization
  if (!search_term || typeof search_term !== 'string' || search_term.trim().length === 0) {
    return res.status(400).json({ error: 'Search term is required and must be a non-empty string' });
  }

  if (result_limit && (typeof result_limit !== 'number' || result_limit < 1 || result_limit > 100)) {
    return res.status(400).json({ error: 'Result limit must be a number between 1 and 100' });
  }

  if (cantica_filter && !validateCantica(cantica_filter)) {
    return res.status(400).json({ error: 'Invalid cantica filter. Must be: inferno, purgatorio, paradiso, or general' });
  }

  // Sanitize inputs
  const cleanSearchTerm = sanitizeString(search_term);
  const cleanCommentaryFilter = commentary_filter ? sanitizeString(commentary_filter) : null;

  if (cleanSearchTerm.length === 0) {
    return res.status(400).json({ error: 'Search term contains only invalid characters' });
  }

  const { data, error } = await supabase.rpc('ddp_search_commentaries', {
    search_term: cleanSearchTerm,
    commentary_filter: cleanCommentaryFilter,
    cantica_filter: cantica_filter || null,
    result_limit: Math.min(result_limit, 100) // Enforce max limit
  });

  if (error) {
    console.error('Supabase error:', error);
    return res.status(500).json({ error: 'Commentary search failed', details: error.message });
  }

  res.status(200).json({
    results: data || [],
    count: data?.length || 0,
    query: cleanSearchTerm,
    filters: {
      commentary_filter: cleanCommentaryFilter,
      cantica_filter
    }
  });
}

export default withSecurity(handler);
