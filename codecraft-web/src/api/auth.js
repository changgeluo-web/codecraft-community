import request from './request'

/** 注册 */
export function register(data) {
  return request.post('/auth/register', data)
}

/** 登录 */
export function login(data) {
  return request.post('/auth/login', data)
}

/** 登出 */
export function logout() {
  return request.post('/auth/logout')
}

/** 刷新令牌 */
export function refreshToken(data) {
  return request.post('/auth/refresh', data)
}