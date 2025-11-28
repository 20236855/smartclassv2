<template>
  <div class="app-container course-center-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2 class="page-title">
        <i class="el-icon-reading"></i>
        课程中心
      </h2>
      <div class="page-subtitle">浏览所有课程并申请选课</div>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="filter-section">
      <el-form :model="queryParams" ref="queryForm" :inline="true" label-width="80px">
        <el-form-item label="课程名称" prop="title">
          <el-input
            v-model="queryParams.title"
            placeholder="请输入课程名称"
            clearable
            style="width: 200px"
            @keyup.enter.native="handleQuery"
          />
        </el-form-item>
        <el-form-item label="课程类型" prop="courseType">
          <el-select v-model="queryParams.courseType" placeholder="请选择课程类型" clearable style="width: 150px">
            <el-option
              v-for="dict in dict.type.course_type"
              :key="dict.value"
              :label="dict.label"
              :value="dict.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

    </div>

    <!-- 课程卡片列表 -->
    <div v-loading="loading">
      <el-row :gutter="20" v-if="courseList && courseList.length > 0">
        <el-col
          v-for="course in courseList"
          :key="course.id"
          :xs="24" :sm="12" :md="8" :lg="6"
        >
          <el-card shadow="hover" class="course-card">
            <!-- 课程封面 -->
            <div class="card-cover" @click="showCourseDetail(course)">
              <el-image
                :src="course.coverImage || defaultCoverImage"
                fit="cover"
                lazy
              >
                <div slot="placeholder" class="image-slot">
                  <i class="el-icon-loading"></i>
                  <span>加载中...</span>
                </div>
                <div slot="error" class="image-slot">
                  <i class="el-icon-reading"></i>
                  <span>{{ course.title }}</span>
                </div>
              </el-image>
              <!-- 课程类型标签 -->
              <div class="course-type-badge" :class="getCourseTypeBadgeClass(course.courseType)">
                <dict-tag :options="dict.type.course_type" :value="course.courseType"/>
              </div>
              <!-- 已选标识 -->
              <div class="enrolled-badge" v-if="isCourseEnrolled(course.id)">
                <i class="el-icon-check"></i> 已选
              </div>
            </div>

            <!-- 课程信息 -->
            <div class="card-info">
              <h3 class="info-title" :title="course.title">{{ course.title }}</h3>
              <div class="info-desc" :title="course.description">
                {{ course.description || '暂无课程简介' }}
              </div>
              <div class="info-teacher" v-if="course.teacherName">
                <i class="el-icon-user"></i> 讲师: {{ course.teacherName }}
              </div>
              <div class="info-meta">
                <span class="meta-item" v-if="course.term">
                  <i class="el-icon-time"></i> {{ course.term }}
                </span>
                <span class="meta-item">
                  <i class="el-icon-star-on"></i> {{ course.credit || 0 }} 学分
                </span>
                <span class="meta-item" v-if="course.studentCount">
                  <i class="el-icon-user"></i> {{ course.studentCount }} 人
                </span>
              </div>
            </div>

            <!-- 操作按钮 -->
            <div class="card-actions">
              <!-- 已选课程显示"课程已选"按钮 -->
              <el-button
                v-if="isCourseEnrolled(course.id)"
                type="success"
                size="small"
                icon="el-icon-check"
                disabled
              >
                课程已选
              </el-button>
              <!-- 未选课程显示"申请选课"按钮 -->
              <el-button
                v-else
                type="primary"
                size="small"
                :icon="getCourseButtonIcon(course)"
                :loading="applyLoadingId === course.id"
                @click="handleCourseAction(course)"
              >
                {{ getCourseButtonText(course) }}
              </el-button>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 空状态 -->
      <el-empty
        v-if="!loading && (!courseList || courseList.length === 0)"
        description="暂无课程"
      />

    </div>

    <!-- 分页 -->
    <div class="pagination-container" v-if="total > 0">
      <el-pagination
        background
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="queryParams.pageNum"
        :page-sizes="[12, 24, 36, 48]"
        :page-size="queryParams.pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
      />
    </div>

    <!-- 课程详情抽屉 -->
    <el-drawer
      :title="selectedCourse ? selectedCourse.title : '课程详情'"
      :visible.sync="drawerVisible"
      direction="rtl"
      size="50%"
    >
      <div class="drawer-content" v-if="selectedCourse">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="课程名称" :span="2">{{ selectedCourse.title }}</el-descriptions-item>
          <el-descriptions-item label="课程类型">
            <dict-tag :options="dict.type.course_type" :value="selectedCourse.courseType"/>
          </el-descriptions-item>
          <el-descriptions-item label="学分">{{ selectedCourse.credit || 0 }}</el-descriptions-item>
          <el-descriptions-item label="学期">{{ selectedCourse.term || '未知' }}</el-descriptions-item>
          <el-descriptions-item label="讲师">{{ selectedCourse.teacherName || '未知' }}</el-descriptions-item>
          <el-descriptions-item label="开始时间">{{ selectedCourse.startTime || '未设置' }}</el-descriptions-item>
          <el-descriptions-item label="结束时间">{{ selectedCourse.endTime || '未设置' }}</el-descriptions-item>
          <el-descriptions-item label="课程描述" :span="2">
            {{ selectedCourse.description || '暂无描述' }}
          </el-descriptions-item>
        </el-descriptions>

        <div class="drawer-actions">
          <el-button
            type="primary"
            :icon="getCourseButtonIcon(selectedCourse)"
            :loading="applyLoadingId === selectedCourse.id"
            @click="handleCourseAction(selectedCourse)"
          >
            {{ getCourseButtonText(selectedCourse) }}
          </el-button>
        </div>
      </div>
    </el-drawer>

    <!-- 添加或修改课程对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="1200px" append-to-body>
      <el-tabs v-model="activeTab" v-if="title.includes('知识图谱')">
        <el-tab-pane label="课程信息" name="basic">
          <el-descriptions :column="2" border>
            <el-descriptions-item label="课程名称">{{ form.title }}</el-descriptions-item>
            <el-descriptions-item label="课程编码">{{ form.courseCode }}</el-descriptions-item>
            <el-descriptions-item label="学分">{{ form.credits }}</el-descriptions-item>
            <el-descriptions-item label="学时">{{ form.hours }}</el-descriptions-item>
            <el-descriptions-item label="课程类型">
              <dict-tag :options="dict.type.course_type" :value="form.courseType"/>
            </el-descriptions-item>
            <el-descriptions-item label="开课学期">{{ form.semester }}</el-descriptions-item>
            <el-descriptions-item label="先修课程" :span="2">{{ form.prerequisites || '无' }}</el-descriptions-item>
            <el-descriptions-item label="课程描述" :span="2">{{ form.description }}</el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>
        <el-tab-pane label="知识图谱" name="graph">
          <knowledge-graph-view :course-id="form.id" v-if="form.id"></knowledge-graph-view>
        </el-tab-pane>
      </el-tabs>
      <el-form v-else ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="课程名称" prop="title">
          <el-input v-model="form.title" placeholder="请输入课程名称" />
        </el-form-item>
        <el-form-item label="课程编码" prop="courseCode">
          <el-input v-model="form.courseCode" placeholder="请输入课程编码" />
        </el-form-item>
        <el-form-item label="学分" prop="credits">
          <el-input-number v-model="form.credits" :min="0" :max="10" />
        </el-form-item>
        <el-form-item label="学时" prop="hours">
          <el-input-number v-model="form.hours" :min="0" :max="200" />
        </el-form-item>
        <el-form-item label="课程类型" prop="courseType">
          <el-select v-model="form.courseType" placeholder="请选择课程类型">
            <el-option
              v-for="dict in dict.type.course_type"
              :key="dict.value"
              :label="dict.label"
              :value="dict.value"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="开课学期" prop="semester">
          <el-input v-model="form.semester" placeholder="请输入开课学期" />
        </el-form-item>
        <el-form-item label="先修课程" prop="prerequisites">
          <el-input v-model="form.prerequisites" placeholder="请输入先修课程" />
        </el-form-item>
        <el-form-item label="课程描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入课程描述" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer" v-if="!title.includes('知识图谱')">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
      <div slot="footer" class="dialog-footer" v-else>
        <el-button @click="cancel">关 闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listCourse, getCourse, addCourse, updateCourse, delCourse, joinCourse } from "@/api/system/course";
// 确认 applyRequest 是从 request.js 中导入的
import { applyRequest } from "@/api/system/request";
import { getMyCourses } from "@/api/system/student";
import KnowledgeGraphView from './components/KnowledgeGraphView.vue';

export default {
  name: "Course",
  dicts: ['course_type'],
  components: {
    KnowledgeGraphView
  },
  data() {
    return {
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 课程表格数据
      courseList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 活动标签页
      activeTab: 'basic',
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 12,  // 卡片布局使用12个一页
        title: null,
        courseCode: null,
        courseType: null,
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        title: [
          { required: true, message: "课程名称不能为空", trigger: "blur" }
        ],
        courseCode: [
          { required: true, message: "课程编码不能为空", trigger: "blur" }
        ],
        credits: [
          { required: true, message: "学分不能为空", trigger: "blur" }
        ],
        hours: [
          { required: true, message: "学时不能为空", trigger: "blur" }
        ],
        courseType: [
          { required: true, message: "课程类型不能为空", trigger: "change" }
        ],
        semester: [
          { required: true, message: "开课学期不能为空", trigger: "blur" }
        ]
      },
      // 默认封面图片
      defaultCoverImage: require('@/assets/images/profile.jpg'),
      // 选中的课程（用于详情抽屉）
      selectedCourse: null,
      // 抽屉是否可见
      drawerVisible: false,
      // 申请选课加载状态
      applyLoadingId: null,
      // 已选课程ID列表
      enrolledCourseIds: []
    };
  },
  created() {
    this.getList();
    this.loadEnrolledCourses();
  },
  methods: {
    /** 查询课程列表 */
    getList() {
      this.loading = true;
      listCourse(this.queryParams).then(response => {
        // 处理课程封面图片URL
        this.courseList = response.rows.map(course => {
          return {
            ...course,
            coverImage: this.processImageUrl(course.coverImage)
          };
        });
        this.total = response.total;
        this.loading = false;
      });
    },
    /** 处理图片URL */
    processImageUrl(coverImage) {
      if (!coverImage) {
        return '';
      }
      // 如果已经是完整的URL，直接返回
      if (coverImage.startsWith('http://') || coverImage.startsWith('https://')) {
        return coverImage;
      }
      // 使用 VUE_APP_BASE_API 前缀（/dev-api）
      return process.env.VUE_APP_BASE_API + coverImage;
    },
    /** 加载已选课程列表 */
    loadEnrolledCourses() {
      getMyCourses().then(response => {
        // 提取已选课程的ID列表
        this.enrolledCourseIds = response.data.map(course => course.id);
        console.log('已选课程ID列表:', this.enrolledCourseIds);
      }).catch(error => {
        console.error('加载已选课程失败:', error);
      });
    },
    /** 判断课程是否已选 */
    isCourseEnrolled(courseId) {
      return this.enrolledCourseIds.includes(courseId);
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        id: null,
        title: null,
        courseCode: null,
        credits: null,
        hours: null,
        courseType: null,
        semester: null,
        prerequisites: null,
        description: null
      };
      this.activeTab = 'basic';
      this.resetForm("form");
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
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
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加课程";
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
        // 重新加载已选课程列表
        this.loadEnrolledCourses();
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
        // 重新加载已选课程列表
        this.loadEnrolledCourses();
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
    },
    /** 获取课程类型徽章样式 */
    getCourseTypeBadgeClass(courseType) {
      // 根据课程类型返回不同的样式类
      return courseType === '必修课' ? 'required' : 'elective';
    },
    /** 分页大小改变 */
    handleSizeChange(val) {
      this.queryParams.pageSize = val;
      this.getList();
    },
    /** 当前页改变 */
    handleCurrentChange(val) {
      this.queryParams.pageNum = val;
      this.getList();
    },
    /** 检查权限 */
    hasPermi(permissions) {
      return this.$store.getters.permissions.some(permission => {
        return permissions.includes(permission);
      });
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const id = row.id || this.ids;
      getCourse(id).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改课程";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateCourse(this.form).then(response => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            addCourse(this.form).then(response => {
              this.$modal.msgSuccess("新增成功");
              this.open = false;
              this.getList();
            });
          }
        }
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids;
      this.$modal.confirm('是否确认删除课程编号为"' + ids + '"的数据项？').then(function() {
        return delCourse(ids);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('system/course/export', {
        ...this.queryParams
      }, `course_${new Date().getTime()}.xlsx`);
    },
    /** 知识图谱按钮操作 */
    handleKnowledgeGraph(row) {
      this.reset();
      const id = row.id || this.ids;
      getCourse(id).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "课程知识图谱 - " + this.form.title;
        this.activeTab = 'graph';
      });
    }
  }
};
</script>

<style lang="scss" scoped>
/* 页面容器 */
.course-center-page {
  padding: 20px;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: calc(100vh - 84px);
}

/* 页面标题 */
.page-header {
  text-align: center;
  margin-bottom: 30px;
  padding: 30px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.page-title {
  font-size: 32px;
  color: #2c3e50;
  margin: 0 0 10px 0;
  font-weight: 600;
}

.page-title i {
  color: #409EFF;
  margin-right: 10px;
}

.page-subtitle {
  font-size: 16px;
  color: #7c8a9d;
  margin: 0;
}

/* 筛选区域 */
.filter-section {
  background: white;
  padding: 20px;
  border-radius: 12px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.admin-actions {
  display: flex;
  gap: 10px;
}

/* 课程卡片 */
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

/* 课程类型徽章 */
.course-type-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  z-index: 1;
}

.course-type-badge.required {
  background: rgba(245, 108, 108, 0.9);
  color: white;
}

.course-type-badge.elective {
  background: rgba(103, 194, 58, 0.9);
  color: white;
}

/* 已选标识 */
.enrolled-badge {
  position: absolute;
  top: 10px;
  left: 10px;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  background: rgba(64, 158, 255, 0.95);
  color: white;
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 4px;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.3);

  i {
    font-size: 14px;
  }
}

/* 卡片信息 */
.card-info {
  padding: 16px;
  background: #fff;
}

.info-title {
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0 0 10px 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.info-desc {
  font-size: 13px;
  color: #7c8a9d;
  margin-bottom: 12px;
  height: 40px;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.info-teacher {
  font-size: 13px;
  color: #606266;
  margin-bottom: 8px;

  i {
    color: #409EFF;
    margin-right: 4px;
  }
}

.info-meta {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #909399;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;
}

.meta-item {
  display: flex;
  align-items: center;

  i {
    margin-right: 4px;
    color: #409EFF;
  }
}

/* 卡片操作按钮 */
.card-actions {
  padding: 12px 16px;
  background: #f8f9fa;
  display: flex;
  gap: 8px;
  justify-content: space-between;

  .el-button {
    flex: 1;
  }
}

/* 分页容器 */
.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 30px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

/* 抽屉内容 */
.drawer-content {
  padding: 20px;
}

.drawer-actions {
  margin-top: 20px;
  text-align: center;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-title {
    font-size: 24px;
  }

  .filter-section {
    flex-direction: column;
  }

  .admin-actions {
    margin-top: 10px;
    width: 100%;
  }
}
</style>
