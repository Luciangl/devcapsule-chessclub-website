import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  site: 'https://smartgalati-test.mycodespace.ai',
  integrations: [
    tailwind({
      applyBaseStyles: true,
    }),
  ],
  i18n: {
    defaultLocale: 'ro',
    locales: ['ro', 'en'],
    routing: {
      prefixDefaultLocale: false,
    },
  },
});
