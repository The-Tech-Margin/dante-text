// Next.js API Route: /api/alexandria/scholarly-search
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';

interface ScholarlySearchRequest {
  search_term: string;
  include_historical?: boolean;
  version_filter?: 'current_2024' | 'alexandria_archive' | 'digitaldante_1996' | 'princeton_dante_project';
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
      version_filter, 
      result_limit = 20 
    }: ScholarlySearchRequest = req.body;

    if (!search_term || search_term.trim().length === 0) {
      return res.status(400).json({ error: 'Search term is required' });
    }

    const { data, error } = await supabase.rpc('alex_scholarly_search_all_versions', {
      search_term: search_term.trim(),
      include_historical,
      version_filter: version_filter || null,
      result_limit
    });

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ error: 'Scholarly search failed', details: error.message });
    }

    res.status(200).json({
      results: data || [],
      count: data?.length || 0,
      query: search_term,
      filters: {
        include_historical,
        version_filter
      }
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
