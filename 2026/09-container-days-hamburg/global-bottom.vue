<template>
  <footer v-if="$nav.currentPage > 1" class="absolute bottom-2 right-4 text-xs opacity-40">
    {{ $nav.currentPage }} / {{ $nav.total }}
  </footer>
</template>
