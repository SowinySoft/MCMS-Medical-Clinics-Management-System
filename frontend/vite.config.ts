import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Dev proxy to the Django/Daphne backend (port 8010) so the SPA talks to
// /api and /ws without CORS. In production the frontend is served behind the
// same origin (nginx) or as static files.
export default defineConfig({
  base: '/',
  plugins: [react()],
  build: {
    // Versioned asset dir so each production build gets new URLs. This avoids
    // Cloudflare/CDN re-serving stale cached .js/.css with the wrong MIME type
    // after a deploy (the old URL stays poisoned in the edge cache).
    assetsDir: 'assets/v2',
    outDir: 'dist',
  },
  server: {
    port: 5173,
    proxy: {
      '/api': { target: 'http://127.0.0.1:8010', changeOrigin: true },
      '/ws': { target: 'ws://127.0.0.1:8010', ws: true },
    },
  },
})
