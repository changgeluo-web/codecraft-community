import request from './request'

/** 知识点列表（分页 / 分类 / 关键词 / 标签） */
export function getPosts(params) {
  return request.get('/posts', { params })
}

/** 知识点详情 */
export function getPost(id) {
  return request.get(`/posts/${id}`)
}

/** 同一项目内的上一条/下一条（按排序序号） */
export function getNeighbors(id) {
  return request.get(`/posts/${id}/neighbors`)
}

/** 发布知识点 */
export function createPost(data) {
  return request.post('/posts', data)
}

/** 编辑知识点 */
export function updatePost(id, data) {
  return request.put(`/posts/${id}`, data)
}

/** 删除知识点 */
export function deletePost(id) {
  return request.delete(`/posts/${id}`)
}

/** 更新学习状态：0待学 1学习中 2已掌握 */
export function updateStudyStatus(id, status) {
  return request.put(`/posts/${id}/study-status`, null, { params: { status } })
}

/** 学习统计 */
export function getStudyStats(categoryId) {
  return request.get('/posts/study-stats', { params: { categoryId } })
}

/** 项目进度看板 */
export function getDashboard() {
  return request.get('/posts/dashboard')
}
