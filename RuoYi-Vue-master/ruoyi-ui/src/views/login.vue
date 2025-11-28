<template>
  <div class="login">
    <!-- 左侧登录表单区域 -->
    <div class="login-left">
      <el-form ref="loginForm" :model="loginForm" :rules="loginRules" class="login-form">
        <h3 class="title">{{title}}</h3>
        <!-- 身份选择 -->
        <el-form-item prop="userType">
          <el-radio-group v-model="loginForm.userType" class="user-type-selector">
            <el-radio-button label="TEACHER">
              <i class="el-icon-user"></i> 教师登录
            </el-radio-button>
            <el-radio-button label="STUDENT">
              <i class="el-icon-s-custom"></i> 学生登录
            </el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item prop="username">
          <el-input
            v-model="loginForm.username"
            type="text"
            auto-complete="off"
            placeholder="账号"
          >
            <svg-icon slot="prefix" icon-class="user" class="el-input__icon input-icon" />
          </el-input>
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            auto-complete="off"
            placeholder="密码"
            @keyup.enter.native="handleLogin"
          >
            <svg-icon slot="prefix" icon-class="password" class="el-input__icon input-icon" />
          </el-input>
        </el-form-item>
        <el-form-item prop="code" v-if="captchaEnabled">
          <el-input
            v-model="loginForm.code"
            auto-complete="off"
            placeholder="验证码"
            style="width: 63%"
            @keyup.enter.native="handleLogin"
          >
            <svg-icon slot="prefix" icon-class="validCode" class="el-input__icon input-icon" />
          </el-input>
          <div class="login-code">
            <img :src="codeUrl" @click="getCode" class="login-code-img"/>
          </div>
        </el-form-item>
        <div class="login-options">
          <el-checkbox v-model="loginForm.rememberMe">记住密码</el-checkbox>
          <span class="forget-pwd" @click="showResetPwdDialog">忘记密码？</span>
        </div>
        <el-form-item style="width:100%;">
          <el-button
            :loading="loading"
            size="medium"
            type="primary"
            style="width:100%;"
            @click.native.prevent="handleLogin"
          >
            <span v-if="!loading">登 录</span>
            <span v-else>登 录 中...</span>
          </el-button>
          <div style="float: right;" v-if="register">
            <router-link class="link-type" :to="'/register'">立即注册</router-link>
          </div>
        </el-form-item>
      </el-form>
    </div>

    <!-- 右侧图片区域 -->
    <div class="login-right">
      <div class="image-container">
        <canvas ref="particleCanvas" class="particle-canvas"></canvas>
        <img :src="loginImage" class="login-image" alt="登录背景" />
      </div>
    </div>

    <!--  底部  -->
    <div class="el-login-footer">
      <span>Copyright © 2018-2025 智慧课程系统 All Rights Reserved.</span>
    </div>

    <!-- 忘记密码对话框 -->
    <el-dialog
      title="重置密码"
      :visible.sync="resetPwdDialogVisible"
      width="420px"
      :close-on-click-modal="false"
      class="reset-pwd-dialog"
    >
      <el-form ref="resetPwdForm" :model="resetPwdForm" :rules="resetPwdRules" label-width="0">
        <!-- 邮箱输入和查询按钮 -->
        <el-form-item prop="email">
          <el-row :gutter="10">
            <el-col :span="16">
              <el-input
                v-model="resetPwdForm.email"
                placeholder="请输入绑定的邮箱"
                :disabled="resetUserInfo.userName !== ''"
              >
                <i slot="prefix" class="el-icon-message"></i>
              </el-input>
            </el-col>
            <el-col :span="8">
              <el-button
                type="primary"
                :loading="queryUserLoading"
                :disabled="resetUserInfo.userName !== ''"
                @click="queryUserByEmail"
                style="width: 100%;"
              >
                {{ resetUserInfo.userName ? '已查询' : '查询账号' }}
              </el-button>
            </el-col>
          </el-row>
        </el-form-item>

        <!-- 显示查询到的用户信息 -->
        <div v-if="resetUserInfo.userName" class="user-info-card">
          <div class="user-info-item">
            <span class="label">用户名：</span>
            <span class="value">{{ resetUserInfo.userName }}</span>
          </div>
          <div class="user-info-item" v-if="resetUserInfo.nickName">
            <span class="label">昵称：</span>
            <span class="value">{{ resetUserInfo.nickName }}</span>
          </div>
          <el-button type="text" size="small" @click="resetEmailQuery" style="padding: 0; margin-top: 5px;">
            <i class="el-icon-refresh"></i> 重新查询
          </el-button>
        </div>

        <!-- 验证码输入（查询到用户后显示） -->
        <el-form-item prop="code" v-if="resetUserInfo.userName">
          <el-row :gutter="10">
            <el-col :span="16">
              <el-input v-model="resetPwdForm.code" placeholder="请输入验证码">
                <i slot="prefix" class="el-icon-key"></i>
              </el-input>
            </el-col>
            <el-col :span="8">
              <el-button
                type="primary"
                :disabled="resetCodeBtnDisabled"
                @click="sendResetCode"
                style="width: 100%;"
              >
                {{ resetCodeBtnText }}
              </el-button>
            </el-col>
          </el-row>
        </el-form-item>

        <!-- 新密码输入（查询到用户后显示） -->
        <el-form-item prop="newPassword" v-if="resetUserInfo.userName">
          <el-input
            v-model="resetPwdForm.newPassword"
            type="password"
            placeholder="请输入新密码(5-20位)"
            show-password
          >
            <i slot="prefix" class="el-icon-lock"></i>
          </el-input>
        </el-form-item>

        <!-- 确认密码输入（查询到用户后显示） -->
        <el-form-item prop="confirmPassword" v-if="resetUserInfo.userName">
          <el-input
            v-model="resetPwdForm.confirmPassword"
            type="password"
            placeholder="请确认新密码"
            show-password
          >
            <i slot="prefix" class="el-icon-lock"></i>
          </el-input>
        </el-form-item>
      </el-form>
      <div slot="footer">
        <el-button @click="resetPwdDialogVisible = false">取 消</el-button>
        <el-button type="primary" :loading="resetPwdLoading" :disabled="!resetUserInfo.userName" @click="handleResetPwd">确认重置</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { getCodeImg, getUserByEmail, sendResetPwdCode, resetPwdByEmail } from "@/api/login"
import Cookies from "js-cookie"
import { encrypt, decrypt } from '@/utils/jsencrypt'
import loginImage from '@/assets/images/picture1.png'

export default {
  name: "Login",
  data() {
    // 确认密码校验
    const validateConfirmPwd = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('请再次输入新密码'))
      } else if (value !== this.resetPwdForm.newPassword) {
        callback(new Error('两次输入的密码不一致'))
      } else {
        callback()
      }
    }
    return {
      title: process.env.VUE_APP_TITLE,
      loginImage,
      codeUrl: "",
      particles: [],
      animationId: null,
      loginForm: {
        username: "admin",
        password: "admin123",
        rememberMe: false,
        code: "",
        uuid: "",
        userType: "STUDENT"  // 默认选择教师登录
      },
      loginRules: {
        userType: [
          { required: true, trigger: "change", message: "请选择登录身份" }
        ],
        username: [
          { required: true, trigger: "blur", message: "请输入您的账号" }
        ],
        password: [
          { required: true, trigger: "blur", message: "请输入您的密码" }
        ],
        code: [{ required: true, trigger: "change", message: "请输入验证码" }]
      },
      loading: false,
      // 验证码开关
      captchaEnabled: true,
      // 注册开关
      register: false,
      redirect: undefined,
      // 重置密码相关
      resetPwdDialogVisible: false,
      resetPwdLoading: false,
      queryUserLoading: false,
      resetCodeBtnDisabled: false,
      resetCodeBtnText: '获取验证码',
      resetCodeTimer: null,
      resetUserInfo: {
        userName: '',
        nickName: ''
      },
      resetPwdForm: {
        email: '',
        code: '',
        newPassword: '',
        confirmPassword: ''
      },
      resetPwdRules: {
        email: [
          { required: true, message: '请输入邮箱', trigger: 'blur' },
          { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
        ],
        code: [
          { required: true, message: '请输入验证码', trigger: 'blur' },
          { min: 6, max: 6, message: '验证码为6位数字', trigger: 'blur' }
        ],
        newPassword: [
          { required: true, message: '请输入新密码', trigger: 'blur' },
          { min: 5, max: 20, message: '密码长度必须在5到20个字符之间', trigger: 'blur' }
        ],
        confirmPassword: [
          { required: true, validator: validateConfirmPwd, trigger: 'blur' }
        ]
      }
    }
  },
  watch: {
    $route: {
      handler: function(route) {
        this.redirect = route.query && route.query.redirect
      },
      immediate: true
    }
  },
  mounted() {
    this.initParticles()
  },
  beforeDestroy() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId)
    }
  },
  created() {
    this.getCode()
    this.getCookie()
  },
  methods: {
    initParticles() {
      const canvas = this.$refs.particleCanvas
      if (!canvas) return

      const ctx = canvas.getContext('2d')
      canvas.width = canvas.offsetWidth
      canvas.height = canvas.offsetHeight

      // 创建粒子
      const particleCount = 100
      for (let i = 0; i < particleCount; i++) {
        this.particles.push({
          x: Math.random() * canvas.width,
          y: Math.random() * canvas.height,
          vx: (Math.random() - 0.5) * 0.8,
          vy: (Math.random() - 0.5) * 0.8,
          radius: Math.random() * 2.5 + 1,
          opacity: Math.random() * 0.6 + 0.3
        })
      }

      this.animateParticles(canvas, ctx)
    },

    animateParticles(canvas, ctx) {
      ctx.clearRect(0, 0, canvas.width, canvas.height)

      // 绘制粒子
      this.particles.forEach(particle => {
        ctx.beginPath()
        ctx.arc(particle.x, particle.y, particle.radius, 0, Math.PI * 2)
        ctx.fillStyle = `rgba(59, 130, 246, ${particle.opacity})`
        ctx.fill()

        // 更新位置
        particle.x += particle.vx
        particle.y += particle.vy

        // 边界检测
        if (particle.x < 0 || particle.x > canvas.width) particle.vx *= -1
        if (particle.y < 0 || particle.y > canvas.height) particle.vy *= -1
      })

      // 绘制连线
      for (let i = 0; i < this.particles.length; i++) {
        for (let j = i + 1; j < this.particles.length; j++) {
          const dx = this.particles[i].x - this.particles[j].x
          const dy = this.particles[i].y - this.particles[j].y
          const distance = Math.sqrt(dx * dx + dy * dy)

          if (distance < 150) {
            ctx.beginPath()
            ctx.strokeStyle = `rgba(59, 130, 246, ${0.2 * (1 - distance / 150)})`
            ctx.lineWidth = 1.5
            ctx.moveTo(this.particles[i].x, this.particles[i].y)
            ctx.lineTo(this.particles[j].x, this.particles[j].y)
            ctx.stroke()
          }
        }
      }

      this.animationId = requestAnimationFrame(() => this.animateParticles(canvas, ctx))
    },

    getCode() {
      getCodeImg().then(res => {
        this.captchaEnabled = res.captchaEnabled === undefined ? true : res.captchaEnabled
        // 获取注册开关状态
        this.register = res.register === undefined ? false : res.register
        if (this.captchaEnabled) {
          this.codeUrl = "data:image/gif;base64," + res.img
          this.loginForm.uuid = res.uuid
        }
      })
    },
    getCookie() {
      const username = Cookies.get("username")
      const password = Cookies.get("password")
      const rememberMe = Cookies.get('rememberMe')
      const userType = Cookies.get('userType')
      this.loginForm = {
        username: username === undefined ? this.loginForm.username : username,
        password: password === undefined ? this.loginForm.password : decrypt(password),
        rememberMe: rememberMe === undefined ? false : Boolean(rememberMe),
        userType: userType === undefined ? this.loginForm.userType : userType
      }
    },
    handleLogin() {
      this.$refs.loginForm.validate(valid => {
        if (valid) {
          this.loading = true
          if (this.loginForm.rememberMe) {
            Cookies.set("username", this.loginForm.username, { expires: 30 })
            Cookies.set("password", encrypt(this.loginForm.password), { expires: 30 })
            Cookies.set('rememberMe', this.loginForm.rememberMe, { expires: 30 })
            Cookies.set('userType', this.loginForm.userType, { expires: 30 })
          } else {
            Cookies.remove("username")
            Cookies.remove("password")
            Cookies.remove('rememberMe')
            Cookies.remove('userType')
          }
          this.$store.dispatch("Login", this.loginForm).then(() => {
            this.$router.push({ path: this.redirect || "/" }).catch(()=>{})
          }).catch(() => {
            this.loading = false
            if (this.captchaEnabled) {
              this.getCode()
            }
          })
        }
      })
    },
    // 显示重置密码对话框
    showResetPwdDialog() {
      this.resetPwdDialogVisible = true
      this.resetPwdForm = {
        email: '',
        code: '',
        newPassword: '',
        confirmPassword: ''
      }
      this.resetUserInfo = {
        userName: '',
        nickName: ''
      }
      this.$nextTick(() => {
        if (this.$refs.resetPwdForm) {
          this.$refs.resetPwdForm.resetFields()
        }
      })
    },
    // 通过邮箱查询用户
    queryUserByEmail() {
      if (!this.resetPwdForm.email) {
        this.$message.warning('请先输入邮箱')
        return
      }
      // 简单邮箱格式校验
      const emailReg = /^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$/
      if (!emailReg.test(this.resetPwdForm.email)) {
        this.$message.warning('请输入正确的邮箱格式')
        return
      }

      this.queryUserLoading = true
      getUserByEmail(this.resetPwdForm.email).then(res => {
        this.resetUserInfo = {
          userName: res.userName,
          nickName: res.nickName || ''
        }
        this.$message.success(`查询成功，用户名: ${res.userName}`)
      }).finally(() => {
        this.queryUserLoading = false
      })
    },
    // 重新查询邮箱
    resetEmailQuery() {
      this.resetUserInfo = {
        userName: '',
        nickName: ''
      }
      this.resetPwdForm = {
        email: '',
        code: '',
        newPassword: '',
        confirmPassword: ''
      }
      // 清除倒计时
      if (this.resetCodeTimer) {
        clearInterval(this.resetCodeTimer)
        this.resetCodeBtnDisabled = false
        this.resetCodeBtnText = '获取验证码'
      }
    },
    // 发送重置密码验证码
    sendResetCode() {
      if (!this.resetUserInfo.userName) {
        this.$message.warning('请先查询账号')
        return
      }

      this.resetCodeBtnDisabled = true
      sendResetPwdCode(this.resetPwdForm.email).then(res => {
        this.$message.success('验证码已发送，请查收邮箱')
        // 开始倒计时
        let countdown = 60
        this.resetCodeBtnText = `${countdown}s后重发`
        this.resetCodeTimer = setInterval(() => {
          countdown--
          if (countdown <= 0) {
            clearInterval(this.resetCodeTimer)
            this.resetCodeBtnDisabled = false
            this.resetCodeBtnText = '获取验证码'
          } else {
            this.resetCodeBtnText = `${countdown}s后重发`
          }
        }, 1000)
      }).catch(() => {
        this.resetCodeBtnDisabled = false
      })
    },
    // 执行重置密码
    handleResetPwd() {
      this.$refs.resetPwdForm.validate(valid => {
        if (valid) {
          this.resetPwdLoading = true
          resetPwdByEmail({
            email: this.resetPwdForm.email,
            code: this.resetPwdForm.code,
            newPassword: this.resetPwdForm.newPassword
          }).then(res => {
            this.$message.success('密码重置成功，请使用新密码登录')
            this.resetPwdDialogVisible = false
            // 清除倒计时和用户信息
            this.resetUserInfo = { userName: '', nickName: '' }
            if (this.resetCodeTimer) {
              clearInterval(this.resetCodeTimer)
              this.resetCodeBtnDisabled = false
              this.resetCodeBtnText = '获取验证码'
            }
          }).finally(() => {
            this.resetPwdLoading = false
          })
        }
      })
    }
  }
}
</script>

<style rel="stylesheet/scss" lang="scss">
.login {
  display: flex;
  height: 100%;
  background: #ffffff;
  position: relative;
  overflow: hidden;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}

// ========== 左侧登录表单区域 ==========
.login-left {
  flex: 0 0 45%;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding: 60px 40px 60px 60px;
  position: relative;
}

// ========== 右侧图片区域 ==========
.login-right {
  flex: 0 0 55%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  padding: 60px 60px 60px 40px;
  overflow: hidden;

  .image-container {
    position: relative;
    width: 680px;
    height: 680px;
    border-radius: 16px;
    overflow: hidden;
  }

  .particle-canvas {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 2;
    pointer-events: none;
  }

  .login-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    z-index: 1;
  }
}

.title {
  margin: 0px auto 40px auto;
  text-align: left;
  color: #05224f;
  font-size: 78px;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.login-form {
  width: 100%;
  max-width: 480px;
  padding: 0;

  .el-input {
    height: 48px;
    input {
      height: 48px;
      border-radius: 8px;
      border: 1px solid #e2e8f0;
      transition: all 0.3s ease;
      font-size: 15px;
      padding-left: 45px;
      background: #ffffff;

      &:focus {
        border-color: #b3cbff;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        background: #ffffff;
      }

      &::placeholder {
        color: #94a3b8;
      }
    }
  }

  .input-icon {
    height: 48px;
    width: 18px;
    margin-left: 4px;
    color: #64748b;
  }

  .el-form-item {
    margin-bottom: 22px;
  }

  .el-button--primary {
    background: #041946;
    border: none;
    border-radius: 8px;
    height: 50px;
    font-size: 16px;
    font-weight: 600;
    letter-spacing: 0.5px;
    transition: all 0.3s ease;

    &:hover {
      background: #506094;
      transform: translateY(-1px);
    }

    &:active {
      transform: translateY(0);
    }
  }

  .el-checkbox {
    color: #475569;
    font-size: 14px;

    .el-checkbox__input.is-checked .el-checkbox__inner {
      background-color: #002470;
      border-color: #7ea7ff;
    }

    .el-checkbox__label {
      color: #475569;
    }
  }

  .link-type {
    color: #002982;
    font-weight: 500;
    transition: all 0.3s ease;
    font-size: 14px;

    &:hover {
      color: #1e40af;
      text-decoration: underline;
    }
  }
}

.login-tip {
  font-size: 14px;
  text-align: center;
  color: #64748b;
}

.login-code {
  width: 33%;
  height: 48px;
  float: right;
  img {
    cursor: pointer;
    vertical-align: middle;
    border-radius: 8px;
    border: 1px solid #e2e8f0;
    transition: all 0.3s ease;

    &:hover {
      border-color: #2563eb;
    }
  }
}

.el-login-footer {
  height: 50px;
  line-height: 50px;
  position: fixed;
  bottom: 0;
  width: 100%;
  text-align: center;
  color: #64748b;
  font-family: Arial;
  font-size: 13px;
  letter-spacing: 0.5px;
  background: rgba(255, 255, 255, 0.95);
  z-index: 10;
}

.login-code-img {
  height: 48px;
  border-radius: 8px;
}

.user-type-selector {
  width: 100%;
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;

  .el-radio-button {
    flex: 1;
  }

  .el-radio-button__inner {
    width: 100%;
    padding: 14px 24px;
    font-size: 15px;
    font-weight: 500;
    border-radius: 8px;
    border: 1px solid #e2e8f0;
    background: #ffffff;
    color: #475569;
    transition: all 0.3s ease;

    i {
      margin-right: 8px;
      font-size: 16px;
    }

    &:hover {
      border-color: #cbd5e1;
      background: #f8fafc;
    }
  }

  .el-radio-button:first-child .el-radio-button__inner {
    border-radius: 8px 0 0 8px;
  }

  .el-radio-button:last-child .el-radio-button__inner {
    border-radius: 0 8px 8px 0;
  }

  .el-radio-button__orig-radio:checked + .el-radio-button__inner {
    background: #081f4f;
    border-color: #081f4f;
    color: #ffffff;
  }
}

// 登录选项（记住密码 + 忘记密码）
.login-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.forget-pwd {
  color: #002982;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    color: #1e40af;
    text-decoration: underline;
  }
}

// 重置密码对话框
.reset-pwd-dialog {
  .el-dialog {
    border-radius: 12px;
    overflow: hidden;
  }

  .el-dialog__header {
    background: linear-gradient(135deg, #041946 0%, #0a3d8f 100%);
    padding: 18px 24px;

    .el-dialog__title {
      color: #ffffff;
      font-weight: 600;
      font-size: 18px;
    }

    .el-dialog__headerbtn .el-dialog__close {
      color: #ffffff;
      font-size: 18px;
    }
  }

  .el-dialog__body {
    padding: 30px 24px 10px;
  }

  .el-dialog__footer {
    padding: 10px 24px 24px;
    border-top: none;
  }

  .el-input__inner {
    height: 44px;
    border-radius: 8px;
    border: 1px solid #e2e8f0;
    font-size: 14px;

    &:focus {
      border-color: #2563eb;
      box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.1);
    }
  }

  .el-input__prefix {
    left: 12px;
    color: #64748b;
  }

  .el-form-item {
    margin-bottom: 20px;
  }

  .el-button--primary {
    background: #041946;
    border-color: #041946;
    border-radius: 8px;
    font-weight: 500;

    &:hover {
      background: #0a3d8f;
      border-color: #0a3d8f;
    }
  }

  .el-button--default {
    border-radius: 8px;
  }

  .user-info-card {
    background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
    border: 1px solid #bae6fd;
    border-radius: 8px;
    padding: 12px 16px;
    margin-bottom: 20px;

    .user-info-item {
      display: flex;
      align-items: center;
      margin-bottom: 6px;

      &:last-of-type {
        margin-bottom: 0;
      }

      .label {
        color: #64748b;
        font-size: 13px;
        min-width: 60px;
      }

      .value {
        color: #0369a1;
        font-size: 14px;
        font-weight: 600;
      }
    }
  }
}
</style>
