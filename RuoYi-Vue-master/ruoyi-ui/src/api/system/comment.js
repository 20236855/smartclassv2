import request from '@/utils/request'

// 查询小节评论(讨论区)列表
export function listComment(query) {
  return request({
    url: '/system/comment/list',
    method: 'get',
    params: query
  })
}

// 查询小节评论(讨论区)详细
export function getComment(id) {
  return request({
    url: '/system/comment/' + id,
    method: 'get'
  })
}

// 新增小节评论(讨论区)
export function addComment(data) {
  return request({
    url: '/system/comment',
    method: 'post',
    data: data
  })
}

// 修改小节评论(讨论区)
export function updateComment(data) {
  return request({
    url: '/system/comment',
    method: 'put',
    data: data
  })
}

// 删除小节评论(讨论区)
export function delComment(id) {
  return request({
    url: '/system/comment/' + id,
    method: 'delete'
  })
}

export function getCommentTree(sectionId) {
  return request({
    url: '/system/comment/tree/' + sectionId,
    method: 'get'
  })
}
