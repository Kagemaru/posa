module.exports = {
  mode: 'jit',
  purge: [
    '../lib/**/*.{ex,eex,heex}',
    './js/**/*.js'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        pz: {
          'dark-blue': '#1E5A96',
          'bright-navy-blue': '#3B7BBE',
          'green-blue-crayola': '#238BCA',
          'carolina-blue': '#3FA8E0',
          'maximum-blue-green': '#46BCC0',
          'blue-munsell': '#2C97A6',
          'emerald': '#69B978',
          'brilliant-green': '#61B44B',
          'prussian-blue': '#1B2D53',
        }
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
