import request from './request'

/** 标签列表（可按项目过滤，返回该项目标签 + 全局标签） */
export function getTags(categoryId) {
  return request.get('/tags', { params: { categoryId } })
}

/** 新建标签 */
export function createTag(data) {
  return request.post('/tags', data)
}

/** 编辑标签 */
export function updateTag(id, data) {
  return request.put(`/tags/${id}`, data)
}

/** 删除标签 */
export function deleteTag(id) {
  return request.delete(`/tags/${id}`)
}
