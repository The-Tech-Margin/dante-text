// Next.js API Route: /api/unified/find-variants
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';

interface UnifiedFindVariantsRequest {
  cantica: 'inferno' | 'purgatorio' | 'paradiso' | 'general';
  canto: number;
  start_line: number;
  end_line: number;
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { cantica, canto, start_line, end_line }: UnifiedFindVariantsRequest = req.body;

    if (!cantica || !canto || start_line === undefined || end_line === undefined) {
      return res.status(400).json({ 
        error: 'Missing required fields: cantica, canto, start_line, end_line' 
      });
    }

    if (start_line > end_line) {
      return res.status(400).json({ error: 'start_line must be <= end_line' });
    }

    const { data, error } = await supabase.rpc('unified_find_passage_variants', {
      input_cantica: cantica,
      input_canto: canto,
      input_start_line: start_line,
      input_end_line: end_line
    });

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ error: 'Failed to find variants', details: error.message });
    }

    const results = data || [];
    const current_variants = results.filter((r: any) => !r.is_historical);
    const historical_variants = results.filter((r: any) => r.is_historical);

    res.status(200).json({
      results,
      current_variants,
      historical_variants,
      count: results.length,
      passage: { cantica, canto, start_line, end_line }
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
