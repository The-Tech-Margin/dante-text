// Next.js API Route: /api/search/commentaries
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';

interface CommentarySearchRequest {
  search_term: string;
  lang_filter?: 'latin' | 'italian' | 'english';
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
    const { search_term, lang_filter, limit = 20 }: CommentarySearchRequest = req.body;

    if (!search_term || search_term.trim().length === 0) {
      return res.status(400).json({ error: 'Search term is required' });
    }

    const { data, error } = await supabase.rpc('search_commentaries_ranked', {
      search_term: search_term.trim(),
      lang_filter: lang_filter || null,
      limit_count: limit
    });

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ error: 'Search failed', details: error.message });
    }

    res.status(200).json({
      results: data || [],
      count: data?.length || 0,
      query: search_term
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
