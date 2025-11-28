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
          <!-- 课程筛选 -->
          <div class="calendar-course-filter">
            <el-select v-model="calendarCourseId" placeholder="选择课程查看任务" size="mini" clearable @change="onCalendarCourseChange">
              <el-option v-for="course in courseList" :key="course.id" :label="course.name" :value="course.id"></el-option>
            </el-select>
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
                'selected': day.isSelected,
                'has-task': day.tasks && day.tasks.length > 0,
                'has-expired-task': day.hasExpiredTask,
                'all-submitted': day.allSubmitted
              }"
              @click="selectDate(day)"
            >
              <span class="day-number">{{ day.day }}</span>
              <span v-if="day.unsubmittedCount > 0" class="task-dot" :title="day.tasks.map(t => t.title).join(', ')">
                {{ day.unsubmittedCount }}
              </span>
            </div>
          </div>
          <!-- 选中日期的任务列表 -->
          <div v-if="selectedDateTasks.length > 0" class="calendar-task-list">
            <div class="task-list-title">📝 {{ selectedDateStr }} 的任务</div>
            <div v-for="task in selectedDateTasks" :key="task.id"
                 class="task-item"
                 :class="{ 'task-expired': task.isExpired, 'task-submitted': task.isSubmitted }"
                 @click="goToTask(task)">
              <span class="task-type" :class="task.type === 'exam' ? 'exam' : 'homework'">
                {{ task.type === 'exam' ? '考试' : '作业' }}
              </span>
              <span class="task-title">{{ task.title }}</span>
              <span v-if="task.isSubmitted" class="task-status submitted">✓ 已提交</span>
              <span v-else-if="task.isExpired" class="task-status expired">⚠ 已过期</span>
              <i class="el-icon-arrow-right"></i>
            </div>
          </div>
        </div>

        <!-- 右侧：视频 -->
        <div class="center-video-card">
          <video :src="gifVideo" autoplay loop muted class="center-video"></video>
        </div>
      </div>


    <!-- 第五层：Dashboard 可视化数据看板 -->
    <div class="content-section dashboard-section">
      <h2 class="section-title">
        <i class="el-icon-data-analysis"></i>
        数据看板 Dashboard
      </h2>

      <div class="dashboard-grid">
        <!-- 学习进度环形图 -->
        <div class="dashboard-card">
          <div class="card-header">
            <span class="card-title">学习进度</span>
            <span class="card-subtitle">课程完成率</span>
          </div>
          <div ref="progressChart" class="chart-container"></div>
        </div>

        <!-- 成绩分析折线图 -->
        <div class="dashboard-card">
          <div class="card-header">
            <span class="card-title">成绩分析</span>
            <div class="chart-switch">
              <el-radio-group v-model="scoreChartMode" size="mini" @change="updateScoreChart">
                <el-radio-button label="time">同科目横向趋势</el-radio-button>
                <el-radio-button label="course">各科目纵向对比</el-radio-button>
              </el-radio-group>
            </div>
          </div>
          <div class="chart-filter" v-if="scoreChartMode === 'time'">
            <el-select v-model="selectedCourseId" placeholder="选择科目查看趋势" size="mini" @change="updateScoreChart">
              <el-option
                v-for="course in courseList"
                :key="course.id"
                :label="course.name"
                :value="course.id">
              </el-option>
            </el-select>
          </div>
          <div ref="scoreChart" class="chart-container" :class="{ 'with-filter': scoreChartMode === 'time' }"></div>
        </div>

        <!-- 任务完成情况柱状图 -->
        <div class="dashboard-card">
          <div class="card-header">
            <span class="card-title">任务完成情况</span>
            <span class="card-subtitle">作业考试提交状态统计</span>
          </div>
          <div ref="taskChart" class="chart-container"></div>
        </div>

        <!-- 知识掌握雷达图 -->
        <div class="dashboard-card">
          <div class="card-header">
            <span class="card-title">能力分析</span>
            <span class="card-subtitle">综合学习能力评估</span>
          </div>
          <div ref="radarChart" class="chart-container"></div>
        </div>
      </div>
    </div>

    <!-- 内容层结束 -->
    </div>

    <!-- 提交作业对话框 -->
    <el-dialog
      :visible.sync="submitDialogVisible"
      width="650px"
      append-to-body
      class="assignment-dialog"
      :close-on-click-modal="false"
    >
      <div slot="title" class="dialog-title-custom">
        <i class="el-icon-upload"></i>
        <span>提交作业</span>
      </div>
      <div v-if="currentAssignment" class="submit-wrapper">
        <!-- 作业信息卡片 -->
        <div class="submit-info-card">
          <div class="info-header">
            <h3 class="info-title">{{ currentAssignment.title }}</h3>
            <el-tag type="primary">📎 上传型</el-tag>
          </div>
          <div class="info-meta">
            <div class="meta-item-row">
              <span class="meta-label">
                <i class="el-icon-folder-opened"></i>
                课程编号：
              </span>
              <span class="meta-value">{{ currentAssignment.courseId }}</span>
            </div>
            <div class="meta-item-row">
              <span class="meta-label">
                <i class="el-icon-time"></i>
                开始时间：
              </span>
              <span class="meta-value">{{ parseTime(currentAssignment.startTime, '{y}-{m}-{d} {h}:{i}') }}</span>
            </div>
            <div class="meta-item-row deadline-meta">
              <span class="meta-label">
                <i class="el-icon-alarm-clock"></i>
                截止时间：
              </span>
              <span class="meta-value">{{ parseTime(currentAssignment.endTime, '{y}-{m}-{d} {h}:{i}') }}</span>
            </div>
          </div>
        </div>

        <!-- 上传型：显示文件上传 -->
        <div class="submit-form-section">
          <el-form label-width="100px" class="dialog-form">
            <el-form-item label="上传文件" required>
              <FileUpload v-model="studentSubmitForm.files" :limit="5" />
              <div class="form-tip">
                <i class="el-icon-info"></i>
                支持上传多个文件，单个文件不超过10MB
              </div>
            </el-form-item>
            <el-form-item label="备注说明">
              <el-input
                v-model="studentSubmitForm.remark"
                type="textarea"
                :rows="4"
                placeholder="如有特别说明，可以在此填写给老师..."
                class="remark-textarea"
              />
            </el-form-item>
          </el-form>
        </div>

        <!-- 提交提示 -->
        <el-alert
          v-if="submittedAssignmentMap[currentAssignment.id]"
          title="您已提交过此作业，重新提交将覆盖之前的内容"
          type="warning"
          :closable="false"
          show-icon
        >
        </el-alert>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="submitDialogVisible = false" size="medium">
          <i class="el-icon-close"></i> 取消
        </el-button>
        <el-button type="primary" @click="handleSubmitUpload" size="medium" :loading="submitting">
          <i class="el-icon-check"></i> 确认提交
        </el-button>
      </div>
    </el-dialog>
  </div>
</template>


<script>
import gifVideo from '@/assets/images/GIF1.mp4'
import { getMyCourses } from "@/api/system/student"
import { listQuestion } from "@/api/system/question"
import { listAssignment, getMySubmissions, uploadAssignment } from "@/api/system/assignment"
import { listBehavior } from "@/api/system/behavior"
import { getStudentDashboardData } from "@/api/system/dashboard"
import * as echarts from 'echarts'
import FileUpload from '@/components/FileUpload'

export default {
  name: "HomePage",
  components: {
    FileUpload
  },
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
      calendarCourseId: null,        // 日历筛选的课程ID
      calendarTasks: [],             // 日历任务列表
      selectedDateTasks: [],         // 选中日期的任务
      selectedDateStr: '',           // 选中日期字符串
      submittedAssignmentMap: {},    // 已提交作业的Map {assignmentId: {status, score, submitTime}}

      // 上传作业对话框
      submitDialogVisible: false,
      currentAssignment: null,
      studentSubmitForm: {
        files: "",
        remark: ""
      },
      submitting: false,

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
      },

      // Dashboard 图表实例
      progressChart: null,
      scoreChart: null,
      taskChart: null,
      radarChart: null,

      // 成绩分析切换
      scoreChartMode: 'time',       // 'time' 同科目时间趋势 | 'course' 不同科目对比
      selectedCourseId: null,       // 选中的课程ID
      courseList: [],               // 课程列表
      allAssignments: [],           // 所有作业数据（用于切换）

      // Dashboard 数据
      dashboardData: {
        courseProgress: 0,          // 课程完成进度百分比
        videoProgress: 0,           // 视频观看进度百分比
        scoreHistory: [],           // 成绩历史记录
        scoreByCourse: {},          // 按科目分组的成绩数据
        courseScoreAvg: [],         // 各科目平均成绩
        taskStats: {                // 任务统计（与作业考试页面一致）
          total: 0,                 // 作业总数
          submitted: 0,             // 已提交
          pending: 0,               // 待提交
          expired: 0                // 已截止
        },
        abilityData: {              // 能力数据
          理论学习: 0,
          实践操作: 0,
          知识掌握: 0,
          作业完成: 0,
          学习时长: 0
        }
      }
    }
  },

  async mounted() {
    this.initClock()
    this.initCalendar()
    this.initMottos()
    this.loadQuickStats()
    this.loadLearningStats()
    this.loadDashboardData()

    // 加载提交记录
    await this.loadMySubmissions()

    // 从本地存储恢复上次选择的课程
    const savedCourseId = localStorage.getItem('calendarCourseId')
    if (savedCourseId) {
      this.calendarCourseId = Number(savedCourseId)
      this.onCalendarCourseChange()
    }
  },

  beforeDestroy() {
    if (this.timeTimer) {
      clearInterval(this.timeTimer)
    }
    if (this.mottoTimer) {
      clearInterval(this.mottoTimer)
    }
    // 销毁图表实例
    if (this.progressChart) this.progressChart.dispose()
    if (this.scoreChart) this.scoreChart.dispose()
    if (this.taskChart) this.taskChart.dispose()
    if (this.radarChart) this.radarChart.dispose()
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
        const dateStr = this.formatDateStr(year, month - 1, prevMonthDays - i)
        const tasks = this.getTasksForDate(dateStr)
        const taskInfo = this.analyzeTasksForDay(tasks)
        days.push({
          day: prevMonthDays - i,
          isCurrentMonth: false,
          isToday: false,
          isSelected: false,
          dateStr: dateStr,
          tasks: tasks,
          ...taskInfo
        })
      }

      // 当月日期
      const today = new Date()
      for (let i = 1; i <= daysInMonth; i++) {
        const isToday = year === today.getFullYear() &&
                       month === today.getMonth() + 1 &&
                       i === today.getDate()
        const dateStr = this.formatDateStr(year, month, i)
        const tasks = this.getTasksForDate(dateStr)
        const taskInfo = this.analyzeTasksForDay(tasks)
        days.push({
          day: i,
          isCurrentMonth: true,
          isToday: isToday,
          isSelected: false,
          dateStr: dateStr,
          tasks: tasks,
          ...taskInfo
        })
      }

      // 下月日期
      const remainingDays = 42 - days.length
      for (let i = 1; i <= remainingDays; i++) {
        const dateStr = this.formatDateStr(year, month + 1, i)
        const tasks = this.getTasksForDate(dateStr)
        const taskInfo = this.analyzeTasksForDay(tasks)
        days.push({
          day: i,
          isCurrentMonth: false,
          isToday: false,
          isSelected: false,
          dateStr: dateStr,
          tasks: tasks,
          ...taskInfo
        })
      }

      this.calendarDays = days
    },

    // 格式化日期字符串 YYYY-MM-DD
    formatDateStr(year, month, day) {
      // 处理月份溢出
      if (month < 1) {
        year--
        month = 12
      } else if (month > 12) {
        year++
        month = 1
      }
      return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
    },

    // 获取指定日期的任务
    getTasksForDate(dateStr) {
      const now = new Date()
      return this.calendarTasks.filter(task => {
        if (!task.endTime) return false
        const taskDate = task.endTime.substring(0, 10)
        return taskDate === dateStr
      }).map(task => {
        // 添加过期和已提交状态
        const endTime = new Date(task.endTime)
        const isExpired = endTime < now
        const isSubmitted = !!this.submittedAssignmentMap[task.id]
        return {
          ...task,
          isExpired,
          isSubmitted
        }
      })
    },

    // 分析某天的任务状态
    analyzeTasksForDay(tasks) {
      if (!tasks || tasks.length === 0) {
        return {
          hasExpiredTask: false,
          allSubmitted: false,
          unsubmittedCount: 0
        }
      }

      const now = new Date()
      let hasExpiredTask = false
      let unsubmittedCount = 0

      tasks.forEach(task => {
        const endTime = new Date(task.endTime)
        const isExpired = endTime < now
        const isSubmitted = !!this.submittedAssignmentMap[task.id]

        // 只有未提交的任务才计入未完成数量（已提交的不显示红点）
        if (!isSubmitted) {
          unsubmittedCount++
          // 只有未提交且已过期的任务才标记为过期
          if (isExpired) {
            hasExpiredTask = true
          }
        }
      })

      const allSubmitted = unsubmittedCount === 0

      return {
        hasExpiredTask,
        allSubmitted,
        unsubmittedCount
      }
    },

    // 课程筛选变化时加载任务
    async onCalendarCourseChange() {
      // 保存当前选中的日期
      const currentSelectedDay = this.calendarDays.find(d => d.isSelected)
      const selectedDayNumber = currentSelectedDay ? currentSelectedDay.day : null

      // 保存用户选择的课程ID到本地存储
      if (this.calendarCourseId) {
        localStorage.setItem('calendarCourseId', this.calendarCourseId)
      } else {
        localStorage.removeItem('calendarCourseId')
      }

      if (!this.calendarCourseId) {
        this.calendarTasks = []
        this.selectedDateTasks = []
        this.selectedDateStr = ''
        this.generateCalendarDays()
        return
      }
      try {
        // 1. 加载任务列表
        const res = await listAssignment({ courseId: this.calendarCourseId, pageSize: 100 })
        this.calendarTasks = (res.rows || []).map(item => ({
          id: item.id,
          title: item.title,
          type: item.type,
          mode: item.mode,
          endTime: item.endTime,
          courseId: item.courseId
        }))
        console.log('📅 日历任务列表:', this.calendarTasks)

        // 2. 加载提交记录
        await this.loadMySubmissions()

        // 3. 生成日历
        this.generateCalendarDays()

        // 4. 恢复之前选中的日期
        if (selectedDayNumber) {
          const dayToSelect = this.calendarDays.find(d => d.day === selectedDayNumber && d.isCurrentMonth)
          if (dayToSelect) {
            this.selectDate(dayToSelect)
          }
        }
      } catch (error) {
        console.error('加载日历任务失败:', error)
        this.calendarTasks = []
        this.generateCalendarDays()
      }
    },

    // 加载学生的提交记录
    async loadMySubmissions() {
      try {
        const res = await getMySubmissions()
        const submissions = res.data || []
        console.log('📝 获取到提交记录:', submissions)

        // 构建提交记录 Map
        this.submittedAssignmentMap = {}
        submissions.forEach(sub => {
          this.submittedAssignmentMap[sub.assignmentId] = {
            status: sub.status,
            score: sub.score,
            submitTime: sub.submitTime
          }
        })
        console.log('📝 提交记录Map:', this.submittedAssignmentMap)
      } catch (error) {
        console.error('获取提交记录失败:', error)
        this.submittedAssignmentMap = {}
      }
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

      // 显示该日期的任务
      this.selectedDateStr = `${this.calendarMonth}月${day.day}日`
      this.selectedDateTasks = day.tasks || []
    },

    // 跳转到任务详情
    goToTask(task) {
      console.log('跳转任务:', task)

      // 如果任务已过期，禁止跳转（无论是否已提交）
      if (task.isExpired) {
        this.$modal.msgWarning('该任务已过期，无法继续提交')
        return
      }

      if (task.mode === 'question') {
        // 答题型，跳转到考试页面（路由是 /course/exam，参数名是 assignmentId）
        this.$router.push({
          path: '/course/exam',
          query: {
            assignmentId: task.id,
            courseId: task.courseId
          }
        })
      } else {
        // 上传型，打开上传对话框
        this.openSubmitDialog(task)
      }
    },

    // 打开提交作业对话框
    openSubmitDialog(task) {
      if (!task || !task.id) {
        return
      }
      this.currentAssignment = task
      this.studentSubmitForm = {
        files: "",
        remark: ""
      }
      this.submitDialogVisible = true
    },

    // 提交上传作业
    handleSubmitUpload() {
      if (!this.studentSubmitForm.files) {
        this.$modal.msgError("请先上传作业文件")
        return
      }

      this.submitting = true
      const assignmentId = this.currentAssignment.id

      uploadAssignment(assignmentId, {
        files: this.studentSubmitForm.files,
        remark: this.studentSubmitForm.remark
      }).then(response => {
        // 更新本地状态
        this.$set(this.submittedAssignmentMap, assignmentId, {
          status: 1,
          submitTime: new Date().toISOString()
        })
        this.$modal.msgSuccess("提交成功！")
        this.submitting = false
        this.submitDialogVisible = false
        // 重新生成日历以更新显示
        this.generateCalendarDays()
      }).catch(error => {
        console.error('提交失败:', error)
        this.$modal.msgError("提交失败，请稍后重试")
        this.submitting = false
      })
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
    },

    // ========== Dashboard 数据看板 ==========
    async loadDashboardData() {
      try {
        // 调用后端API获取学生Dashboard数据
        console.log('=== 开始加载Dashboard数据 ===')
        const dashboardRes = await getStudentDashboardData()
        console.log('Dashboard API响应:', dashboardRes)
        const data = dashboardRes.data || {}
        console.log('Dashboard数据:', data)

        // 1. 设置课程列表（用于成绩分析下拉框）
        const courses = data.courses || []
        console.log('课程列表原始数据:', courses)
        this.courseList = courses.map(c => ({
          id: c.id,
          name: c.name || c.title || '未命名课程'  // 兼容不同字段名
        }))
        console.log('处理后的课程列表:', this.courseList)
        if (this.courseList.length > 0 && !this.selectedCourseId) {
          this.selectedCourseId = this.courseList[0].id
        }

        // 2. 处理成绩数据（使用 scoreRecords，直接从 assignment_submission 表查询）
        const scoreRecords = data.scoreRecords || []
        console.log('📊 成绩记录原始数据:', scoreRecords)
        console.log('📊 成绩记录数量:', scoreRecords.length)

        // 按课程分组成绩数据
        const scoreByCourse = {}
        const courseScoreSum = {}
        const courseScoreCount = {}
        const courseNameMap = {}  // 存储课程ID到课程名的映射

        if (scoreRecords.length > 0) {
          scoreRecords.forEach((item, index) => {
            const courseId = item.courseId
            console.log(`📝 处理第${index + 1}条成绩: `, item)

            if (!scoreByCourse[courseId]) {
              scoreByCourse[courseId] = []
              courseScoreSum[courseId] = 0
              courseScoreCount[courseId] = 0
              courseNameMap[courseId] = item.courseName  // 记录课程名
            }
            // 获取成绩值（score 字段来自 assignment_submission 表）
            const score = item.score != null ? Number(item.score) : null

            console.log(`  -> 作业[${item.assignmentName}] 课程ID=${courseId}, 成绩=${score}`)

            // 已提交的作业都加入列表
            scoreByCourse[courseId].push({
              name: item.assignmentName || '未命名',
              score: score,  // 保留 null，表示待批改
              date: item.submitTime || item.endTime,
              courseName: item.courseName,
              totalScore: item.totalScore || 100,
              isGraded: score != null  // 是否已批改
            })
            // 只有有成绩的才计入平均分
            if (score != null && score >= 0) {
              courseScoreSum[courseId] += score
              courseScoreCount[courseId]++
            }
          })
        } else {
          console.log('⚠️ 没有成绩记录数据')
        }

        console.log('📊 按课程分组后的成绩:', scoreByCourse)
        console.log('📊 课程名映射:', courseNameMap)

        // 如果 courseList 为空，从成绩记录中提取课程信息
        if (this.courseList.length === 0 && Object.keys(courseNameMap).length > 0) {
          console.log('⚠️ courseList为空，从成绩记录中提取课程')
          this.courseList = Object.keys(courseNameMap).map(id => ({
            id: Number(id),
            name: courseNameMap[id] || '未命名课程'
          }))
          console.log('📚 从成绩记录提取的课程列表:', this.courseList)
          if (this.courseList.length > 0 && !this.selectedCourseId) {
            this.selectedCourseId = this.courseList[0].id
          }
        }

        // 同时也处理 submissions 用于任务统计
        const submissions = data.submissions || []
        console.log('📋 作业列表数据:', submissions)

        this.dashboardData.scoreByCourse = scoreByCourse

        // 计算各科目平均成绩（从成绩记录的课程中计算）
        const courseIdsWithScore = Object.keys(scoreByCourse).map(id => Number(id))
        console.log('📊 有成绩的课程ID列表:', courseIdsWithScore)

        this.dashboardData.courseScoreAvg = courseIdsWithScore.map(courseId => {
          const avg = courseScoreCount[courseId] > 0
            ? Math.round(courseScoreSum[courseId] / courseScoreCount[courseId])
            : 0
          const courseName = courseNameMap[courseId] || this.courseList.find(c => c.id === courseId)?.name || '未命名'
          console.log(`📈 课程[${courseName}] ID=${courseId}, 平均分=${avg}`)
          return {
            courseId: courseId,
            courseName: courseName,
            avgScore: avg
          }
        })

        console.log('📊 各科目平均成绩:', this.dashboardData.courseScoreAvg)

        // 3. 设置任务完成统计（与作业考试页面保持一致）
        // total: 作业总数, submitted: 已提交, pending: 待提交, expired: 已截止
        this.dashboardData.taskStats = data.taskStats || { total: 0, submitted: 0, pending: 0, expired: 0 }

        // 4. 使用后端返回的视频学习数据
        const videoStats = data.videoStats || { totalVideos: 0, completedVideos: 0, totalWatchDuration: 0 }
        const totalVideos = videoStats.totalVideos || 1
        const completedVideos = videoStats.completedVideos || 0
        const totalWatchDuration = videoStats.totalWatchDuration || 0

        this.dashboardData.videoProgress = totalVideos > 0 ? Math.round((completedVideos / totalVideos) * 100) : 0
        // 学习时长能力值：每小时10分，最高100
        this.dashboardData.abilityData.学习时长 = Math.min(100, Math.round(totalWatchDuration / 360))

        // 5. 课程进度计算
        const totalCourses = this.courseList.length || 1
        this.dashboardData.courseProgress = Math.min(100, Math.round((totalCourses / Math.max(totalCourses, 5)) * 100))

        // 6. 能力值计算（使用已提交数/作业总数计算作业完成率）
        const { total, submitted } = this.dashboardData.taskStats
        this.dashboardData.abilityData.作业完成 = total > 0 ? Math.round((submitted / total) * 100) : 0

        // 知识掌握：使用后端返回的知识点统计
        const knowledgePointCount = data.knowledgePointCount || 0
        this.dashboardData.abilityData.知识掌握 = Math.min(100, Math.round(knowledgePointCount * 0.5))

        this.dashboardData.abilityData.理论学习 = Math.min(100, this.dashboardData.courseProgress + 20)
        this.dashboardData.abilityData.实践操作 = Math.min(100, this.dashboardData.videoProgress + 15)

        // 初始化图表
        this.$nextTick(() => {
          this.initProgressChart()
          this.initScoreChart()
          this.initTaskChart()
          this.initRadarChart()
        })
      } catch (error) {
        console.error('加载Dashboard数据失败:', error)
        this.$nextTick(() => {
          this.initProgressChart()
          this.initScoreChart()
          this.initTaskChart()
          this.initRadarChart()
        })
      }
    },

    // 学习进度环形图
    initProgressChart() {
      if (!this.$refs.progressChart) return
      this.progressChart = echarts.init(this.$refs.progressChart)

      const courseProgress = this.dashboardData.courseProgress || 0
      const videoProgress = this.dashboardData.videoProgress || 0

      this.progressChart.setOption({
        tooltip: {
          trigger: 'item',
          formatter: '{b}: {c}%'
        },
        legend: {
          bottom: '5%',
          left: 'center',
          textStyle: { color: '#475569' }
        },
        series: [
          {
            name: '学习进度',
            type: 'pie',
            radius: ['40%', '70%'],
            center: ['50%', '45%'],
            avoidLabelOverlap: false,
            itemStyle: {
              borderRadius: 10,
              borderColor: '#fff',
              borderWidth: 2
            },
            label: {
              show: true,
              position: 'center',
              formatter: () => `${Math.round((courseProgress + videoProgress) / 2)}%`,
              fontSize: 24,
              fontWeight: 'bold',
              color: '#3b82f6'
            },
            emphasis: {
              label: { show: true, fontSize: 26, fontWeight: 'bold' }
            },
            labelLine: { show: false },
            data: [
              { value: courseProgress, name: '课程进度', itemStyle: { color: '#667eea' } },
              { value: videoProgress, name: '视频学习', itemStyle: { color: '#4facfe' } },
              { value: Math.max(0, 100 - courseProgress - videoProgress), name: '待完成', itemStyle: { color: '#e2e8f0' } }
            ]
          }
        ]
      })
    },

    // 成绩分析图表（支持切换模式）
    initScoreChart() {
      if (!this.$refs.scoreChart) return
      if (!this.scoreChart) {
        this.scoreChart = echarts.init(this.$refs.scoreChart)
      }
      this.updateScoreChart()
    },

    // 更新成绩分析图表
    updateScoreChart() {
      if (!this.scoreChart) return

      if (this.scoreChartMode === 'time') {
        // 同科目不同时间答题趋势
        this.renderTimeScoreChart()
      } else {
        // 不同科目之间的对比
        this.renderCourseScoreChart()
      }
    },

    // 渲染同科目时间趋势图
    renderTimeScoreChart() {
      const courseId = this.selectedCourseId
      let scoreData = []

      console.log('渲染成绩趋势图, 当前课程ID:', courseId)
      console.log('scoreByCourse:', this.dashboardData.scoreByCourse)

      if (courseId && this.dashboardData.scoreByCourse[courseId]) {
        // 显示所有已提交的作业（包括待批改的）
        scoreData = this.dashboardData.scoreByCourse[courseId]
          .sort((a, b) => new Date(a.date) - new Date(b.date))
          .slice(-10) // 最近10次
      }

      console.log('成绩数据:', scoreData)

      // 没有数据时显示引导提示
      if (scoreData.length === 0) {
        this.scoreChart.setOption({
          title: {
            text: '📚 完成作业后查看成绩趋势',
            subtext: '提交作业并获得批改后，这里将显示您的成绩变化',
            left: 'center',
            top: 'center',
            textStyle: { color: '#667eea', fontSize: 14, fontWeight: 'normal' },
            subtextStyle: { color: '#94a3b8', fontSize: 12 }
          },
          xAxis: { show: false },
          yAxis: { show: false },
          series: []
        }, true)
        return
      }

      // 构建图表数据，区分已批改和待批改
      const chartData = scoreData.map(item => {
        if (item.score != null) {
          return {
            value: item.score,
            itemStyle: { color: '#5b86e5' }
          }
        } else {
          // 待批改：显示为灰色虚线点，值显示为 0 但 tooltip 显示待批改
          return {
            value: 0,
            itemStyle: { color: '#94a3b8' },
            symbol: 'diamond',
            symbolSize: 10
          }
        }
      })

      this.scoreChart.setOption({
        title: { show: false },
        tooltip: {
          trigger: 'axis',
          axisPointer: { type: 'cross' },
          formatter: function(params) {
            const idx = params[0].dataIndex
            const item = scoreData[idx]
            if (item.score != null) {
              return `${item.name}<br/>成绩: ${item.score}分`
            } else {
              return `${item.name}<br/>状态: 待批改`
            }
          }
        },
        grid: {
          left: '3%', right: '12%', bottom: '15%', top: '10%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          show: true,
          data: scoreData.map(item => {
            let name = item.name.length > 6 ? item.name.substring(0, 6) + '...' : item.name
            // 待批改的在名称后添加标记
            if (item.score == null) {
              name += '⏳'
            }
            return name
          }),
          axisLabel: { rotate: 25, fontSize: 10, color: '#64748b' }
        },
        yAxis: {
          type: 'value',
          show: true,
          min: 0,
          max: 100,
          axisLabel: { color: '#64748b' }
        },
        series: [{
          name: '成绩',
          type: 'line',
          smooth: true,
          symbol: 'circle',
          symbolSize: 8,
          data: chartData,
          itemStyle: { color: '#5b86e5' },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: 'rgba(91, 134, 229, 0.4)' },
              { offset: 1, color: 'rgba(91, 134, 229, 0.05)' }
            ])
          },
          lineStyle: { width: 3, color: '#5b86e5' },
          markLine: {
            silent: true,
            data: [{ type: 'average', name: '平均分' }],
            lineStyle: { color: '#ef4444', type: 'dashed' },
            label: {
              position: 'insideEndTop',
              formatter: '{b}: {c}'
            }
          }
        }]
      }, true)
    },

    // 渲染不同科目对比图
    renderCourseScoreChart() {
      let courseData = this.dashboardData.courseScoreAvg || []

      console.log('📊 渲染科目对比图, 原始数据:', courseData)

      // 显示所有有成绩数据的科目（包括平均分>=0的）
      const filteredData = courseData.filter(item => item.avgScore >= 0)
      console.log('📊 过滤后的数据:', filteredData)

      // 没有数据时显示引导提示
      if (filteredData.length === 0) {
        this.scoreChart.setOption({
          title: {
            text: '📊 各科目成绩对比',
            subtext: '完成多门课程的作业后，这里将显示各科目成绩对比',
            left: 'center',
            top: 'center',
            textStyle: { color: '#667eea', fontSize: 14, fontWeight: 'normal' },
            subtextStyle: { color: '#94a3b8', fontSize: 12 }
          },
          xAxis: { show: false },
          yAxis: { show: false },
          series: []
        }, true)
        return
      }

      const colors = ['#667eea', '#5b86e5', '#4facfe', '#43e97b', '#fbbf24', '#ef4444']

      this.scoreChart.setOption({
        title: { show: false },
        tooltip: {
          trigger: 'axis',
          axisPointer: { type: 'shadow' },
          formatter: '{b}: {c}分'
        },
        grid: {
          left: '3%', right: '8%', bottom: '15%', top: '10%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          show: true,
          data: filteredData.map(item => item.courseName.length > 5 ? item.courseName.substring(0, 5) + '...' : item.courseName),
          axisLabel: { rotate: 25, fontSize: 10, color: '#64748b' }
        },
        yAxis: {
          type: 'value',
          show: true,
          min: 0,
          max: 100,
          axisLabel: { color: '#64748b' }
        },
        series: [{
          name: '平均成绩',
          type: 'bar',
          barWidth: '50%',
          data: filteredData.map((item, index) => ({
            value: item.avgScore,
            itemStyle: {
              color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                { offset: 0, color: colors[index % colors.length] },
                { offset: 1, color: colors[index % colors.length] + '99' }
              ]),
              borderRadius: [8, 8, 0, 0]
            }
          })),
          markLine: {
            silent: true,
            data: [{ type: 'average', name: '总平均' }],
            lineStyle: { color: '#ef4444', type: 'dashed' }
          }
        }]
      }, true)
    },

    // 任务完成情况饼图（与作业考试页面统计保持一致）
    initTaskChart() {
      if (!this.$refs.taskChart) return
      this.taskChart = echarts.init(this.$refs.taskChart)

      // 使用与作业考试页面一致的统计: total, submitted, pending, expired
      const { total, submitted, pending, expired } = this.dashboardData.taskStats

      // 没有数据时显示引导提示
      if (total === 0) {
        this.taskChart.setOption({
          title: {
            text: '📝 作业考试完成情况',
            subtext: '选课后，这里将显示您的作业和考试完成状态',
            left: 'center',
            top: 'center',
            textStyle: { color: '#667eea', fontSize: 14, fontWeight: 'normal' },
            subtextStyle: { color: '#94a3b8', fontSize: 12 }
          },
          series: []
        })
        return
      }

      this.taskChart.setOption({
        title: { show: false },
        tooltip: {
          trigger: 'item',
          formatter: (params) => {
            const percent = Math.round(params.value / total * 100)
            return `${params.name}<br/>数量: ${params.value} 个<br/>占比: ${percent}%`
          }
        },
        legend: {
          bottom: '5%',
          left: 'center',
          textStyle: { color: '#64748b', fontSize: 12 }
        },
        series: [{
          name: '作业考试状态',
          type: 'pie',
          radius: ['35%', '65%'],
          center: ['50%', '45%'],
          avoidLabelOverlap: true,
          itemStyle: {
            borderRadius: 6,
            borderColor: '#fff',
            borderWidth: 2
          },
          label: {
            show: true,
            formatter: '{b}\n{c}个',
            fontSize: 11,
            color: '#475569'
          },
          emphasis: {
            label: { show: true, fontSize: 13, fontWeight: 'bold' }
          },
          data: [
            {
              value: submitted,
              name: '已提交',
              itemStyle: {
                color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                  { offset: 0, color: '#43e97b' },
                  { offset: 1, color: '#38f9d7' }
                ])
              }
            },
            {
              value: pending,
              name: '待提交',
              itemStyle: {
                color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                  { offset: 0, color: '#fbbf24' },
                  { offset: 1, color: '#f59e0b' }
                ])
              }
            },
            {
              value: expired,
              name: '已截止',
              itemStyle: {
                color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                  { offset: 0, color: '#ef4444' },
                  { offset: 1, color: '#dc2626' }
                ])
              }
            }
          ]
        }]
      })
    },

    // 能力分析雷达图
    initRadarChart() {
      if (!this.$refs.radarChart) return
      this.radarChart = echarts.init(this.$refs.radarChart)

      const abilityData = this.dashboardData.abilityData
      const hasData = Object.values(abilityData).some(v => v > 0)

      // 没有数据时显示引导提示
      if (!hasData) {
        this.radarChart.setOption({
          title: {
            text: '🎯 综合能力分析',
            subtext: '开始学习后，这里将展示您的综合能力评估',
            left: 'center',
            top: 'center',
            textStyle: { color: '#667eea', fontSize: 14, fontWeight: 'normal' },
            subtextStyle: { color: '#94a3b8', fontSize: 12 }
          },
          radar: { indicator: [] },
          series: []
        })
        return
      }

      const indicator = [
        { name: '理论学习', max: 100 },
        { name: '实践操作', max: 100 },
        { name: '知识掌握', max: 100 },
        { name: '作业完成', max: 100 },
        { name: '学习时长', max: 100 }
      ]

      const dataValues = [abilityData.理论学习, abilityData.实践操作, abilityData.知识掌握, abilityData.作业完成, abilityData.学习时长]

      this.radarChart.setOption({
        title: { show: false },
        tooltip: { trigger: 'item' },
        radar: {
          indicator: indicator,
          radius: '65%',
          center: ['50%', '55%'],
          splitArea: {
            areaStyle: {
              color: ['rgba(147, 197, 253, 0.1)', 'rgba(147, 197, 253, 0.2)', 'rgba(147, 197, 253, 0.3)', 'rgba(147, 197, 253, 0.4)']
            }
          },
          axisName: { color: '#475569', fontSize: 11 },
          splitLine: { lineStyle: { color: 'rgba(147, 197, 253, 0.5)' } }
        },
        series: [{
          name: '能力分析',
          type: 'radar',
          symbol: 'circle',
          symbolSize: 6,
          data: [{
            value: dataValues,
            name: '综合能力',
            areaStyle: {
              color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                { offset: 0, color: 'rgba(102, 126, 234, 0.6)' },
                { offset: 1, color: 'rgba(79, 172, 254, 0.3)' }
              ])
            },
            lineStyle: { color: '#667eea', width: 2 },
            itemStyle: { color: '#667eea' }
          }]
        }]
      })
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
  background: linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 50%, #d1d5db 100%);
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
    background: radial-gradient(circle at 30% 20%, rgba(255, 255, 255, 0.98), rgba(239, 246, 255, 0.95) 55%);
    box-shadow: 0 4px 12px rgba(59, 130, 246, 0.2), inset 0 2px 8px rgba(255, 255, 255, 0.9);
    border: 5px solid rgba(96, 165, 250, 0.7);
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
      background: #1e40af;
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
      background: #ef4444;
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
    color: #1e40af;
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
      background: linear-gradient(90deg, rgba(96, 165, 250, 0), rgba(59, 130, 246, 0.6), rgba(96, 165, 250, 0));
      box-shadow: 0 0 8px rgba(59, 130, 246, 0.3);
    }
  }



  .welcome-sub {
    font-size: 40px;
    color: #2563eb;
    font-weight: bold;
  }
}

.welcome-sub {
  font-size: 24px;
  letter-spacing: 0.20em;
  color: #3b82f6;
  font-weight: 400;
}

.welcome-main {
  margin-top: 4px;
  font-size: 78px; /* 顶部主标题再大一档 */
  font-weight: 700; /* 更粗一点，突出主体 */
  letter-spacing: 0.07em; /* 稍微再拉开一点间距 */
  color: #1e40af;
  text-shadow: 0 2px 8px rgba(59, 130, 246, 0.15);
}

.welcome-motto {
  margin-top: 12px;
  font-size: 25px;
  color: #60a5fa;
}

// ========== 左侧日历（第二层） ==========
.calendar-card-left {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(239, 246, 255, 0.9) 100%);
  border-radius: 18px;
  padding: 20px;
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.15), 0 2px 8px rgba(37, 99, 235, 0.1);
  border: 1px solid rgba(96, 165, 250, 0.3);

  .calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 12px;
    border-bottom: 2px solid rgba(96, 165, 250, 0.5);

    .calendar-nav {
      background: linear-gradient(135deg, #eff6ff, #dbeafe);
      border: 1px solid #60a5fa;
      border-radius: 8px;
      width: 36px;
      height: 36px;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.3s;
      color: #2563eb;
      font-weight: 600;

      &:hover {
        background: linear-gradient(135deg, #3b82f6, #2563eb);
        color: white;
        border-color: #1d4ed8;
        transform: scale(1.1);
        box-shadow: 0 2px 8px rgba(37, 99, 235, 0.3);
      }
    }

    .calendar-title {
      font-size: 20px;
      font-weight: 700;
      color: #1e40af;
      text-shadow: 0 1px 2px rgba(255, 255, 255, 0.5);
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
      color: #1e40af;
      padding: 8px 0;
      background: rgba(255, 255, 255, 0.7);
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
      color: #1e40af;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.3s;
      background: rgba(255, 255, 255, 0.8);
      border: 1px solid rgba(96, 165, 250, 0.3);

      &:hover {
        background: rgba(255, 255, 255, 0.98);
        transform: scale(1.05);
        border-color: rgba(59, 130, 246, 0.6);
      }

      &.other-month {
        color: #93c5fd;
        background: rgba(255, 255, 255, 0.4);
      }

      &.today {
        background: linear-gradient(135deg, #3b82f6, #60a5fa);
        color: white;
        font-weight: 700;
        box-shadow: 0 3px 10px rgba(37, 99, 235, 0.4);
        border: none;
      }

      &.selected {
        background: rgba(59, 130, 246, 0.15);
        border: 2px solid #2563eb;
        font-weight: 600;
      }

      &.has-task {
        position: relative;
        background: linear-gradient(135deg, rgba(59, 130, 246, 0.3), rgba(96, 165, 250, 0.25));
        border-color: rgba(37, 99, 235, 0.6);

        .day-number {
          position: relative;
          z-index: 1;
          color: #1e40af;
          font-weight: 600;
        }

        .task-dot {
          position: absolute;
          top: 2px;
          right: 2px;
          background: #ef4444;
          color: white;
          font-size: 10px;
          width: 16px;
          height: 16px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: 600;
        }
      }

      // 有过期任务的日期（未提交）
      &.has-expired-task {
        background: linear-gradient(135deg, rgba(107, 114, 128, 0.25), rgba(156, 163, 175, 0.2));
        border-color: rgba(107, 114, 128, 0.5);

        .day-number {
          color: #6b7280;
          opacity: 0.7;
        }
      }

      // 所有任务都已提交的日期
      &.all-submitted {
        background: linear-gradient(135deg, rgba(16, 185, 129, 0.15), rgba(5, 150, 105, 0.1));
        border-color: rgba(16, 185, 129, 0.4);

        .day-number {
          color: #059669;
        }
      }
    }
  }

  .calendar-course-filter {
    margin-bottom: 12px;

    .el-select {
      width: 100%;
    }
  }

  .calendar-task-list {
    margin-top: 12px;
    padding-top: 12px;
    border-top: 1px solid rgba(96, 165, 250, 0.4);

    .task-list-title {
      font-size: 13px;
      font-weight: 600;
      color: #1e40af;
      margin-bottom: 8px;
    }

    .task-item {
      display: flex;
      align-items: center;
      padding: 8px 10px;
      background: rgba(255, 255, 255, 0.7);
      border-radius: 8px;
      margin-bottom: 6px;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: rgba(255, 255, 255, 0.95);
        transform: translateX(4px);
      }

      .task-type {
        font-size: 11px;
        padding: 2px 6px;
        border-radius: 4px;
        margin-right: 8px;
        font-weight: 600;

        &.homework {
          background: #dbeafe;
          color: #1d4ed8;
        }

        &.exam {
          background: #fef3c7;
          color: #d97706;
        }
      }

      .task-title {
        flex: 1;
        font-size: 13px;
        color: #334155;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .task-status {
        font-size: 11px;
        padding: 2px 8px;
        border-radius: 4px;
        margin-right: 8px;
        font-weight: 600;

        &.submitted {
          background: #d1fae5;
          color: #059669;
        }

        &.expired {
          background: #fee2e2;
          color: #dc2626;
        }
      }

      .el-icon-arrow-right {
        color: #94a3b8;
        font-size: 12px;
      }

      // 已过期任务样式
      &.task-expired {
        background: rgba(243, 244, 246, 0.7);
        opacity: 0.75;
        cursor: not-allowed;

        .task-title {
          color: #6b7280;
          text-decoration: line-through;
        }

        &:hover {
          background: rgba(243, 244, 246, 0.7);
          transform: none;
        }

        .el-icon-arrow-right {
          display: none;
        }
      }

      // 已提交任务样式
      &.task-submitted {
        background: rgba(209, 250, 229, 0.3);
        border: 1px solid rgba(16, 185, 129, 0.3);

        .task-title {
          color: #059669;
        }

        // 已提交且已过期的任务不可点击
        &.task-expired {
          cursor: not-allowed;

          &:hover {
            background: rgba(243, 244, 246, 0.7);
            transform: none;
          }

          .el-icon-arrow-right {
            display: none;
          }
        }
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
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(239, 246, 255, 0.9) 100%);
  border-radius: 20px;
  padding: 20px 40px;
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.15), 0 2px 8px rgba(37, 99, 235, 0.1);
  border: 1px solid rgba(96, 165, 250, 0.3);
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
  background: radial-gradient(circle at 30% 20%, rgba(255, 255, 255, 0.98), rgba(239, 246, 255, 0.95) 55%);
  border: 2px solid rgba(96, 165, 250, 0.6);
  position: relative;
  backdrop-filter: blur(14px);
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.2), 0 2px 8px rgba(37, 99, 235, 0.1);

  &::before {
    content: '';
    position: absolute;
    inset: -8px;
    border-radius: 50%;
    border: 1px dashed rgba(96, 165, 250, 0.4);
    box-shadow: 0 0 10px rgba(59, 130, 246, 0.15);
    animation: orbit-ring 14s linear infinite;
  }

  &::after {
    content: '';
    position: absolute;
    inset: 18px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(59, 130, 246, 0.08), transparent 70%);
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
  background: linear-gradient(135deg, #1e40af, #3b82f6);
  border-radius: 18px;
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.25), 0 2px 8px rgba(37, 99, 235, 0.15);
  border: 1px solid #60a5fa;
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
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(239, 246, 255, 0.9) 100%);
  border-radius: 18px;
  padding: 24px;
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.15), 0 2px 8px rgba(37, 99, 235, 0.1);
  border: 1px solid rgba(96, 165, 250, 0.3);
  position: relative;

  .section-title {
    font-size: 22px;
    font-weight: 600;
    font-kerning:100;
    color: #1e40af;
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
    background: rgba(255, 255, 255, 0.9);
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
      background: rgba(255, 255, 255, 0.98);
      border-color: rgba(59, 130, 246, 0.7);
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
      color: #1e40af;
    }

    .action-count {
      font-size: 14px;
      color: #60a5fa;
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
    background: rgba(255, 255, 255, 0.9);
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
      background: rgba(255, 255, 255, 0.98);
      border-color: rgba(59, 130, 246, 0.7);
    }

    .stat-icon {
      font-size: 36px;
      filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.1));
    }

    .stat-info {
      flex: 1;

      .stat-label {
        font-size: 14px;
        color: #60a5fa;
        margin-bottom: 8px;
      }

      .stat-value {
        font-size: 22px;
        font-weight: 600;
        color: #1e40af;
      }
    }
  }
}

// ========== Dashboard 数据看板 ==========
.dashboard-section {
  margin-top: 10px;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.dashboard-card {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.12);
  border: 1px solid rgba(96, 165, 250, 0.4);
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 16px rgba(59, 130, 246, 0.2);
    border-color: rgba(59, 130, 246, 0.6);
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    padding-bottom: 12px;
    border-bottom: 1px solid rgba(96, 165, 250, 0.3);
    flex-wrap: wrap;
    gap: 8px;

    .card-title {
      font-size: 16px;
      font-weight: 600;
      color: #1e40af;
    }

    .card-subtitle {
      font-size: 12px;
      color: #60a5fa;
    }

    .chart-switch {
      ::v-deep .el-radio-button__inner {
        padding: 5px 10px;
        font-size: 11px;
        border-color: rgba(96, 165, 250, 0.5);
        background: rgba(255, 255, 255, 0.95);
        color: #3b82f6;
      }
      ::v-deep .el-radio-button__orig-radio:checked + .el-radio-button__inner {
        background: linear-gradient(135deg, #3b82f6, #2563eb);
        border-color: #2563eb;
        box-shadow: none;
        color: white;
      }
    }
  }

  .chart-filter {
    margin-bottom: 10px;
    ::v-deep .el-select {
      width: 200px;
      .el-input__inner {
        border-color: rgba(96, 165, 250, 0.5);
        background: rgba(255, 255, 255, 0.98);
        font-size: 12px;
        height: 28px;
        line-height: 28px;
      }
    }
  }

  .chart-container {
    width: 100%;
    height: 260px;

    &.with-filter {
      height: 220px;
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

  .dashboard-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .quick-actions,
  .stats-grid,
  .dashboard-grid {
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

  .dashboard-card .chart-container {
    height: 220px;
  }
}

/* ==================== 提交作业对话框样式 ==================== */
.assignment-dialog {
  ::v-deep .el-dialog__header {
    background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%);
    padding: 20px 24px;
    border-radius: 8px 8px 0 0;
  }

  ::v-deep .el-dialog__body {
    padding: 24px;
  }

  ::v-deep .el-dialog__footer {
    padding: 16px 24px;
    border-top: 1px solid #f0f2f5;
  }

  .dialog-title-custom {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 18px;
    font-weight: 600;
    color: white;

    i {
      font-size: 22px;
    }
  }

  .submit-wrapper {
    .submit-info-card {
      background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
      border-radius: 12px;
      padding: 20px;
      margin-bottom: 24px;
      border: 1px solid rgba(59, 130, 246, 0.3);

      .info-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
        padding-bottom: 12px;
        border-bottom: 1px solid rgba(59, 130, 246, 0.2);

        .info-title {
          margin: 0;
          font-size: 18px;
          font-weight: 600;
          color: #1e40af;
        }
      }

      .info-meta {
        display: flex;
        flex-direction: column;
        gap: 12px;

        .meta-item-row {
          display: flex;
          align-items: center;
          font-size: 14px;

          .meta-label {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #606266;
            font-weight: 500;
            min-width: 100px;

            i {
              color: #3b82f6;
              font-size: 16px;
            }
          }

          .meta-value {
            color: #303133;
          }

          &.deadline-meta {
            .meta-value {
              color: #E6A23C;
              font-weight: 500;
            }
          }
        }
      }
    }

    .submit-form-section {
      .dialog-form {
        .form-tip {
          margin-top: 8px;
          font-size: 12px;
          color: #909399;
          display: flex;
          align-items: center;
          gap: 4px;

          i {
            color: #3b82f6;
          }
        }

        .remark-textarea {
          ::v-deep textarea {
            border-radius: 8px;
            border-color: #dcdfe6;
            transition: all 0.3s;

            &:focus {
              border-color: #3b82f6;
              box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
            }
          }
        }
      }
    }
  }

  .dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;

    .el-button {
      padding: 10px 24px;
      border-radius: 8px;
      font-weight: 500;
      transition: all 0.3s;

      i {
        margin-right: 4px;
      }

      &.el-button--primary {
        background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%);
        border: none;

        &:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
        }
      }
    }
  }
}
</style>