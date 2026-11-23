<template>
  <p v-if="loading">Loading Excalidraw...</p>
  <div :class="$attrs.class" v-if="svg" v-html="svg"></div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { exportToSvg } from '@excalidraw/excalidraw'

const loading = ref(false)
const svg = ref<string | null>(null)

interface AppState {
  exportWithDarkMode: boolean;
  exportBackground: boolean;
}

const props = withDefaults(defineProps<{
  drawFilePath: string
  darkMode?: true
  background?: boolean
}>(), {
  darkMode: false,
  background: false,
})

onMounted(async () => {
  loading.value = true
  try {
    await loadJsonAndExport(props)
  } finally {
    loading.value = false
  }
})

const loadJsonAndExport = async ({ drawFilePath: path, darkMode = false, background = false }: { drawFilePath: string; darkMode: boolean; background: boolean }) => {
  try {
    const url = new URL(path, window.location.origin + import.meta.env.BASE_URL).href
    const json = await (await fetch(url)).json()

    const svgElement = await exportToSvg({
      ...json,
      appState: {
        ...(json.appState as any),
        exportWithDarkMode: darkMode,
        exportBackground: background,
      }
    })
    svgElement.style.maxWidth = '100%'
    svgElement.style.height = 'auto'

    svg.value = svgElement.outerHTML
  } catch (error) {
    console.error('Failed to load JSON or export to SVG', error)
  }
}
</script>
