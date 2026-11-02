<script setup>
import { computed } from 'vue'

const props = defineProps({
  user: { type: Object, default: null },
  size: { type: Number, default: 40 }
})

const src = computed(() => props.user?.avatarUrl || props.user?.avatar || '')
const text = computed(() => {
  const name = props.user?.nickname || props.user?.username || '匿'
  return name.slice(0, 1)
})
</script>

<template>
  <el-avatar class="cc-avatar" :size="size" :src="src">{{ text }}</el-avatar>
</template>

<style scoped>
.cc-avatar {
  background: linear-gradient(135deg, #b45309, #8f5426);
  color: #fff;
  font-weight: 600;
  flex-shrink: 0;
}
</style>
