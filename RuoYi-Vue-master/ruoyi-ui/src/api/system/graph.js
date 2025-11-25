import request from '@/utils/request'

// 查询知识图谱列表
export function listGraph(query) {
  return request({
    url: '/system/graph/list',
    method: 'get',
    params: query
  })
}

// 查询知识图谱详细
export function getGraph(id) {
  return request({
    url: '/system/graph/' + id,
    method: 'get'
  })
}

// 新增知识图谱
export function addGraph(data) {
  return request({
    url: '/system/graph',
    method: 'post',
    data: data
  })
}

// 修改知识图谱
export function updateGraph(data) {
  return request({
    url: '/system/graph',
    method: 'put',
    data: data
  })
}

// 删除知识图谱
export function delGraph(id) {
  return request({
    url: '/system/graph/' + id,
    method: 'delete'
  })
}

// 触发为指定课程生成知识图谱
export function extractCourseGraph(courseId) {
  return request({
    url: '/system/graph/extract/course/' + courseId,
    method: 'post'
  })
}

// 触发为指定章节生成知识图谱
export function extractChapterGraph(courseId, chapterId) {
  return request({
    url: '/system/graph/extract/chapter/' + courseId + '/' + chapterId,
    method: 'post'
  })
}
