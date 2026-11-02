<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getPost, getNeighbors, deletePost, updateStudyStatus } from '@/api/post'
import { useUserStore } from '@/stores/user'
import { useKnowledgeStore } from '@/stores/knowledge'
import MarkdownRenderer from '@/components/MarkdownRenderer.vue'
import { formatRelativeTime } from '@/utils/format'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const knowledgeStore = useKnowledgeStore()

const post = ref(null)
const nav = ref({ prev: null, next: null })
const loading = ref(false)
const savingStatus = ref(false)

const isMine = computed(() => userStore.isLoggedIn && post.value && post.value.authorId === userStore.userId)
const tags = computed(() => post.value?.tags || [])

const studyOptions = [
  { value: 0, label: '待学' },
  { value: 1, label: '学习中' },
  { value: 2, label: '已掌握' }
]

async function load(id) {
  loading.value = true
  try {
    post.value = await getPost(id)
    nav.value = (await getNeighbors(id)) || { prev: null, next: null }
    // 让侧边栏展开这条知识点所属项目
    if (post.value?.categoryId) {
      knowledgeStore.expandedId = post.value.categoryId
      knowledgeStore.fetchPosts(post.value.categoryId)
    }
  } catch (e) {
    post.value = null
  } finally {
    loading.value = false
  }
}

async function setStudyStatus(status) {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录后再标记学习状态')
    return
  }
  savingStatus.value = true
  try {
    await updateStudyStatus(post.value.id, status)
    post.value.studyStatus = status
    ElMessage.success('学习状态已更新')
  } finally {
    savingStatus.value = false
  }
}

function goNeighbor(node) {
  if (node && node.id) router.push('/post/' + node.id)
}

async function removePost() {
  await ElMessageBox.confirm('确定删除知识点「' + post.value.title + '」吗？', '删除知识点', { type: 'warning' })
  await deletePost(post.value.id)
  ElMessage.success('已删除')
  knowledgeStore.refreshPosts(post.value.categoryId)
  router.push('/')
}

function editPost() {
  router.push('/editor/' + post.value.id)
}

onMounted(() => load(route.params.id))
watch(() => route.params.id, (id) => { if (id) load(id) })
</script>

<template>
  <div class="dt">
    <el-skeleton v-if="loading" class="dt__skeleton" :rows="10" animated />

    <el-empty v-else-if="!post" description="知识点不存在或已被删除">
      <el-button type="primary" @click="router.push('/')">返回首页</el-button>
    </el-empty>

    <template v-else>
      <article class="dt__inner">
        <!-- 标题区 -->
        <header class="dt__head">
          <div class="dt__crumbs">
            <router-link to="/" class="dt__crumb">{{ post.categoryName || '知识库' }}</router-link>
            <span v-if="post.sortOrder != null" class="dt__order">第 {{ post.sortOrder }} 条</span>
          </div>
          <h1 class="dt__title">{{ post.title }}</h1>
          <div class="dt__meta">
            <span>{{ formatRelativeTime(post.updatedAt || post.createdAt) }}更新</span>
            <span v-for="tag in tags.slice(0, 6)" :key="tag.id" class="dt__tag">#{{ tag.name }}</span>
          </div>
        </header>

        <!-- 操作条 -->
        <div class="dt__toolbar">
          <span class="dt__study-label">学习状态：</span>
          <el-radio-group :model-value="post.studyStatus ?? 0" size="small" :disabled="savingStatus" @change="setStudyStatus">
            <el-radio-button v-for="opt in studyOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</el-radio-button>
          </el-radio-group>
          <div class="dt__toolbar-right" v-if="isMine">
            <el-button size="small" @click="editPost"><el-icon><EditPen /></el-icon>&nbsp;编辑</el-button>
            <el-button size="small" type="danger" plain @click="removePost"><el-icon><Delete /></el-icon>&nbsp;删除</el-button>
          </div>
        </div>

        <!-- 正文 -->
        <div class="dt__content">
          <MarkdownRenderer :content="post.content" />
        </div>

        <!-- 上一条 / 下一条 -->
        <nav class="dt__nav">
          <div class="dt__nav-item" :class="{ 'is-disabled': !nav.prev }" @click="nav.prev && goNeighbor(nav.prev)">
            <span class="dt__nav-circle"><el-icon><ArrowLeft /></el-icon></span>
            <div class="dt__nav-text">
              <span class="dt__nav-dir">上一条</span>
              <span class="dt__nav-title">{{ nav.prev ? nav.prev.title : '已经是第一条了' }}</span>
            </div>
          </div>
          <div class="dt__nav-item dt__nav-item--right" :class="{ 'is-disabled': !nav.next }" @click="nav.next && goNeighbor(nav.next)">
            <div class="dt__nav-text">
              <span class="dt__nav-dir">下一条</span>
              <span class="dt__nav-title">{{ nav.next ? nav.next.title : '已经是最后一条了' }}</span>
            </div>
            <span class="dt__nav-circle"><el-icon><ArrowRight /></el-icon></span>
          </div>
        </nav>

        <div class="dt__back">
          <el-button text @click="router.push('/')">
            <el-icon><ArrowLeft /></el-icon>&nbsp;返回首页
          </el-button>
        </div>
      </article>
    </template>
  </div>
</template>

<style scoped>
.dt { min-height: 100%; }

.dt__inner {
  max-width: 860px;
  margin: 0 auto;
  padding: 32px 28px 48px;
}

.dt__crumbs {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}
.dt__crumb {
  font-size: 13px;
  font-weight: 600;
  color: var(--cc-primary);
}
.dt__order {
  font-size: 11.5px;
  font-weight: 600;
  color: var(--cc-primary);
  background: var(--cc-primary-soft);
  border: 1px solid var(--cc-border-light);
  padding: 1px 9px;
  border-radius: 999px;
}

.dt__title {
  position: relative;
  margin: 0 0 12px;
  font-size: 29px;
  font-weight: 800;
  line-height: 1.35;
  letter-spacing: 0.01em;
  color: var(--cc-text-main);
  padding-bottom: 14px;
}
.dt__title::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: 0;
  width: 56px;
  height: 4px;
  border-radius: 4px;
  background: var(--cc-gradient);
}

.dt__meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  font-size: 12px;
  color: var(--cc-text-muted);
  margin-bottom: 18px;
}
.dt__tag { color: var(--cc-primary); background: var(--cc-primary-soft); padding: 2px 8px; border-radius: 6px; }

.dt__toolbar {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  max-width: 100%;
  background: rgba(255, 255, 255, 0.78);
  border: 1px solid var(--cc-border-light);
  border-radius: var(--cc-radius-pill);
  padding: 7px 8px 7px 16px;
  margin-bottom: 18px;
  box-shadow: var(--cc-shadow-sm);
  backdrop-filter: blur(10px);
}
.dt__study-label { font-size: 13px; color: var(--cc-text-sub); }
.dt__toolbar-right { margin-left: 8px; display: flex; gap: 8px; padding-left: 10px; border-left: 1px solid var(--cc-border-light); }

.dt__content {
  position: relative;
  background: var(--cc-bg-card);
  border: 1px solid var(--cc-border-light);
  border-radius: var(--cc-radius-lg);
  padding: 30px 34px;
  margin-bottom: 24px;
  box-shadow: var(--cc-shadow);
  backdrop-filter: blur(8px);
  overflow: hidden;
}
.dt__content::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 3px;
  background: var(--cc-gradient);
}

.dt__nav {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
  margin-bottom: 12px;
}
.dt__nav-item {
  position: relative;
  background: var(--cc-bg-card);
  border: 1px solid var(--cc-border-light);
  border-radius: var(--cc-radius-lg);
  padding: 16px 20px;
  cursor: pointer;
  transition: var(--cc-transition);
  display: flex;
  align-items: center;
  gap: 14px;
  min-width: 0;
  box-shadow: var(--cc-shadow-sm);
  overflow: hidden;
}
.dt__nav-item::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(194,112,61,.08), rgba(154,91,47,.05));
  opacity: 0;
  transition: var(--cc-transition-fast);
}
.dt__nav-item:hover:not(.is-disabled) {
  border-color: var(--cc-border-strong);
  box-shadow: var(--cc-shadow-hover);
  transform: translateY(-2px);
}
.dt__nav-item:hover:not(.is-disabled)::after { opacity: 1; }
.dt__nav-item--right { flex-direction: row-reverse; text-align: right; }
.dt__nav-item--right .dt__nav-text { align-items: flex-end; }

.dt__nav-circle {
  flex-shrink: 0;
  width: 38px;
  height: 38px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--cc-primary);
  background: var(--cc-primary-soft);
  border: 1px solid var(--cc-border-light);
  transition: var(--cc-transition-fast);
}
.dt__nav-item:hover:not(.is-disabled) .dt__nav-circle {
  background: var(--cc-gradient);
  color: #fff;
  border-color: transparent;
  box-shadow: 0 4px 14px rgba(194, 112, 61, 0.4);
}

.dt__nav-text {
  display: flex;
  flex-direction: column;
  gap: 3px;
  min-width: 0;
  position: relative;
  z-index: 1;
}
.dt__nav-item.is-disabled { opacity: 0.55; cursor: default; }

.dt__nav-dir {
  font-size: 11.5px;
  color: var(--cc-text-muted);
  font-weight: 600;
  letter-spacing: 0.06em;
}
.dt__nav-title {
  font-size: 13px;
  font-weight: 600;
  color: var(--cc-text-main);
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  position: relative;
  z-index: 1;
}

.dt__back { text-align: center; }

@media (max-width: 640px) {
  .dt__inner { padding: 20px 14px 40px; }
  .dt__nav { grid-template-columns: 1fr; }
}
</style>
