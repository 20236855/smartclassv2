import request from '@/utils/request'

// 查询选课申请列表
export function listRequest(query) {
  return request({
    url: '/system/request/list',
    method: 'get',
    params: query
  })
}

// 查询选课申请详细
export function getRequest(id) {
  return request({
    url: '/system/request/' + id,
    method: 'get'
  })
}

// 新增选课申请
export function addRequest(data) {
  return request({
    url: '/system/request',
    method: 'post',
    data: data
  })
}

// 修改选课申请
export function updateRequest(data) {
  return request({
    url: '/system/request',
    method: 'put',
    data: data
  })
}

// 删除选课申请
export function delRequest(id) {
  return request({
    url: '/system/request/' + id,
    method: 'delete'
  })
}

// 学生在课程页面发起选课申请
export function applyRequest(courseId, data) {
  return request({
    url: '/system/request/apply/' + courseId,
    method: 'post',
    data: data
  })
}
