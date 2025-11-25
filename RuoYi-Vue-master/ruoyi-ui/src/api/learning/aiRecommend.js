import request from '@/utils/request'

/**
 * 获取AI个性化推荐结果
 * @param {Object} params - { studentUserId: 学生ID, courseId: 课程ID }
 * @returns {Promise} - 后端返回的AiRecommendResultVo数据
 */
export function getRecommendResult(params) {
  return request({
    url: '/system/ai/recommend/getResult', // 与后端Controller的@RequestMapping完全一致
    method: 'get',
    params: params,
    timeout: 30000
  })
}

/**
 * 获取大模型输入数据（调试用）
 * @param {Object} params - { studentUserId: 学生ID, courseId: 课程ID }
 * @returns {Promise} - 后端返回的拼接字符串
 */
export function getModelInput(params) {
  return request({
    url: '/system/ai/recommend/getModelInput', // 对应后端的getModelInput接口
    method: 'get',
    params: params,
    timeout: 30000
  })
}