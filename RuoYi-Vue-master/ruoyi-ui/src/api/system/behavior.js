import request from '@/utils/request'

// 查询视频学习行为列表
export function listBehavior(query) {
  return request({
    url: '/system/video-behavior/list',
    method: 'get',
    params: query
  })
}

// 查询视频学习行为详细
export function getBehavior(id) {
  return request({
    url: '/system/video-behavior/' + id,
    method: 'get'
  })
}

// 根据学生ID和视频ID查询学习行为记录
export function findBehaviorByStudentAndVideo(studentId, videoId) {
  return request({
    url: '/system/video-behavior/query/byStudentAndVideo',
    method: 'get',
    params: {
      studentId: studentId,
      videoId: videoId
    }
  })
}

// 新增视频学习行为
export function addBehavior(data) {
  return request({
    url: '/system/video-behavior',
    method: 'post',
    data: data
  })
}

// 插入或更新视频学习行为（UPSERT操作）
export function upsertBehavior(data) {
  return request({
    url: '/system/video-behavior/upsert',
    method: 'post',
    data: data
  })
}

// 修改视频学习行为
export function updateBehavior(data) {
  return request({
    url: '/system/video-behavior',
    method: 'put',
    data: data
  })
}

// 删除视频学习行为
export function delBehavior(id) {
  return request({
    url: '/system/video-behavior/' + id,
    method: 'delete'
  })
}
