/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable standalone output for Docker deployment
  // This creates a self-contained version of the app that includes
  // all necessary dependencies and can run without node_modules
  output: 'standalone',

  // TypeScript configuration - skip errors during build
  // This is useful for development but consider removing in production
  typescript: {
    ignoreBuildErrors: true,
  },

  // Experimental features that might be needed for standalone builds
  experimental: {
    // Ensure standalone builds work correctly with newer Next.js versions
    outputFileTracingRoot: undefined,
  },

  // Ensure static assets are handled correctly
  trailingSlash: false,

  // Configure image optimization for containerized environments
  images: {
    // Disable image optimization in standalone builds to avoid issues
    unoptimized: true,
  },
};

module.exports = nextConfig;
