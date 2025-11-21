<template>
  <div class="course-center-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <i class="el-icon-reading"></i>
          课程中心
        </h1>
        <p class="page-subtitle">探索精彩课程，开启学习之旅</p>
      </div>
    </div>

    <!-- 课程轮播大屏 -->
    <div class="carousel-section" v-if="featuredCourses.length > 0">
      <el-carousel :interval="5000" height="400px" arrow="always" indicator-position="outside">
        <el-carousel-item v-for="course in featuredCourses" :key="course.id">
          <div class="carousel-item-wrapper" @click="showCourseDetail(course)">
            <div class="carousel-image">
              <el-image
                :src="course.coverImage || defaultCoverImage"
                fit="cover"
                style="width: 100%; height: 100%;"
              >
                <div slot="error" class="image-error">
                  <div class="gradient-bg"></div>
                  <i class="el-icon-picture-outline"></i>
                </div>
              </el-image>
              <div class="carousel-overlay"></div>
            </div>
            <div class="carousel-info">
              <div class="carousel-badge">
                <i class="el-icon-star-on"></i>
                精选课程
              </div>
              <h2 class="carousel-title">{{ course.title }}</h2>
              <p class="carousel-description">{{ course.description || '暂无简介' }}</p>
              <div class="carousel-meta">
                <span class="meta-item">
                  <i class="el-icon-user"></i>
                  {{ course.teacherName || '暂无讲师' }}
                </span>
                <span class="meta-item">
                  <i class="el-icon-s-custom"></i>
                  {{ course.studentCount || 0 }} 人学习
                </span>
                <span class="meta-item">
                  <i class="el-icon-medal"></i>
                  {{ course.credit }} 学分
                </span>
              </div>
              <el-button
                type="primary"
                size="large"
                class="carousel-btn"
                @click.stop="handleCourseAction(course)"
              >
                {{ getCourseButtonText(course) }}
                <i class="el-icon-right"></i>
              </el-button>
            </div>
          </div>
        </el-carousel-item>
      </el-carousel>
    </div>

    <!-- 搜索筛选区域 -->
    <div class="search-section">
      <div class="search-wrapper">
        <el-input
          v-model="queryParams.title"
          placeholder="🔍 搜索您感兴趣的课程..."
          clearable
          @keyup.enter.native="handleQuery"
          class="search-input"
          size="large"
        >
          <el-button slot="append" icon="el-icon-search" @click="handleQuery"></el-button>
        </el-input>
        <el-select
          v-model="queryParams.courseType"
          placeholder="课程类型"
          clearable
          class="filter-select"
          size="large"
          @change="handleQuery"
        >
          <el-option
            v-for="dict in dict.type.course_type"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
        <el-button
          icon="el-icon-refresh"
          size="large"
          class="reset-btn"
          @click="resetQuery"
        >
          重置
        </el-button>
      </div>
    </div>

    <!-- 课程列表标题 -->
    <div class="list-header">
      <h3 class="list-title">
        <span class="title-icon">📚</span>
        全部课程
        <span class="course-count">（{{ total }} 门）</span>
      </h3>
    </div>

    <!-- 课程卡片列表 -->
    <div class="course-list-section" v-loading="loading">
      <div class="course-grid" v-if="courseList && courseList.length > 0">
        <div
          v-for="course in courseList"
          :key="course.id"
          class="course-card"
          @click="showCourseDetail(course)"
        >
          <div class="card-image-wrapper">
            <el-image
              :src="course.coverImage || defaultCoverImage"
              fit="cover"
              class="card-image"
              lazy
            >
              <div slot="placeholder" class="image-loading">
                <i class="el-icon-loading"></i>
              </div>
              <div slot="error" class="image-error-small">
                <div class="gradient-bg-small"></div>
                <i class="el-icon-picture-outline"></i>
              </div>
            </el-image>
            <div class="card-overlay">
              <div class="overlay-content">
                <i class="el-icon-view"></i>
                <span>查看详情</span>
              </div>
            </div>
          </div>
          <div class="card-content">
            <div class="card-header-row">
              <h3 class="card-title" :title="course.title">{{ course.title }}</h3>
              <div class="card-status-badge">
                <dict-tag :options="dict.type.course_status" :value="course.status"/>
              </div>
            </div>
            <div class="card-teacher">
              <i class="el-icon-user-solid"></i>
              {{ course.teacherName || '暂无讲师' }}
            </div>
            <div class="card-meta">
              <span class="meta-item">
                <i class="el-icon-s-custom"></i>
                {{ course.studentCount || 0 }}
              </span>
              <span class="meta-item">
                <i class="el-icon-medal"></i>
                {{ course.credit }} 学分
              </span>
            </div>
            <el-button
              :type="getCourseButtonType(course)"
              size="small"
              class="card-action-btn"
              :loading="applyLoadingId === course.id"
              @click.stop="handleCourseAction(course)"
            >
              <i :class="getCourseButtonIcon(course)"></i>
              {{ getCourseButtonText(course) }}
            </el-button>
          </div>
        </div>
      </div>
      <div v-if="!loading && (!courseList || courseList.length === 0)" class="empty-state">
        <i class="el-icon-folder-opened"></i>
        <p>暂未开放任何课程</p>
      </div>
    </div>

    <!-- 3. 分页组件 -->
    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <!-- 课程详情抽屉 -->
    <el-drawer
      :title="selectedCourse.title"
      :visible.sync="drawerVisible"
      direction="rtl"
      size="45%"
      class="course-detail-drawer"
    >
      <div class="drawer-content" v-if="selectedCourse.id">
        <!-- 教师信息卡片 -->
        <div class="teacher-card">
          <div class="teacher-info">
            <div class="name">👨‍🏫 {{ selectedCourse.teacherName || '暂无讲师' }}</div>
            <div class="title">授课教师</div>
          </div>
        </div>

        <!-- 课程详情 -->
        <div class="detail-section">
          <h4>课程简介</h4>
          <p class="description">{{ selectedCourse.description || '这门课很神秘，还没有简介哦~' }}</p>
        </div>

        <div class="detail-section">
          <h4>课程信息</h4>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="课程状态">
              <dict-tag :options="dict.type.course_status" :value="selectedCourse.status"/>
            </el-descriptions-item>
            <el-descriptions-item label="课程类型">
              <dict-tag :options="dict.type.course_type" :value="selectedCourse.courseType"/>
            </el-descriptions-item>
            <el-descriptions-item label="学分">{{ selectedCourse.credit }}</el-descriptions-item>
            <el-descriptions-item label="开课学期">{{ selectedCourse.term }}</el-descriptions-item>
          </el-descriptions>
        </div>
      </div>
      <!-- 抽屉底部操作栏 -->
      <div class="drawer-footer">
        <el-button @click="drawerVisible = false">关闭</el-button>
        <el-button
          :type="getCourseButtonType(selectedCourse)"
          :loading="applyLoadingId === selectedCourse.id"
          @click="handleCourseAction(selectedCourse)"
        >
          {{ getCourseButtonText(selectedCourse) }}
        </el-button>
      </div>
    </el-drawer>
  </div>
</template>

<script>
import { listCourse, joinCourse } from "@/api/system/course";
// 确认 applyRequest 是从 request.js 中导入的
import { applyRequest } from "@/api/system/request";

export default {
  name: "CourseCenter",
  dicts: ['course_type', 'course_status'],
  data() {
    return {
      loading: true,
      showSearch: true,
      total: 0,
      courseList: [],
      featuredCourses: [], // 精选课程（用于轮播）
      applyLoadingId: null,
      queryParams: {
        pageNum: 1,
        pageSize: 12,
        title: null,
        courseType: null,
        status: null,
      },
      drawerVisible: false,
      selectedCourse: {},
      // 默认封面图片 - 使用一个优雅的渐变色作为占位符
      defaultCoverImage: 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjIyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZCIgeDE9IjAlIiB5MT0iMCUiIHgyPSIxMDAlIiB5Mj0iMTAwJSI+CiAgICAgIDxzdG9wIG9mZnNldD0iMCUiIHN0eWxlPSJzdG9wLWNvbG9yOiM2NjdlZWE7c3RvcC1vcGFjaXR5OjEiIC8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3R5bGU9InN0b3AtY29sb3I6Izc2NGJhMjtzdG9wLW9wYWNpdHk6MSIgLz4KICAgIDwvbGluZWFyR3JhZGllbnQ+CiAgPC9kZWZzPgogIDxyZWN0IHdpZHRoPSI0MDAiIGhlaWdodD0iMjI1IiBmaWxsPSJ1cmwoI2dyYWQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIyNCIgZmlsbD0id2hpdGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj7or77nqIvlsIHpnaI8L3RleHQ+Cjwvc3ZnPg=='
    };
  },
  created() {
    this.getList();
  },
  methods: {
    getList() {
      this.loading = true;
      listCourse(this.queryParams).then(response => {
        console.log("课程列表API返回的原始数据:", response.rows);
        // 处理课程封面图片URL
        this.courseList = response.rows.map(course => {
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
        this.total = response.total;

        // 提取前3个课程作为精选课程（用于轮播）
        // 只在第一页且没有搜索条件时显示轮播
        if (this.queryParams.pageNum === 1 && !this.queryParams.title && !this.queryParams.courseType) {
          this.featuredCourses = this.courseList.slice(0, Math.min(3, this.courseList.length));
        } else {
          this.featuredCourses = [];
        }

        this.loading = false;
      });
    },

    // 处理图片URL的方法
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

      // 关键修复：使用 VUE_APP_BASE_API 前缀（/dev-api）
      // 这样会通过 vue.config.js 中的代理转发到后端
      const finalUrl = process.env.VUE_APP_BASE_API + coverImage;
      console.log('封面图片处理:', {
        原始路径: coverImage,
        最终路径: finalUrl,
        BASE_API: process.env.VUE_APP_BASE_API
      });
      return finalUrl;
    },
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    /** 判断课程是否已结束 */
    isCourseEnded(course) {
      if (!course.endTime) return false;
      const now = new Date();
      const endTime = new Date(course.endTime);
      return endTime < now;
    },

    /** 获取课程按钮类型 */
    getCourseButtonType(course) {
      return this.isCourseEnded(course) ? 'success' : 'primary';
    },

    /** 获取课程按钮图标 */
    getCourseButtonIcon(course) {
      return this.isCourseEnded(course) ? 'el-icon-check' : 'el-icon-plus';
    },

    /** 获取课程按钮文本 */
    getCourseButtonText(course) {
      return this.isCourseEnded(course) ? '直接加入' : '申请选课';
    },

    /** 智能课程操作 */
    handleCourseAction(course) {
      if (!course || !course.id) return;

      if (this.isCourseEnded(course)) {
        // 课程已结束，直接加入
        this.handleDirectJoin(course);
      } else {
        // 课程未结束，申请选课
        this.handleApply(course);
      }
    },

    /** 直接加入课程（已结束课程） */
    handleDirectJoin(course) {
      this.$modal.confirm(`课程《${course.title}》已结束，确认要直接加入我的课程吗？`).then(() => {
        this.applyLoadingId = course.id;
        return joinCourse(course.id);
      }).then(() => {
        this.$modal.msgSuccess("课程已直接加入您的课程列表");
        if(this.drawerVisible) {
          this.drawerVisible = false;
        }
      }).catch(() => {
        // 用户点击取消，不做任何事
      }).finally(() => {
        this.applyLoadingId = null;
      });
    },

    /** 申请选课（未结束课程） */
    handleApply(course) {
      if (!course || !course.id) return;
      this.$modal.confirm(`确认要申请选修《${course.title}》这门课程吗？`).then(() => {
        this.applyLoadingId = course.id;
        //【关键修改】: 第一个参数是ID，第二个是请求体
        return applyRequest(course.id, {});
      }).then(() => {
        this.$modal.msgSuccess("选课申请已提交，请等待审核");
        if(this.drawerVisible) {
          this.drawerVisible = false;
        }
      }).catch(() => {
        // 用户点击取消，不做任何事
      }).finally(() => {
        this.applyLoadingId = null;
      });
    },
    /** 显示课程详情抽屉 */
    showCourseDetail(course) {
      this.selectedCourse = course;
      this.drawerVisible = true;
    }
  }
};
</script>

<style lang="scss" scoped>
.course-center-page {
  background: #f5f7fa;
  min-height: 100vh;
  padding-bottom: 40px;
}

// 页面头部
.page-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 60px 40px 40px;
  color: #fff;
  text-align: center;

  .header-content {
    max-width: 1200px;
    margin: 0 auto;
  }

  .page-title {
    font-size: 42px;
    font-weight: 700;
    margin: 0 0 16px 0;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 16px;

    i {
      font-size: 48px;
    }
  }

  .page-subtitle {
    font-size: 18px;
    opacity: 0.95;
    margin: 0;
  }
}

// 轮播区域
.carousel-section {
  max-width: 1200px;
  margin: -60px auto 40px;
  padding: 0 20px;

  ::v-deep .el-carousel {
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  }

  ::v-deep .el-carousel__container {
    height: 400px;
  }

  ::v-deep .el-carousel__arrow {
    background: rgba(255, 255, 255, 0.3);
    backdrop-filter: blur(10px);
    width: 50px;
    height: 50px;
    font-size: 20px;

    &:hover {
      background: rgba(255, 255, 255, 0.5);
    }
  }

  ::v-deep .el-carousel__indicators {
    .el-carousel__button {
      width: 12px;
      height: 12px;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.5);
    }

    .is-active .el-carousel__button {
      background: #fff;
      width: 30px;
      border-radius: 6px;
    }
  }
}

.carousel-item-wrapper {
  position: relative;
  width: 100%;
  height: 100%;
  cursor: pointer;
  overflow: hidden;
}

.carousel-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;

  .image-error {
    width: 100%;
    height: 100%;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;

    .gradient-bg {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }

    i {
      font-size: 80px;
      color: rgba(255, 255, 255, 0.6);
      position: relative;
      z-index: 1;
    }
  }
}

.carousel-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(
    to right,
    rgba(0, 0, 0, 0.7) 0%,
    rgba(0, 0, 0, 0.3) 50%,
    transparent 100%
  );
}

.carousel-info {
  position: absolute;
  top: 50%;
  left: 60px;
  transform: translateY(-50%);
  max-width: 500px;
  color: #fff;
  z-index: 2;

  .carousel-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: rgba(255, 215, 0, 0.9);
    color: #333;
    padding: 6px 16px;
    border-radius: 20px;
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 20px;

    i {
      font-size: 16px;
    }
  }

  .carousel-title {
    font-size: 36px;
    font-weight: 700;
    margin: 0 0 16px 0;
    line-height: 1.3;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  }

  .carousel-description {
    font-size: 16px;
    line-height: 1.6;
    margin: 0 0 24px 0;
    opacity: 0.95;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .carousel-meta {
    display: flex;
    gap: 24px;
    margin-bottom: 28px;

    .meta-item {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 15px;

      i {
        font-size: 18px;
      }
    }
  }

  .carousel-btn {
    padding: 14px 32px;
    font-size: 16px;
    font-weight: 600;
    border-radius: 30px;
    border: none;
    background: #fff;
    color: #667eea;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
    transition: all 0.3s ease;

    i {
      margin-left: 8px;
    }

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
      background: #f0f0f0;
    }
  }
}

// 搜索区域
.search-section {
  max-width: 1200px;
  margin: 0 auto 40px;
  padding: 0 20px;
}

.search-wrapper {
  display: flex;
  gap: 16px;
  background: #fff;
  padding: 24px;
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);

  .search-input {
    flex: 1;

    ::v-deep .el-input__inner {
      border-radius: 12px;
      border: 2px solid #e5e7eb;
      font-size: 15px;
      padding-left: 16px;

      &:focus {
        border-color: #667eea;
      }
    }

    ::v-deep .el-input-group__append {
      background: #667eea;
      border: none;
      border-radius: 0 12px 12px 0;
      color: #fff;
      cursor: pointer;
      transition: all 0.3s ease;

      &:hover {
        background: #5568d3;
      }

      .el-button {
        color: #fff;
      }
    }
  }

  .filter-select {
    width: 200px;

    ::v-deep .el-input__inner {
      border-radius: 12px;
      border: 2px solid #e5e7eb;

      &:focus {
        border-color: #667eea;
      }
    }
  }

  .reset-btn {
    border-radius: 12px;
    border: 2px solid #e5e7eb;
    background: #fff;
    color: #6b7280;

    &:hover {
      border-color: #667eea;
      color: #667eea;
      background: #f9fafb;
    }
  }
}

// 列表标题
.list-header {
  max-width: 1200px;
  margin: 0 auto 24px;
  padding: 0 20px;

  .list-title {
    font-size: 24px;
    font-weight: 700;
    color: #1f2937;
    margin: 0;
    display: flex;
    align-items: center;
    gap: 12px;

    .title-icon {
      font-size: 28px;
    }

    .course-count {
      font-size: 16px;
      font-weight: 400;
      color: #6b7280;
    }
  }
}

// 课程列表
.course-list-section {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  min-height: 400px;
}

.course-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
}

.course-card {
  background: #fff;
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);

  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 12px 32px rgba(0, 0, 0, 0.15);

    .card-overlay {
      opacity: 1;
    }
  }
}

.card-image-wrapper {
  position: relative;
  width: 100%;
  padding-top: 56.25%;
  overflow: hidden;
  background: #f3f4f6;
}

.card-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;

  ::v-deep img {
    transition: transform 0.3s ease;
  }
}

.course-card:hover .card-image ::v-deep img {
  transform: scale(1.1);
}

.image-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  font-size: 24px;
}

.image-error-small {
  width: 100%;
  height: 100%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;

  .gradient-bg-small {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }

  i {
    font-size: 48px;
    color: rgba(255, 255, 255, 0.6);
    position: relative;
    z-index: 1;
  }
}

.card-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;

  .overlay-content {
    color: #fff;
    font-size: 16px;
    font-weight: 600;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;

    i {
      font-size: 32px;
    }
  }
}

.card-content {
  padding: 20px;
}

.card-header-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 12px;
}

.card-status-badge {
  flex-shrink: 0;
  margin-top: 2px;
}

.card-title {
  flex: 1;
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: auto;
}

.card-teacher {
  font-size: 14px;
  color: #6b7280;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 6px;

  i {
    color: #667eea;
  }
}

.card-meta {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
  padding-top: 12px;
  border-top: 1px solid #f3f4f6;

  .meta-item {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 13px;
    color: #6b7280;

    i {
      color: #667eea;
      font-size: 16px;
    }
  }
}

.card-action-btn {
  width: 100%;
  border-radius: 8px;
  font-weight: 600;
  padding: 10px;
  transition: all 0.3s ease;

  i {
    margin-right: 4px;
  }

  &:hover {
    transform: translateY(-2px);
  }
}

// 空状态
.empty-state {
  text-align: center;
  padding: 80px 20px;
  color: #9ca3af;

  i {
    font-size: 80px;
    margin-bottom: 16px;
    display: block;
  }

  p {
    font-size: 16px;
    margin: 0;
  }
}

// 分页
::v-deep .pagination-container {
  max-width: 1200px;
  margin: 40px auto 0;
  padding: 0 20px;
}

// 抽屉样式
::v-deep .course-detail-drawer {
  .el-drawer__header {
    padding: 24px;
    margin-bottom: 0;
    border-bottom: 1px solid #f0f0f0;
    font-size: 20px;
    font-weight: 600;
    color: #1f2937;
  }

  .el-drawer__body {
    padding: 0;
  }
}

.drawer-content {
  padding: 24px;
  height: calc(100% - 80px);
  overflow-y: auto;
}

.teacher-card {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  margin-bottom: 24px;
  color: #fff;

  .teacher-info {
    text-align: center;

    .name {
      font-size: 20px;
      font-weight: 600;
      margin-bottom: 4px;
    }

    .title {
      font-size: 14px;
      opacity: 0.9;
    }
  }
}

.detail-section {
  margin-bottom: 24px;

  h4 {
    font-size: 16px;
    font-weight: 600;
    color: #1f2937;
    margin: 0 0 16px 0;
    padding-bottom: 8px;
    border-bottom: 2px solid #667eea;
  }

  .description {
    font-size: 14px;
    line-height: 1.8;
    color: #6b7280;
    margin: 0;
  }
}

.drawer-footer {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16px 24px;
  background: #fff;
  border-top: 1px solid #f0f0f0;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}
</style>
