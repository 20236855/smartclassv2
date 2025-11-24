<template>
  <div class="app-container my-courses-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2 class="page-title">
        <i class="el-icon-notebook-2"></i>
        我的课程
      </h2>
      <div class="page-subtitle">已选课程列表</div>
    </div>

    <!-- 课程卡片列表 -->
    <div v-loading="loading">
      <el-row :gutter="20" v-if="courseList && courseList.length > 0">
        <el-col
          v-for="course in courseList"
          :key="course.id"
          :xs="24" :sm="12" :md="8" :lg="6"
        >
          <!-- 点击卡片触发跳转 -->
          <el-card shadow="hover" class="course-card" @click.native="handleCourseClick(course)">
            <div class="card-cover">
              <el-image
                :src="course.coverImage || defaultCoverImage"
                fit="cover"
                lazy
                :preview-src-list="course.coverImage ? [course.coverImage] : []"
              >
                <div slot="placeholder" class="image-slot">
                  <i class="el-icon-loading"></i>
                  <span>加载中...</span>
                </div>
                <div slot="error" class="image-slot">
                  <i class="el-icon-picture-outline"></i>
                  <span>暂无封面</span>
                </div>
              </el-image>
            </div>
            <div class="card-info">
              <h3 class="info-title" :title="course.title">{{ course.title }}</h3>
              <div class="info-desc" :title="course.description">
                {{ course.description || '暂无课程简介' }}
              </div>
              <div class="info-teacher">
                讲师: {{ course.teacherName || '未知' }}
              </div>
              <div class="info-meta">
                <span class="meta-item">
                  <i class="el-icon-time"></i> {{ course.term || '未知学期' }}
                </span>
                <span class="meta-item">
                  <i class="el-icon-star-on"></i> {{ course.credit || 0 }} 学分
                </span>
              </div>
            </div>
            <div class="card-actions">
              <el-button type="primary" size="mini" icon="el-icon-video-play">
                进入学习
              </el-button>
              <el-button
                type="danger"
                size="mini"
                icon="el-icon-delete"
                plain
                @click.stop="handleWithdraw(course)"
              >
                退课
              </el-button>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 空状态提示 -->
      <el-empty
        v-if="!loading && (!courseList || courseList.length === 0)"
        description="您还没有已选上的课程"
        :image-size="200"
      >
        <el-button type="primary" @click="goToCourseCenter">去选课</el-button>
      </el-empty>
    </div>
  </div>
</template>

<script>
// 导入需要的API
import { getMyCourses, withdrawCourse } from "@/api/system/student";

export default {
  name: "MyCourses",
  data() {
    return {
      loading: true,
      courseList: [],
      // 默认封面图片（SVG格式）
      defaultCoverImage: 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjIyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZCIgeDE9IjAlIiB5MT0iMCUiIHgyPSIxMDAlIiB5Mj0iMTAwJSI+CiAgICAgIDxzdG9wIG9mZnNldD0iMCUiIHN0eWxlPSJzdG9wLWNvbG9yOiM2NjdlZWE7c3RvcC1vcGFjaXR5OjEiIC8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3R5bGU9InN0b3AtY29sb3I6Izc2NGJhMjtzdG9wLW9wYWNpdHk6MSIgLz4KICAgIDwvbGluZWFyR3JhZGllbnQ+CiAgPC9kZWZzPgogIDxyZWN0IHdpZHRoPSI0MDAiIGhlaWdodD0iMjI1IiBmaWxsPSJ1cmwoI2dyYWQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIyNCIgZmlsbD0id2hpdGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj7or77nqIvlsIHpnaI8L3RleHQ+Cjwvc3ZnPg=='
    };
  },
  created() {
    this.loadMyCourses();
  },
  methods: {
    /** 加载我的课程列表 */
    loadMyCourses() {
      this.loading = true;
      getMyCourses().then(response => {
        console.log("我的课程API返回的原始数据:", response.data);
        // 处理课程封面图片URL
        this.courseList = response.data.map(course => {
          const processedImage = this.processImageUrl(course.coverImage);
          console.log(`课程 "${course.title}" 封面图片:`, {
            原始路径: course.coverImage,
            处理后路径: processedImage
          });
          return {
            ...course,
            coverImage: processedImage
          };
        });
      }).finally(() => {
        this.loading = false;
      });
    },

    // 处理图片URL的方法（与课程中心保持一致）
    processImageUrl(coverImage) {
      if (!coverImage) {
        console.log('封面图片为空');
        return '';
      }

      // 如果已经是完整的URL，直接返回
      if (coverImage.startsWith('http://') || coverImage.startsWith('https://')) {
        console.log('封面图片是完整URL:', coverImage);
        return coverImage;
      }

      // 使用 VUE_APP_BASE_API 前缀（/dev-api）
      const finalUrl = process.env.VUE_APP_BASE_API + coverImage;
      console.log('封面图片处理:', {
        原始路径: coverImage,
        最终路径: finalUrl,
        BASE_API: process.env.VUE_APP_BASE_API
      });
      return finalUrl;
    },

    /**
     * 处理卡片点击事件，跳转到章节页面
     * @param {object} course 被点击的课程对象
     */
    handleCourseClick(course) {
      // 跳转到课程章节页面
      this.$router.push({ path: '/course/chapter/' + course.id });
    },

    /**
     * 跳转到课程中心
     */
    goToCourseCenter() {
      // ⭐ 修正路由路径：根据菜单配置 (menu_id=2006, path='course', parent='系统管理')
      // 完整路径是 /system/course
      this.$router.push({ path: '/system/course' });
    },

    /**
     * 处理退课操作
     * @param {object} course 要退课的课程对象
     */
    handleWithdraw(course) {
      this.$modal.confirm(`确认要退出《${course.title}》这门课程吗？退课后将无法继续学习该课程。`).then(() => {
        return withdrawCourse(course.id);
      }).then(() => {
        this.$modal.msgSuccess("退课成功");
        // 重新加载课程列表
        this.loadMyCourses();
      }).catch(() => {
        // 用户取消或退课失败
      });
    }
  }
};
</script>

<style lang="scss" scoped>
/* 页面容器 - 与课程中心保持一致 */
.my-courses-page {
  padding: 20px;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: calc(100vh - 84px);
}

/* 页面头部 */
.page-header {
  margin-bottom: 24px;
  padding: 20px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.page-title {
  font-size: 28px;
  font-weight: 600;
  margin: 0 0 8px 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  display: flex;
  align-items: center;
  gap: 12px;

  i {
    font-size: 32px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    -webkit-background-clip: text;
    background-clip: text;
    -webkit-text-fill-color: transparent;
  }
}

.page-subtitle {
  font-size: 14px;
  color: #909399;
  margin-left: 44px;
}

/* 课程卡片 - 与课程中心保持一致 */
.course-card {
  margin-bottom: 20px;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);

  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
  }
}

::v-deep .el-card__body {
  padding: 0;
}

/* 卡片封面 */
.card-cover {
  width: 100%;
  padding-top: 56.25%;
  position: relative;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  overflow: hidden;

  &::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(180deg, transparent 0%, rgba(0,0,0,0.3) 100%);
    opacity: 0;
    transition: opacity 0.3s ease;
  }

  &:hover::after {
    opacity: 1;
  }
}

.card-cover .el-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;

  ::v-deep img {
    transition: transform 0.3s ease;
  }

  &:hover ::v-deep img {
    transform: scale(1.05);
  }
}

.card-cover .image-slot {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
  color: #909399;
  font-size: 14px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

  i {
    font-size: 48px;
    margin-bottom: 10px;
    color: rgba(255, 255, 255, 0.8);
  }

  span {
    color: rgba(255, 255, 255, 0.9);
    font-size: 14px;
  }
}

/* 卡片信息 */
.card-info {
  padding: 16px;
  background: #fff;
}

.info-title {
  margin: 0 0 12px 0;
  font-size: 17px;
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  color: #303133;
  line-height: 1.4;
  transition: color 0.3s ease;

  &:hover {
    color: #409eff;
  }
}

.info-desc {
  font-size: 13px;
  color: #606266;
  height: 38px;
  line-height: 1.5;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  margin: 0 0 12px 0;
}

.info-teacher {
  font-size: 13px;
  color: #606266;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 6px;

  &::before {
    content: '👨‍🏫';
    font-size: 16px;
  }
}

.info-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: #909399;
  padding: 8px 0 0 0;
  border-top: 1px solid #f0f2f5;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 4px;

  i {
    color: #409eff;
  }
}

/* 卡片操作按钮 */
.card-actions {
  padding: 12px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
  border-top: 1px solid #f0f2f5;
  background: #fafafa;

  .el-button {
    border-radius: 20px;
    padding: 8px 16px;
    font-weight: 500;
    transition: all 0.3s ease;
    flex: 1;

    &:hover {
      transform: translateY(-2px);
    }

    &.el-button--primary:hover {
      box-shadow: 0 4px 12px rgba(64, 158, 255, 0.4);
    }

    &.el-button--danger:hover {
      box-shadow: 0 4px 12px rgba(245, 108, 108, 0.4);
    }
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .my-courses-page {
    padding: 10px;
  }

  .page-title {
    font-size: 22px;

    i {
      font-size: 24px;
    }
  }
}
</style>
