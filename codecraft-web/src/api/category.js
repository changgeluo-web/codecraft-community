import request from './request'

/** 项目（分类）列表，含知识点数量 */
export function getCategories() {
  return request.get('/categories')
}

/** 新建项目 */
export function createCategory(data) {
  return request.post('/categories', data)
}

/** 编辑项目 */
export function updateCategory(id, data) {
  return request.put(`/categories/${id}`, data)
}

/** 删除项目（项目下存在知识点时后端会拒绝） */
export function deleteCategory(id) {
  return request.delete(`/categories/${id}`)
}
