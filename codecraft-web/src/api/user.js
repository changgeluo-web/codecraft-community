import request from './request'

/** 获取当前登录用户信息 */
export function getMe() {
  return request.get('/users/me')
}

/** 修改个人资料 */
export function updateMe(data) {
  return request.put('/users/me', data)
}

/** 修改密码 */
export function changePassword(data) {
  return request.put('/users/me/password', data)
}
