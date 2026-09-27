/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}',
    './content/**/*.{md,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        chess: {
          dark: '#0f172a',
          surface: '#1e293b',
          border: '#334155',
          gold: '#d97706',
          'gold-light': '#f59e0b',
          'gold-hover': '#b45309',
          ivory: '#fcfaf6',
          cream: '#f3ece2',
          muted: '#64748b',
        },
      },
      fontFamily: {
        sans: ['system-ui', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
