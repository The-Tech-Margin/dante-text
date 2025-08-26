// Next.js API Route: /api/ddp/search-commentaries
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';

interface DDPSearchRequest {
  search_term: string;
  commentary_filter?: string;
  cantica_filter?: 'inferno' | 'purgatorio' | 'paradiso' | 'general';
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
      commentary_filter,
      cantica_filter,
      result_limit = 20 
    }: DDPSearchRequest = req.body;

    if (!search_term || search_term.trim().length === 0) {
      return res.status(400).json({ error: 'Search term is required' });
    }

    const { data, error } = await supabase.rpc('ddp_search_commentaries', {
      search_term: search_term.trim(),
      commentary_filter: commentary_filter || null,
      cantica_filter: cantica_filter || null,
      result_limit
    });

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ error: 'Commentary search failed', details: error.message });
    }

    res.status(200).json({
      results: data || [],
      count: data?.length || 0,
      query: search_term,
      filters: {
        commentary_filter,
        cantica_filter
      }
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
