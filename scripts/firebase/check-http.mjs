// No cloud mutation. Verify HTTPS and the multi-page behavior relied on by Rocada.
const origin = process.argv[2];
const canonicalOrigin = process.argv[3] || origin;
if (!origin) throw new Error('Usage: node check-http.mjs https://PUBLIC_HOSTNAME [EXPECTED_CANONICAL_ORIGIN]');
for (const [path, expected] of [['/', 200], ['/contact/', 200], ['/galerie/', 200], ['/__firebase_missing_page_check__/', 404]]) {
  const response = await fetch(new URL(path, origin), { signal: AbortSignal.timeout(20000), redirect: 'manual' });
  if (response.status !== expected) throw new Error(`${path}: expected ${expected}, got ${response.status}`);
  if (!response.headers.get('content-type')?.includes('text/html')) throw new Error(`${path}: expected HTML`);
  const body = await response.text();
  if (path === '/' && !body.includes(`rel="canonical" href="${canonicalOrigin}/"`)) throw new Error('Home canonical URL does not match the configured public URL');
  console.log(`${response.status} ${path}`);
}
const redirect = await fetch(new URL('/contact', origin), { signal: AbortSignal.timeout(20000), redirect: 'manual' });
if (![301, 302, 307, 308].includes(redirect.status) || new URL(redirect.headers.get('location'), origin).pathname !== '/contact/') {
  throw new Error('Expected /contact to redirect to /contact/');
}
console.log('Trailing-slash redirect verified.');
