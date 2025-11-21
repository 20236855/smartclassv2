<template>
  <div class="learning-detail-page">
    <!-- 返回按钮 -->
    <div class="back-button" @click="goBack">
      <i class="el-icon-arrow-left"></i>
      <span>返回</span>
    </div>

    <div v-if="videoDetail" class="detail-container">
      <!-- 左侧：视频信息 -->
      <div class="left-section">
        <!-- 视频标题卡片 -->
        <div class="video-header-card">
          <div class="video-icon-large">
            <i class="el-icon-video-play"></i>
          </div>
          <h1 class="video-title">{{ videoDetail.title || `视频 ${videoDetail.videoId}` }}</h1>
          <p class="video-course">{{ videoDetail.courseName }} · {{ videoDetail.chapterName }}</p>
        </div>

        <!-- 学习进度卡片 -->
        <div class="progress-card">
          <div class="card-header">
            <span class="card-icon">📊</span>
            <h3>学习进度</h3>
          </div>
          <div class="progress-circle-container">
            <el-progress
              type="circle"
              :percentage="Math.round(videoDetail.completionRate)"
              :width="160"
              :stroke-width="12"
              :color="getProgressColor(videoDetail.completionRate)"
            >
              <template slot="default">
                <div class="progress-text">
                  <div class="percentage">{{ Math.round(videoDetail.completionRate) }}%</div>
                  <div class="label">完成度</div>
                </div>
              </template>
            </el-progress>
          </div>
          <div class="time-stats">
            <div class="time-item">
              <div class="time-label">已观看</div>
              <div class="time-value">{{ formatDuration(videoDetail.watchDuration) }}</div>
            </div>
            <div class="time-divider"></div>
            <div class="time-item">
              <div class="time-label">总时长</div>
              <div class="time-value">{{ formatDuration(videoDetail.videoDuration) }}</div>
            </div>
          </div>
        </div>

        <!-- 操作按钮 -->
        <div class="action-buttons">
          <el-button type="primary" size="large" @click="continueWatching" class="continue-btn">
            <i class="el-icon-video-play"></i>
            {{ videoDetail.isCompleted ? '重新观看' : '继续观看' }}
          </el-button>
        </div>
      </div>

      <!-- 右侧：学习记录 -->
      <div class="right-section">
        <!-- 学习记录卡片 -->
        <div class="records-card">
          <div class="card-header">
            <span class="card-icon">📝</span>
            <h3>学习记录</h3>
          </div>
          <div class="record-list">
            <div class="record-item">
              <div class="record-icon-wrapper blue">
                <i class="el-icon-view"></i>
              </div>
              <div class="record-content">
                <div class="record-label">观看次数</div>
                <div class="record-value">{{ videoDetail.watchCount || 0 }} 次</div>
              </div>
            </div>
            <div class="record-item" v-if="videoDetail.firstWatchAt">
              <div class="record-icon-wrapper green">
                <i class="el-icon-time"></i>
              </div>
              <div class="record-content">
                <div class="record-label">首次观看</div>
                <div class="record-value">{{ formatRelativeTime(videoDetail.firstWatchAt) }}</div>
              </div>
            </div>
            <div class="record-item" v-if="videoDetail.lastWatchAt">
              <div class="record-icon-wrapper purple">
                <i class="el-icon-clock"></i>
              </div>
              <div class="record-content">
                <div class="record-label">最近观看</div>
                <div class="record-value">{{ formatRelativeTime(videoDetail.lastWatchAt) }}</div>
              </div>
            </div>
            <div class="record-item" v-if="videoDetail.lastPosition > 0">
              <div class="record-icon-wrapper orange">
                <i class="el-icon-video-pause"></i>
              </div>
              <div class="record-content">
                <div class="record-label">上次停止位置</div>
                <div class="record-value">{{ formatDuration(videoDetail.lastPosition) }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- 学习统计卡片 -->
        <div class="stats-card">
          <div class="card-header">
            <span class="card-icon">📈</span>
            <h3>学习统计</h3>
          </div>
          <div class="stats-grid">
            <div class="stat-box">
              <div class="stat-icon">⏩</div>
              <div class="stat-info">
                <div class="stat-label">快进次数</div>
                <div class="stat-number">{{ videoDetail.fastForwardCount || 0 }}</div>
              </div>
            </div>
            <div class="stat-box">
              <div class="stat-icon">⏸️</div>
              <div class="stat-info">
                <div class="stat-label">暂停次数</div>
                <div class="stat-number">{{ videoDetail.pauseCount || 0 }}</div>
              </div>
            </div>
            <div class="stat-box">
              <div class="stat-icon">⚡</div>
              <div class="stat-info">
                <div class="stat-label">播放速度</div>
                <div class="stat-number">{{ videoDetail.playbackSpeed || 1.0 }}x</div>
              </div>
            </div>
            <div class="stat-box">
              <div class="stat-icon">{{ videoDetail.isCompleted ? '✅' : '⏳' }}</div>
              <div class="stat-info">
                <div class="stat-label">完成状态</div>
                <div class="stat-number">{{ videoDetail.isCompleted ? '已完成' : '进行中' }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "LearningDetail",
  data() {
    return {
      videoDetail: null
    };
  },
  created() {
    // 从路由参数或状态中获取视频详情
    const videoId = this.$route.params.id;
    const videoData = this.$route.params.videoData;

    if (videoData) {
      this.videoDetail = videoData;
    } else if (videoId) {
      // 如果只有ID，可以从API加载
      this.loadVideoDetail(videoId);
    }
  },
  methods: {
    goBack() {
      this.$router.go(-1);
    },

    continueWatching() {
      if (this.videoDetail && this.videoDetail.videoId) {
        const query = {
          courseName: this.videoDetail.courseName,
          courseId: this.videoDetail.courseId
        };

        // 如果视频已完成，重新观看从头开始
        if (this.videoDetail.isCompleted) {
          query.t = 0;
          this.$message({
            message: '即将从头开始播放视频',
            type: 'success',
            duration: 2000
          });
        }
        // 如果有上次观看位置且未完成，继续观看
        else if (this.videoDetail.lastPosition && this.videoDetail.lastPosition > 0) {
          query.t = Math.floor(this.videoDetail.lastPosition);
          this.$message({
            message: `即将跳转到上次观看位置: ${this.formatDuration(this.videoDetail.lastPosition)}`,
            type: 'info',
            duration: 2000
          });
        }

        this.$router.push({
          path: `/course/section/${this.videoDetail.videoId}`,
          query: query
        });
      }
    },

    loadVideoDetail(videoId) {
      // 这里可以调用API加载详情
      console.log("加载视频详情:", videoId);
    },

    formatDuration(seconds) {
      if (!seconds || seconds === 0) return '0:00';
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      const secs = Math.floor(seconds % 60);

      if (hours > 0) {
        return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
      }
      return `${minutes}:${secs.toString().padStart(2, '0')}`;
    },

    formatRelativeTime(dateTime) {
      if (!dateTime) return '';

      const now = new Date();
      const date = new Date(dateTime);
      const diffMs = now - date;
      const diffMins = Math.floor(diffMs / 60000);
      const diffHours = Math.floor(diffMs / 3600000);
      const diffDays = Math.floor(diffMs / 86400000);

      if (diffMins < 1) return '刚刚';
      if (diffMins < 60) return `${diffMins}分钟前`;
      if (diffHours < 24) return `${diffHours}小时前`;
      if (diffDays < 7) return `${diffDays}天前`;

      return date.toLocaleDateString('zh-CN');
    },

    getProgressColor(percentage) {
      if (percentage >= 100) return '#10b981';
      if (percentage >= 60) return '#3b82f6';
      if (percentage >= 30) return '#f59e0b';
      return '#ef4444';
    }
  }
};
</script>

<style lang="scss" scoped>
.learning-detail-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 20px;

  .back-button {
    max-width: 1200px;
    margin: 0 auto 24px;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 20px;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 8px;
    color: #fff;
    font-size: 14px;
    cursor: pointer;
    transition: all 0.3s ease;
    backdrop-filter: blur(10px);

    &:hover {
      background: rgba(255, 255, 255, 0.3);
      transform: translateX(-4px);
    }

    i {
      font-size: 16px;
    }
  }

  .detail-container {
    max-width: 1200px;
    margin: 0 auto;
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;

    @media (max-width: 968px) {
      grid-template-columns: 1fr;
    }
  }

  .left-section,
  .right-section {
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  // 视频标题卡片
  .video-header-card {
    background: #fff;
    border-radius: 20px;
    padding: 40px;
    text-align: center;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);

    .video-icon-large {
      width: 80px;
      height: 80px;
      margin: 0 auto 24px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border-radius: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);

      i {
        font-size: 40px;
        color: #fff;
      }
    }

    .video-title {
      font-size: 28px;
      font-weight: 700;
      color: #1f2937;
      margin: 0 0 12px 0;
      line-height: 1.3;
    }

    .video-course {
      font-size: 16px;
      color: #6b7280;
      margin: 0;
    }
  }

  // 学习进度卡片
  .progress-card {
    background: #fff;
    border-radius: 20px;
    padding: 32px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);

    .card-header {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 28px;

      .card-icon {
        font-size: 24px;
      }

      h3 {
        font-size: 20px;
        font-weight: 600;
        color: #1f2937;
        margin: 0;
      }
    }

    .progress-circle-container {
      display: flex;
      justify-content: center;
      margin-bottom: 28px;

      .progress-text {
        text-align: center;

        .percentage {
          font-size: 32px;
          font-weight: 700;
          color: #1f2937;
          margin-bottom: 4px;
        }

        .label {
          font-size: 14px;
          color: #6b7280;
        }
      }
    }

    .time-stats {
      display: flex;
      justify-content: space-around;
      padding: 20px;
      background: #f9fafb;
      border-radius: 12px;

      .time-item {
        text-align: center;

        .time-label {
          font-size: 13px;
          color: #6b7280;
          margin-bottom: 8px;
        }

        .time-value {
          font-size: 20px;
          font-weight: 700;
          color: #3b82f6;
        }
      }

      .time-divider {
        width: 1px;
        background: #e5e7eb;
      }
    }
  }

  // 操作按钮
  .action-buttons {
    .continue-btn {
      width: 100%;
      height: 56px;
      font-size: 16px;
      font-weight: 600;
      border-radius: 12px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border: none;
      box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);
      transition: all 0.3s ease;

      i {
        margin-right: 8px;
        font-size: 18px;
      }

      &:hover {
        transform: translateY(-2px);
        box-shadow: 0 12px 32px rgba(102, 126, 234, 0.5);
      }
    }
  }

  // 学习记录卡片
  .records-card {
    background: #fff;
    border-radius: 20px;
    padding: 32px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);

    .card-header {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 24px;

      .card-icon {
        font-size: 24px;
      }

      h3 {
        font-size: 20px;
        font-weight: 600;
        color: #1f2937;
        margin: 0;
      }
    }

    .record-list {
      display: flex;
      flex-direction: column;
      gap: 16px;

      .record-item {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 16px;
        background: #f9fafb;
        border-radius: 12px;
        transition: all 0.3s ease;

        &:hover {
          background: #f3f4f6;
          transform: translateX(4px);
        }

        .record-icon-wrapper {
          width: 48px;
          height: 48px;
          border-radius: 12px;
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;

          i {
            font-size: 22px;
            color: #fff;
          }

          &.blue {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
          }

          &.green {
            background: linear-gradient(135deg, #10b981, #059669);
          }

          &.purple {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
          }

          &.orange {
            background: linear-gradient(135deg, #f59e0b, #d97706);
          }
        }

        .record-content {
          flex: 1;

          .record-label {
            font-size: 13px;
            color: #6b7280;
            margin-bottom: 4px;
          }

          .record-value {
            font-size: 16px;
            font-weight: 600;
            color: #1f2937;
          }
        }
      }
    }
  }

  // 学习统计卡片
  .stats-card {
    background: #fff;
    border-radius: 20px;
    padding: 32px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);

    .card-header {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 24px;

      .card-icon {
        font-size: 24px;
      }

      h3 {
        font-size: 20px;
        font-weight: 600;
        color: #1f2937;
        margin: 0;
      }
    }

    .stats-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;

      .stat-box {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 16px;
        background: #f9fafb;
        border-radius: 12px;
        transition: all 0.3s ease;

        &:hover {
          background: #f3f4f6;
          transform: scale(1.02);
        }

        .stat-icon {
          font-size: 28px;
        }

        .stat-info {
          flex: 1;

          .stat-label {
            font-size: 12px;
            color: #6b7280;
            margin-bottom: 4px;
          }

          .stat-number {
            font-size: 16px;
            font-weight: 700;
            color: #1f2937;
          }
        }
      }
    }
  }
}
</style>


