<template>
  <div class="home-container">
    <!-- 内容层 -->
    <div class="content-layer">
      <!-- 顶部第一行：左时钟日期 / 中文字 -->
      <div class="top-card">
        <!-- 左：时钟 -->
        <div class="clock-display">
          <div class="clock-circle">
            <div class="clock-face">
              <div class="hand hour-hand" :style="{ transform: `rotate(${hourDeg}deg)` }"></div>
              <div class="hand minute-hand" :style="{ transform: `rotate(${minuteDeg}deg)` }"></div>
              <div class="hand second-hand" :style="{ transform: `rotate(${secondDeg}deg)` }"></div>
              <div class="clock-center"></div>
            </div>
          </div>
          <div class="time">{{ currentTime }}</div>
        </div>

        <!-- 中：欢迎文字 -->
        <div class="welcome-text">
          <div class="welcome-header">
            <div class="welcome-sub">{{ currentMotto }}</div>
          </div>
        </div>
      </div>

      <!-- 第二行：左 日历 / 右 视频 (比例1:2) -->
      <div class="second-row">
        <!-- 左列：日历 -->
        <div class="calendar-card-left">
          <div class="calendar-header">
            <button class="calendar-nav" @click="prevMonth">
              <i class="el-icon-arrow-left"></i>
            </button>
            <div class="calendar-title">{{ calendarYear }}年{{ calendarMonth }}月</div>
            <button class="calendar-nav" @click="nextMonth">
              <i class="el-icon-arrow-right"></i>
            </button>
          </div>
          <div class="calendar-weekdays">
            <div v-for="day in weekdays" :key="day" class="weekday">{{ day }}</div>
          </div>
          <div class="calendar-days">
            <div
              v-for="(day, index) in calendarDays"
              :key="index"
              class="calendar-day"
              :class="{
                'other-month': !day.isCurrentMonth,
                'today': day.isToday,
                'selected': day.isSelected
              }"
              @click="selectDate(day)"
            >
              {{ day.day }}
            </div>
          </div>
        </div>

        <!-- 右侧：视频 -->
        <div class="center-video-card">
          <video :src="gifVideo" autoplay loop muted class="center-video"></video>
        </div>
      </div>

      <!-- 第三层：快捷功能 -->
      <div class="content-section">
        <h2 class="section-title">
          <i class="el-icon-star-on"></i>
          快捷功能
        </h2>

        <div class="quick-actions">
          <div class="action-card" @click="handleAction('course')">
            <i class="el-icon-reading action-icon-simple" style="color: #667eea"></i>
            <div class="action-info">
              <div class="action-title">我的课程</div>
              <div class="action-count">{{ quickStats.courseCount }} 门</div>
            </div>
          </div>
          <div class="action-card" @click="handleAction('homework')">
            <i class="el-icon-edit-outline action-icon-simple" style="color: #5b86e5"></i>
            <div class="action-info">
              <div class="action-title">题目练习</div>
              <div class="action-count">{{ quickStats.questionCount }} 个</div>
            </div>
          </div>
          <div class="action-card" @click="handleAction('exam')">
            <i class="el-icon-tickets action-icon-simple" style="color: #4facfe"></i>
            <div class="action-info">
              <div class="action-title">作业考试</div>
              <div class="action-count">{{ quickStats.assignmentCount }} 场</div>
            </div>
          </div>
          <div class="action-card" @click="handleAction('message')">
            <i class="el-icon-video-camera action-icon-simple" style="color: #43e97b"></i>
            <div class="action-info">
              <div class="action-title">课程中心</div>
              <div class="action-count">{{ quickStats.videoCount }} 个</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 第四层：学习统计 -->
      <div class="content-section">
      <h2 class="section-title">
        <i class="el-icon-data-line"></i>
        学习统计
      </h2>

      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-icon" style="color: #667eea">
            <i class="el-icon-time"></i>
          </div>
          <div class="stat-info">
            <div class="stat-label">学习时长</div>
            <div class="stat-value">{{ learningStats.studyHours }} 小时</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="color: #5b86e5">
            <i class="el-icon-trophy"></i>
          </div>
          <div class="stat-info">
            <div class="stat-label">课程学习</div>
            <div class="stat-value">{{ learningStats.completedCourses }} 门</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="color: #4facfe">
            <i class="el-icon-medal"></i>
          </div>
          <div class="stat-info">
            <div class="stat-label">已掌握知识点</div>
            <div class="stat-value">{{ learningStats.knowledgePoints }} 个</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon" style="color: #43e97b">
            <i class="el-icon-star-on"></i>
          </div>
          <div class="stat-info">
            <div class="stat-label">平均分数</div>
            <div class="stat-value">{{ learningStats.averageScore }} 分</div>
          </div>
        </div>
      </div>
    </div>
    <!-- 内容层结束 -->
    </div>
  </div>
</template>


<script>
import gifVideo from '@/assets/images/GIF1.mp4'
import { getMyCourses } from "@/api/system/student"
import { listQuestion } from "@/api/system/question"
import { listAssignment } from "@/api/system/assignment"
import { listBehavior } from "@/api/system/behavior"

export default {
  name: "HomePage",
  data() {
    return {
      gifVideo,
      // 时钟
      currentTime: '',
      currentDate: '',
      currentWeek: '',
      hourDeg: 0,
      minuteDeg: 0,
      secondDeg: 0,
      timeTimer: null,

      // 鼓励语轮播
      mottos: [
        '不积跬步，无以至千里 📚',
        '业精于勤，荒于嬉 💼',
        '宝剑锋从磨砺出，梅花香自苦寒来 🌸',
        '长风破浪会有时，直挂云帆济沧海 📖',
        '青春须早为，岂能长少年 💡',
        '少壮不努力，老大徒伤悲 ✏️',
        '锲而不舍，金石可镂 🌟',
        '纸上得来终觉浅，绝知此事要躬行 🗒️',
        '黑发不知勤学早，白首方悔读书迟 ⚡',
        '古人学问无遗力，少壮工夫老始成  🎉',
        '问渠那得清如许 为有源头活水来 🏆',
        '书当快意读易尽，客有可人期不来 🎯',
        '路漫漫其修远兮，吾将上下而求索 📈'

      ],
      currentMottoIndex: 0,
      currentMotto: '',
      mottoTimer: null,

      // 日历
      calendarYear: new Date().getFullYear(),
      calendarMonth: new Date().getMonth() + 1,
      calendarDays: [],
      weekdays: ['日', '一', '二', '三', '四', '五', '六'],
      selectedDate: null,

      // 快捷功能统计数据
      quickStats: {
        courseCount: 0,      // 我的课程数量
        questionCount: 0,    // 题目练习数量
        assignmentCount: 0,  // 作业考试数量
        videoCount: 0        // 视频学习数量
      },

      // 学习统计数据
      learningStats: {
        studyHours: 0,        // 学习时长
        completedCourses: 0,  // 完成课程
        knowledgePoints: 0,   // 已掌握知识点
        averageScore: 0       // 平均分数
      }
    }
  },

  mounted() {
    this.initClock()
    this.initCalendar()
    this.initMottos()
    this.loadQuickStats()
    this.loadLearningStats()
  },

  beforeDestroy() {
    if (this.timeTimer) {
      clearInterval(this.timeTimer)
    }
    if (this.mottoTimer) {
      clearInterval(this.mottoTimer)
    }
  },

  methods: {
    // ========== 时钟相关 ==========
    initClock() {
      this.updateClock()
      this.timeTimer = setInterval(() => {
        this.updateClock()
      }, 1000)
    },

    updateClock() {
      const now = new Date()

      // 更新时间显示
      const hours = String(now.getHours()).padStart(2, '0')
      const minutes = String(now.getMinutes()).padStart(2, '0')
      const seconds = String(now.getSeconds()).padStart(2, '0')
      this.currentTime = `${hours}:${minutes}:${seconds}`

      // 更新日期显示
      const year = now.getFullYear()
      const month = String(now.getMonth() + 1).padStart(2, '0')
      const date = String(now.getDate()).padStart(2, '0')
      this.currentDate = `${year}年${month}月${date}日`

      // 更新星期显示
      const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
      this.currentWeek = weekdays[now.getDay()]

      // 更新时钟指针角度（transform-origin 改为 0% 50%，所以不需要减90度）
      const h = now.getHours() % 12
      const m = now.getMinutes()
      const s = now.getSeconds()

      this.hourDeg = (h * 30) + (m * 0.5)
      this.minuteDeg = (m * 6) + (s * 0.1)
      this.secondDeg = (s * 6)
    },

    // ========== 鼓励语轮播 ==========
    initMottos() {
      if (!this.mottos || this.mottos.length === 0) return
      this.currentMottoIndex = 0
      this.currentMotto = this.mottos[0]
      this.mottoTimer = setInterval(() => {
        this.nextMotto()
      }, 5000)
    },

    nextMotto() {
      if (!this.mottos || this.mottos.length === 0) return
      this.currentMottoIndex = (this.currentMottoIndex + 1) % this.mottos.length
      this.currentMotto = this.mottos[this.currentMottoIndex]
    },

    // ========== 日历相关 ==========
    initCalendar() {
      this.generateCalendarDays()
    },

    generateCalendarDays() {
      const year = this.calendarYear
      const month = this.calendarMonth

      // 当月第一天
      const firstDay = new Date(year, month - 1, 1)
      const firstDayWeek = firstDay.getDay()

      // 当月天数
      const daysInMonth = new Date(year, month, 0).getDate()

      // 上月天数
      const prevMonthDays = new Date(year, month - 1, 0).getDate()

      const days = []

      // 上月日期
      for (let i = firstDayWeek - 1; i >= 0; i--) {
        days.push({
          day: prevMonthDays - i,
          isCurrentMonth: false,
          isToday: false,
          isSelected: false
        })
      }

      // 当月日期
      const today = new Date()
      for (let i = 1; i <= daysInMonth; i++) {
        const isToday = year === today.getFullYear() &&
                       month === today.getMonth() + 1 &&
                       i === today.getDate()
        days.push({
          day: i,
          isCurrentMonth: true,
          isToday: isToday,
          isSelected: false
        })
      }

      // 下月日期
      const remainingDays = 42 - days.length
      for (let i = 1; i <= remainingDays; i++) {
        days.push({
          day: i,
          isCurrentMonth: false,
          isToday: false,
          isSelected: false
        })
      }

      this.calendarDays = days
    },


    prevMonth() {
      if (this.calendarMonth === 1) {
        this.calendarYear--
        this.calendarMonth = 12
      } else {
        this.calendarMonth--
      }
      this.generateCalendarDays()
    },

    nextMonth() {
      if (this.calendarMonth === 12) {
        this.calendarYear++
        this.calendarMonth = 1
      } else {
        this.calendarMonth++
      }
      this.generateCalendarDays()
    },

    selectDate(day) {
      if (!day.isCurrentMonth) return

      this.calendarDays.forEach(d => {
        d.isSelected = false
      })
      day.isSelected = true

      this.$message.success(`选择日期：${this.calendarYear}年${this.calendarMonth}月${day.day}日`)
    },

    // ========== 快捷功能 ==========
    handleAction(type) {
      const routes = {
        course: '/system/student',              // 我的课程（动态路由）
        homework: '/system/question/courses',   // 题目练习（静态路由）
        exam: '/system/assignment',             // 作业考试（动态路由）
        message: '/system/course'               // 视频学习（跳转到课程中心，动态路由）
      }

      if (routes[type]) {
        this.$router.push(routes[type])
      } else {
        this.$message.info('功能开发中...')
      }
    },

    // ========== 加载快捷功能统计数据 ==========
    async loadQuickStats() {
      try {
        // 获取我的课程数量
        const coursesRes = await getMyCourses()
        this.quickStats.courseCount = coursesRes.data ? coursesRes.data.length : 0

        // 获取题目练习数量（所有课程的题目总数）
        const questionsRes = await listQuestion({ pageNum: 1, pageSize: 1 })
        this.quickStats.questionCount = questionsRes.total || 0

        // 获取作业考试数量
        const assignmentsRes = await listAssignment({ pageNum: 1, pageSize: 1 })
        this.quickStats.assignmentCount = assignmentsRes.total || 0

        // 获取系统总课程数量（课程中心）
        const { listCourse } = await import("@/api/system/course")
        const allCoursesRes = await listCourse({ pageNum: 1, pageSize: 1, isDeleted: 0 })
        this.quickStats.videoCount = allCoursesRes.total || 0
      } catch (error) {
        console.error('加载快捷功能统计数据失败:', error)
      }
    },

    // ========== 加载学习统计数据 ==========
    async loadLearningStats() {
      try {
        // 获取学习时长（通过学习行为记录计算）
        const behaviorRes = await listBehavior({ pageNum: 1, pageSize: 9999 })
        if (behaviorRes.rows && behaviorRes.rows.length > 0) {
          // 计算总学习时长（秒转小时）
          const totalSeconds = behaviorRes.rows.reduce((sum, item) => {
            return sum + (item.watchDuration || 0)
          }, 0)
          this.learningStats.studyHours = Math.round(totalSeconds / 3600)
        }

        // 获取我的课程列表，计算完成课程数（使用课程总数）
        const coursesRes = await getMyCourses()
        if (coursesRes.data && coursesRes.data.length > 0) {
          // 使用我的课程总数作为完成课程数
          this.learningStats.completedCourses = coursesRes.data.length
        }

        // 获取已掌握知识点数量（使用题目总数）
        const questionsRes = await listQuestion({ pageNum: 1, pageSize: 1 })
        this.learningStats.knowledgePoints = questionsRes.total || 0

        // 获取平均分数（使用作业的totalScore字段计算平均值）
        const assignmentsRes = await listAssignment({ pageNum: 1, pageSize: 9999 })
        if (assignmentsRes.rows && assignmentsRes.rows.length > 0) {
          // 计算所有作业的平均总分
          const totalScore = assignmentsRes.rows.reduce((sum, item) => {
            return sum + (item.totalScore || 0)
          }, 0)
          this.learningStats.averageScore = assignmentsRes.rows.length > 0
            ? Math.round(totalScore / assignmentsRes.rows.length)
            : 0
        }
      } catch (error) {
        console.error('加载学习统计数据失败:', error)
      }
    }
  }
}
</script>


<style scoped lang="scss">
.home-container {
  min-height: 100vh;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei",
    system-ui, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  position: relative;
  overflow-x: hidden;
  background: #f8fafc;
}

// ========== 内容层 ==========
.content-layer {
  position: relative;
  z-index: 1;
  min-height: 100vh;
  padding: 24px 20px 20px;
}
.welcome-header {
  margin-bottom: 24px;
  text-align: center;
  position: relative;
  padding-bottom: 18px;
}

// ========== 左侧时钟显示 ==========
.clock-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;

  .clock-circle {
    width: 130px;
    height: 130px;
    border-radius: 50%;
    background: radial-gradient(circle at 30% 20%, rgba(255, 255, 255, 0.95), rgba(248, 250, 252, 0.9) 55%);
    box-shadow: 0 4px 12px rgba(198, 132, 172, 0.2), inset 0 2px 8px rgba(255, 255, 255, 0.8);
    border: 5px solid rgba(152, 197, 252, 0.7);
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;

    .clock-face {
      width: 100%;
      height: 100%;
      position: relative;
    }

    .hand {
      position: absolute;
      top: 50%;
      left: 50%;
      transform-origin: 50% 0%;
      background: #63aeff;
      border-radius: 7px;
    }

    .hour-hand {
      width: 4px;
      height: 25px;
      margin-left: -2px;
      margin-top: 0;
    }

    .minute-hand {
      width: 3px;
      height: 35px;
      margin-left: -1.5px;
      margin-top: 0;
    }

    .second-hand {
      width: 2px;
      height: 50px;
      margin-left: -1px;
      margin-top: 0;
      background: #ffaeee;
    }

    .clock-center {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 8px;
      height: 8px;
      background: #1e293b;
      border-radius: 50%;
      z-index: 10;
    }
  }

  .time {
    font-size: 25px;
    font-weight: 600;
    color: #ffffff;
  }
}

// ========== 中间欢迎文字 ==========
.welcome-text {
  text-align: center;

  .welcome-header {
    position: relative;
    padding-bottom: 20px;

    &::after {
      content: '';
      position: absolute;
      left: 50%;
      bottom: 0;
      transform: translateX(-50%);
      width: 300px;
      height: 2px;
      background: linear-gradient(90deg, rgba(59, 130, 246, 0), rgba(59, 130, 246, 0.6), rgba(59, 130, 246, 0));
      box-shadow: 0 0 8px rgba(59, 130, 246, 0.3);
    }
  }



  .welcome-sub {
    font-size: 40px;
    color: #1958b0;
    font-weight: bold;
  }
}

.welcome-sub {
  font-size: 24px;
  letter-spacing: 0.20em;
  color: #64748b;
  font-weight: 400;
}

.welcome-main {
  margin-top: 4px;
  font-size: 78px; /* 顶部主标题再大一档 */
  font-weight: 700; /* 更粗一点，突出主体 */
  letter-spacing: 0.07em; /* 稍微再拉开一点间距 */
  color: #1e293b;
  text-shadow: 0 2px 8px rgba(59, 130, 246, 0.15);
}

.welcome-motto {
  margin-top: 12px;
  font-size: 25px;
  color: #b1d2ff;
}

// ========== 左侧日历（第二层） ==========
.calendar-card-left {
  background: linear-gradient(135deg, rgba(147, 197, 253, 0.6) 0%, rgba(191, 219, 254, 0.55) 100%);
  border-radius: 18px;
  padding: 20px;
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.2), 0 2px 8px rgba(0, 0, 0, 0.06);
  border: 1px solid rgba(96, 165, 250, 0.7);

  .calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 12px;
    border-bottom: 2px solid rgba(96, 165, 250, 0.3);

    .calendar-nav {
      background: linear-gradient(135deg, rgba(255, 255, 255, 0.8), rgba(248, 250, 252, 0.7));
      border: 1px solid rgba(59, 130, 246, 0.4);
      border-radius: 8px;
      width: 36px;
      height: 36px;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.3s;
      color: #698cff;
      font-weight: 600;

      &:hover {
        background: linear-gradient(135deg, #98b9ff, #3b82f6);
        color: white;
        border-color: #7594f9;
        transform: scale(1.1);
        box-shadow: 0 2px 8px rgba(37, 99, 235, 0.3);
      }
    }

    .calendar-title {
      font-size: 20px;
      font-weight: 700;
      color: #ffffff;
      text-shadow: 0 1px 2px rgba(30, 64, 175, 0.1);
    }
  }

  .calendar-weekdays {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 6px;
    margin-bottom: 10px;

    .weekday {
      text-align: center;
      font-size: 13px;
      font-weight: 600;
      color: #475569;
      padding: 8px 0;
      background: rgba(255, 255, 255, 0.4);
      border-radius: 6px;
    }
  }

  .calendar-days {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 6px;

    .calendar-day {
      aspect-ratio: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 14px;
      color: #1e293b;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.3s;
      background: rgba(255, 255, 255, 0.5);
      border: 1px solid rgba(147, 197, 253, 0.3);

      &:hover {
        background: rgba(255, 255, 255, 0.9);
        transform: scale(1.05);
        border-color: rgba(96, 165, 250, 0.5);
      }

      &.other-month {
        color: #cbd5e1;
        background: rgba(255, 255, 255, 0.2);
      }

      &.today {
        background: linear-gradient(135deg, #87a3ff, #bbd1ff);
        color: white;
        font-weight: 700;
        box-shadow: 0 3px 10px rgba(30, 64, 175, 0.5);
        border: none;
      }

      &.selected {
        background: rgba(37, 99, 235, 0.2);
        border: 2px solid #7e9cff;
        font-weight: 600;
      }
    }
  }
}

// 第二行：快捷功能 + 视频布局 (1:2)
.second-row {
  display: grid;
  grid-template-columns: 1fr 2fr; /* 两列，右侧视频占2份 */
  gap: 20px;
  margin-bottom: 24px;
  align-items: stretch;
}

// ========== 顶部区域：整体背景卡片 ==========
.top-section {
  margin-bottom: 24px;
}

.top-card {
  background: linear-gradient(135deg, rgba(147, 197, 253, 0.6) 0%, rgba(191, 219, 254, 0.55) 100%);
  border-radius: 20px;
  padding: 20px 40px;
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.2), 0 2px 8px rgba(0, 0, 0, 0.06);
  border: 1px solid rgba(96, 165, 250, 0.7);
  display: grid;
  grid-template-columns: 1fr 3fr;
  align-items: center;
  column-gap: 40px;
  position: relative;
  overflow: hidden;
  margin-bottom: 24px;
  height: 230px;
}

.top-digital {
  display: flex;
  justify-content: flex-start; /* 稍微向左一点，让两边时钟距离更大 */
  color: #1e293b;
}

.top-center {
  display: flex;
  justify-content: center;
}

.top-analog {
  display: flex;
  justify-content: flex-end; /* 稍微向右一点 */
}

// ========== 时钟区域（仅保留指针圆盘） ==========
.clock-card {
  background: transparent;
  border-radius: 0;
  padding: 0;
  color: #6077a9;
  box-shadow: none;
  display: flex;
  justify-content: center;
  align-items: center;
}

.clock-display {
  .time {
    font-size: 40px;
    font-weight: 550;
    margin-bottom: 10px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  }

  .date {
    font-size: 20px;
    margin-bottom: 6px;
    opacity: 0.8;
    color: #475569;
  }

  .week {
    font-size: 18px;
    opacity: 0.7;
    color: #64748b;
  }
}

.clock-animation {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 0;
}

.clock-circle {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  background: radial-gradient(circle at 30% 20%, rgba(255, 255, 255, 0.95), rgba(248, 250, 252, 0.9) 55%);
  border: 2px solid rgba(226, 232, 240, 0.8);
  position: relative;
  backdrop-filter: blur(14px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08), 0 2px 8px rgba(59, 130, 246, 0.1);

  &::before {
    content: '';
    position: absolute;
    inset: -8px;
    border-radius: 50%;
    border: 1px dashed rgba(59, 130, 246, 0.2);
    box-shadow: 0 0 10px rgba(59, 130, 246, 0.1);
    animation: orbit-ring 14s linear infinite;
  }

  &::after {
    content: '';
    position: absolute;
    inset: 18px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(59, 130, 246, 0.05), transparent 70%);
    opacity: 0.7;
    filter: blur(4px);
  }

  .hour-hand,
  .minute-hand,
  .second-hand {
    position: absolute;
    background: #1e293b;
    transform-origin: 0% 50%;
    top: 50%;
    left: 50%;
    border-radius: 10px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
  }

  .hour-hand {
    width: 40px;
    height: 4px;
  }

  .minute-hand {
    width: 55px;
    height: 3px;
  }

  .second-hand {
    width: 65px;
    height: 2px;
    background: #3b82f6;
    box-shadow: 0 1px 4px rgba(59, 130, 246, 0.4);
  }

  .clock-center {
    position: absolute;
    width: 12px;
    height: 12px;
    background: #1e293b;
    border-radius: 50%;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    z-index: 10;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  }
}

// ========== 视频卡片 ==========
.center-video-card {
  position: relative;
  background: #000;
  border-radius: 18px;
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.15), 0 2px 8px rgba(0, 0, 0, 0.04);
  border: 1px solid rgba(147, 197, 253, 0.5);
  overflow: hidden;
  padding: 0;
  height: 100%;

  .center-video {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
    transform: scale(1.5);
  }
}



// ========== 内容区域 ==========
.content-section {
  margin-bottom: 30px;
  background: linear-gradient(135deg, rgba(147, 197, 253, 0.6) 0%, rgba(191, 219, 254, 0.55) 100%);
  border-radius: 18px;
  padding: 24px;
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.2), 0 2px 8px rgba(0, 0, 0, 0.06);
  border: 1px solid rgba(96, 165, 250, 0.7);
  position: relative;

  .section-title {
    font-size: 22px;
    font-weight: 600;
    font-kerning:100;
    color: #1e293b;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 10px;

    i {
      color: #3b82f6;
    }
  }
}



// ========== 快捷功能 ==========
.quick-actions {
  display: grid;
  grid-template-columns: repeat(4, 1fr); /* 四个功能块横向排列 */
  gap: 20px;
  position: relative;
  z-index: 1;

  .action-card {
    background: rgba(255, 255, 255, 0.7);
    border-radius: 16px;
    padding: 24px 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
    cursor: pointer;
    transition: all 0.3s;
    box-shadow: 0 2px 6px rgba(59, 130, 246, 0.12);
    border: 1px solid rgba(96, 165, 250, 0.5);

    &:hover {
      transform: translateY(-5px);
      box-shadow: 0 4px 12px rgba(59, 130, 246, 0.25);
      background: rgba(255, 255, 255, 0.95);
      border-color: rgba(59, 130, 246, 0.6);
    }

    .action-icon-simple {
      font-size: 48px;
      flex-shrink: 0;
      filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
    }

    .action-info {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 4px;
    }

    .action-title {
      font-size: 16px;
      font-weight: 600;
      color: #1e293b;
    }

    .action-count {
      font-size: 14px;
      color: #64748b;
      font-weight: 500;
    }
  }
}


// ========== 学习统计 ==========
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;

  .stat-card {
    background: rgba(255, 255, 255, 0.7);
    border-radius: 15px;
    padding: 25px;
    display: flex;
    align-items: center;
    gap: 20px;
    box-shadow: 0 2px 6px rgba(59, 130, 246, 0.12);
    border: 1px solid rgba(96, 165, 250, 0.5);
    transition: all 0.3s;

    &:hover {
      transform: translateY(-5px);
      box-shadow: 0 4px 12px rgba(59, 130, 246, 0.25);
      background: rgba(255, 255, 255, 0.95);
      border-color: rgba(59, 130, 246, 0.6);
    }

    .stat-icon {
      font-size: 36px;
      filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.1));
    }

    .stat-info {
      flex: 1;

      .stat-label {
        font-size: 14px;
        color: #64748b;
        margin-bottom: 8px;
      }

      .stat-value {
        font-size: 22px;
        font-weight: 600;
        color: #1e293b;
      }
    }
  }
}

// ========== 响应式 ==========
@media (max-width: 1400px) {
  .top-card {
    grid-template-columns: 1fr;
    gap: 20px;
  }

  .second-row {
    grid-template-columns: 1fr;
    gap: 15px;
  }

  .quick-actions {
    grid-template-columns: repeat(2, 1fr);
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .quick-actions,
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .clock-display .time {
    font-size: 24px;
  }

  .welcome-main {
    font-size: 32px;
  }

  .welcome-sub {
    font-size: 14px;
  }
}
</style>