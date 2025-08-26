// Next.js API Route: /api/ddp/find-passages
import { NextApiRequest, NextApiResponse } from 'next';
import { supabase } from '../../lib/supabase';
import { withSecurity, validateCantica, validateCanto, validateLine } from '../../lib/security';

interface DDPFindPassagesRequest {
  cantica: 'inferno' | 'purgatorio' | 'paradiso' | 'general';
  canto: number;
  start_line: number;
  end_line: number;
}

async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { cantica, canto, start_line, end_line }: DDPFindPassagesRequest = req.body;

  // Input validation
  if (!validateCantica(cantica)) {
    return res.status(400).json({ error: 'Invalid cantica. Must be: inferno, purgatorio, paradiso, or general' });
  }

  if (!validateCanto(canto)) {
    return res.status(400).json({ error: 'Invalid canto. Must be a number between 1 and 100' });
  }

  if (!validateLine(start_line) || !validateLine(end_line)) {
    return res.status(400).json({ error: 'Invalid line numbers. Must be between 1 and 200' });
  }

  if (start_line > end_line) {
    return res.status(400).json({ error: 'Start line must be less than or equal to end line' });
  }

  const { data, error } = await supabase.rpc('ddp_find_passages', {
    input_cantica: cantica,
    input_canto: parseInt(canto.toString()),
    input_start_line: parseInt(start_line.toString()),
    input_end_line: parseInt(end_line.toString())
  });

  if (error) {
    console.error('Supabase error:', error);
    return res.status(500).json({ error: 'Failed to find passages', details: error.message });
  }

  res.status(200).json({
    results: data || [],
    count: data?.length || 0,
    passage: { cantica, canto, start_line, end_line }
  });
}

export default withSecurity(handler);
