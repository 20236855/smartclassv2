<template>
  <div class="course-tasks-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <el-button type="text" icon="el-icon-back" @click="goBack" class="back-btn">
        返回课程详情
      </el-button>
      <div class="header-content">
        <h2 class="page-title">
          <i class="el-icon-edit-outline"></i>
          {{ courseTitle || '课程任务' }}
        </h2>
        <p class="page-subtitle">作业与考试</p>
      </div>
    </div>

    <!-- 任务统计 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <i class="el-icon-document stat-icon" style="color: #409EFF;"></i>
            <div class="stat-info">
              <div class="stat-value">{{ totalTasks }}</div>
              <div class="stat-label">总任务数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <i class="el-icon-edit stat-icon" style="color: #67C23A;"></i>
            <div class="stat-info">
              <div class="stat-value">{{ homeworkCount }}</div>
              <div class="stat-label">作业</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <i class="el-icon-medal stat-icon" style="color: #E6A23C;"></i>
            <div class="stat-info">
              <div class="stat-value">{{ examCount }}</div>
              <div class="stat-label">考试</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <i class="el-icon-circle-check stat-icon" style="color: #909399;"></i>
            <div class="stat-info">
              <div class="stat-value">{{ completedCount }}</div>
              <div class="stat-label">已完成</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 任务列表 -->
    <div v-loading="loading" class="tasks-content">
      <el-row :gutter="20" class="task-list" v-if="taskList.length > 0">
        <el-col
          v-for="task in taskList"
          :key="task.id"
          :xs="24" :sm="12" :md="8" :lg="6"
        >
          <el-card shadow="hover" class="task-card" :class="getTaskCardClass(task)">
            <div class="task-header">
              <div class="task-type-badge" :class="task.type === 'homework' ? 'badge-homework' : 'badge-exam'">
                <i :class="task.type === 'homework' ? 'el-icon-edit' : 'el-icon-medal'"></i>
                {{ task.type === 'homework' ? '作业' : '考试' }}
              </div>
              <el-tag :type="getStatusType(task)" size="small">
                {{ getStatusText(task) }}
              </el-tag>
            </div>
            <h3 class="task-title" :title="task.title">{{ task.title }}</h3>
            <div class="task-description" v-if="task.description">
              {{ task.description }}
            </div>
            <div class="task-meta">
              <div class="meta-item">
                <i class="el-icon-time"></i>
                开始：{{ formatDate(task.startTime) }}
              </div>
              <div class="meta-item">
                <i class="el-icon-alarm-clock"></i>
                截止：{{ formatDate(task.endTime) }}
              </div>
              <div class="meta-item" v-if="task.totalScore">
                <i class="el-icon-star-on"></i>
                总分：{{ task.totalScore }}
              </div>
              <div class="meta-item" v-if="task.duration">
                <i class="el-icon-timer"></i>
                时长：{{ task.duration }} 分钟
              </div>
            </div>
            <div class="task-actions">
              <el-button
                type="primary"
                size="small"
                :disabled="isExpired(task)"
                @click="startTask(task)"
              >
                <i :class="task.mode === 'question' ? 'el-icon-edit' : 'el-icon-upload'"></i>
                {{ task.mode === 'question' ? '开始答题' : '提交作业' }}
              </el-button>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 无数据提示 -->
      <el-empty
        v-if="!loading && taskList.length === 0"
        description="该课程暂无任务"
        :image-size="120"
      >
        <el-button type="primary" @click="goBack">返回课程详情</el-button>
      </el-empty>
    </div>
  </div>
</template>

<script>
import { listAssignment } from "@/api/system/assignment"

export default {
  name: "CourseTasks",
  data() {
    return {
      loading: true,
      courseId: null,
      courseTitle: '',
      taskList: [],
      totalTasks: 0,
      homeworkCount: 0,
      examCount: 0,
      completedCount: 0
    }
  },
  created() {
    this.courseId = this.$route.query.courseId
    this.courseTitle = this.$route.query.courseTitle || ''

    if (this.courseId) {
      this.loadCourseTasks()
    } else {
      this.$modal.msgError("缺少课程ID参数")
      this.loading = false
    }
  },
  methods: {
    // 加载课程任务
    async loadCourseTasks() {
      this.loading = true
      try {
        const response = await listAssignment({
          courseId: this.courseId,
          status: 1,
          isDeleted: 0,
          pageNum: 1,
          pageSize: 999
        })

        this.taskList = response.rows || []

        // 统计数据
        this.totalTasks = this.taskList.length
        this.homeworkCount = this.taskList.filter(t => t.type === 'homework').length
        this.examCount = this.taskList.filter(t => t.type === 'exam').length
        this.completedCount = 0 // TODO: 从提交记录中获取

        // 按开始时间排序
        this.taskList.sort((a, b) => new Date(a.startTime) - new Date(b.startTime))
      } catch (error) {
        console.error('加载课程任务失败:', error)
        this.$modal.msgError("加载课程任务失败")
      } finally {
        this.loading = false
      }
    },
    // 返回课程详情
    goBack() {
      this.$router.go(-1)
    },
    // 格式化日期
    formatDate(date) {
      if (!date) return '未设置'
      return this.parseTime(date, '{y}-{m}-{d} {h}:{i}')
    },
    // 获取任务状态文本
    getStatusText(task) {
      const now = new Date()
      const start = task.startTime ? new Date(task.startTime) : null
      const end = task.endTime ? new Date(task.endTime) : null

      if (end && now > end) return '已截止'
      if (start && now < start) return '未开始'
      return '进行中'
    },
    // 获取任务状态类型
    getStatusType(task) {
      const status = this.getStatusText(task)
      if (status === '进行中') return 'success'
      if (status === '未开始') return 'info'
      return 'danger'
    },
    // 判断任务是否已过期
    isExpired(task) {
      if (!task.endTime) return false
      return new Date() > new Date(task.endTime)
    },
    // 获取任务卡片样式类
    getTaskCardClass(task) {
      if (this.isExpired(task)) return 'task-expired'
      if (this.getStatusText(task) === '未开始') return 'task-pending'
      return 'task-active'
    },
    // 开始任务
    startTask(task) {
      if (this.isExpired(task)) {
        this.$modal.msgWarning("任务已截止")
        return
      }

      // 跳转到作业/考试页面
      this.$router.push({
        path: '/system/assignment',
        query: {
          assignmentId: task.id,
          courseId: this.courseId
        }
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.course-tasks-container {
  padding: 20px;
  background: #f0f2f5;
  min-height: calc(100vh - 84px);
}

.page-header {
  background: white;
  padding: 24px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);

  .back-btn {
    font-size: 14px;
    margin-bottom: 12px;
    padding: 0;

    &:hover {
      color: #409EFF;
    }
  }

  .header-content {
    .page-title {
      font-size: 24px;
      font-weight: 600;
      color: #303133;
      margin: 0 0 8px 0;
      display: flex;
      align-items: center;
      gap: 8px;

      i {
        font-size: 28px;
        color: #409EFF;
      }
    }

    .page-subtitle {
      font-size: 14px;
      color: #909399;
      margin: 0;
    }
  }
}

.stats-row {
  margin-bottom: 20px;

  .stat-card {
    border-radius: 8px;

    ::v-deep .el-card__body {
      padding: 20px;
    }

    .stat-content {
      display: flex;
      align-items: center;
      gap: 16px;

      .stat-icon {
        font-size: 48px;
      }

      .stat-info {
        flex: 1;

        .stat-value {
          font-size: 28px;
          font-weight: 600;
          color: #303133;
          line-height: 1;
          margin-bottom: 8px;
        }

        .stat-label {
          font-size: 14px;
          color: #909399;
        }
      }
    }
  }
}

.tasks-content {
  background: white;
  padding: 24px;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);

  .task-list {
    .task-card {
      margin-bottom: 16px;
      border-radius: 8px;
      transition: all 0.3s;

      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
      }

      &.task-active {
        border-left: 4px solid #67C23A;
      }

      &.task-pending {
        border-left: 4px solid #909399;
      }

      &.task-expired {
        border-left: 4px solid #F56C6C;
        opacity: 0.7;
      }

      .task-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 12px;

        .task-type-badge {
          display: inline-flex;
          align-items: center;
          gap: 4px;
          padding: 4px 12px;
          border-radius: 12px;
          font-size: 12px;
          font-weight: 600;

          &.badge-homework {
            background: #e1f3d8;
            color: #67C23A;
          }

          &.badge-exam {
            background: #fdf6ec;
            color: #E6A23C;
          }
        }
      }

      .task-title {
        font-size: 16px;
        font-weight: 600;
        color: #303133;
        margin: 0 0 8px 0;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .task-description {
        font-size: 14px;
        color: #606266;
        margin-bottom: 12px;
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
      }

      .task-meta {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 8px;
        margin-bottom: 16px;

        .meta-item {
          font-size: 13px;
          color: #909399;
          display: flex;
          align-items: center;
          gap: 4px;

          i {
            font-size: 14px;
          }
        }
      }

      .task-actions {
        display: flex;
        justify-content: center;

        .el-button {
          width: 100%;
        }
      }
    }
  }
}
</style>
