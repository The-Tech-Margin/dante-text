// Next.js API Route: /api/commentary/[id]/stats
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../../lib/supabase';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { id } = req.query;

    if (!id || typeof id !== 'string') {
      return res.status(400).json({ error: 'Commentary ID is required' });
    }

    // Validate UUID format
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(id)) {
      return res.status(400).json({ error: 'Invalid commentary ID format' });
    }

    const { data, error } = await supabase.rpc('get_commentary_stats', {
      commentary_id: id
    });

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ error: 'Failed to get commentary stats', details: error.message });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({ error: 'Commentary not found or has no texts' });
    }

    res.status(200).json({
      commentary_id: id,
      stats: data[0],
      generated_at: new Date().toISOString()
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
