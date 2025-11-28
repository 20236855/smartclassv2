import request from '@/utils/request'

// 查询作业或考试列表
export function listAssignment(query) {
  return request({
    url: '/system/assignment/list',
    method: 'get',
    params: query
  })
}

// 查询作业或考试详细
export function getAssignment(id) {
  return request({
    url: '/system/assignment/' + id,
    method: 'get'
  })
}

// 新增作业或考试
export function addAssignment(data) {
  return request({
    url: '/system/assignment',
    method: 'post',
    data: data
  })
}

// 修改作业或考试
export function updateAssignment(data) {
  return request({
    url: '/system/assignment',
    method: 'put',
    data: data
  })
}

// 删除作业或考试
export function delAssignment(id) {
  return request({
    url: '/system/assignment/' + id,
    method: 'delete'
  })
}

// 获取作业的题目列表（包含题目详情和选项）
export function getAssignmentQuestions(assignmentId) {
  return request({
    url: '/system/assignment/' + assignmentId + '/questions',
    method: 'get'
  })
}

// 获取我的提交记录
export function getMySubmissions() {
  return request({
    url: '/system/assignment/my-submissions',
    method: 'get'
  })
}

// 上传作业（上传型作业提交）
export function uploadAssignment(assignmentId, data) {
  return request({
    url: '/system/assignment/' + assignmentId + '/upload',
    method: 'post',
    data: data
  })
}

// 提交作业答案（答题型作业提交）
export function submitAssignment(assignmentId, data) {
  return request({
    url: '/system/assignment/' + assignmentId + '/submit',
    method: 'post',
    data: data
  })
}

// 获取作业提交详情
export function getSubmissionDetail(assignmentId) {
  return request({
    url: '/system/assignment/' + assignmentId + '/submission',
    method: 'get'
  })
}
