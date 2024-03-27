// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  mode: 'jit',
  content: [
    "./js/**/*.js",
    "../lib/posa_web.ex",
    "../lib/posa_web/**/*.*ex"
  ],
  theme: {
    extend: {
      fontFamily: {
        pz: 'Roboto Slab, serif'
      },
      colors: {
        brand: "#FD4F00",
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
        },
      },
      backgroundImage: {
        pz: 'url(/images/bg-top-left.svg),url(/images/bg-top-right.svg)'
      },
      gridTemplateColumns: {
        auto_fit: 'repeat(auto-fit, minmax(500px, 1fr))'
      },
      animation: {
        sweep: 'sweep 0.5s ease-in-out',
      },
      keyframes: {
        sweep: {
          '0%': { opacity: 0, transform: 'translateX(-10px)' },
          '100%': { opacity: 1, transform: 'translateX(0)' }
        }
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, { values })
    })
  ]
}
