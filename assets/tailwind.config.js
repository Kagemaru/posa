module.exports = {
  // mode: 'jit',
  purge: [
    '../lib/**/*.{ex,eex,leex,slim}',
    './js/**/*.js'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
