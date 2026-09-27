import { defineConfig } from 'astro/config';

// Static output only: the site is served from a Google Cloud Storage bucket.
export default defineConfig({
  site: 'https://smartgalati-test4.mycodespace.ai',
  output: 'static',
  trailingSlash: 'always',
  build: { format: 'directory' },
  i18n: {
    defaultLocale: 'ro',
    locales: ['ro'],
    routing: { prefixDefaultLocale: false },
  },
  devToolbar: { enabled: false },
});
