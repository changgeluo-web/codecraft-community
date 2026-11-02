import { defineStore } from 'pinia'
import { getPosts } from '@/api/post'
import { getCategories } from '@/api/category'

/**
 * 知识库侧边栏状态：项目列表 + 每个项目下的知识点目录（懒加载）。
 */
export const useKnowledgeStore = defineStore('knowledge', {
  state: () => ({
    categories: [],
    categoriesLoaded: false,
    postsByCategory: {}, // categoryId -> [post]
    loadingCategory: null,
    expandedId: null,
    collapsed: false
  }),

  actions: {
    async fetchCategories(force = false) {
      if (this.categoriesLoaded && !force) return this.categories
      // 并发去重：多个组件同时挂载只发一次请求
      if (this._catPromise) return this._catPromise
      this._catPromise = getCategories()
        .then((data) => (this.categories = data || []))
        .finally(() => { this._catPromise = null })
      await this._catPromise
      this.categoriesLoaded = true
      // 默认展开第一个项目
      if (!this.expandedId && this.categories.length) {
        this.toggle(this.categories[0].id)
      }
      return this.categories
    },

    async fetchPosts(categoryId, force = false) {
      if (!force && this.postsByCategory[categoryId]) return this.postsByCategory[categoryId]
      this.loadingCategory = categoryId
      try {
        const data = await getPosts({ categoryId, page: 1, size: 500 })
        this.postsByCategory[categoryId] = data?.records || []
      } finally {
        this.loadingCategory = null
      }
      return this.postsByCategory[categoryId]
    },

    /** 知识点被增删改后，刷新对应项目目录 */
    refreshPosts(categoryId) {
      if (categoryId) this.fetchPosts(categoryId, true)
      this.fetchCategories(true)
    },

    toggle(categoryId) {
      this.expandedId = this.expandedId === categoryId ? null : categoryId
      if (this.expandedId) this.fetchPosts(this.expandedId)
    },

    async openPost(categoryId, postId) {
      this.expandedId = categoryId
      await this.fetchPosts(categoryId)
    }
  }
})
