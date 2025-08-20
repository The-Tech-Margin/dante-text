// Next.js API Route: /api/analysis/compare-passage
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';

interface PassageComparisonRequest {
  cantica: 'inferno' | 'purgatorio' | 'paradiso';
  canto: number;
  start_line: number;
  end_line: number;
}

interface CommentaryComparison {
  commentary_id: string;
  commentary_name: string;
  author: string;
  language: string;
  text_excerpt: string;
  coverage_score: number;
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { cantica, canto, start_line, end_line }: PassageComparisonRequest = req.body;

    if (!cantica || !canto || start_line === undefined || end_line === undefined) {
      return res.status(400).json({ 
        error: 'Missing required fields: cantica, canto, start_line, end_line' 
      });
    }

    if (start_line > end_line) {
      return res.status(400).json({ 
        error: 'start_line must be less than or equal to end_line' 
      });
    }

    const { data, error } = await supabase.rpc('compare_commentaries_by_passage', {
      input_cantica: cantica,
      input_canto: canto,
      input_start_line: start_line,
      input_end_line: end_line
    });

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ 
        error: 'Comparison failed', 
        details: error.message 
      });
    }

    res.status(200).json({
      passage: {
        cantica,
        canto,
        start_line,
        end_line
      },
      comparisons: data || [],
      count: data?.length || 0
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
