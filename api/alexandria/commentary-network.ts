// Next.js API Route: /api/alexandria/commentary-network
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';

interface CommentaryNetworkRequest {
  commentary_id: string;
  max_depth?: number;
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { commentary_id, max_depth = 2 }: CommentaryNetworkRequest = req.body;

    if (!commentary_id || commentary_id.trim().length === 0) {
      return res.status(400).json({ error: 'Commentary ID is required' });
    }

    const { data, error } = await supabase.rpc('alex_get_commentary_network', {
      input_commentary_id: commentary_id,
      max_depth
    });

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ error: 'Failed to get commentary network', details: error.message });
    }

    res.status(200).json({
      results: data || [],
      count: data?.length || 0,
      commentary_id,
      max_depth
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
