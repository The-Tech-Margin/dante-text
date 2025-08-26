/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    // Enable static exports if needed for API-only deployment
    outputStandalone: true,
  },
  // API routes configuration
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: '/api/:path*',
      },
    ];
  },
  // Environment variables
  env: {
    SUPABASE_URL: process.env.SUPABASE_URL,
    SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY,
  },
};

module.exports = nextConfig;
