import request from '@/utils/request'

// 查询能力点-知识点关联（支撑能力模型与知识点的映射）列表
export function listRelation(query) {
  return request({
    url: '/learning/relation/list',
    method: 'get',
    params: query
  })
}

// 查询能力点-知识点关联（支撑能力模型与知识点的映射）详细
export function getRelation(id) {
  return request({
    url: '/learning/relation/' + id,
    method: 'get'
  })
}

// 新增能力点-知识点关联（支撑能力模型与知识点的映射）
export function addRelation(data) {
  return request({
    url: '/learning/relation',
    method: 'post',
    data: data
  })
}

// 修改能力点-知识点关联（支撑能力模型与知识点的映射）
export function updateRelation(data) {
  return request({
    url: '/learning/relation',
    method: 'put',
    data: data
  })
}

// 删除能力点-知识点关联（支撑能力模型与知识点的映射）
export function delRelation(id) {
  return request({
    url: '/learning/relation/' + id,
    method: 'delete'
  })
}
