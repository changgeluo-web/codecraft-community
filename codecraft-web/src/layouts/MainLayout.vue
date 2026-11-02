<script setup>
import AppHeader from '@/components/AppHeader.vue'
</script>

<template>
  <div class="layout">
    <AppHeader />
    <main class="layout__body">
      <router-view />
    </main>
  </div>
</template>

<style scoped>
.layout {
  min-height: 100vh;
}

.layout__body {
  margin-top: var(--cc-header-height);
  height: calc(100vh - var(--cc-header-height));
  overflow-y: auto;
  overflow-x: hidden;
}
</style>
