import type { APIRoute } from 'astro';

// Generated so the allowed prefix follows the build's base path (root on GCS and
// Firebase, /<repository>/ on a GitHub Pages project site). No sitemap is built.
export const GET: APIRoute = () =>
  new Response(`User-agent: *\nAllow: ${import.meta.env.BASE_URL}\n`, {
    headers: { 'Content-Type': 'text/plain; charset=utf-8' },
  });
