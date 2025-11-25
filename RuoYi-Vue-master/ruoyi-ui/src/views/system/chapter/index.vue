<template>
  <div class="app-container course-detail-page">
    <!-- 1. 课程信息头 -->
    <div class="page-header" v-loading="courseLoading">
      <div class="header-background"></div>
      <div class="header-content" v-if="courseInfo">
        <div class="header-left">
          <el-image class="header-cover" :src="processCoverUrl(courseInfo.coverImage)" fit="cover" lazy>
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
        <div class="header-info">
          <h1 class="info-title">
            <i class="el-icon-reading"></i>
            {{ courseInfo.title }}
          </h1>
          <p class="info-desc">{{ courseInfo.description || '暂无课程简介' }}</p>
          <div class="info-meta">
            <div class="meta-item">
              <i class="el-icon-user"></i>
              <span>{{ courseInfo.teacherName || '未知教师' }}</span>
            </div>
            <div class="meta-item">
              <i class="el-icon-date"></i>
              <span>{{ courseInfo.term || '未知学期' }}</span>
            </div>
            <div class="meta-item" v-if="courseInfo.credit">
              <i class="el-icon-star-on"></i>
              <span>{{ courseInfo.credit }} 学分</span>
            </div>
            <div class="meta-item" v-if="courseInfo.courseType">
              <i class="el-icon-collection-tag"></i>
              <span>{{ formatCourseType(courseInfo.courseType) }}</span>
            </div>
          </div>
        </div>
        <el-button class="back-button" icon="el-icon-arrow-left" @click="goBack" circle></el-button>
      </div>
    </div>

    <!-- 2. Tab切换区域：章节 和 资源 -->
    <div class="content-wrapper">
      <el-card class="tabs-card" shadow="hover">
        <el-tabs v-model="activeTab" @tab-click="handleTabClick" class="custom-tabs">

          <!-- Tab 1: 课程章节 -->
          <el-tab-pane name="chapters">
            <span slot="label">
              <i class="el-icon-menu"></i>
              课程章节
              <el-badge :value="chapterData.length" :max="99" v-if="chapterData.length > 0" class="tab-badge"></el-badge>
            </span>
            <div v-loading="chapterLoading" class="tab-content-wrapper">
              <el-collapse v-model="activeCollapse" accordion v-if="chapterData.length > 0" class="custom-collapse">
                <el-collapse-item v-for="chapter in chapterData" :key="chapter.id" :name="chapter.id">
                  <template slot="title">
                    <div class="chapter-title">
                      <i class="el-icon-folder-opened"></i>
                      <span>{{ chapter.title }}</span>
                      <el-tag size="mini" type="info" v-if="chapter.sections && chapter.sections.length > 0">
                        {{ chapter.sections.length }} 个小节
                      </el-tag>
                    </div>
                  </template>
                  <ul class="section-list" v-if="chapter.sections && chapter.sections.length > 0">
                    <li class="section-item" v-for="(section, index) in chapter.sections" :key="section.id" @click="handleSectionClick(section)">
                      <div class="section-left">
                        <span class="section-number">{{ index + 1 }}</span>
                        <i class="el-icon-video-play section-icon"></i>
                        <span class="section-title">{{ section.title }}</span>
                      </div>
                      <div class="section-right">
                        <span class="section-duration" v-if="section.duration">
                          <i class="el-icon-time"></i>
                          {{ formatDuration(section.duration) }}
                        </span>
                        <i class="el-icon-arrow-right section-arrow"></i>
                      </div>
                    </li>
                  </ul>
                  <el-empty v-else description="该章节下暂无小节" :image-size="80"></el-empty>
                </el-collapse-item>
              </el-collapse>
              <el-empty v-if="!chapterLoading && chapterData.length === 0" description="该课程下暂无章节内容" :image-size="120">
                <el-button type="primary" size="small" @click="goBack">返回课程列表</el-button>
              </el-empty>
            </div>
          </el-tab-pane>

          <!-- Tab 2: 课程资源 -->
          <el-tab-pane name="resources">
            <span slot="label">
              <i class="el-icon-folder"></i>
              课程资源
              <el-badge :value="resourceTotal" :max="99" v-if="resourceTotal > 0" class="tab-badge"></el-badge>
            </span>
            <div v-loading="resourceLoading" class="tab-content-wrapper">
              <el-row :gutter="20" class="resource-list" v-if="resourceData.length > 0">
                <el-col :xs="24" :sm="12" :md="8" v-for="resource in resourceData" :key="resource.id" class="resource-card-col">
                  <el-card shadow="hover" class="resource-card">
                    <div class="card-content">
                      <div class="file-icon" :style="{ color: getFileIcon(resource.fileType).color }">
                        <i :class="getFileIcon(resource.fileType).icon"></i>
                      </div>
                      <div class="file-info">
                        <div class="file-name" :title="resource.name">{{ resource.name }}</div>
                        <div class="file-meta">
                          <span class="file-size">{{ formatFileSize(resource.fileSize) }}</span>
                          <span class="divider">|</span>
                          <span class="file-date">{{ parseTime(resource.createTime, '{y}-{m}-{d}') }}</span>
                        </div>
                      </div>
                    </div>
                    <div class="card-actions">
                      <el-button type="primary" icon="el-icon-download" size="small" @click="handleDownload(resource)" plain>
                        下载
                        <el-badge :value="resource.downloadCount || 0" :max="999" v-if="resource.downloadCount > 0" class="download-badge"></el-badge>
                      </el-button>
                    </div>
                  </el-card>
                </el-col>
              </el-row>
              <el-empty v-if="!resourceLoading && resourceData.length === 0" description="该课程下暂无资源" :image-size="120">
                <el-button type="primary" size="small" @click="activeTab = 'chapters'">查看课程章节</el-button>
              </el-empty>
              <!-- 资源分页 -->
              <pagination
                v-show="resourceTotal > 0"
                :total="resourceTotal"
                :page.sync="resourceParams.pageNum"
                :limit.sync="resourceParams.pageSize"
                @pagination="loadResources"
                class="resource-pagination"
              />
            </div>
          </el-tab-pane>

          <!-- Tab 3: 知识图谱 -->
          <el-tab-pane name="knowledge-graph">
            <span slot="label">
              <i class="el-icon-share"></i>
              知识图谱
            </span>
            <div class="tab-content-wrapper">
              <KnowledgeGraphView :courseId="courseId" v-if="activeTab === 'knowledge-graph'" />
            </div>
          </el-tab-pane>

          <!-- Tab 4: 题目练习 -->
          <el-tab-pane name="practice">
            <span slot="label">
              <i class="el-icon-edit-outline"></i>
              题目练习
            </span>
            <div class="tab-content-wrapper practice-tab-content">
              <!-- 顶部统计栏 -->
              <div class="task-stats-bar">
                <div class="stat-item">
                  <span class="stat-label">总任务</span>
                  <span class="stat-value">{{ taskStats.total }}</span>
                </div>
                <div class="stat-divider"></div>
                <div class="stat-item stat-homework">
                  <span class="stat-label">作业</span>
                  <span class="stat-value">{{ taskStats.homework }}</span>
                </div>
                <div class="stat-divider"></div>
                <div class="stat-item stat-exam">
                  <span class="stat-label">考试</span>
                  <span class="stat-value">{{ taskStats.exam }}</span>
                </div>
                <div class="stat-divider"></div>
                <div class="stat-item stat-completed">
                  <span class="stat-label">已完成</span>
                  <span class="stat-value">{{ taskStats.completed }}</span>
                </div>
              </div>

              <!-- 按章节分组的任务列表 -->
              <div v-loading="taskLoading" class="tasks-container">
                <div v-if="chapterTasks.length > 0" class="chapter-tasks-list">
                  <div
                    v-for="chapter in chapterTasks"
                    :key="chapter.id"
                    class="chapter-section"
                  >
                    <!-- 章节标题 -->
                    <div class="chapter-title-bar">
                      <div class="chapter-title-content">
                        <i class="el-icon-folder-opened"></i>
                        <span>{{ chapter.title }}</span>
                      </div>
                      <span class="task-count">{{ chapter.tasks.length }} 个任务</span>
                    </div>

                    <!-- 任务列表 -->
                    <div class="tasks-grid">
                      <div
                        v-for="task in chapter.tasks"
                        :key="task.id"
                        class="task-item"
                        :class="getTaskStatusClass(task)"
                        @click="startTask(task)"
                      >
                        <!-- 状态指示条 -->
                        <div class="task-status-bar" :class="getTaskStatusClass(task)"></div>

                        <!-- 任务内容 -->
                        <div class="task-content">
                          <!-- 头部：类型和状态 -->
                          <div class="task-header">
                            <span class="task-type" :class="task.type === 'homework' ? 'type-homework' : 'type-exam'">
                              <i :class="task.type === 'homework' ? 'el-icon-edit' : 'el-icon-medal'"></i>
                              {{ task.type === 'homework' ? '作业' : '考试' }}
                            </span>
                            <span class="task-status" :class="'status-' + getTaskStatusClass(task)">
                              {{ getTaskStatusText(task) }}
                            </span>
                          </div>

                          <!-- 标题 -->
                          <h4 class="task-name">{{ task.title }}</h4>

                          <!-- 描述 -->
                          <p class="task-desc" v-if="task.description">{{ task.description }}</p>

                          <!-- 元信息 -->
                          <div class="task-meta">
                            <span class="meta-item" v-if="task.startTime">
                              <i class="el-icon-time"></i>
                              {{ formatTaskDate(task.startTime) }}
                            </span>
                            <span class="meta-item" v-if="task.endTime">
                              <i class="el-icon-alarm-clock"></i>
                              截止 {{ formatTaskDate(task.endTime) }}
                            </span>
                            <span class="meta-item" v-if="task.totalScore">
                              <i class="el-icon-star-on"></i>
                              {{ task.totalScore }}分
                            </span>
                            <span class="meta-item" v-if="task.duration">
                              <i class="el-icon-timer"></i>
                              {{ task.duration }}分钟
                            </span>
                          </div>

                          <!-- 操作按钮 -->
                          <div class="task-footer">
                            <el-button
                              :type="isTaskExpired(task) ? 'info' : 'primary'"
                              size="small"
                              :disabled="isTaskExpired(task)"
                              plain
                            >
                              {{ task.mode === 'question' ? '开始答题' : '提交作业' }}
                              <i class="el-icon-arrow-right"></i>
                            </el-button>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- 无任务提示 -->
                <el-empty
                  v-if="!taskLoading && chapterTasks.length === 0"
                  description="该课程暂无练习任务"
                  :image-size="120"
                >
                  <template slot="image">
                    <i class="el-icon-document-copy" style="font-size: 100px; color: #C0C4CC;"></i>
                  </template>
                </el-empty>
              </div>
            </div>
          </el-tab-pane>

        </el-tabs>
      </el-card>
    </div>
  </div>
</template>

<script>
// 导入所有需要的API
import { getCourse } from "@/api/system/course";
import { listChapter } from "@/api/system/chapter";
import { listSection } from "@/api/system/section";
import { listResource } from "@/api/system/resource";
import { listAssignment, getAssignmentQuestions } from "@/api/system/assignment";
import { getQuestion } from "@/api/system/question";
import axios from 'axios';
import { getToken } from '@/utils/auth';
import KnowledgeGraphView from '@/views/system/course/components/KnowledgeGraphView.vue';

export default {
  name: "CourseDetail",
  components: {
    KnowledgeGraphView
  },
  data() {
    return {
      courseId: null,
      activeTab: 'chapters',
      backendHost: process.env.VUE_APP_BASE_API,

      courseLoading: true,
      courseInfo: null,

      chapterLoading: true,
      chapterData: [],
      activeCollapse: '',

      resourceLoading: false,
      isResourceLoaded: false,
      resourceData: [],
      resourceTotal: 0,
      resourceParams: {
        pageNum: 1,
        pageSize: 9, // 每行3个，显示3行
        courseId: null,
      },

      // 任务相关数据
      taskLoading: false,
      chapterTasks: [],
      activeChapters: [],
      taskStats: {
        total: 0,
        homework: 0,
        exam: 0,
        completed: 0
      }
    };
  },
  created() {
    this.courseId = this.$route.params && this.$route.params.courseId;
    this.resourceParams.courseId = this.courseId;

    if (this.courseId) {
      this.loadCourseInfo();
      this.loadChapterContent();
    } else {
      this.$modal.msgError("无效的课程ID");
      this.courseLoading = this.chapterLoading = false;
    }
  },
  methods: {
    goBack() {
      this.$router.go(-1);
    },
    handleTabClick(tab) {
      if (tab.name === 'resources' && !this.isResourceLoaded) {
        this.loadResources();
      }
      if (tab.name === 'practice' && this.chapterTasks.length === 0) {
        this.loadCourseTasks();
      }
    },
    // 处理封面图片URL
    processCoverUrl(coverImage) {
      if (!coverImage) {
        return this.getDefaultCover();
      }
      // 如果已经是完整URL，直接返回
      if (coverImage.startsWith('http://') || coverImage.startsWith('https://')) {
        return coverImage;
      }
      // 如果是相对路径，添加后端API前缀
      return this.backendHost + coverImage;
    },
    // 获取默认封面
    getDefaultCover() {
      return 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjIyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZCIgeDE9IjAlIiB5MT0iMCUiIHgyPSIxMDAlIiB5Mj0iMTAwJSI+CiAgICAgIDxzdG9wIG9mZnNldD0iMCUiIHN0eWxlPSJzdG9wLWNvbG9yOiM2NjdlZWE7c3RvcC1vcGFjaXR5OjEiIC8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3R5bGU9InN0b3AtY29sb3I6Izc2NGJhMjtzdG9wLW9wYWNpdHk6MSIgLz4KICAgIDwvbGluZWFyR3JhZGllbnQ+CiAgPC9kZWZzPgogIDxyZWN0IHdpZHRoPSI0MDAiIGhlaWdodD0iMjI1IiBmaWxsPSJ1cmwoI2dyYWQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIyNCIgZmlsbD0id2hpdGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj7or77nqIvlsIHpnaI8L3RleHQ+Cjwvc3ZnPg==';
    },
    // 格式化课程类型
    formatCourseType(type) {
      const typeMap = {
        'required': '必修课',
        'elective': '选修课',
        'public': '公共课'
      };
      return typeMap[type] || type;
    },
    async loadCourseInfo() {
      this.courseLoading = true;
      try {
        const response = await getCourse(this.courseId);
        this.courseInfo = response.data;
      } catch (error) {
        console.error("加载课程信息失败:", error);
      } finally {
        this.courseLoading = false;
      }
    },
    async loadChapterContent() {
      this.chapterLoading = true;
      try {
        const [chapterRes, sectionRes] = await Promise.all([
          listChapter({ courseId: this.courseId, pageNum: 1, pageSize: 999 }),
          listSection({ courseId: this.courseId, pageNum: 1, pageSize: 999 })
        ]);
        const chapters = chapterRes.rows || [];
        const sections = sectionRes.rows || [];
        this.chapterData = this.structureData(chapters, sections);
        if (this.chapterData.length > 0) {
          this.activeCollapse = this.chapterData[0].id;
        }
      } catch (error) {
        console.error("加载课程章节失败:", error);
      } finally {
        this.chapterLoading = false;
      }
    },
    async loadResources() {
      this.resourceLoading = true;
      try {
        const response = await listResource(this.resourceParams);
        this.resourceData = response.rows || [];
        this.resourceTotal = response.total || 0;
        this.isResourceLoaded = true;
      } catch (error) {
        console.error("加载课程资源失败:", error);
      } finally {
        this.resourceLoading = false;
      }
    },
    structureData(chapters, sections) {
      return chapters.map(chapter => ({
        ...chapter,
        sections: sections
          .filter(section => String(section.chapterId) === String(chapter.id))
          .sort((a, b) => a.sortOrder - b.sortOrder),
      })).sort((a, b) => a.sortOrder - b.sortOrder);
    },
    handleSectionClick(section) {
      this.$router.push({
        path: `/course/section/${section.id}`,
        query: {
          courseName: this.courseInfo ? this.courseInfo.title : '',
          courseId: this.courseId
        }
      });
    },
    // 加载课程任务（按章节分组）
    async loadCourseTasks() {
      this.taskLoading = true;
      console.log('🔍 开始加载课程任务，课程ID:', this.courseId);

      try {
        // 1. 加载课程的所有任务
        const assignmentResponse = await listAssignment({
          courseId: this.courseId,
          status: 1,
          isDeleted: 0,
          pageNum: 1,
          pageSize: 999
        });

        const assignments = assignmentResponse.rows || [];
        console.log('📚 获取到任务列表:', assignments.length, '个任务', assignments);

        // 2. 为每个任务获取题目，从而获取章节信息
        const tasksWithChapters = await Promise.all(
          assignments.map(async (assignment) => {
            try {
              const questionsResponse = await getAssignmentQuestions(assignment.id);
              const questions = questionsResponse.data || [];
              console.log(`📝 任务 ${assignment.id} (${assignment.title}) 包含 ${questions.length} 个题目:`, questions);

              // 获取任务中所有题目的章节ID（去重）
              // 注意：后端返回的字段名是 chapter_id（下划线），需要兼容处理
              const chapterIds = [...new Set(questions.map(q => q.chapterId || q.chapter_id).filter(id => id))];
              console.log(`📂 任务 ${assignment.id} 关联的章节ID:`, chapterIds);

              return {
                ...assignment,
                chapterIds: chapterIds
              };
            } catch (error) {
              console.error(`❌ 获取任务 ${assignment.id} 的题目失败:`, error);
              return {
                ...assignment,
                chapterIds: []
              };
            }
          })
        );

        console.log('✅ 所有任务及其章节信息:', tasksWithChapters);

        // 3. 按章节分组任务
        const chapterMap = new Map();

        // 初始化所有章节
        console.log('📖 当前课程的章节列表:', this.chapterData);
        this.chapterData.forEach(chapter => {
          chapterMap.set(chapter.id, {
            id: chapter.id,
            title: chapter.title,
            sortOrder: chapter.sortOrder,
            tasks: []
          });
        });

        // 将任务分配到对应章节
        tasksWithChapters.forEach(task => {
          if (task.chapterIds && task.chapterIds.length > 0) {
            // 如果任务有多个章节，添加到所有相关章节
            task.chapterIds.forEach(chapterId => {
              if (chapterMap.has(chapterId)) {
                chapterMap.get(chapterId).tasks.push(task);
                console.log(`✓ 将任务 "${task.title}" 添加到章节 ${chapterId}`);
              } else {
                console.warn(`⚠️ 章节 ${chapterId} 不存在于章节列表中`);
              }
            });
          } else {
            console.warn(`⚠️ 任务 "${task.title}" 没有关联任何章节`);
          }
        });

        // 4. 转换为数组并过滤掉没有任务的章节
        this.chapterTasks = Array.from(chapterMap.values())
          .filter(chapter => chapter.tasks.length > 0)
          .sort((a, b) => a.sortOrder - b.sortOrder);

        console.log('📊 最终按章节分组的任务:', this.chapterTasks);
        console.log('📊 chapterTasks.length:', this.chapterTasks.length);
        console.log('📊 第一个章节的任务:', this.chapterTasks.length > 0 ? this.chapterTasks[0] : '无');

        // 5. 计算统计数据
        this.taskStats.total = assignments.length;
        this.taskStats.homework = assignments.filter(t => t.type === 'homework').length;
        this.taskStats.exam = assignments.filter(t => t.type === 'exam').length;
        this.taskStats.completed = 0; // TODO: 从提交记录获取

        console.log('📈 任务统计:', this.taskStats);

        // 6. 默认展开第一个章节
        if (this.chapterTasks.length > 0) {
          this.activeChapters = [this.chapterTasks[0].id];
        }

      } catch (error) {
        console.error('❌ 加载课程任务失败:', error);
        this.$modal.msgError('加载课程任务失败');
      } finally {
        this.taskLoading = false;
      }
    },

    // 格式化任务日期
    formatTaskDate(date) {
      if (!date) return '未设置';
      return this.parseTime(date, '{m}-{d} {h}:{i}');
    },

    // 获取任务状态文本
    getTaskStatusText(task) {
      const now = new Date();
      const start = task.startTime ? new Date(task.startTime) : null;
      const end = task.endTime ? new Date(task.endTime) : null;

      if (end && now > end) return '已截止';
      if (start && now < start) return '未开始';
      return '进行中';
    },

    // 获取任务状态标签类型
    getTaskStatusTagType(task) {
      const status = this.getTaskStatusText(task);
      if (status === '进行中') return 'success';
      if (status === '未开始') return 'info';
      return 'danger';
    },

    // 获取任务卡片样式类
    getTaskStatusClass(task) {
      const status = this.getTaskStatusText(task);
      if (status === '已截止') return 'task-expired';
      if (status === '未开始') return 'task-pending';
      return 'task-active';
    },

    // 判断任务是否已过期
    isTaskExpired(task) {
      if (!task.endTime) return false;
      return new Date() > new Date(task.endTime);
    },

    // 开始任务
    startTask(task) {
      if (this.isTaskExpired(task)) {
        this.$modal.msgWarning('任务已截止');
        return;
      }

      // 如果是答题型任务，跳转到答题页面
      if (task.mode === 'question') {
        this.$router.push({
          path: '/course/exam',
          query: {
            assignmentId: task.id,
            courseId: this.courseId,
            title: task.title,
            type: task.type,
            duration: task.duration
          }
        });
      } else {
        // 文件上传型任务，跳转到作业列表页面
        this.$router.push({
          path: '/system/assignment',
          query: {
            assignmentId: task.id,
            courseId: this.courseId
          }
        });
      }
    },
    handleDownload(resource) {
      // 乐观更新UI
      const res = this.resourceData.find(r => r.id === resource.id);
      if (res) {
        res.downloadCount = (res.downloadCount || 0) + 1;
      }

      // 使用自定义下载方法，调用正确的API
      this.downloadResource(resource);
    },

    // 下载资源文件
    downloadResource(resource) {
      const loading = this.$loading({
        lock: true,
        text: '正在下载文件，请稍候...',
        spinner: 'el-icon-loading',
        background: 'rgba(0, 0, 0, 0.7)'
      });

      // 调用后端下载接口
      const url = process.env.VUE_APP_BASE_API + '/system/resource/download/' + resource.id;

      axios({
        method: 'get',
        url: url,
        responseType: 'blob',
        headers: {
          'Authorization': 'Bearer ' + getToken()
        }
      }).then((response) => {
        // 从响应头获取文件名
        let fileName = resource.name;
        const contentDisposition = response.headers['content-disposition'];
        if (contentDisposition) {
          const fileNameMatch = contentDisposition.match(/filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/);
          if (fileNameMatch && fileNameMatch[1]) {
            fileName = decodeURIComponent(fileNameMatch[1].replace(/['"]/g, ''));
          }
        }

        // 创建blob对象
        const blob = new Blob([response.data]);

        // 创建下载链接
        const downloadUrl = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = downloadUrl;
        link.download = fileName;
        document.body.appendChild(link);
        link.click();

        // 清理
        document.body.removeChild(link);
        window.URL.revokeObjectURL(downloadUrl);

        loading.close();
        this.$message.success('下载成功');
      }).catch((error) => {
        console.error('下载失败:', error);
        loading.close();
        this.$message.error('下载失败，请稍后重试');

        // 回滚下载次数
        const res = this.resourceData.find(r => r.id === resource.id);
        if (res && res.downloadCount > 0) {
          res.downloadCount = res.downloadCount - 1;
        }
      });
    },
    formatDuration(seconds) {
      if (!seconds || seconds <= 0) return '';
      const min = Math.floor(seconds / 60);
      const sec = seconds % 60;
      return `${String(min).padStart(2, '0')}:${String(sec).padStart(2, '0')}`;
    },
    formatFileSize(bytes) {
      if (bytes === 0) return '0 B';
      if (!bytes) return '--';
      const k = 1024;
      const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    },
    getFileIcon(fileType) {
      const type = (fileType || '').toLowerCase();
      if (['pdf'].includes(type)) return { icon: 'el-icon-document', color: '#e53935' };
      if (['doc', 'docx'].includes(type)) return { icon: 'el-icon-document', color: '#1E88E5' };
      if (['ppt', 'pptx'].includes(type)) return { icon: 'el-icon-monitor', color: '#d84a1b' };
      if (['xls', 'xlsx'].includes(type)) return { icon: 'el-icon-data-analysis', color: '#43A047' };
      if (['zip', 'rar', '7z'].includes(type)) return { icon: 'el-icon-box', color: '#FDD835' };
      if (['jpg', 'jpeg', 'png', 'gif'].includes(type)) return { icon: 'el-icon-picture-outline', color: '#7E57C2' };
      if (['mp4', 'avi', 'mov'].includes(type)) return { icon: 'el-icon-video-camera', color: '#00ACC1' };
      return { icon: 'el-icon-folder', color: '#546E7A' };
    }
  }
};
</script>

<style lang="scss" scoped>
.course-detail-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  padding-bottom: 40px;

  /* 页面头部 */
  .page-header {
    position: relative;
    margin-bottom: 30px;
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 8px 24px rgba(102, 126, 234, 0.15);

    .header-background {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      opacity: 1;
    }

    .header-content {
      position: relative;
      display: flex;
      align-items: center;
      padding: 40px;
      min-height: 240px;
      z-index: 1;
    }

    .back-button {
      position: absolute;
      top: 20px;
      right: 20px;
      background: rgba(255, 255, 255, 0.2);
      border: 1px solid rgba(255, 255, 255, 0.3);
      color: #fff;
      transition: all 0.3s;
      z-index: 2;

      &:hover {
        background: rgba(255, 255, 255, 0.3);
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
      }
    }

    .header-left {
      flex-shrink: 0;
      margin-right: 30px;
    }

    .header-cover {
      width: 320px;
      height: 180px;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
      background: rgba(255, 255, 255, 0.1);
      transition: all 0.3s;

      &:hover {
        transform: scale(1.02);
        box-shadow: 0 12px 32px rgba(0, 0, 0, 0.3);
      }

      .image-slot {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        width: 100%;
        height: 100%;
        color: rgba(255, 255, 255, 0.8);
        font-size: 14px;
        background: rgba(0, 0, 0, 0.1);

        i {
          font-size: 48px;
          margin-bottom: 10px;
        }
      }
    }

    .header-info {
      flex: 1;
      color: #fff;

      .info-title {
        margin: 0 0 16px;
        font-size: 32px;
        font-weight: 700;
        color: #fff;
        text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        display: flex;
        align-items: center;
        gap: 12px;

        i {
          font-size: 36px;
          animation: pulse 2s ease-in-out infinite;
        }
      }

      .info-desc {
        font-size: 16px;
        color: rgba(255, 255, 255, 0.95);
        margin-bottom: 24px;
        line-height: 1.6;
        text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
      }

      .info-meta {
        display: flex;
        flex-wrap: wrap;
        gap: 24px;

        .meta-item {
          display: flex;
          align-items: center;
          gap: 8px;
          font-size: 15px;
          color: rgba(255, 255, 255, 0.95);
          background: rgba(255, 255, 255, 0.15);
          padding: 8px 16px;
          border-radius: 20px;
          backdrop-filter: blur(10px);
          transition: all 0.3s;

          i {
            font-size: 18px;
          }

          &:hover {
            background: rgba(255, 255, 255, 0.25);
            transform: translateY(-2px);
          }
        }
      }
    }
  }

  /* 内容区域 */
  .content-wrapper {
    max-width: 1200px;
    margin: 0 auto;
  }

  .tabs-card {
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);

    ::v-deep .el-card__body {
      padding: 0;
    }
  }

  /* 自定义标签页 */
  .custom-tabs {
    ::v-deep .el-tabs__header {
      margin: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      padding: 0 20px;
    }

    ::v-deep .el-tabs__nav-wrap::after {
      display: none;
    }

    ::v-deep .el-tabs__item {
      color: rgba(255, 255, 255, 0.8);
      font-size: 16px;
      font-weight: 500;
      height: 56px;
      line-height: 56px;
      padding: 0 24px;
      transition: all 0.3s;

      i {
        margin-right: 6px;
        font-size: 18px;
      }

      &:hover {
        color: #fff;
        background: rgba(255, 255, 255, 0.1);
      }

      &.is-active {
        color: #fff;
        background: rgba(255, 255, 255, 0.15);
        font-weight: 600;
      }
    }

    ::v-deep .el-tabs__active-bar {
      background-color: #fff;
      height: 3px;
    }

    .tab-badge {
      margin-left: 8px;

      ::v-deep .el-badge__content {
        background-color: rgba(255, 255, 255, 0.3);
        border: 1px solid rgba(255, 255, 255, 0.5);
        color: #fff;
      }
    }
  }

  .tab-content-wrapper {
    padding: 30px;
    min-height: 400px;
    background: #fff;
  }

  /* 自定义折叠面板 */
  .custom-collapse {
    border: none;

    ::v-deep .el-collapse-item {
      margin-bottom: 16px;
      border-radius: 12px;
      overflow: hidden;
      border: 1px solid #e8eaed;
      transition: all 0.3s;

      &:hover {
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        transform: translateY(-2px);
      }
    }

    ::v-deep .el-collapse-item__header {
      height: auto;
      line-height: 1.5;
      padding: 16px 20px;
      background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
      border: none;
      font-size: 16px;
      font-weight: 600;
      color: #303133;
      transition: all 0.3s;

      &:hover {
        background: linear-gradient(135deg, #e9ecef 0%, #dee2e6 100%);
      }

      &.is-active {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: #fff;

        .chapter-title {
          color: #fff;

          i {
            color: #fff;
          }

          .el-tag {
            background: rgba(255, 255, 255, 0.2);
            border-color: rgba(255, 255, 255, 0.3);
            color: #fff;
          }
        }
      }
    }

    ::v-deep .el-collapse-item__arrow {
      color: inherit;
      font-size: 14px;
      font-weight: bold;
    }

    ::v-deep .el-collapse-item__wrap {
      border: none;
      background: #fff;
    }

    ::v-deep .el-collapse-item__content {
      padding: 0;
    }
  }

  .chapter-title {
    display: flex;
    align-items: center;
    gap: 12px;
    width: 100%;
    color: #303133;

    i {
      font-size: 20px;
      color: #667eea;
    }

    span {
      flex: 1;
    }

    .el-tag {
      margin-left: auto;
    }
  }

  /* 章节列表样式 */
  .section-list {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .section-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    cursor: pointer;
    border-bottom: 1px solid #f0f2f5;
    transition: all 0.3s;

    &:last-child {
      border-bottom: none;
    }

    &:hover {
      background: linear-gradient(90deg, #f8f9ff 0%, #fff 100%);
      padding-left: 28px;

      .section-arrow {
        opacity: 1;
        transform: translateX(4px);
      }
    }

    .section-left {
      display: flex;
      align-items: center;
      gap: 12px;
      flex: 1;
    }

    .section-number {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 28px;
      height: 28px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #fff;
      border-radius: 50%;
      font-size: 13px;
      font-weight: 600;
      flex-shrink: 0;
    }

    .section-icon {
      font-size: 20px;
      color: #667eea;
      flex-shrink: 0;
    }

    .section-title {
      flex: 1;
      color: #303133;
      font-size: 15px;
      font-weight: 500;
    }

    .section-right {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .section-duration {
      display: flex;
      align-items: center;
      gap: 4px;
      font-size: 13px;
      color: #909399;
      background: #f5f7fa;
      padding: 4px 12px;
      border-radius: 12px;

      i {
        font-size: 14px;
      }
    }

    .section-arrow {
      font-size: 16px;
      color: #667eea;
      opacity: 0;
      transition: all 0.3s;
    }
  }

  /* 资源卡片样式 */
  .resource-list {
    margin-top: 0;
  }

  .resource-card-col {
    margin-bottom: 24px;
  }

  .resource-card {
    height: 100%;
    border-radius: 12px;
    border: 1px solid #e8eaed;
    transition: all 0.3s;

    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 24px rgba(102, 126, 234, 0.15);
      border-color: #667eea;
    }

    ::v-deep .el-card__body {
      display: flex;
      flex-direction: column;
      height: 100%;
      padding: 20px;
    }
  }

  .card-content {
    display: flex;
    align-items: center;
    flex: 1;
    min-height: 80px;
  }

  .file-icon {
    font-size: 56px;
    margin-right: 16px;
    flex-shrink: 0;
    transition: all 0.3s;

    .resource-card:hover & {
      transform: scale(1.1);
    }
  }

  .file-info {
    display: flex;
    flex-direction: column;
    justify-content: center;
    overflow: hidden;
    flex: 1;
  }

  .file-name {
    font-size: 16px;
    font-weight: 600;
    color: #303133;
    margin-bottom: 8px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    transition: all 0.3s;

    .resource-card:hover & {
      color: #667eea;
    }
  }

  .file-meta {
    display: flex;
    align-items: center;
    font-size: 13px;
    color: #909399;

    .file-size {
      font-weight: 500;
    }

    .divider {
      margin: 0 8px;
      color: #dcdfe6;
    }

    .file-date {
      color: #909399;
    }
  }

  .card-actions {
    margin-top: 16px;
    padding-top: 16px;
    border-top: 1px solid #f0f2f5;
    display: flex;
    justify-content: flex-end;
    align-items: center;

    .el-button {
      width: 100%;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border: none;
      color: #fff;
      font-weight: 500;
      transition: all 0.3s;

      &:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
      }

      &.is-plain {
        background: #fff;
        border: 1px solid #667eea;
        color: #667eea;

        &:hover {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: #fff;
        }
      }
    }

    .download-badge {
      margin-left: 8px;

      ::v-deep .el-badge__content {
        background-color: rgba(255, 255, 255, 0.3);
        border: 1px solid rgba(255, 255, 255, 0.5);
      }
    }
  }

  .resource-pagination {
    margin-top: 30px;
    text-align: center;
  }

  /* 动画 */
  @keyframes pulse {
    0%, 100% {
      transform: scale(1);
    }
    50% {
      transform: scale(1.05);
    }
  }

  /* 响应式设计 */
  @media (max-width: 768px) {
    .page-header {
      .header-content {
        flex-direction: column;
        padding: 30px 20px;
      }

      .header-left {
        margin-right: 0;
        margin-bottom: 20px;
      }

      .header-cover {
        width: 100%;
        max-width: 320px;
      }

      .header-info {
        .info-title {
          font-size: 24px;

          i {
            font-size: 28px;
          }
        }

        .info-desc {
          font-size: 14px;
        }

        .info-meta {
          gap: 12px;

          .meta-item {
            font-size: 13px;
            padding: 6px 12px;
          }
        }
      }
    }

    .tab-content-wrapper {
      padding: 20px;
    }

    // 题目练习入口样式
    .practice-entry {
      padding: 40px 20px;
      text-align: center;
    }

    .section-item {
      padding: 12px 16px;

      &:hover {
        padding-left: 20px;
      }

      .section-left {
        gap: 8px;
      }

      .section-number {
        width: 24px;
        height: 24px;
        font-size: 12px;
      }

      .section-title {
        font-size: 14px;
      }
    }
  }
}

/* ==================== 任务练习样式 ==================== */
.practice-tab-content {
  padding: 0 !important;
}

.task-stats-bar {
  display: flex;
  align-items: center;
  justify-content: space-around;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
  border-radius: 12px;
  margin-bottom: 24px;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);

  .stat-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;

    .stat-label {
      font-size: 13px;
      color: rgba(255, 255, 255, 0.9);
      font-weight: 500;
    }

    .stat-value {
      font-size: 28px;
      font-weight: 700;
      color: white;
      line-height: 1;
    }

    &.stat-homework .stat-value {
      color: #a8e6cf;
    }

    &.stat-exam .stat-value {
      color: #ffd3b6;
    }

    &.stat-completed .stat-value {
      color: #dfe6e9;
    }
  }

  .stat-divider {
    width: 1px;
    height: 40px;
    background: rgba(255, 255, 255, 0.2);
  }
}

.tasks-container {
  min-height: 300px;
}

.chapter-tasks-list {
  .chapter-section {
    margin-bottom: 32px;

    &:last-child {
      margin-bottom: 0;
    }
  }

  .chapter-title-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%);
    border-radius: 10px;
    margin-bottom: 16px;
    border-left: 4px solid #667eea;

    .chapter-title-content {
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 16px;
      font-weight: 600;
      color: #303133;

      i {
        font-size: 18px;
        color: #667eea;
      }
    }

    .task-count {
      font-size: 13px;
      color: #909399;
      background: white;
      padding: 4px 12px;
      border-radius: 12px;
      font-weight: 500;
    }
  }

  .tasks-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
    gap: 16px;
  }

  .task-item {
    background: white;
    border-radius: 10px;
    overflow: hidden;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    cursor: pointer;
    border: 1px solid #e8ecf1;
    position: relative;

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 24px rgba(102, 126, 234, 0.15);
      border-color: #667eea;
    }

    .task-status-bar {
      height: 4px;
      width: 100%;

      &.task-active {
        background: linear-gradient(90deg, #67C23A 0%, #85CE61 100%);
      }

      &.task-pending {
        background: linear-gradient(90deg, #909399 0%, #b3b3b3 100%);
      }

      &.task-expired {
        background: linear-gradient(90deg, #F56C6C 0%, #f78989 100%);
      }
    }

    .task-content {
      padding: 20px;
    }

    .task-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 14px;

      .task-type {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        font-size: 12px;
        font-weight: 600;
        padding: 5px 12px;
        border-radius: 14px;

        &.type-homework {
          background: #f0f9ff;
          color: #67C23A;
        }

        &.type-exam {
          background: #fffbeb;
          color: #E6A23C;
        }

        i {
          font-size: 13px;
        }
      }

      .task-status {
        font-size: 12px;
        font-weight: 500;
        padding: 4px 10px;
        border-radius: 10px;

        &.status-task-active {
          background: #f0f9ff;
          color: #67C23A;
        }

        &.status-task-pending {
          background: #f5f5f5;
          color: #909399;
        }

        &.status-task-expired {
          background: #fef0f0;
          color: #F56C6C;
        }
      }
    }

    .task-name {
      font-size: 15px;
      font-weight: 600;
      color: #303133;
      margin: 0 0 10px 0;
      line-height: 1.5;
      overflow: hidden;
      text-overflow: ellipsis;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      line-clamp: 2;
      -webkit-box-orient: vertical;
    }

    .task-desc {
      font-size: 13px;
      color: #909399;
      line-height: 1.6;
      margin: 0 0 14px 0;
      overflow: hidden;
      text-overflow: ellipsis;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      line-clamp: 2;
      -webkit-box-orient: vertical;
    }

    .task-meta {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      margin-bottom: 16px;
      padding-top: 12px;
      border-top: 1px dashed #e8ecf1;

      .meta-item {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 12px;
        color: #606266;

        i {
          font-size: 13px;
          color: #909399;
        }
      }
    }

    .task-footer {
      .el-button {
        width: 100%;
        border-radius: 8px;
        font-weight: 500;
        transition: all 0.3s;

        i {
          margin-left: 4px;
          transition: transform 0.3s;
        }

        &:hover i {
          transform: translateX(3px);
        }
      }
    }
  }
}
</style>
