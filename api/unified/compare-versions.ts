// Next.js API Route: /api/unified/compare-versions
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';

interface UnifiedCompareVersionsRequest {
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
    const { commentary_name }: UnifiedCompareVersionsRequest = req.body;

    if (!commentary_name || commentary_name.trim().length === 0) {
      return res.status(400).json({ error: 'Commentary name is required' });
    }

    const { data, error } = await supabase.rpc('unified_compare_commentary_versions', {
      input_commentary_name: commentary_name.trim()
    });

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ error: 'Failed to compare versions', details: error.message });
    }

    const results = data || [];
    const current_versions = results.filter((r: any) => r.source_system === 'ddp_current');
    const historical_versions = results.filter((r: any) => r.source_system === 'alex_historical');

    res.status(200).json({
      results,
      current_versions,
      historical_versions,
      commentary_name,
      version_count: results.length
    });

  } catch (error) {
    console.error('API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
