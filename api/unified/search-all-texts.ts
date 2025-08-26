// Next.js API Route: /api/unified/search-all-texts
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';

interface UnifiedSearchRequest {
  search_term: string;
  include_historical?: boolean;
  include_current?: boolean;
  commentary_filter?: string;
  result_limit?: number;
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { 
      search_term, 
      include_historical = true,
      include_current = true,
      commentary_filter,
      result_limit = 50 
    }: UnifiedSearchRequest = req.body;

    if (!search_term || search_term.trim().length === 0) {
      return res.status(400).json({ error: 'Search term is required' });
    }

    const { data, error } = await supabase.rpc('unified_search_all_texts', {
      search_term: search_term.trim(),
      include_historical,
      include_current,
      commentary_filter: commentary_filter || null,
      result_limit
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
      query: search_term,
      filters: {
        include_historical,
        include_current,
        commentary_filter
      }
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
