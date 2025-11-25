<template>
  <div class="app-container learning-progress-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="title-section">
          <h1 class="page-title">
            <i class="el-icon-video-play"></i>
            我的学习进度
          </h1>
          <p class="page-subtitle">跟踪您的视频学习进度，继续未完成的课程</p>
        </div>
        <div class="stats-section">
          <div class="stat-card">
            <div class="stat-number">{{ completedCount }}</div>
            <div class="stat-label">已完成</div>
          </div>
          <div class="stat-card">
            <div class="stat-number">{{ inProgressCount }}</div>
            <div class="stat-label">进行中</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 筛选和搜索 -->
    <div class="filter-section">
      <div class="filter-left">
        <el-radio-group v-model="activeFilter" @change="handleFilterChange" class="filter-tabs">
          <el-radio-button label="all">全部视频</el-radio-button>
          <el-radio-button label="completed">已完成</el-radio-button>
          <el-radio-button label="inProgress">进行中</el-radio-button>
        </el-radio-group>
      </div>
      <div class="filter-right">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索课程或章节..."
          prefix-icon="el-icon-search"
          @input="handleSearch"
          class="search-input"
          clearable
        />
      </div>
    </div>

    <!-- 视频列表 -->
    <div class="video-list-container" v-loading="loading">
      <div v-if="filteredVideoList.length === 0" class="empty-state">
        <el-empty description="暂无视频数据" :image-size="120">
          <el-button type="primary" @click="refreshData">刷新数据</el-button>
        </el-empty>
      </div>

      <div v-else class="video-grid">
        <div
          v-for="video in filteredVideoList"
          :key="video.id"
          class="video-card"
          :class="{ 'completed': video.isCompleted, 'in-progress': video.isInProgress }"
        >
          <!-- 视频信息 -->
          <div class="video-info">
            <h3 class="video-title" :title="video.title">{{ video.title || `视频 ${video.videoId}` }}</h3>
            <p class="video-meta">
              <span class="course-name">{{ video.courseName || '未知课程' }}</span>
              <span class="chapter-name" v-if="video.chapterName">· {{ video.chapterName }}</span>
            </p>

            <!-- 进度信息 -->
            <div class="progress-info">
              <div class="progress-text">
                <span v-if="video.isCompleted" class="status-completed">
                  <i class="el-icon-check"></i> 已完成
                </span>
                <span v-else-if="video.isInProgress" class="status-progress">
                  <i class="el-icon-time"></i>
                  已观看 {{ Math.round(video.completionRate) }}%
                </span>
                <span v-else class="status-not-started">
                  <i class="el-icon-video-play"></i> 未开始
                </span>
              </div>

              <!-- 进度条 -->
              <div class="progress-bar-container" v-if="!video.isCompleted">
                <div class="progress-bar-bg">
                  <div
                    class="progress-bar-fill"
                    :style="{ width: video.completionRate + '%' }"
                  ></div>
                </div>
                <span class="progress-percentage">{{ Math.round(video.completionRate) }}%</span>
              </div>
            </div>

            <!-- 学习统计 -->
            <div class="learning-stats">
              <div class="stat-item">
                <i class="el-icon-view"></i>
                <span>观看 {{ video.watchCount || 0 }} 次</span>
              </div>
              <div class="stat-item" v-if="video.lastWatchAt">
                <i class="el-icon-time"></i>
                <span>{{ formatRelativeTime(video.lastWatchAt) }}</span>
              </div>
            </div>

            <!-- 继续观看按钮 -->
            <div class="action-buttons">
              <el-button
                type="primary"
                size="small"
                @click.stop="playVideo(video)"
                :icon="video.isCompleted ? 'el-icon-refresh' : 'el-icon-video-play'"
              >
                {{ video.isCompleted ? '重新观看' : (video.isInProgress ? '继续观看' : '开始观看') }}
              </el-button>
              <el-button
                size="small"
                @click.stop="showVideoDetails(video)"
                icon="el-icon-info"
              >
                详情
              </el-button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 分页 -->
    <div class="pagination-container" v-if="total > 0">
      <el-pagination
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="queryParams.pageNum"
        :page-sizes="[12, 24, 48, 96]"
        :page-size="queryParams.pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        background
      />
    </div>


  </div>
</template>

<script>
import { listBehavior } from "@/api/system/behavior"

export default {
  name: "LearningProgress",
  data() {
    return {
      // 加载状态
      loading: true,
      // 总条数
      total: 0,
      // 视频学习数据
      videoList: [],
      // 筛选后的视频列表
      filteredVideoList: [],
      // 当前筛选条件
      activeFilter: 'all',
      // 搜索关键词
      searchKeyword: '',
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 12,
        isCompleted: null,
      },
      // 统计数据
      completedCount: 0,
      inProgressCount: 0,
      totalWatchTime: '0分钟',
    }
  },
  created() {
    this.getList()
  },
  computed: {
    // 根据筛选条件和搜索关键词过滤视频列表
    filteredList() {
      let list = [...this.videoList]

      // 根据完成状态筛选
      if (this.activeFilter === 'completed') {
        list = list.filter(video => video.isCompleted)
      } else if (this.activeFilter === 'inProgress') {
        list = list.filter(video => video.isInProgress && !video.isCompleted)
      } else if (this.activeFilter === 'notStarted') {
        list = list.filter(video => !video.isInProgress && !video.isCompleted)
      }

      // 根据搜索关键词筛选
      if (this.searchKeyword) {
        const keyword = this.searchKeyword.toLowerCase()
        list = list.filter(video =>
          (video.title && video.title.toLowerCase().includes(keyword)) ||
          (video.courseName && video.courseName.toLowerCase().includes(keyword)) ||
          (video.chapterName && video.chapterName.toLowerCase().includes(keyword))
        )
      }

      return list
    }
  },
  methods: {
    /** 查询视频学习行为列表 */
    getList() {
      this.loading = true
      listBehavior(this.queryParams).then(response => {
        // 处理数据，添加计算字段
        this.videoList = response.rows.map(item => ({
          ...item,
          isCompleted: item.isCompleted === 1,
          isInProgress: item.completionRate > 0 && item.isCompleted !== 1,
          title: item.title || `第${item.videoId}节`,
          courseName: item.courseName || '未知课程',
          chapterName: item.chapterName || '未知章节',
          lastPosition: item.lastPosition || 0
        }))

        this.filteredVideoList = this.filteredList
        this.total = response.total
        this.calculateStats()
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },

    /** 计算统计数据 */
    calculateStats() {
      this.completedCount = this.videoList.filter(v => v.isCompleted).length
      this.inProgressCount = this.videoList.filter(v => v.isInProgress && !v.isCompleted).length

      // 计算总观看时长
      const totalMinutes = this.videoList.reduce((sum, video) => {
        return sum + (video.watchDuration || 0)
      }, 0)

      if (totalMinutes >= 60) {
        const hours = Math.floor(totalMinutes / 60)
        const minutes = totalMinutes % 60
        this.totalWatchTime = `${hours}小时${minutes}分钟`
      } else {
        this.totalWatchTime = `${totalMinutes}分钟`
      }
    },

    /** 筛选条件改变 */
    handleFilterChange() {
      this.filteredVideoList = this.filteredList
    },

    /** 搜索 */
    handleSearch() {
      this.filteredVideoList = this.filteredList
    },

    /** 刷新数据 */
    refreshData() {
      this.getList()
    },

    /** 分页大小改变 */
    handleSizeChange(val) {
      this.queryParams.pageSize = val
      this.getList()
    },

    /** 当前页改变 */
    handleCurrentChange(val) {
      this.queryParams.pageNum = val
      this.getList()
    },
    /** 播放视频 */
    playVideo(video) {
      // 构建跳转路由，包含上次观看位置
      const sectionId = video.videoId
      const routeData = {
        path: `/course/section/${sectionId}`,
        query: {
          courseName: video.courseName,
          courseId: video.courseId
        }
      }

      // 如果视频已完成，重新观看从头开始
      if (video.isCompleted) {
        routeData.query.t = 0
        console.log(`🔄 重新观看已完成的视频，从头开始播放`)

        // 显示提示信息
        this.$message({
          message: '即将从头开始播放视频',
          type: 'success',
          duration: 2000
        })
      }
      // 如果有上次观看位置且未完成，继续观看
      else if (video.lastPosition && video.lastPosition > 0) {
        routeData.query.t = Math.floor(video.lastPosition)
        console.log(`🎯 继续观看视频，跳转到: ${this.formatDuration(video.lastPosition)}`)

        // 显示提示信息
        this.$message({
          message: `即将跳转到上次观看位置: ${this.formatDuration(video.lastPosition)}`,
          type: 'info',
          duration: 2000
        })
      } else {
        console.log(`▶️ 开始观看新视频`)
      }

      // 跳转到视频播放页面
      this.$router.push(routeData)
    },

    /** 显示视频详情 */
    showVideoDetails(video) {
      // 跳转到详情页面，传递视频数据
      this.$router.push({
        name: 'LearningDetail',
        params: {
          id: video.id,
          videoData: video
        }
      });
    },



    /** 格式化时长 */
    formatDuration(seconds) {
      if (!seconds || seconds <= 0) return '0秒'

      const hours = Math.floor(seconds / 3600)
      const minutes = Math.floor((seconds % 3600) / 60)
      const secs = Math.floor(seconds % 60)

      if (hours > 0) {
        return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
      } else {
        return `${minutes}:${secs.toString().padStart(2, '0')}`
      }
    },

    /** 格式化日期时间 */
    formatDateTime(dateTime) {
      if (!dateTime) return '未知'
      return this.parseTime(dateTime, '{y}-{m}-{d} {h}:{i}')
    },

    /** 格式化相对时间 */
    formatRelativeTime(dateTime) {
      if (!dateTime) return '未知'

      const now = new Date()
      const date = new Date(dateTime)
      const diff = now - date
      const days = Math.floor(diff / (1000 * 60 * 60 * 24))

      if (days === 0) {
        const hours = Math.floor(diff / (1000 * 60 * 60))
        if (hours === 0) {
          const minutes = Math.floor(diff / (1000 * 60))
          return minutes <= 0 ? '刚刚' : `${minutes}分钟前`
        }
        return `${hours}小时前`
      } else if (days === 1) {
        return '昨天'
      } else if (days < 7) {
        return `${days}天前`
      } else {
        return this.parseTime(dateTime, '{m}-{d}')
      }
    },

    /** 获取进度条颜色 */
    getProgressColor(percentage) {
      if (percentage >= 100) return '#67C23A'
      if (percentage >= 80) return '#E6A23C'
      if (percentage >= 50) return '#409EFF'
      return '#F56C6C'
    }
  }
}
</script>

<style lang="scss" scoped>
.learning-progress-page {
  background: #f5f7fa;
  min-height: calc(100vh - 84px);

  .page-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 32px 24px;
    margin: -20px -20px 24px -20px;
    border-radius: 0 0 16px 16px;

    .header-content {
      display: flex;
      justify-content: space-between;
      align-items: center;
      max-width: 1200px;
      margin: 0 auto;

      .title-section {
        .page-title {
          font-size: 28px;
          font-weight: 600;
          margin: 0 0 8px 0;
          display: flex;
          align-items: center;
          gap: 12px;

          i {
            font-size: 32px;
          }
        }

        .page-subtitle {
          font-size: 16px;
          opacity: 0.9;
          margin: 0;
        }
      }

      .stats-section {
        display: flex;
        gap: 24px;

        .stat-card {
          text-align: center;
          background: rgba(255, 255, 255, 0.15);
          padding: 16px 20px;
          border-radius: 12px;
          backdrop-filter: blur(10px);
          min-width: 80px;

          .stat-number {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 4px;
          }

          .stat-label {
            font-size: 14px;
            opacity: 0.9;
          }
        }
      }
    }
  }

  .filter-section {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    padding: 0 4px;

    .filter-left {
      .filter-tabs {
        ::v-deep .el-radio-button__inner {
          border-radius: 20px;
          margin-right: 8px;
          border: 1px solid #dcdfe6;
          background: white;
          color: #606266;

          &:hover {
            color: #667eea;
            border-color: #667eea;
          }
        }

        ::v-deep .el-radio-button__orig-radio:checked + .el-radio-button__inner {
          background: #667eea;
          border-color: #667eea;
          color: white;
          box-shadow: none;
        }
      }
    }

    .filter-right {
      .search-input {
        width: 300px;

        ::v-deep .el-input__inner {
          border-radius: 20px;
          border: 1px solid #dcdfe6;

          &:focus {
            border-color: #667eea;
          }
        }
      }
    }
  }

  .video-list-container {
    .empty-state {
      text-align: center;
      padding: 60px 20px;
      background: white;
      border-radius: 12px;
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    }

    .video-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 20px;

      .video-card {
        background: white;
        border-radius: 8px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
        overflow: hidden;
        transition: all 0.2s ease;
        border: 1px solid #e8eaed;
        border-left: 3px solid transparent;

        &:hover {
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
          border-left-color: #606266;
        }

        &.completed {
          border-left-color: #67C23A;
        }

        &.in-progress {
          border-left-color: #409EFF;
        }

        .video-info {
          padding: 18px 20px;

          .video-title {
            font-size: 15px;
            font-weight: 500;
            color: #303133;
            margin: 0 0 8px 0;
            line-height: 1.5;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
          }

          .video-meta {
            font-size: 14px;
            color: #909399;
            margin: 0 0 16px 0;

            .course-name {
              font-weight: 500;
            }

            .chapter-name {
              opacity: 0.8;
            }
          }

          .progress-info {
            margin-bottom: 16px;

            .progress-text {
              margin-bottom: 8px;

              .status-completed {
                color: #67C23A;
                font-weight: 500;

                i {
                  margin-right: 4px;
                }
              }

              .status-progress {
                color: #409EFF;
                font-weight: 500;

                i {
                  margin-right: 4px;
                }
              }

              .status-not-started {
                color: #909399;

                i {
                  margin-right: 4px;
                }
              }
            }

            .progress-bar-container {
              display: flex;
              align-items: center;
              gap: 8px;

              .progress-bar-bg {
                flex: 1;
                height: 6px;
                background: #f0f2f5;
                border-radius: 3px;
                overflow: hidden;

                .progress-bar-fill {
                  height: 100%;
                  background: linear-gradient(90deg, #409EFF 0%, #67C23A 100%);
                  border-radius: 3px;
                  transition: width 0.3s ease;
                }
              }

              .progress-percentage {
                font-size: 12px;
                color: #909399;
                font-weight: 500;
                min-width: 35px;
                text-align: right;
              }
            }
          }

          .learning-stats {
            display: flex;
            gap: 16px;
            margin-bottom: 16px;

            .stat-item {
              display: flex;
              align-items: center;
              gap: 4px;
              font-size: 12px;
              color: #909399;

              i {
                font-size: 14px;
              }
            }
          }

          .action-buttons {
            display: flex;
            gap: 8px;

            .el-button {
              flex: 1;
              border-radius: 6px;

              &.el-button--primary {
                background: #667eea;
                border-color: #667eea;

                &:hover {
                  background: #5a6fd8;
                  border-color: #5a6fd8;
                }
              }
            }
          }
        }
      }
    }
  }

  .pagination-container {
    margin-top: 32px;
    text-align: center;

    ::v-deep .el-pagination {
      .el-pager li {
        border-radius: 6px;
        margin: 0 2px;

        &.active {
          background: #667eea;
          border-color: #667eea;
        }
      }

      .btn-prev,
      .btn-next {
        border-radius: 6px;
      }
    }
  }
}
</style>
