// https://nuxt.com/docs/api/configuration/nuxt-config
import { defineNuxtConfig } from 'nuxt/config'
import materialIcons from 'quasar/icon-set/svg-material-icons'
import materialIconsRound from 'quasar/icon-set/svg-material-icons-round'

export default defineNuxtConfig({
  ssr: false,
  compatibilityDate: '2024-11-09',
  devtools: { enabled: true },
  modules: [
    'nuxt-quasar-ui',
    '@pinia/nuxt',
    '@nuxt/test-utils/module',
  ],
  quasar: {
    plugins: [
      'Dialog',
      'Loading',
    ],
    sassVariables: true,
    iconSet: {
      ...materialIcons,
      colorPicker: materialIconsRound.colorPicker,
    },
    extras: {
      font: 'roboto-font',
      fontIcons: ['material-icons'],
      animations: 'all',
    },
    config: {
      dark: true,
      brand: {
        primary:        "#2ccadb",
        secondary:      "#098f60",
        accent:         "#9C27B0",
        positive:       "#21BA45",
        negative:       "#C10015",
        info:           "#31CCEC",
        warning:        "#F2C037",
        dark:           "#1D1D1D",
      }
    },
    components: {
      defaults: {
        QBtn: {
          color: 'primary',
        },
        QCircularProgress: {
          color: 'primary',
          indeterminate: true,
        },
        QSelect: {
          outlined: true,
          dense: true,
        },
        QInput: {
          outlined: true,
        },
        QToggle: {
          color: 'primary',
        },
      },
    },
  },
  css:['~/assets/styles/style.css']
})