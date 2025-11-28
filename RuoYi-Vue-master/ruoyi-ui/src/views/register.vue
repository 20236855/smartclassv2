<template>
  <div class="register">
    <!-- 左侧注册表单区域 -->
    <div class="register-left">
      <el-form ref="registerForm" :model="registerForm" :rules="registerRules" class="register-form">
        <h3 class="title">{{title}}</h3>
        <el-form-item prop="username">
          <el-input v-model="registerForm.username" type="text" auto-complete="off" placeholder="账号">
            <svg-icon slot="prefix" icon-class="user" class="el-input__icon input-icon" />
          </el-input>
        </el-form-item>
        <el-form-item prop="email">
          <el-input v-model="registerForm.email" type="text" auto-complete="off" placeholder="邮箱">
            <svg-icon slot="prefix" icon-class="email" class="el-input__icon input-icon" />
          </el-input>
        </el-form-item>
        <el-form-item prop="emailCode">
          <el-input
            v-model="registerForm.emailCode"
            auto-complete="off"
            placeholder="邮箱验证码"
            style="width: 63%"
          >
            <svg-icon slot="prefix" icon-class="validCode" class="el-input__icon input-icon" />
          </el-input>
          <el-button
            class="email-code-btn"
            :disabled="emailCodeDisabled"
            @click="sendEmailCode"
          >
            {{ emailCodeText }}
          </el-button>
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="registerForm.password"
            type="password"
            auto-complete="off"
            placeholder="密码"
            @keyup.enter.native="handleRegister"
          >
            <svg-icon slot="prefix" icon-class="password" class="el-input__icon input-icon" />
          </el-input>
        </el-form-item>
        <el-form-item prop="confirmPassword">
          <el-input
            v-model="registerForm.confirmPassword"
            type="password"
            auto-complete="off"
            placeholder="确认密码"
            @keyup.enter.native="handleRegister"
          >
            <svg-icon slot="prefix" icon-class="password" class="el-input__icon input-icon" />
          </el-input>
        </el-form-item>
        <el-form-item prop="code" v-if="captchaEnabled">
          <el-input
            v-model="registerForm.code"
            auto-complete="off"
            placeholder="图形验证码"
            style="width: 63%"
            @keyup.enter.native="handleRegister"
          >
            <svg-icon slot="prefix" icon-class="validCode" class="el-input__icon input-icon" />
          </el-input>
          <div class="register-code">
            <img :src="codeUrl" @click="getCode" class="register-code-img"/>
          </div>
        </el-form-item>
        <el-form-item style="width:100%;">
          <el-button
            :loading="loading"
            size="medium"
            type="primary"
            style="width:100%;"
            @click.native.prevent="handleRegister"
          >
            <span v-if="!loading">注 册</span>
            <span v-else>注 册 中...</span>
          </el-button>
          <div style="float: right;">
            <router-link class="link-type" :to="'/login'">使用已有账户登录</router-link>
          </div>
        </el-form-item>
      </el-form>
    </div>

    <!-- 右侧图片区域 -->
    <div class="register-right">
      <div class="image-container">
        <canvas ref="particleCanvas" class="particle-canvas"></canvas>
        <img :src="registerImage" class="register-image" alt="注册背景" />
      </div>
    </div>

    <!--  底部  -->
    <div class="el-register-footer">
      <span>Copyright © 2018-2025 智慧课程系统 All Rights Reserved.</span>
    </div>
  </div>
</template>

<script>
import { getCodeImg, register, verifySyncStatus, sendEmailCode } from "@/api/login"
import registerImage from '@/assets/images/picture1.png'

export default {
  name: "Register",
  data() {
    const equalToPassword = (rule, value, callback) => {
      if (this.registerForm.password !== value) {
        callback(new Error("两次输入的密码不一致"))
      } else {
        callback()
      }
    }
    return {
      title: process.env.VUE_APP_TITLE,
      registerImage,
      codeUrl: "",
      particles: [],
      animationId: null,
      emailCodeDisabled: false,
      emailCodeText: "获取验证码",
      emailCodeTimer: null,
      registerForm: {
        username: "",
        email: "",
        emailCode: "",
        password: "",
        confirmPassword: "",
        code: "",
        uuid: ""
      },
      registerRules: {
        username: [
          { required: true, trigger: "blur", message: "请输入您的账号" },
          { min: 2, max: 20, message: '用户账号长度必须介于 2 和 20 之间', trigger: 'blur' }
        ],
        email: [
          { required: true, trigger: "blur", message: "请输入您的邮箱" },
          { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
        ],
        emailCode: [
          { required: true, trigger: "blur", message: "请输入邮箱验证码" }
        ],
        password: [
          { required: true, trigger: "blur", message: "请输入您的密码" },
          { min: 5, max: 20, message: "用户密码长度必须介于 5 和 20 之间", trigger: "blur" },
          { pattern: /^[^<>"'|\\]+$/, message: "不能包含非法字符：< > \" ' \\\ |", trigger: "blur" }
        ],
        confirmPassword: [
          { required: true, trigger: "blur", message: "请再次输入您的密码" },
          { required: true, validator: equalToPassword, trigger: "blur" }
        ],
        code: [{ required: true, trigger: "change", message: "请输入图形验证码" }]
      },
      loading: false,
      captchaEnabled: true
    }
  },
  mounted() {
    this.initParticles()
  },
  beforeDestroy() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId)
    }
    if (this.emailCodeTimer) {
      clearInterval(this.emailCodeTimer)
    }
  },
  created() {
    this.getCode()
  },
  methods: {
    // 发送邮箱验证码
    sendEmailCode() {
      // 先验证邮箱格式
      this.$refs.registerForm.validateField('email', (errorMsg) => {
        if (errorMsg) {
          return
        }
        if (!this.registerForm.email) {
          this.$message.error('请输入邮箱')
          return
        }
        // 发送验证码
        sendEmailCode(this.registerForm.email).then(res => {
          this.$message.success('验证码已发送到您的邮箱，请注意查收')
          // 开始倒计时
          this.startCountdown()
        }).catch(err => {
          this.$message.error(err.msg || '发送失败，请稍后重试')
        })
      })
    },
    // 倒计时
    startCountdown() {
      let seconds = 60
      this.emailCodeDisabled = true
      this.emailCodeText = `${seconds}秒后重试`
      this.emailCodeTimer = setInterval(() => {
        seconds--
        if (seconds <= 0) {
          clearInterval(this.emailCodeTimer)
          this.emailCodeDisabled = false
          this.emailCodeText = '获取验证码'
        } else {
          this.emailCodeText = `${seconds}秒后重试`
        }
      }, 1000)
    },
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
        if (this.captchaEnabled) {
          this.codeUrl = "data:image/gif;base64," + res.img
          this.registerForm.uuid = res.uuid
        }
      })
    },
    handleRegister() {
      this.$refs.registerForm.validate(valid => {
        if (valid) {
          this.loading = true
          register(this.registerForm).then(res => {
            const username = this.registerForm.username

            // 验证同步状态
            this.verifySyncAndShowResult(username)
          }).catch(() => {
            this.loading = false
            if (this.captchaEnabled) {
              this.getCode()
            }
          })
        }
      })
    },
    verifySyncAndShowResult(username) {
      // 等待1秒确保触发器执行完成
      setTimeout(() => {
        verifySyncStatus(username).then(res => {
          this.loading = false
          const syncData = res.data

          // 构建同步状态消息
          let message = `<div style="text-align: left;">
            <h3 style="color: #67C23A; margin-bottom: 15px;">✅ 恭喜你，账号 ${username} 注册成功！</h3>
            <div style="background: #f5f7fa; padding: 15px; border-radius: 4px; margin-bottom: 15px;">
              <h4 style="margin-top: 0;">📊 数据同步验证结果：</h4>
              <p style="margin: 8px 0;">
                <span style="font-weight: bold;">记录同步：</span>
                ${syncData.synced ? '<span style="color: #67C23A;">✓ 已同步</span>' : '<span style="color: #F56C6C;">✗ 未同步</span>'}
              </p>
              <p style="margin: 8px 0;">
                <span style="font-weight: bold;">用户名匹配：</span>
                ${syncData.usernameMatch ? '<span style="color: #67C23A;">✓ 匹配</span>' : '<span style="color: #F56C6C;">✗ 不匹配</span>'}
              </p>
              <p style="margin: 8px 0;">
                <span style="font-weight: bold;">ID关联：</span>
                ${syncData.sysUserIdMatch ? '<span style="color: #67C23A;">✓ 正确</span>' : '<span style="color: #F56C6C;">✗ 错误</span>'}
              </p>
              <p style="margin: 8px 0;">
                <span style="font-weight: bold;">整体状态：</span>
                ${syncData.syncSuccess ? '<span style="color: #67C23A; font-weight: bold;">✓ 同步成功</span>' : '<span style="color: #F56C6C; font-weight: bold;">✗ 同步失败</span>'}
              </p>
            </div>`

          // 如果同步成功，显示详细信息
          if (syncData.syncSuccess && syncData.user) {
            message += `<div style="background: #ecf5ff; padding: 15px; border-radius: 4px; margin-bottom: 15px;">
              <h4 style="margin-top: 0; color: #409EFF;">📝 用户信息：</h4>
              <p style="margin: 5px 0;"><span style="font-weight: bold;">用户名：</span>${syncData.user.username}</p>
              <p style="margin: 5px 0;"><span style="font-weight: bold;">真实姓名：</span>${syncData.user.realName || '未设置'}</p>
              <p style="margin: 5px 0;"><span style="font-weight: bold;">邮箱：</span>${syncData.user.email || '未设置'}</p>
              <p style="margin: 5px 0;"><span style="font-weight: bold;">角色：</span><span style="color: #67C23A;">${syncData.user.role}</span></p>
              <p style="margin: 5px 0;"><span style="font-weight: bold;">状态：</span><span style="color: #67C23A;">${syncData.user.status}</span></p>
            </div>`
          }

          message += `<p style="color: #909399; font-size: 12px; margin-top: 10px;">提示：两个用户表（sys_user 和 user）已成功同步</p>
          </div>`

          this.$alert(message, '注册成功', {
            dangerouslyUseHTMLString: true,
            type: syncData.syncSuccess ? 'success' : 'warning',
            confirmButtonText: '去登录',
            callback: () => {
              this.$router.push("/login")
            }
          })
        }).catch(err => {
          this.loading = false
          // 即使验证失败，也显示注册成功
          this.$alert(`<font color='red'>恭喜你，您的账号 ${username} 注册成功！</font><br/><br/><font color='orange'>注意：同步状态验证失败，请联系管理员检查</font>`, '系统提示', {
            dangerouslyUseHTMLString: true,
            type: 'warning'
          }).then(() => {
            this.$router.push("/login")
          }).catch(() => {})
        })
      }, 1000)
    }
  }
}
</script>

<style rel="stylesheet/scss" lang="scss">
.register {
  display: flex;
  height: 100%;
  background: #ffffff;
  position: relative;
  overflow: hidden;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}

// ========== 左侧注册表单区域 ==========
.register-left {
  flex: 0 0 45%;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding: 60px 40px 60px 60px;
  position: relative;
}

// ========== 右侧图片区域 ==========
.register-right {
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

  .register-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    z-index: 1;
  }
}

.title {
  margin: 0px auto 35px auto;
  text-align: left;
  color: #001b46;
  font-size: 78px;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.register-form {
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
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
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
    margin-bottom: 20px;
  }

  .el-button--primary {
    background: #001d5c;
    border: none;
    border-radius: 8px;
    height: 50px;
    font-size: 16px;
    font-weight: 600;
    letter-spacing: 0.5px;
    transition: all 0.3s ease;

    &:hover {
      background: #283666;
      transform: translateY(-1px);
    }

    &:active {
      transform: translateY(0);
    }
  }

  .link-type {
    color: #042367;
    font-weight: 500;
    transition: all 0.3s ease;
    font-size: 14px;

    &:hover {
      color: #1e40af;
      text-decoration: underline;
    }
  }
}

.register-tip {
  font-size: 13px;
  text-align: center;
  color: #64748b;
}

.register-code {
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

.email-code-btn {
  width: 35%;
  height: 48px;
  float: right;
  border-radius: 8px;
  font-size: 14px;
  background: #001d5c;
  border: none;
  color: #fff;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover:not(:disabled) {
    background: #283666;
    transform: translateY(-1px);
  }

  &:disabled {
    background: #c0c4cc;
    cursor: not-allowed;
  }
}

.el-register-footer {
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

.register-code-img {
  height: 48px;
  border-radius: 8px;
}
</style>
