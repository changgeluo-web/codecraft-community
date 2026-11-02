<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useKnowledgeStore } from '@/stores/knowledge'
import UserAvatar from './UserAvatar.vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const knowledgeStore = useKnowledgeStore()

const keyword = ref(route.query.keyword || '')

const inKnowledge = computed(() => route.path === '/' || route.path.startsWith('/post/'))

function onSearch() {
  const kw = keyword.value.trim()
  if (!kw) return
  router.push({ path: '/search', query: { keyword: kw } })
}

function goWrite() {
  if (!userStore.isLoggedIn) {
    router.push({ path: '/login', query: { redirect: '/' } })
    return
  }
  router.push('/editor')
}

async function handleLogout() {
  await userStore.logout()
  router.push('/')
}

function handleUserCommand(cmd) {
  if (cmd === 'logout') { handleLogout(); return }
  router.push(cmd)
}

if (userStore.isLoggedIn && !userStore.profileLoaded) userStore.fetchProfile()
</script>

<template>
  <header class="hdr">
    <div class="hdr__inner">
      <div class="hdr__left">
        <button v-if="inKnowledge" class="hdr__iconbtn" :title="knowledgeStore.collapsed ? '展开目录' : '收起目录'" @click="knowledgeStore.collapsed = !knowledgeStore.collapsed">
          <el-icon><Fold v-if="!knowledgeStore.collapsed" /><Expand v-else /></el-icon>
        </button>
        <router-link to="/" class="hdr__logo">
          <span class="hdr__logo-icon">⌘</span>
          <span class="hdr__logo-text">知识记录系统</span>
        </router-link>
      </div>

      <div class="hdr__search">
        <el-input v-model="keyword" placeholder="搜索知识点…" clearable @keyup.enter="onSearch">
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
      </div>

      <div class="hdr__actions">
        <button class="hdr__write" @click="goWrite">
          <el-icon style="font-size:14px"><EditPen /></el-icon>
          <span>记录知识点</span>
        </button>

        <template v-if="userStore.isLoggedIn">
          <el-dropdown trigger="click" @command="handleUserCommand">
            <div class="hdr__user">
              <UserAvatar :user="userStore.user" :size="30" />
              <span class="hdr__username">{{ userStore.nickname }}</span>
              <el-icon class="hdr__caret"><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="/settings">
                  <el-icon><Setting /></el-icon>&nbsp;个人设置
                </el-dropdown-item>
                <el-dropdown-item command="/search">
                  <el-icon><Search /></el-icon>&nbsp;搜索知识点
                </el-dropdown-item>
                <el-dropdown-item divided command="logout">
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </template>
        <button v-else class="hdr__login" @click="router.push('/login')">登录</button>
      </div>
    </div>
  </header>
</template>

<style scoped>
.hdr {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: var(--cc-header-height);
  background: linear-gradient(180deg, rgba(58, 44, 30, 0.96), rgba(47, 37, 26, 0.94));
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
  z-index: 100;
}

.hdr__inner {
  height: 100%;
  max-width: 1560px;
  margin: 0 auto;
  padding: 0 18px;
  display: flex;
  align-items: center;
  gap: 14px;
}

.hdr__left { display: flex; align-items: center; gap: 6px; }

.hdr__iconbtn {
  border: none;
  background: transparent;
  color: #b8a184;
  cursor: pointer;
  display: flex;
  align-items: center;
  padding: 7px;
  border-radius: 9px;
  transition: var(--cc-transition-fast);
}
.hdr__iconbtn:hover { background: rgba(255, 255, 255, 0.08); color: #fff; }

.hdr__logo { display: flex; align-items: center; gap: 10px; }
.hdr__logo-icon {
  width: 32px;
  height: 32px;
  border-radius: 10px;
  background: var(--cc-gradient);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 17px;
  box-shadow: 0 4px 14px rgba(194, 112, 61, 0.5);
}
.hdr__logo-text {
  font-size: 16px;
  font-weight: 800;
  letter-spacing: 0.02em;
  color: #fff;
  white-space: nowrap;
}

.hdr__search {
  flex: 1;
  max-width: 420px;
  margin-left: auto;
}
.hdr__search :deep(.el-input__wrapper) {
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.08);
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.08);
  padding-left: 16px;
  transition: var(--cc-transition-fast);
}
.hdr__search :deep(.el-input__wrapper:hover) { background: rgba(255, 255, 255, 0.12); }
.hdr__search :deep(.el-input__wrapper.is-focus) {
  background: rgba(40, 31, 21, 0.6);
  box-shadow: inset 0 0 0 1.5px rgba(217, 160, 107, 0.7), 0 0 0 4px rgba(194, 112, 61, 0.18);
}
.hdr__search :deep(.el-input__inner) { color: #f8f1e6; }
.hdr__search :deep(.el-input__inner::placeholder) { color: #9c8468; }
.hdr__search :deep(.el-input__prefix) { color: #9c8468; }

.hdr__actions { display: flex; align-items: center; gap: 12px; }

.hdr__write {
  display: flex;
  align-items: center;
  gap: 6px;
  border: none;
  cursor: pointer;
  padding: 9px 18px;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 700;
  color: #fff;
  background: var(--cc-gradient);
  box-shadow: 0 4px 16px rgba(194, 112, 61, 0.45);
  transition: var(--cc-transition-fast);
  white-space: nowrap;
}
.hdr__write:hover { transform: translateY(-1.5px); box-shadow: 0 8px 22px rgba(194, 112, 61, 0.6); }
.hdr__write:active { transform: translateY(0); }

.hdr__user {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 10px 4px 5px;
  border-radius: 999px;
  border: 1px solid transparent;
  transition: var(--cc-transition-fast);
}
.hdr__user:hover { background: rgba(255, 255, 255, 0.08); border-color: rgba(255, 255, 255, 0.1); }
.hdr__username { font-size: 13px; color: #ecdfcc; max-width: 90px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.hdr__caret { color: #9c8468; font-size: 12px; }

.hdr__login {
  border: none;
  cursor: pointer;
  padding: 8px 22px;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 700;
  color: #a05a2c;
  background: #fff;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.25);
  transition: var(--cc-transition-fast);
}
.hdr__login:hover { transform: translateY(-1px); background: #faf0e4; }

@media (max-width: 720px) {
  .hdr__search { display: none; }
  .hdr__username { display: none; }
}
</style>
