// Next.js API Route: /api/search/highlights
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';

interface HighlightSearchRequest {
  search_term: string;
  commentary_filter?: string;
  limit?: number;
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { search_term, commentary_filter, limit = 20 }: HighlightSearchRequest = req.body;

    if (!search_term || search_term.trim().length === 0) {
      return res.status(400).json({ error: 'Search term is required' });
    }

    const { data, error } = await supabase.rpc('search_with_highlights', {
      search_term: search_term.trim(),
      commentary_filter: commentary_filter || null,
      limit_count: limit
    });

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ error: 'Highlight search failed', details: error.message });
    }

    res.status(200).json({
      results: data || [],
      count: data?.length || 0,
      query: search_term,
      commentary_filter
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
