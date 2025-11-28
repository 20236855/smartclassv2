import request from '@/utils/request'

// 登录方法
export function login(username, password, code, uuid, userType) {
  const data = {
    username,
    password,
    code,
    uuid,
    userType
  }
  return request({
    url: '/login',
    headers: {
      isToken: false,
      repeatSubmit: false
    },
    method: 'post',
    data: data
  })
}

// 注册方法
export function register(data) {
  return request({
    url: '/register',
    headers: {
      isToken: false
    },
    method: 'post',
    data: data
  })
}

// 获取用户详细信息
export function getInfo() {
  return request({
    url: '/getInfo',
    method: 'get'
  })
}

// 退出方法
export function logout() {
  return request({
    url: '/logout',
    method: 'post'
  })
}

// 获取验证码
export function getCodeImg() {
  return request({
    url: '/captchaImage',
    headers: {
      isToken: false
    },
    method: 'get',
    timeout: 20000
  })
}

// 发送邮箱验证码
export function sendEmailCode(email) {
  return request({
    url: '/sendEmailCode',
    headers: {
      isToken: false
    },
    method: 'post',
    params: { email }
  })
}

// 验证用户同步状态
export function verifySyncStatus(username) {
  return request({
    url: '/verifySyncStatus',
    headers: {
      isToken: false
    },
    method: 'get',
    params: { username }
  })
}

// 通过邮箱查询用户
export function getUserByEmail(email) {
  return request({
    url: '/getUserByEmail',
    headers: {
      isToken: false
    },
    method: 'get',
    params: { email }
  })
}

// 发送重置密码验证码
export function sendResetPwdCode(email) {
  return request({
    url: '/sendResetPwdCode',
    headers: {
      isToken: false
    },
    method: 'post',
    params: { email }
  })
}

// 通过邮箱验证码重置密码
export function resetPwdByEmail(data) {
  return request({
    url: '/resetPwdByEmail',
    headers: {
      isToken: false
    },
    method: 'post',
    data: data
  })
}