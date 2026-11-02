<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useKnowledgeStore } from '@/stores/knowledge'
import { useUserStore } from '@/stores/user'
import ManageDialog from '@/components/ManageDialog.vue'

const route = useRoute()
const router = useRouter()
const store = useKnowledgeStore()
const userStore = useUserStore()

const manageVisible = ref(false)

const activePostId = computed(() => {
  const m = String(route.path).match(/^\/post\/(\d+)/)
  return m ? Number(m[1]) : null
})

function go(post) {
  router.push('/post/' + post.id)
}

function goWrite(categoryId) {
  if (!userStore.isLoggedIn) {
    router.push({ path: '/login', query: { redirect: route.fullPath } })
    return
  }
  router.push({ path: '/editor', query: categoryId ? { categoryId } : {} })
}

function onManageSaved() {
  store.fetchCategories(true)
  if (store.expandedId) store.fetchPosts(store.expandedId, true)
}

onMounted(async () => {
  await store.fetchCategories()
  // 直接以 URL 进入某条知识点时，展开它所属项目
  const pid = activePostId.value
  if (pid) {
    for (const cat of store.categories) {
      const posts = await store.fetchPosts(cat.id)
      if ((posts || []).some((p) => p.id === pid)) {
        store.expandedId = cat.id
        break
      }
    }
  }
})
</script>

<template>
  <div class="side">
    <div class="side__head">
      <span class="side__title">我的项目</span>
      <el-button v-if="userStore.isLoggedIn" text size="small" @click="manageVisible = true">
        <el-icon><Setting /></el-icon>&nbsp;管理
      </el-button>
    </div>

    <div class="side__scroll">
      <el-skeleton v-if="!store.categoriesLoaded" :rows="6" animated />
      <template v-else>
        <div v-for="cat in store.categories" :key="cat.id" class="side__group">
          <div class="side__cat" :class="{ 'is-open': store.expandedId === cat.id }" @click="store.toggle(cat.id)">
            <el-icon class="side__cat-arrow" :class="{ 'is-open': store.expandedId === cat.id }"><ArrowRight /></el-icon>
            <span class="side__cat-name">{{ cat.name }}</span>
            <span class="side__cat-count">{{ cat.postCount ?? 0 }}</span>
          </div>

          <div v-if="store.expandedId === cat.id" class="side__posts">
            <div v-if="store.loadingCategory === cat.id" class="side__empty">加载中…</div>
            <div v-if="store.loadingCategory !== cat.id && (!store.postsByCategory[cat.id] || store.postsByCategory[cat.id].length === 0)" class="side__empty">
              还没有知识点
            </div>
            <div
              v-for="(post, idx) in store.postsByCategory[cat.id] || []"
              :key="post.id"
              class="side__post"
              :class="{ 'is-active': activePostId === post.id }"
              @click="go(post)"
            >
              <span class="side__post-no">{{ post.sortOrder ?? idx + 1 }}</span>
              <span class="side__post-title" :title="post.title">{{ post.title }}</span>
            </div>
            <div v-if="userStore.isLoggedIn" class="side__add" @click="goWrite(cat.id)">+ 在此项目记录知识点</div>
          </div>
        </div>

        <div v-if="store.categories.length === 0" class="side__empty side__empty--top">
          <template v-if="userStore.isLoggedIn">
            还没有项目，点击右上角「管理」创建
          </template>
          <template v-else>登录后即可创建项目与知识点</template>
        </div>
      </template>
    </div>

    <ManageDialog v-model="manageVisible" @saved="onManageSaved" />
  </div>
</template>

<style scoped>
.side {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
  color: #ecdfcc;
}

.side__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 18px 12px;
}

.side__title {
  font-size: 12px;
  font-weight: 700;
  color: #b8a184;
  letter-spacing: 0.14em;
}
.side__head :deep(.el-button) {
  color: #b8a184;
  border: none;
}
.side__head :deep(.el-button:hover) { color: #fff; background: rgba(255,255,255,.07); }

.side__scroll {
  flex: 1;
  overflow-y: auto;
  padding: 4px 10px 24px;
}
.side__scroll::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.14); background-clip: padding-box; }

.side__group { margin-bottom: 2px; }

.side__cat {
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 10px 12px;
  border-radius: 10px;
  cursor: pointer;
  font-size: 13.5px;
  font-weight: 600;
  color: #f7efe2;
  transition: var(--cc-transition-fast);
}
.side__cat:hover { background: rgba(255, 255, 255, 0.06); }
.side__cat.is-open {
  background: linear-gradient(90deg, rgba(194, 112, 61, 0.32), rgba(154, 91, 47, 0.14));
  color: #fff;
  box-shadow: inset 0 0 0 1px rgba(232, 205, 170, 0.25);
}

.side__cat-arrow {
  transition: transform 0.2s var(--cc-ease);
  font-size: 12px;
  color: #9c8468;
}
.side__cat-arrow.is-open { transform: rotate(90deg); color: #e0b98f; }

.side__cat-name { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.side__cat-count {
  font-size: 11px;
  font-weight: 600;
  color: #e0b98f;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 999px;
  padding: 1px 8px;
  font-variant-numeric: tabular-nums;
}

.side__posts { padding: 4px 0 8px 10px; }

.side__post {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 7px 10px;
  margin-left: 8px;
  border-radius: 9px;
  cursor: pointer;
  font-size: 13px;
  color: #d8c7ae;
  transition: var(--cc-transition-fast);
}
.side__post:hover { color: #fff; background: rgba(255, 255, 255, 0.06); }
.side__post.is-active {
  color: #fff;
  font-weight: 600;
  background: rgba(194, 112, 61, 0.22);
  box-shadow: inset 2px 0 0 #9a5b2f;
}

.side__post-no {
  flex-shrink: 0;
  width: 21px;
  height: 21px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 10.5px;
  font-weight: 700;
  color: #b8a184;
  background: rgba(255, 255, 255, 0.07);
  border-radius: 7px;
  font-variant-numeric: tabular-nums;
  transition: var(--cc-transition-fast);
}
.side__post:hover .side__post-no { color: #f5e8d5; background: rgba(255, 255, 255, 0.12); }
.side__post.is-active .side__post-no {
  background: var(--cc-gradient);
  color: #fff;
  box-shadow: 0 2px 8px rgba(194, 112, 61, 0.5);
}
.side__post-title { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.side__add {
  margin: 8px 12px 2px 20px;
  padding: 6px 0;
  text-align: center;
  font-size: 12px;
  color: #b8a184;
  cursor: pointer;
  border: 1px dashed rgba(255, 255, 255, 0.16);
  border-radius: 9px;
  transition: var(--cc-transition-fast);
}
.side__add:hover {
  color: #f5e8d5;
  background: rgba(194, 112, 61, 0.12);
  border-color: rgba(224, 185, 143, 0.4);
}

.side__empty { padding: 10px 14px; font-size: 12px; color: #9c8468; }
.side__empty--top { padding-top: 28px; text-align: center; }

:deep(.el-skeleton__item) { background: rgba(255, 255, 255, 0.07); }
</style>
