// Next.js API Route: /api/alexandria/compare-versions
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';

interface CompareVersionsRequest {
  commentary_name: string;
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { commentary_name }: CompareVersionsRequest = req.body;

    if (!commentary_name || commentary_name.trim().length === 0) {
      return res.status(400).json({ error: 'Commentary name is required' });
    }

    const { data, error } = await supabase.rpc('alex_compare_commentary_versions', {
      input_commentary_name: commentary_name.trim()
    });

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ error: 'Failed to compare versions', details: error.message });
    }

    res.status(200).json({
      results: data || [],
      count: data?.length || 0,
      commentary_name
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
