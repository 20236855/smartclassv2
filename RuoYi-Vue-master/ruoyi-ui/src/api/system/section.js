import request from '@/utils/request'

// 查询课程小节列表
export function listSection(query) {
  return request({
    url: '/system/section/list',
    method: 'get',
    params: query
  })
}

// 查询课程小节详细
export function getSection(id) {
  return request({
    url: '/system/section/' + id,
    method: 'get'
  })
}

// 新增课程小节
export function addSection(data) {
  return request({
    url: '/system/section',
    method: 'post',
    data: data
  })
}

// 修改课程小节
export function updateSection(data) {
  return request({
    url: '/system/section',
    method: 'put',
    data: data
  })
}

// 删除课程小节
export function delSection(id) {
  return request({
    url: '/system/section/' + id,
    method: 'delete'
  })
}

