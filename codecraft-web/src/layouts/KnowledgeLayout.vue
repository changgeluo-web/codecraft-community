<script setup>
import { onMounted } from 'vue'
import KnowledgeSidebar from '@/components/KnowledgeSidebar.vue'
import { useKnowledgeStore } from '@/stores/knowledge'

const knowledgeStore = useKnowledgeStore()
onMounted(() => {
  knowledgeStore.fetchCategories()
})
</script>

<template>
  <div class="kb">
    <KnowledgeSidebar v-show="!knowledgeStore.collapsed" class="kb__side" />
    <section class="kb__main">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" :key="$route.fullPath" />
        </transition>
      </router-view>
    </section>
  </div>
</template>

<style scoped>
.kb {
  display: flex;
  height: 100%;
  min-height: 0;
}

.kb__side {
  width: 268px;
  flex-shrink: 0;
  background: linear-gradient(180deg, #3a2c1e 0%, #2f251a 55%, #281f15 100%);
  box-shadow: inset -1px 0 0 rgba(255, 255, 255, 0.06);
}

.kb__main {
  flex: 1;
  min-width: 0;
  overflow-y: auto;
  scroll-behavior: smooth;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.15s var(--cc-ease);
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

@media (max-width: 860px) {
  .kb__side {
    position: absolute;
    z-index: 30;
    top: var(--cc-header-height);
    bottom: 0;
    box-shadow: var(--cc-shadow-md);
  }
}
</style>
