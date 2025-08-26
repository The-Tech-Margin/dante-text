import { NextApiRequest, NextApiResponse } from 'next';

// Input sanitization
export const sanitizeString = (input: string): string => {
  if (typeof input !== 'string') return '';
  return input.trim().replace(/[<>\"'&]/g, '');
};

// Validate cantica type
export const validateCantica = (cantica: any): cantica is 'inferno' | 'purgatorio' | 'paradiso' | 'general' => {
  return ['inferno', 'purgatorio', 'paradiso', 'general'].includes(cantica);
};

// Validate canto number
export const validateCanto = (canto: any): boolean => {
  const num = parseInt(canto);
  return !isNaN(num) && num >= 1 && num <= 100;
};

// Validate line numbers
export const validateLine = (line: any): boolean => {
  const num = parseInt(line);
  return !isNaN(num) && num >= 1 && num <= 200;
};

// Rate limiting store (in-memory for simplicity)
const rateLimit = new Map<string, { count: number; resetTime: number }>();

export const checkRateLimit = (req: NextApiRequest): boolean => {
  const clientIP = req.headers['x-forwarded-for'] as string || 
                   req.headers['x-real-ip'] as string || 
                   req.socket.remoteAddress || 
                   'unknown';
  
  const now = Date.now();
  const windowMs = 60000; // 1 minute
  const maxRequests = 30; // 30 requests per minute
  
  const clientData = rateLimit.get(clientIP);
  
  if (!clientData || now > clientData.resetTime) {
    rateLimit.set(clientIP, { count: 1, resetTime: now + windowMs });
    return true;
  }
  
  if (clientData.count >= maxRequests) {
    return false;
  }
  
  clientData.count++;
  return true;
};

// CORS headers for API security
export const setCorsHeaders = (res: NextApiResponse): void => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Access-Control-Max-Age', '86400');
};

// Security middleware wrapper
export const withSecurity = (handler: (req: NextApiRequest, res: NextApiResponse) => Promise<void>) => {
  return async (req: NextApiRequest, res: NextApiResponse) => {
    // Set CORS headers
    setCorsHeaders(res);
    
    // Handle preflight requests
    if (req.method === 'OPTIONS') {
      return res.status(200).end();
    }
    
    // Only allow POST requests
    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed. Only POST requests are supported.' });
    }
    
    // Rate limiting
    if (!checkRateLimit(req)) {
      return res.status(429).json({ error: 'Too many requests. Please try again later.' });
    }
    
    // Content-Type validation
    if (req.headers['content-type'] !== 'application/json') {
      return res.status(400).json({ error: 'Content-Type must be application/json' });
    }
    
    // Body validation
    if (!req.body || typeof req.body !== 'object') {
      return res.status(400).json({ error: 'Valid JSON body required' });
    }
    
    try {
      await handler(req, res);
    } catch (error) {
      console.error('API handler error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  };
};
