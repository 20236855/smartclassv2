import request from '@/utils/request'

// 查询学生选课列表
export function listStudent(query) {
  return request({
    url: '/system/student/list',
    method: 'get',
    params: query
  })
}

// 查询学生选课详细
export function getStudent(id) {
  return request({
    url: '/system/student/' + id,
    method: 'get'
  })
}

// 新增学生选课
export function addStudent(data) {
  return request({
    url: '/system/student',
    method: 'post',
    data: data
  })
}

// 修改学生选课
export function updateStudent(data) {
  return request({
    url: '/system/student',
    method: 'put',
    data: data
  })
}

// 删除学生选课
export function delStudent(id) {
  return request({
    url: '/system/student/' + id,
    method: 'delete'
  })
}

// ⭐【关键新增】查询我的课程列表
export function getMyCourses() {
  return request({
    url: '/system/student/my-courses',
    method: 'get'
  })
}

// 退课接口
export function withdrawCourse(courseId) {
  return request({
    url: '/system/student/withdraw/' + courseId,
    method: 'delete'
  })
}
