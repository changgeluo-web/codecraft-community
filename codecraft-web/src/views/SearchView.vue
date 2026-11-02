<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { searchPosts } from '@/api/search'
import PostCard from '@/components/PostCard.vue'

const route = useRoute()
const router = useRouter()

const keyword = ref(route.query.keyword || '')
const results = ref([])
const total = ref(0)
const page = ref(1)
const size = 10
const loading = ref(false)

async function doSearch() {
  const kw = keyword.value.trim()
  loading.value = true
  try {
    // 无关键词时后端返回全部知识点（按项目顺序、项目内序号排列）
    const params = { page: page.value, size }
    if (kw) params.keyword = kw
    const data = await searchPosts(params)
    const list = data?.records || data?.list || (Array.isArray(data) ? data : [])
    results.value = list
    total.value = data?.total || list.length
  } finally {
    loading.value = false
  }
}

function submit() {
  page.value = 1
  const kw = keyword.value.trim()
  if (kw) router.replace({ path: '/search', query: { keyword: kw } })
  else router.replace({ path: '/search' })
  doSearch()
}

// 点输入框的清空按钮 → 回到全部列表
watch(keyword, (v, old) => {
  if (!v.trim() && old && old.trim()) {
    page.value = 1
    router.replace({ path: '/search' })
    doSearch()
  }
})

onMounted(() => {
  doSearch()
})

watch(
  () => route.query.keyword,
  (kw) => {
    keyword.value = kw || ''
    page.value = 1
    doSearch()
  }
)

function handlePageChange(p) {
  page.value = p
  doSearch()
}
</script>

<template>
  <div class="search-page cc-page">
    <div class="cc-page-head">
      <button class="cc-back" @click="router.push('/')">
        <el-icon><ArrowLeft /></el-icon>&nbsp;返回首页
      </button>
      <h2>浏览全部知识点</h2>
    </div>
    <div class="search-page__bar">
      <el-input v-model="keyword" size="large" placeholder="搜索标题 / 摘要…" clearable @keyup.enter="submit">
        <template #prefix><el-icon><Search /></el-icon></template>
        <template #append><el-button type="primary" @click="submit">搜索</el-button></template>
      </el-input>
    </div>

    <div class="search-page__count">
      <template v-if="keyword.trim()">“{{ keyword.trim() }}” 共找到 {{ total }} 条结果　<a class="search-page__clear" @click="keyword = ''; submit()">清除筛选</a></template>
      <template v-else>全部知识点 · 共 {{ total }} 条</template>
    </div>

    <div v-if="loading && results.length === 0" class="search-page__grid">
      <div v-for="i in 6" :key="i" class="search-page__skel cc-card"><el-skeleton :rows="3" animated /></div>
    </div>
    <template v-else>
      <div v-if="results.length" class="search-page__grid">
        <PostCard v-for="post in results" :key="post.id" :post="post" />
      </div>
      <el-empty v-else :description="keyword.trim() ? '没有找到相关内容' : '还没有知识点，去记录第一条吧'" />
    </template>

    <div class="cc-pagination">
      <el-pagination
        v-if="total > size"
        background
        layout="prev, pager, next"
        :total="total"
        :page-size="size"
        :current-page="page"
        @current-change="handlePageChange"
      />
    </div>
  </div>
</template>

<style scoped>
.search-page {
  max-width: 1240px;
  margin: 0 auto;
  padding: 24px 20px 64px;
}

.search-page__grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 14px;
  align-items: stretch;
}

.search-page__skel {
  padding: 20px 22px;
  min-height: 170px;
}

.search-page__bar {
  max-width: 640px;
  margin: 0 auto 20px;
}

.search-page__clear {
  color: var(--cc-primary);
  cursor: pointer;
  font-weight: 600;
}
.search-page__clear:hover { text-decoration: underline; }

.search-page__count {
  color: var(--cc-text-sub);
  font-size: 13px;
  margin-bottom: 14px;
}
</style>