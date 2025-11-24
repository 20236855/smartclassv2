import request from '@/utils/request'

// 查询学生知识点掌握情况（支撑知识图谱状态标识）列表
export function listMastery(query) {
  return request({
    url: '/system/mastery/list',
    method: 'get',
    params: query
  })
}

// 查询学生知识点掌握情况（支撑知识图谱状态标识）详细
export function getMastery(id) {
  return request({
    url: '/system/mastery/' + id,
    method: 'get'
  })
}

// 新增学生知识点掌握情况（支撑知识图谱状态标识）
export function addMastery(data) {
  return request({
    url: '/system/mastery',
    method: 'post',
    data: data
  })
}

// 修改学生知识点掌握情况（支撑知识图谱状态标识）
export function updateMastery(data) {
  return request({
    url: '/system/mastery',
    method: 'put',
    data: data
  })
}

// 删除学生知识点掌握情况（支撑知识图谱状态标识）
export function delMastery(id) {
  return request({
    url: '/system/mastery/' + id,
    method: 'delete'
  })
}
