import request from '@/utils/request'

// 查询学生学习行为记录（视频/资源/互动行为）列表
export function listLbehavior(query) {
  return request({
    url: '/system/lbehavior/list',
    method: 'get',
    params: query
  })
}

// 查询学生学习行为记录（视频/资源/互动行为）详细
export function getLbehavior(id) {
  return request({
    url: '/system/lbehavior/' + id,
    method: 'get'
  })
}

// 新增学生学习行为记录（视频/资源/互动行为）
export function addLbehavior(data) {
  return request({
    url: '/system/lbehavior',
    method: 'post',
    data: data
  })
}

// 修改学生学习行为记录（视频/资源/互动行为）
export function updateLbehavior(data) {
  return request({
    url: '/system/lbehavior',
    method: 'put',
    data: data
  })
}

// 删除学生学习行为记录（视频/资源/互动行为）
export function delLbehavior(id) {
  return request({
    url: '/system/lbehavior/' + id,
    method: 'delete'
  })
}

// 查询当前用户的学习行为记录
export function myLbehavior(query) {
  return request({
    url: '/system/lbehavior/my',
    method: 'get',
    params: query
  })
}

// ==================== 自动记录学习行为 ====================

/**
 * 记录学习行为（自动判断新增或更新）
 * @param {Object} data 行为数据
 */
export function recordBehavior(data) {
  return request({
    url: '/system/lbehavior/record',
    method: 'post',
    data: data
  })
}

/**
 * 记录视频观看行为
 * @param {Long} courseId 课程ID
 * @param {Long} sectionId 小节ID（视频ID）
 * @param {Number} startTime 开始秒
 * @param {Number} endTime 结束秒
 * @param {Number} duration 本次观看时长
 * @param {Boolean} isReplay 是否重复观看
 */
export function recordVideoView(courseId, sectionId, startTime, endTime, duration, isReplay = false) {
  return recordBehavior({
    courseId: courseId,
    behaviorType: 'video_view',
    targetId: sectionId,
    targetType: 'section',
    duration: Math.floor(duration || 0),
    detail: JSON.stringify({
      start_time: Math.floor(startTime || 0),
      end_time: Math.floor(endTime || 0),
      is_replay: isReplay ? 1 : 0
    })
  })
}

/**
 * 记录资源查看行为
 * @param {Long} courseId 课程ID
 * @param {Long} resourceId 资源ID
 * @param {String} viewPages 查看页数（如 "1-5"）
 * @param {Boolean} isBookmark 是否收藏
 */
export function recordResourceView(courseId, resourceId, viewPages = '', isBookmark = false) {
  return recordBehavior({
    courseId: courseId,
    behaviorType: 'resource_view',
    targetId: resourceId,
    targetType: 'course_resource',
    detail: JSON.stringify({
      view_pages: viewPages,
      is_bookmark: isBookmark ? 1 : 0
    })
  })
}

/**
 * 记录资源下载行为
 * @param {Long} courseId 课程ID
 * @param {Long} resourceId 资源ID
 */
export function recordResourceDownload(courseId, resourceId) {
  return recordBehavior({
    courseId: courseId,
    behaviorType: 'resource_download',
    targetId: resourceId,
    targetType: 'course_resource',
    detail: JSON.stringify({
      download_time: new Date().toISOString()
    })
  })
}

/**
 * 记录评论行为
 * @param {Long} courseId 课程ID
 * @param {Long} commentId 评论ID
 * @param {Long} sectionId 小节ID
 */
export function recordComment(courseId, commentId, sectionId) {
  return recordBehavior({
    courseId: courseId,
    behaviorType: 'comment',
    targetId: commentId,
    targetType: 'section_comment',
    detail: JSON.stringify({
      section_id: sectionId,
      comment_time: new Date().toISOString()
    })
  })
}
