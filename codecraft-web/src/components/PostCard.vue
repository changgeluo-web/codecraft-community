<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { formatRelativeTime } from '@/utils/format'

const props = defineProps({ post: { type: Object, required: true } })
const router = useRouter()

const post = computed(() => props.post)
const tags = computed(() => post.value.tags || [])
const categoryName = computed(() => post.value.categoryName || post.value.category?.name || '技术')

const studyStatusMap = { 0: { label: '待学', color: '#b3a48f', bg: '#f1e8db' }, 1: { label: '学习中', color: '#b45309', bg: '#fdebd7' }, 2: { label: '已掌握', color: '#16a34a', bg: '#dcfce7' } }
const studyStatus = computed(() => studyStatusMap[post.value.studyStatus ?? 0] || studyStatusMap[0])


function goDetail() {
  if (!post.value.id) return
  router.push(`/post/${post.value.id}`)
}

</script>

<template>
  <article class="card" @click="goDetail">
    <!-- 左侧色条 -->
    <div class="card__bar"></div>

    <div class="card__inner">
      <!-- 头部：分类 + 学习状态 -->
      <div class="card__head">
        <span class="card__cat">{{ categoryName }}</span>
        <span v-if="post.sortOrder != null" class="card__order">No.{{ post.sortOrder }}</span>
        <span class="card__study" :style="{ color: studyStatus.color, background: studyStatus.bg }">{{ studyStatus.label }}</span>
      </div>

      <!-- 标题 -->
      <h3 class="card__title">{{ post.title }}</h3>

      <!-- 摘要 -->
      <p v-if="post.summary" class="card__summary">{{ post.summary }}</p>

      <!-- 时间 + 标签 -->
      <div class="card__meta">
        <span class="card__time">{{ formatRelativeTime(post.createdAt) }}记录</span>
        <span v-for="tag in tags.slice(0, 3)" :key="tag.id || tag.name || tag" class="card__tag">
          #{{ tag.name || tag }}
        </span>
      </div>
    </div>
  </article>
</template>

<style scoped>
.card {
  display: flex;
  background: var(--cc-bg-card);
  border: 1px solid var(--cc-border-light);
  border-radius: var(--cc-radius-lg);
  cursor: pointer;
  overflow: hidden;
  box-shadow: var(--cc-shadow-sm);
  backdrop-filter: blur(8px);
  transition: transform 0.28s var(--cc-ease-spring), box-shadow 0.28s var(--cc-ease), border-color 0.28s var(--cc-ease);
}

.card:hover {
  transform: translateY(-3px);
  border-color: var(--cc-border);
  box-shadow: var(--cc-shadow-hover);
}

/* 左侧色条：品牌渐变 */
.card__bar {
  width: 4px;
  flex-shrink: 0;
  background: linear-gradient(180deg, #c2703d, #e0b98f);
  transition: width 0.2s ease;
}
.card:hover .card__bar { width: 6px; }

/* 内容区 */
.card__inner {
  flex: 1;
  padding: 16px 20px;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

/* 头部 */
.card__head {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 8px;
}
.card__order {
  font-size: 11px;
  color: var(--cc-text-muted);
  background: var(--cc-bg);
  padding: 1px 6px;
  border-radius: 4px;
}
.card__cat {
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.02em;
  color: var(--cc-primary);
  background: var(--cc-primary-soft);
  border: 1px solid var(--cc-border-light);
  padding: 1px 10px;
  border-radius: 999px;
}
.card__study {
  font-size: 11px; font-weight: 600;
  padding: 2px 10px; border-radius: var(--cc-radius-pill);
  transition: var(--cc-transition-fast);
}
.card__pin {
  font-size: 11px; font-weight: 600;
  color: #fff; background: var(--cc-accent);
  padding: 2px 8px; border-radius: var(--cc-radius-pill);
}

/* 标题 */
.card__title {
  margin: 0 0 6px;
  font-size: 16px; font-weight: 700;
  color: var(--cc-text-main); line-height: 1.45;
  transition: color 0.2s;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.card:hover .card__title { color: var(--cc-primary); }

/* 摘要 */
.card__summary {
  margin: 0 0 12px;
  font-size: 13px; color: var(--cc-text-sub);
  line-height: 1.6;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  flex: 1;
}

/* 作者 + 时间 */
.card__meta {
  display: flex; align-items: center; gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 10px;
}
.card__time { font-size: 12px; color: var(--cc-text-muted); white-space: nowrap; }

/* 底栏 */
.card__footer {
  display: flex; align-items: center; gap: 16px;
  flex-wrap: wrap;
}
.card__stat {
  display: flex; align-items: center; gap: 4px;
  font-size: 12px; color: var(--cc-text-muted);
  transition: color 0.2s;
}
.card__stat:hover { color: var(--cc-primary); }
.card__stat .el-icon { font-size: 13px; }

.card__tags {
  display: flex; gap: 6px;
  margin-left: auto;
}
.card__tag {
  font-size: 11px; color: var(--cc-primary);
  background: var(--cc-primary-light);
  padding: 2px 8px; border-radius: var(--cc-radius-pill);
  transition: var(--cc-transition-fast);
}
.card__tag:hover { background: var(--cc-primary); color: #fff; }
</style>
