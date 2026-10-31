/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        brand: { 50: '#eef7ff', 100: '#d9edff', 500: '#1677ff', 600: '#0968df', 700: '#0757b9' },
      },
      fontFamily: { sans: ['DM Sans', 'Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'], display: ['Manrope', 'DM Sans', 'sans-serif'] },
      boxShadow: { panel: '0 1px 2px rgba(15,23,42,.04), 0 8px 24px rgba(15,23,42,.04)' },
    },
  },
  plugins: [],
}
