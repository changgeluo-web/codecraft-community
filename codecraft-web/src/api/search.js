import request from './request'

/** 搜索知识点（标题 / 内容 / 标签 / 作者） */
export function searchPosts(params) {
  return request.get('/search', { params })
}