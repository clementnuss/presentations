/* ./setup/shiki.ts */
import { defineShikiSetup } from '@slidev/types'

export default defineShikiSetup(() => {
  return {
    themes: {
      dark: 'catppuccin-frappe',
      light: 'github-light-high-contrast',
    },
  }
})
