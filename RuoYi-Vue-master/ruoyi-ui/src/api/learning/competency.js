import request from '@/utils/request'

// 查询课程能力点（定义能力模型维度）列表
export function listCompetency(query) {
  return request({
    url: '/learning/competency/list',
    method: 'get',
    params: query
  })
}

// 查询课程能力点（定义能力模型维度）详细
export function getCompetency(id) {
  return request({
    url: '/learning/competency/' + id,
    method: 'get'
  })
}

// 新增课程能力点（定义能力模型维度）
export function addCompetency(data) {
  return request({
    url: '/learning/competency',
    method: 'post',
    data: data
  })
}

// 修改课程能力点（定义能力模型维度）
export function updateCompetency(data) {
  return request({
    url: '/learning/competency',
    method: 'put',
    data: data
  })
}

// 删除课程能力点（定义能力模型维度）
export function delCompetency(id) {
  return request({
    url: '/learning/competency/' + id,
    method: 'delete'
  })
}
