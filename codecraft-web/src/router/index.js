import { createRouter, createWebHistory } from 'vue-router'
import { getAccessToken } from '@/utils/auth'

const routes = [
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    children: [
      {
        path: '',
        component: () => import('@/layouts/KnowledgeLayout.vue'),
        children: [
          {
            path: '',
            name: 'home',
            component: () => import('@/views/OverviewView.vue'),
            meta: { title: '知识首页' }
          },
          {
            path: 'post/:id',
            name: 'post-detail',
            component: () => import('@/views/PostDetailView.vue'),
            meta: { title: '知识点详情' }
          }
        ]
      },
      {
        path: 'search',
        name: 'search',
        component: () => import('@/views/SearchView.vue'),
        meta: { title: '搜索' }
      },
      {
        path: 'editor',
        name: 'editor',
        component: () => import('@/views/EditorView.vue'),
        meta: { title: '记录知识点', requiresAuth: true }
      },
      {
        path: 'editor/:id',
        name: 'editor-edit',
        component: () => import('@/views/EditorView.vue'),
        meta: { title: '编辑知识点', requiresAuth: true }
      },
      {
        path: 'settings',
        name: 'settings',
        component: () => import('@/views/SettingsView.vue'),
        meta: { title: '个人设置', requiresAuth: true }
      }
    ]
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/LoginView.vue'),
    meta: { title: '登录', guestOnly: true }
  },
  {
    path: '/register',
    name: 'register',
    component: () => import('@/views/RegisterView.vue'),
    meta: { title: '注册', guestOnly: true }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/views/NotFoundView.vue'),
    meta: { title: '页面不存在' }
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

router.beforeEach(async (to) => {
  const loggedIn = !!getAccessToken()

  if (to.meta.requiresAuth && !loggedIn) {
    return { path: '/login', query: { redirect: to.fullPath } }
  }

  if (to.meta.guestOnly && loggedIn) {
    return { path: '/' }
  }

  return true
})

router.afterEach((to) => {
  document.title = to.meta.title ? `${to.meta.title} · 知识记录系统` : '知识记录系统'
})

export default router
