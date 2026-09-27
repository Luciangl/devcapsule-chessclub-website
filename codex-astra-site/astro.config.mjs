import { defineConfig } from 'astro/config';
export default defineConfig({
  site: 'https://smartgalati-test3.mycodespace.ai',
  output: 'static',
  trailingSlash: 'always',
  i18n: { defaultLocale: 'ro', locales: ['ro', 'en'], routing: { prefixDefaultLocale: false } },
});
