// Next.js API Route: /api/alexandria/compare-versions
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';
import { withSecurity, sanitizeString } from '../../lib/security';

interface CompareVersionsRequest {
  commentary_name: string;
}

async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { commentary_name }: CompareVersionsRequest = req.body;

  if (!commentary_name || typeof commentary_name !== 'string' || commentary_name.trim().length === 0) {
    return res.status(400).json({ error: 'Commentary name is required and must be a non-empty string' });
  }

  const cleanCommentaryName = sanitizeString(commentary_name);
  
  if (cleanCommentaryName.length === 0) {
    return res.status(400).json({ error: 'Commentary name contains only invalid characters' });
  }

  const { data, error } = await supabase.rpc('alex_compare_commentary_versions', {
    input_commentary_name: cleanCommentaryName
  });

  if (error) {
    console.error('Supabase error:', error);
    return res.status(500).json({ error: 'Failed to compare versions', details: error.message });
  }

  res.status(200).json({
    results: data || [],
    count: data?.length || 0,
    commentary_name: cleanCommentaryName
  });
}

export default withSecurity(handler);
