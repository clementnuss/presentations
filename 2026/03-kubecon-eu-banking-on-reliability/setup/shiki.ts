import { defineShikiSetup } from '@slidev/types'

export default defineShikiSetup(() => {
  return {
    themes: {
      dark: 'vitesse-dark',
      light: 'catppuccin-latte',
    },
    transformers: [
      // Add custom transformers here if needed
    ],
  }
})
