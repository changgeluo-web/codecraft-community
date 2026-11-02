import { defineStore } from 'pinia'
import { login as apiLogin, register as apiRegister, logout as apiLogout } from '@/api/auth'
import { getMe as apiGetMe, updateMe as apiUpdateMe, changePassword as apiChangePassword } from '@/api/user'
import { getAccessToken, setTokens, clearTokens } from '@/utils/auth'

export const useUserStore = defineStore('user', {
  state: () => ({
    user: null, // 当前登录用户
    profileLoaded: false,
    token: getAccessToken() || '' // 响应式 token，驱动 isLoggedIn 更新
  }),

  getters: {
    isLoggedIn: (state) => !!state.token,
    isAdmin: (state) => state.user?.role === 'ADMIN',
    isModerator: (state) => ['ADMIN', 'MODERATOR'].includes(state.user?.role),
    userId: (state) => state.user?.id || null,
    nickname: (state) => state.user?.nickname || state.user?.username || ''
  },

  actions: {
    /** 登录 */
    async login(payload) {
      const data = await apiLogin(payload)
      setTokens(data.accessToken, data.refreshToken)
      this.token = data.accessToken || ''
      this.user = data.user || null
      return data
    },

    /** 注册 */
    async register(payload) {
      const data = await apiRegister(payload)
      setTokens(data.accessToken, data.refreshToken)
      this.token = data.accessToken || ''
      this.user = data.user || null
      return data
    },

    /** 拉取当前用户信息 */
    async fetchProfile() {
      if (!getAccessToken()) {
        this.profileLoaded = true
        return null
      }
      try {
        this.user = await apiGetMe()
      } catch (e) {
        this.user = null
      } finally {
        this.profileLoaded = true
      }
      return this.user
    },

    /** 更新资料 */
    async updateProfile(payload) {
      const data = await apiUpdateMe(payload)
      this.user = data || this.user
      return data
    },

    /** 修改密码 */
    changePassword(payload) {
      return apiChangePassword(payload)
    },

    /** 登出 */
    async logout() {
      try {
        await apiLogout()
      } catch (e) {
        // 忽略登出接口异常
      }
      clearTokens()
      this.token = ''
      this.user = null
    }
  }
})