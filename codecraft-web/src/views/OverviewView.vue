<script setup>
import { ref, onMounted, computed } from 'vue'
import { useUserStore } from '@/stores/user'
import { useKnowledgeStore } from '@/stores/knowledge'
import { getPosts, getDashboard } from '@/api/post'
import PostCard from '@/components/PostCard.vue'

const userStore = useUserStore()
const knowledgeStore = useKnowledgeStore()

const recent = ref([])
const dashboard = ref(null)
const loading = ref(false)

const totalKnowledge = computed(() =>
  knowledgeStore.categories.reduce((sum, c) => sum + (c.postCount || 0), 0)
)

onMounted(async () => {
  loading.value = true
  try {
    const data = await getPosts({ page: 1, size: 6 })
    recent.value = data?.records || []
    if (userStore.isLoggedIn) {
      try { dashboard.value = await getDashboard() } catch (e) { /* 未登录过期时忽略 */ }
    }
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="ov">
    <div class="ov__inner">
      <!-- 欢迎横幅 -->
      <section class="ov__hero">
        <span class="ov__hero-mark">⌘</span>
        <div>
          <h1 class="ov__title">{{ userStore.isLoggedIn ? '你好，' + userStore.nickname : '个人技术知识库' }}</h1>
          <p class="ov__desc">把学过的每个技术点记成一条可检索、可排序、可翻阅的知识卡片。左侧选择项目，即可按顺序逐条学习。</p>
        </div>
        <div class="ov__hero-actions">
          <el-button v-if="!userStore.isLoggedIn" type="primary" size="large" round @click="$router.push('/login')">登录后开始记录</el-button>
          <template v-else>
            <button class="ov__hero-btn" @click="$router.push('/editor')">✍️ 记录知识点</button>
            <button class="ov__hero-btn ov__hero-btn--ghost" @click="$router.push('/search')">🔍 浏览全部</button>
          </template>
        </div>
      </section>

      <!-- 统计卡片 -->
      <section v-if="userStore.isLoggedIn && dashboard" class="ov__stats">
        <div class="ov__stat">
          <span class="ov__stat-icon ov__stat-icon--a"><el-icon><Folder /></el-icon></span>
          <div>
            <span class="ov__stat-num">{{ dashboard.totalProjects }}</span>
            <span class="ov__stat-label">学习项目</span>
          </div>
        </div>
        <div class="ov__stat">
          <span class="ov__stat-icon ov__stat-icon--b"><el-icon><Reading /></el-icon></span>
          <div>
            <span class="ov__stat-num">{{ dashboard.totalKnowledge }}</span>
            <span class="ov__stat-label">知识点总数</span>
          </div>
        </div>
        <div class="ov__stat">
          <span class="ov__stat-icon ov__stat-icon--c"><el-icon><CircleCheck /></el-icon></span>
          <div>
            <span class="ov__stat-num">{{ dashboard.totalMastered }}</span>
            <span class="ov__stat-label">已掌握</span>
          </div>
        </div>
        <div class="ov__stat">
          <span class="ov__stat-icon ov__stat-icon--d"><el-icon><TrendCharts /></el-icon></span>
          <div>
            <span class="ov__stat-num">{{ dashboard.overallProgress }}%</span>
            <span class="ov__stat-label">掌握进度</span>
          </div>
        </div>
      </section>

      <!-- 项目进度 -->
      <section v-if="userStore.isLoggedIn && dashboard && dashboard.projects && dashboard.projects.length" class="ov__block">
        <h2 class="ov__blocktitle">项目进度</h2>
        <div class="ov__projects">
          <div v-for="p in dashboard.projects" :key="p.categoryId" class="ov__project">
            <div class="ov__project-head">
              <span class="ov__project-name">{{ p.projectName }}</span>
              <span class="ov__project-pct"><b>{{ p.progress || 0 }}%</b><i>{{ p.mastered }}/{{ p.total }}</i></span>
            </div>
            <el-progress :percentage="p.progress || 0" :stroke-width="7" :show-text="false" />
          </div>
        </div>
      </section>

      <!-- 最近记录 -->
      <section class="ov__block">
        <div class="ov__blockhead">
          <h2 class="ov__blocktitle">最近记录</h2>
          <router-link to="/search" class="ov__more">全部知识点 →</router-link>
        </div>
        <div v-if="loading"><el-skeleton :rows="4" animated /></div>
        <el-empty v-else-if="recent.length === 0" description="还没有知识点，点击右上角「记录知识点」开始吧">
          <el-button v-if="userStore.isLoggedIn" type="primary" @click="$router.push('/editor')">记录第一条</el-button>
        </el-empty>
        <div v-else class="ov__recent">
          <PostCard v-for="p in recent" :key="p.id" :post="p" />
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.ov { height: 100%; }
.ov__inner {
  max-width: 1020px;
  margin: 0 auto;
  padding: 28px 28px 64px;
}

/* —— 大渐变横幅 —— */
.ov__hero {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  background: linear-gradient(125deg, #b45309 0%, #c2703d 55%, #d97706 100%);
  border-radius: var(--cc-radius-xl);
  padding: 34px 38px;
  margin-bottom: 22px;
  box-shadow: 0 16px 44px rgba(194, 112, 61, 0.35);
  overflow: hidden;
}
.ov__hero::before,
.ov__hero::after {
  content: '';
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.09);
  pointer-events: none;
}
.ov__hero::before { width: 320px; height: 320px; top: -160px; right: -80px; }
.ov__hero::after { width: 200px; height: 200px; bottom: -110px; left: 22%; background: rgba(255,255,255,.06); }

.ov__title { margin: 0 0 8px; font-size: 26px; font-weight: 800; color: #fff; letter-spacing: 0.01em; }
.ov__desc { margin: 0; font-size: 13.5px; line-height: 1.75; color: rgba(255, 255, 255, 0.82); max-width: 560px; position: relative; z-index: 1; }
.ov__hero-actions { display: flex; gap: 12px; position: relative; z-index: 1; flex-shrink: 0; }
.ov__hero-btn {
  border: none;
  cursor: pointer;
  padding: 12px 22px;
  border-radius: 999px;
  font-size: 14px;
  font-weight: 700;
  color: #a05a2c;
  background: #fff;
  box-shadow: 0 8px 22px rgba(60, 40, 20, 0.3);
  transition: var(--cc-transition-fast);
  white-space: nowrap;
}
.ov__hero-btn:hover { transform: translateY(-2px); background: #faf3ea; }
.ov__hero-btn--ghost {
  background: rgba(255, 255, 255, 0.12);
  color: #fff;
  border: 1px solid rgba(255, 255, 255, 0.35);
  box-shadow: none;
}
.ov__hero-btn--ghost:hover { background: rgba(255, 255, 255, 0.2); }

.ov__hero :deep(.el-button--primary) {
  background: #fff;
  color: #a05a2c;
  box-shadow: 0 8px 22px rgba(60, 40, 20, 0.3);
  position: relative;
  z-index: 1;
  white-space: nowrap;
}
.ov__hero :deep(.el-button--primary:hover) { background: #faf0e4; transform: translateY(-1px); }

/* —— 统计卡 —— */
.ov__stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
  margin-bottom: 30px;
}
.ov__stat {
  display: flex;
  align-items: center;
  gap: 12px;
  background: var(--cc-bg-card);
  border: 1px solid var(--cc-border-light);
  border-radius: var(--cc-radius-lg);
  padding: 16px 18px;
  box-shadow: var(--cc-shadow-sm);
  backdrop-filter: blur(8px);
  transition: var(--cc-transition-fast);
}
.ov__stat:hover { transform: translateY(-2px); box-shadow: var(--cc-shadow-md); }
.ov__stat-icon {
  width: 44px;
  height: 44px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 21px;
  flex-shrink: 0;
  transition: var(--cc-transition-fast);
}
.ov__stat:hover .ov__stat-icon { transform: scale(1.08) rotate(-4deg); }
.ov__stat-icon--a { background: linear-gradient(135deg, #ecd5c0, #f0dcc4); color: #a05a2c; }
.ov__stat-icon--b { background: linear-gradient(135deg, #f3e5d3, #e8d0b4); color: #b45309; }
.ov__stat-icon--c { background: linear-gradient(135deg, #d1fae5, #a7f3d0); color: #059669; }
.ov__stat-icon--d { background: linear-gradient(135deg, #ffedd5, #fed7aa); color: #ea580c; }

.ov__hero-mark {
  position: absolute;
  right: 4px;
  bottom: -58px;
  font-size: 190px;
  line-height: 1;
  font-weight: 800;
  color: rgba(255, 255, 255, 0.07);
  pointer-events: none;
  user-select: none;
}
.ov__stat > div { display: flex; flex-direction: column; line-height: 1.25; }
.ov__stat-num { font-size: 22px; font-weight: 800; color: var(--cc-text-main); }
.ov__stat-label { font-size: 12px; color: var(--cc-text-muted); }

/* —— 区块 —— */
.ov__block { margin-bottom: 30px; }
.ov__blockhead { display: flex; align-items: baseline; justify-content: space-between; }
.ov__blocktitle {
  margin: 0 0 14px;
  font-size: 16px;
  font-weight: 800;
  color: var(--cc-text-main);
  display: flex;
  align-items: center;
  gap: 8px;
}
.ov__blocktitle::before {
  content: '';
  width: 4px;
  height: 15px;
  border-radius: 4px;
  background: var(--cc-gradient);
}
.ov__more { font-size: 13px; color: var(--cc-primary); font-weight: 600; }

.ov__projects { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.ov__project {
  background: var(--cc-bg-card);
  border: 1px solid var(--cc-border-light);
  border-radius: var(--cc-radius-lg);
  padding: 15px 18px;
  box-shadow: var(--cc-shadow-sm);
  transition: var(--cc-transition-fast);
}
.ov__project:hover { box-shadow: var(--cc-shadow-md); transform: translateY(-1px); }
.ov__project-head {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 10px;
}
.ov__project-name { font-size: 13.5px; font-weight: 700; color: var(--cc-text-main); }
.ov__project-pct { display: flex; align-items: baseline; gap: 6px; }
.ov__project-pct b { font-size: 14px; color: var(--cc-primary); }
.ov__project-pct i { font-style: normal; font-size: 11px; color: var(--cc-text-muted); }

.ov__recent { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }

@media (max-width: 900px) {
  .ov__stats { grid-template-columns: repeat(2, 1fr); }
  .ov__projects, .ov__recent { grid-template-columns: 1fr; }
  .ov__hero { flex-direction: column; align-items: flex-start; padding: 26px; }
}
</style>
