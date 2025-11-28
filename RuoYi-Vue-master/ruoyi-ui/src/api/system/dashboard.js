import request from '@/utils/request'

/**
 * 获取学生数据看板数据
 * 包含：课程列表、作业提交状态、成绩数据、任务统计
 */
export function getStudentDashboardData() {
  return request({
    url: '/system/dashboard/student-data',
    method: 'get'
  })
}

