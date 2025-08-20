// Next.js API Route: /api/navigation/tree
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';

interface NavigationNode {
  cantica: 'inferno' | 'purgatorio' | 'paradiso';
  canto_id: number;
  text_count: number;
  line_range: string;
  has_texts: boolean;
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { commentary_id } = req.query;

    if (!commentary_id || typeof commentary_id !== 'string') {
      return res.status(400).json({ 
        error: 'commentary_id query parameter is required' 
      });
    }

    const { data, error } = await supabase.rpc('get_navigation_tree', {
      input_commentary_id: commentary_id
    });

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ 
        error: 'Navigation tree fetch failed', 
        details: error.message 
      });
    }

    // Group results by cantica for hierarchical structure
    const groupedData = (data || []).reduce((acc: any, node: NavigationNode) => {
      if (!acc[node.cantica]) {
        acc[node.cantica] = [];
      }
      acc[node.cantica].push({
        canto_id: node.canto_id,
        text_count: node.text_count,
        line_range: node.line_range,
        has_texts: node.has_texts
      });
      return acc;
    }, {});

    res.status(200).json({
      commentary_id,
      navigation_tree: groupedData,
      total_canticas: Object.keys(groupedData).length,
      total_cantos: data?.length || 0
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
