import axios from 'axios'
import { ElMessage } from 'element-plus'
import { getAccessToken, getRefreshToken, setTokens, clearTokens } from '@/utils/auth'

const service = axios.create({
  baseURL: '/api',
  timeout: 15000
})

// 请求拦截：附加 Authorization；access token 临期(60s)先用 refresh 换新，
// 从源头避免带过期 token 请求导致的 401 控制台报错
service.interceptors.request.use(
  async (config) => {
    let token = getAccessToken()
    if (token) {
      if (tokenRemainingMs(token) < 60000 && getRefreshToken()) {
        try {
          token = await refreshOnce()
        } catch (e) {
          /* 刷新失败则维持旧 token，由响应拦截器的 401 流程兜底 */
        }
      }
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// ---------- 401 刷新令牌逻辑 ----------
let isRefreshing = false
let pendingQueue = []

/** 解析 JWT 的 exp，返回剩余毫秒（解析失败按已过期处理） */
function tokenRemainingMs(token) {
  try {
    const payload = JSON.parse(atob(token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')))
    return payload.exp * 1000 - Date.now()
  } catch (e) {
    return -1
  }
}

/** 单飞刷新：并发请求共享同一个 refresh，避免重复刷新 */
let refreshPromise = null
function refreshOnce() {
  if (!refreshPromise) {
    refreshPromise = doRefresh().finally(() => { refreshPromise = null })
  }
  return refreshPromise
}

async function doRefresh() {
  const refreshToken = getRefreshToken()
  if (!refreshToken) throw new Error('无刷新令牌')
  // 使用原始 axios，避免再次进入拦截器
  const res = await axios.post('/api/auth/refresh', { refreshToken })
  const body = res.data
  const payload = body && body.data ? body.data : body
  if (!payload || !payload.accessToken) throw new Error('刷新令牌失败')
  setTokens(payload.accessToken, payload.refreshToken || refreshToken)
  return payload.accessToken
}

function redirectToLogin() {
  clearTokens()
  const current = window.location.pathname + window.location.search
  if (!current.startsWith('/login')) {
    window.location.href = `/login?redirect=${encodeURIComponent(current)}`
  }
}

// 响应拦截：统一处理业务码 / 401
service.interceptors.response.use(
  (response) => {
    const res = response.data
    if (res && typeof res === 'object' && 'code' in res) {
      if (res.code === 200) {
        return res.data
      }
      if (res.code === 401) {
        redirectToLogin()
      } else {
        ElMessage.error(res.message || '请求失败')
      }
      return Promise.reject(new Error(res.message || `业务错误码 ${res.code}`))
    }
    return res
  },
  async (error) => {
    const { response, config } = error
    if (response && response.status === 401 && config && !config._retry) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          pendingQueue.push({ resolve, reject, config })
        })
      }
      config._retry = true
      isRefreshing = true
      try {
        const newToken = await refreshOnce()
        pendingQueue.forEach((item) => {
          item.config.headers.Authorization = `Bearer ${newToken}`
          item.resolve(service(item.config))
        })
        pendingQueue = []
        config.headers.Authorization = `Bearer ${newToken}`
        return service(config)
      } catch (refreshError) {
        pendingQueue.forEach((item) => item.reject(refreshError))
        pendingQueue = []
        redirectToLogin()
        ElMessage.error('登录状态已过期，请重新登录')
        return Promise.reject(refreshError)
      } finally {
        isRefreshing = false
      }
    }

    const message =
      (response && response.data && response.data.message) || error.message || '网络异常，请稍后重试'
    if (!(response && response.status === 401)) {
      ElMessage.error(message)
    }
    return Promise.reject(error)
  }
)

export default service