import { defineConfig } from 'astro/config';

// Static output only. Firebase deployment overrides site with astro build --site.
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
