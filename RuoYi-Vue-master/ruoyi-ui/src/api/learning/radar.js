// 导入若依的请求工具
import request from '@/utils/request'

/**
 * 查询学生能力雷达图数据
 * @param {Object} params - { studentId: 学生ID, courseId: 课程ID }
 * @returns {Promise} - 后端返回的数据
 */
export function getRadarData(params) {
  // 注意：这里的URL要和后端Controller的@RequestMapping一致！
  // 后端Controller路径是 /learning/radar/getData，所以这里写 '/learning/radar/getData'
  return request({
    url: '/learning/radar/getData',
    method: 'get',
    params: params  // 传递查询参数（studentId和courseId）
  })
}