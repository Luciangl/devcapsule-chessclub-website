import { readFileSync, writeFileSync, readdirSync, lstatSync, copyFileSync, mkdirSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export function publicOrigin(value) {
  // Hosting custom domains are HTTPS origins, not URLs with paths or credentials.
  if (!/^https:\/\/[a-z0-9.-]+\/?$/i.test(value)) {
    throw new Error('FIREBASE_SITE_URL must be an HTTPS domain with no port, path, credentials, query, or fragment.');
  }
  const url = new URL(value);
  if (!url.hostname.includes('.') || url.hostname.length > 253 ||
      !url.hostname.split('.').every(label => /^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/i.test(label))) {
    throw new Error('FIREBASE_SITE_URL must contain a valid domain name.');
  }
  return url.origin;
}

export function assertUnbilled(info, project) {
  if (!info || info.projectId !== project || info.billingEnabled !== false ||
      (info.billingAccountName !== undefined && info.billingAccountName !== '')) {
    throw new Error('Refusing deployment: expected this exact project with billingEnabled=false and no linked billing account. Use a separate Firebase Spark project.');
  }
}

export function prepare(project, source, destination) {
  if (!/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/.test(project)) throw new Error('Invalid project ID');
  if (!lstatSync(source).isDirectory() || lstatSync(source).isSymbolicLink()) throw new Error('dist must be a real directory');
  for (const page of ['index.html', '404.html']) {
    if (!lstatSync(join(source, page)).isFile()) throw new Error(`Missing static ${page}`);
  }
  // Refuse symlinks and hidden files instead of following them into source/secrets.
  const files = [];
  function walk(path, relative = '') {
    for (const name of readdirSync(path)) {
      if (name.startsWith('.')) throw new Error(`Hidden build artifact: ${join(relative, name)}`);
      const abs = join(path, name), rel = join(relative, name), stat = lstatSync(abs);
      if (stat.isSymbolicLink()) throw new Error(`Symlink in static build: ${rel}`);
      if (stat.isDirectory()) walk(abs, rel);
      else if (stat.isFile()) files.push(rel);
      else throw new Error(`Not a regular file: ${rel}`);
    }
  }
  walk(source);
  const out = join(destination, 'public');
  for (const rel of files) {
    const target = join(out, rel);
    mkdirSync(resolve(target, '..'), { recursive: true });
    copyFileSync(join(source, rel), target);
  }
  // Construct from a small allowlist; never merge arbitrary source firebase.json.
  const config = {
    hosting: {
      site: project,
      public: 'public',
      ignore: ['firebase.json', '**/.*', '**/node_modules/**'],
      cleanUrls: true,
      trailingSlash: true,
      headers: [
        { source: '**', headers: [{ key: 'Cache-Control', value: 'public, max-age=300, must-revalidate' }] },
        { source: '/_astro/**', headers: [{ key: 'Cache-Control', value: 'public, max-age=31536000, immutable' }] },
      ],
    },
  };
  writeFileSync(join(destination, 'firebase.json'), JSON.stringify(config, null, 2) + '\n');
  console.log(`Prepared ${files.length} static files for Hosting site ${project}`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    const [command, project, source, destination] = process.argv.slice(2);
    if (command === 'billing') {
      assertUnbilled(JSON.parse(readFileSync(0, 'utf8')), project);
      console.log(`Verified unbilled project: ${project}`);
    } else if (command === 'origin') console.log(publicOrigin(project));
    else if (command === 'prepare') prepare(project, source, destination);
    else throw new Error('Expected billing, origin, or prepare');
  } catch (error) { console.error(error.message); process.exitCode = 1; }
}
