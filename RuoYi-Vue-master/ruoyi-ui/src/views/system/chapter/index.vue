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

          <!-- Tab 1: 视频学习 -->
          <el-tab-pane name="chapters">
            <span slot="label">
              <i class="el-icon-menu"></i>
              视频学习
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
                      <el-button type="success" icon="el-icon-view" size="small" @click="handlePreview(resource)" plain :disabled="!canPreview(resource.fileType)">
                        预览
                      </el-button>
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

          <!-- Tab 4: 学习分析 -->
          <el-tab-pane name="learning-analysis">
            <span slot="label">
              <i class="el-icon-data-analysis"></i>
              学习分析
            </span>
            <div class="tab-content-wrapper">
              <LearningAnalysis :courseId="courseId" v-if="activeTab === 'learning-analysis'" />
            </div>
          </el-tab-pane>

          <!-- Tab 5: 题目练习 -->
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
                              :type="isTaskSubmitted(task) ? 'success' : (isTaskExpired(task) ? 'info' : 'primary')"
                              size="small"
                              :disabled="isTaskButtonDisabled(task)"
                              plain
                            >
                              {{ getTaskButtonText(task) }}
                              <i :class="isTaskSubmitted(task) ? (isExamSubmitted(task) ? 'el-icon-check' : 'el-icon-refresh') : 'el-icon-arrow-right'"></i>
                            </el-button>
                            <!-- 预览按钮 -->
                            <el-button
                              v-if="isTaskSubmitted(task)"
                              type="warning"
                              size="small"
                              plain
                              @click.stop="viewSubmission(task)"
                            >
                              <i class="el-icon-view"></i> 预览
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
          v-if="isTaskSubmitted(currentAssignment)"
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

    <!-- 资源预览对话框 -->
    <el-dialog :title="previewTitle" :visible.sync="previewOpen" :width="previewWidth" append-to-body :before-close="closePreview" class="preview-dialog">
      <div class="preview-container" v-loading="previewLoading">
        <!-- 图片预览 -->
        <div v-if="previewType === 'image'" class="image-preview">
          <el-image :src="previewUrl" fit="contain" :preview-src-list="[previewUrl]" style="max-width: 100%; max-height: 70vh;">
            <div slot="error" class="image-error">
              <i class="el-icon-picture-outline"></i>
              <span>图片加载失败</span>
            </div>
          </el-image>
        </div>
        <!-- PDF预览 -->
        <div v-else-if="previewType === 'pdf'" class="pdf-preview">
          <iframe :src="previewUrl" width="100%" height="600px" frameborder="0"></iframe>
        </div>
        <!-- Office文档预览（Word/Excel/PPT统一处理） -->
        <div v-else-if="previewType === 'word' || previewType === 'excel' || previewType === 'ppt' || previewType === 'office'" class="office-preview">
          <div class="office-download-box">
            <div class="office-icon">
              <i :class="previewType === 'word' ? 'el-icon-document' : (previewType === 'excel' ? 'el-icon-s-grid' : 'el-icon-data-board')"
                 :style="{fontSize: '64px', color: previewType === 'word' ? '#409EFF' : (previewType === 'excel' ? '#67C23A' : '#E6A23C')}"></i>
            </div>
            <h3 style="margin: 20px 0 10px; color: #303133;">{{ currentPreviewResource ? currentPreviewResource.name : 'Office 文档' }}</h3>
            <p style="color: #909399; margin-bottom: 20px;">
              Office 文档暂不支持在线预览，请下载后使用本地软件打开
            </p>
            <el-button type="primary" size="large" icon="el-icon-download" @click="handleDownload(currentPreviewResource)">
              下载文件到本地查看
            </el-button>
            <p style="margin-top: 15px; color: #C0C4CC; font-size: 12px;">
              支持 Microsoft Word、Excel、PowerPoint 或 WPS Office 打开
            </p>
          </div>
        </div>
        <!-- 视频预览 -->
        <div v-else-if="previewType === 'video'" class="video-preview">
          <video :src="previewUrl" controls style="max-width: 100%; max-height: 70vh;">
            您的浏览器不支持视频播放
          </video>
        </div>
        <!-- 音频预览 -->
        <div v-else-if="previewType === 'audio'" class="audio-preview">
          <audio :src="previewUrl" controls style="width: 100%;">
            您的浏览器不支持音频播放
          </audio>
        </div>
        <!-- 文本预览 -->
        <div v-else-if="previewType === 'text'" class="text-preview">
          <div v-if="textContent" class="text-content">
            <pre>{{ textContent }}</pre>
          </div>
          <div v-else class="text-loading">
            <i class="el-icon-loading"></i>
            <span>正在加载文本内容...</span>
          </div>
        </div>
        <!-- 不支持预览 -->
        <div v-else class="unsupported-preview">
          <i class="el-icon-document" style="font-size: 64px; color: #909399;"></i>
          <p>该文件类型暂不支持在线预览</p>
          <el-button type="primary" @click="handleDownload(currentPreviewResource)">下载查看</el-button>
        </div>
      </div>
    </el-dialog>

    <!-- 查看提交对话框 -->
    <el-dialog
      title="查看提交内容"
      :visible.sync="viewSubmissionOpen"
      :width="inlinePreviewFile ? '900px' : '700px'"
      append-to-body
      class="submission-dialog"
    >
      <div v-loading="viewSubmissionLoading" class="submission-content">
        <template v-if="currentSubmission && currentViewTask">
          <!-- 作业信息 -->
          <div class="submission-info">
            <h3>{{ currentViewTask.title }}</h3>
            <div class="info-tags">
              <el-tag size="small" :type="currentViewTask.type === 'exam' ? 'danger' : 'primary'">
                {{ currentViewTask.type === 'exam' ? '考试' : '作业' }}
              </el-tag>
              <el-tag size="small" type="info">
                {{ currentViewTask.mode === 'question' ? '答题型' : '上传型' }}
              </el-tag>
              <el-tag size="small" :type="getSubmissionStatusType(currentSubmission.status)">
                {{ getSubmissionStatusText(currentSubmission.status) }}
              </el-tag>
            </div>
          </div>

          <!-- 提交时间和得分 -->
          <el-descriptions :column="2" border size="small" class="submission-meta">
            <el-descriptions-item label="提交时间">
              {{ parseTime(currentSubmission.submitTime) }}
            </el-descriptions-item>
            <el-descriptions-item label="得分">
              <span v-if="currentSubmission.score != null" class="score-text">
                {{ currentSubmission.score }} 分
              </span>
              <span v-else class="pending-text">待批改</span>
            </el-descriptions-item>
            <el-descriptions-item label="批改时间" v-if="currentSubmission.gradeTime">
              {{ parseTime(currentSubmission.gradeTime) }}
            </el-descriptions-item>
            <el-descriptions-item label="批改反馈" :span="2" v-if="currentSubmission.feedback">
              {{ currentSubmission.feedback }}
            </el-descriptions-item>
          </el-descriptions>

          <!-- 上传型：显示提交的文件 -->
          <div v-if="(currentViewTask.mode === 'upload' || currentViewTask.mode === 'file') && currentSubmission.filePath" class="submission-files">
            <h4><i class="el-icon-folder-opened"></i> 提交的文件</h4>
            <div class="file-list">
              <div v-for="(file, index) in parseFilePaths(currentSubmission.filePath)" :key="index" class="file-item">
                <div class="file-info">
                  <i :class="getFileIcon(file)"></i>
                  <span class="file-name">{{ getFileName(file) }}</span>
                </div>
                <div class="file-actions">
                  <el-button type="primary" size="small" @click="showInlinePreview(file)" v-if="canPreviewFile(file)">
                    <i class="el-icon-view"></i> 预览
                  </el-button>
                  <el-button type="info" size="small" @click="showInlinePreview(file)" v-else disabled>
                    <i class="el-icon-view"></i> 不支持预览
                  </el-button>
                </div>
              </div>
            </div>

            <!-- 内嵌预览区域 -->
            <div v-if="inlinePreviewFile" class="inline-preview-area">
              <div class="inline-preview-header">
                <span><i class="el-icon-view"></i> 预览: {{ getFileName(inlinePreviewFile) }}</span>
                <el-button type="text" size="small" @click="closeInlinePreview">
                  <i class="el-icon-close"></i> 关闭预览
                </el-button>
              </div>
              <div class="inline-preview-content">
                <!-- 图片预览 -->
                <el-image
                  v-if="inlinePreviewType === 'image'"
                  :src="inlinePreviewUrl"
                  fit="contain"
                  :preview-src-list="[inlinePreviewUrl]"
                  style="max-width: 100%; max-height: 500px;"
                >
                  <div slot="error" class="image-error">
                    <i class="el-icon-picture-outline"></i>
                    <span>图片加载失败</span>
                  </div>
                </el-image>
                <!-- PDF预览 -->
                <iframe
                  v-else-if="inlinePreviewType === 'pdf'"
                  :src="inlinePreviewUrl"
                  width="100%"
                  height="500px"
                  frameborder="0"
                ></iframe>
                <!-- 视频预览 -->
                <video
                  v-else-if="inlinePreviewType === 'video'"
                  :src="inlinePreviewUrl"
                  controls
                  style="max-width: 100%; max-height: 500px;"
                >
                  您的浏览器不支持视频播放
                </video>
                <!-- 音频预览 -->
                <audio
                  v-else-if="inlinePreviewType === 'audio'"
                  :src="inlinePreviewUrl"
                  controls
                  style="width: 100%;"
                >
                  您的浏览器不支持音频播放
                </audio>
                <!-- 文本预览 -->
                <pre v-else-if="inlinePreviewType === 'text'" class="text-preview-content">{{ inlinePreviewText }}</pre>
                <!-- Office文档预览 -->
                <div v-else-if="inlinePreviewType === 'office'" class="office-preview-tip">
                  <el-alert title="Office文档需要下载后查看" type="info" :closable="false">
                    <template slot="title">
                      <p>浏览器暂不支持直接预览 Office 文档</p>
                      <el-button type="primary" size="small" @click="downloadSubmissionFile(inlinePreviewFile)" style="margin-top: 10px;">
                        <i class="el-icon-download"></i> 下载文件查看
                      </el-button>
                    </template>
                  </el-alert>
                </div>
              </div>
            </div>

            <!-- 备注 -->
            <div v-if="currentSubmission.content" class="submission-remark">
              <h4><i class="el-icon-edit-outline"></i> 备注</h4>
              <p>{{ currentSubmission.content }}</p>
            </div>
          </div>

          <!-- 答题型：显示答题内容 -->
          <div v-if="currentViewTask.mode === 'question'" class="submission-answers">
            <h4><i class="el-icon-document"></i> 答题内容</h4>

            <!-- 成功解析的答案列表 -->
            <div v-if="parsedAnswers && parsedAnswers.length > 0" class="answers-list">
              <div
                v-for="(item, index) in parsedAnswers"
                :key="index"
                class="answer-item-card"
              >
                <!-- 题目头部 -->
                <div class="answer-item-header">
                  <span class="question-number">第 {{ index + 1 }} 题</span>
                  <el-tag v-if="item.question" size="mini" :type="getQuestionTypeColor(item.question.questionType)">
                    {{ getQuestionTypeName(item.question.questionType) }}
                  </el-tag>
                  <span v-if="item.question" class="question-score">{{ item.question.score }} 分</span>
                </div>

                <!-- 题目内容 -->
                <div class="answer-item-content">
                  <div class="question-title-text">
                    <strong>题目：</strong>{{ item.question ? item.question.questionTitle : '题目信息缺失' }}
                  </div>

                  <!-- 你的答案 -->
                  <div class="answer-row">
                    <span class="answer-label">你的答案：</span>
                    <span class="answer-value user-answer">{{ formatAnswer(item.answer) || '未作答' }}</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- 完全没有内容 -->
            <el-empty v-else description="暂无答题记录" :image-size="80"></el-empty>
          </div>
        </template>

        <el-empty v-else-if="!viewSubmissionLoading" description="暂无提交记录"></el-empty>
      </div>
      <div slot="footer">
        <el-button @click="viewSubmissionOpen = false">关闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
// 导入所有需要的API
import { getCourse } from "@/api/system/course";
import { listChapter } from "@/api/system/chapter";
import { listSection } from "@/api/system/section";
import { listResource, getPreviewInfo } from "@/api/system/resource";
import { listAssignment, getAssignmentQuestions, getMySubmissions, uploadAssignment, getSubmissionDetail } from "@/api/system/assignment";
import { getQuestion } from "@/api/system/question";
import { recordResourceDownload } from "@/api/system/lbehavior";
import axios from 'axios';
import { getToken } from '@/utils/auth';
import KnowledgeGraphView from '@/views/system/course/components/KnowledgeGraphView.vue';
import LearningAnalysis from '@/views/system/course/components/LearningAnalysis.vue';
import FileUpload from '@/components/FileUpload';

export default {
  name: "CourseDetail",
  components: {
    KnowledgeGraphView,
    LearningAnalysis,
    FileUpload
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
      },
      // 学生提交记录 Map: { assignmentId: { status, score, submitTime } }
      submittedMap: {},

      // 上传作业对话框
      submitDialogVisible: false,
      currentAssignment: null,
      studentSubmitForm: {
        files: "",
        remark: ""
      },
      submitting: false,

      // 预览相关
      previewOpen: false,
      previewLoading: false,
      previewTitle: "资源预览",
      previewType: "",
      previewUrl: "",
      previewWidth: "80%",
      currentPreviewResource: null,
      textContent: "",
      officePreviewNote: "",
      officePreviewFailed: false,

      // 查看提交对话框
      viewSubmissionOpen: false,
      viewSubmissionLoading: false,
      currentSubmission: null,
      currentViewTask: null,
      currentSubmissionQuestions: [], // 存储当前提交对应的题目信息

      // 内嵌预览
      inlinePreviewFile: null,
      inlinePreviewType: '',
      inlinePreviewUrl: '',
      inlinePreviewText: '',

      // Office 文档预览
      officeLoading: false,
      officeLoadError: false,
      excelSheets: [],
      currentSheetIndex: 0,
      excelHtml: ''
    };
  },
  computed: {
    // 解析后的答案列表
    parsedAnswers() {
      console.log('=== parsedAnswers 计算属性被调用 ===');
      console.log('currentSubmission:', this.currentSubmission);

      if (!this.currentSubmission) {
        console.log('currentSubmission 为空，返回空数组');
        return [];
      }

      // 尝试多个可能的字段名
      const content = this.currentSubmission.content
        || this.currentSubmission.answerContent
        || this.currentSubmission.answer_content
        || this.currentSubmission.answers;

      console.log('提取的 content:', content);
      console.log('content 类型:', typeof content);

      if (!content) {
        console.log('content 为空，返回空数组');
        return [];
      }

      const result = this.parseAnswerContent(content);
      console.log('parsedAnswers 最终返回:', result);
      return result;
    }
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

        // 1.5 加载学生的提交记录
        try {
          const submissionsResponse = await getMySubmissions();
          const submissions = submissionsResponse.data || [];
          console.log('📝 获取到提交记录:', submissions);
          // 构建提交记录 Map
          this.submittedMap = {};
          submissions.forEach(sub => {
            this.submittedMap[sub.assignmentId] = {
              status: sub.status,
              score: sub.score,
              submitTime: sub.submitTime,
              filePath: sub.filePath || sub.file_path || '',
              content: sub.content || ''
            };
          });
          console.log('📝 提交记录Map:', this.submittedMap);
        } catch (subError) {
          console.error('获取提交记录失败:', subError);
          this.submittedMap = {};
        }

        // 2. 为每个任务获取题目，从而获取章节信息
        const tasksWithChapters = await Promise.all(
          assignments.map(async (assignment) => {
            // 如果是上传型作业，不需要获取题目，直接返回空章节ID
            if (assignment.mode === 'upload' || assignment.mode === 'file') {
              console.log(`📎 任务 ${assignment.id} (${assignment.title}) 是上传型作业，无需获取题目`);
              return {
                ...assignment,
                chapterIds: []
              };
            }

            // 答题型作业，获取题目来确定章节
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
        const unassignedTasks = []; // 没有章节关联的任务

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

        // 将任务分配到对应章节（每个任务只添加到第一个关联的章节，避免重复）
        tasksWithChapters.forEach(task => {
          if (task.chapterIds && task.chapterIds.length > 0) {
            // 只将任务添加到第一个有效的章节，避免重复显示
            const firstValidChapterId = task.chapterIds.find(chapterId => chapterMap.has(chapterId));

            if (firstValidChapterId) {
              chapterMap.get(firstValidChapterId).tasks.push(task);
              console.log(`✓ 将任务 "${task.title}" 添加到章节 ${firstValidChapterId}${task.chapterIds.length > 1 ? ' (该任务关联多个章节，仅显示在第一个章节)' : ''}`);
            } else {
              console.warn(`⚠️ 任务 "${task.title}" 的所有章节ID都不存在于章节列表中:`, task.chapterIds);
              unassignedTasks.push(task);
            }
          } else {
            // 没有章节关联的任务（主要是上传型作业）
            console.log(`📎 任务 "${task.title}" 没有关联章节，添加到"其他任务"分组`);
            unassignedTasks.push(task);
          }
        });

        // 4. 转换为数组并过滤掉没有任务的章节
        this.chapterTasks = Array.from(chapterMap.values())
          .filter(chapter => chapter.tasks.length > 0)
          .sort((a, b) => a.sortOrder - b.sortOrder);

        // 5. 如果有未分配章节的任务，添加"其他任务"分组
        if (unassignedTasks.length > 0) {
          this.chapterTasks.push({
            id: 'other',
            title: '其他任务',
            sortOrder: 9999, // 放在最后
            tasks: unassignedTasks
          });
          console.log(`📋 添加"其他任务"分组，包含 ${unassignedTasks.length} 个任务`);
        }

        console.log('📊 最终按章节分组的任务:', this.chapterTasks);
        console.log('📊 chapterTasks.length:', this.chapterTasks.length);
        console.log('📊 第一个章节的任务:', this.chapterTasks.length > 0 ? this.chapterTasks[0] : '无');

        // 5. 计算统计数据
        this.taskStats.total = assignments.length;
        this.taskStats.homework = assignments.filter(t => t.type === 'homework').length;
        this.taskStats.exam = assignments.filter(t => t.type === 'exam').length;
        // 从提交记录计算已完成数量
        this.taskStats.completed = assignments.filter(t => this.isTaskSubmitted(t)).length;

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

    // 判断任务是否已提交
    isTaskSubmitted(task) {
      const submission = this.submittedMap[task.id];
      return submission && submission.status >= 1;
    },

    // 获取任务的提交信息（分数等）
    getTaskSubmission(task) {
      return this.submittedMap[task.id] || null;
    },

    // 获取任务状态文本
    getTaskStatusText(task) {
      const now = new Date();
      const start = task.startTime ? new Date(task.startTime) : null;
      const end = task.endTime ? new Date(task.endTime) : null;

      // 优先判断是否已提交
      if (this.isTaskSubmitted(task)) {
        const submission = this.getTaskSubmission(task);
        if (submission.score != null) {
          return `已批改 ${submission.score}分`;
        }
        return '已提交';
      }

      if (end && now > end) return '已截止';
      if (start && now < start) return '未开始';
      return '进行中';
    },

    // 获取任务状态标签类型
    getTaskStatusTagType(task) {
      if (this.isTaskSubmitted(task)) return 'success';
      const status = this.getTaskStatusText(task);
      if (status === '进行中') return 'warning';
      if (status === '未开始') return 'info';
      return 'danger';
    },

    // 获取任务卡片样式类
    getTaskStatusClass(task) {
      if (this.isTaskSubmitted(task)) return 'task-submitted';
      const now = new Date();
      const start = task.startTime ? new Date(task.startTime) : null;
      const end = task.endTime ? new Date(task.endTime) : null;
      if (end && now > end) return 'task-expired';
      if (start && now < start) return 'task-pending';
      return 'task-active';
    },

    // 判断任务是否已过期
    isTaskExpired(task) {
      if (!task.endTime) return false;
      return new Date() > new Date(task.endTime);
    },

    // 获取按钮文字
    getTaskButtonText(task) {
      if (this.isTaskSubmitted(task)) {
        // 考试已提交，显示"已完成"
        if (task.type === 'exam') {
          return '已完成';
        }
        // 作业可以重新提交
        return task.mode === 'question' ? '重新答题' : '重新提交';
      }
      return task.mode === 'question' ? '开始答题' : '提交作业';
    },

    // 判断是否是已提交的考试
    isExamSubmitted(task) {
      return task.type === 'exam' && this.isTaskSubmitted(task);
    },

    // 判断按钮是否禁用
    isTaskButtonDisabled(task) {
      // 考试已提交，禁用按钮
      if (this.isExamSubmitted(task)) {
        return true;
      }
      // 已截止且未提交，禁用按钮
      if (this.isTaskExpired(task) && !this.isTaskSubmitted(task)) {
        return true;
      }
      return false;
    },

    // 开始任务
    startTask(task) {
      // 考试已提交，不允许重新作答
      if (this.isExamSubmitted(task)) {
        this.$modal.msgWarning('考试只能提交一次，不允许重新作答');
        return;
      }

      if (this.isTaskExpired(task) && !this.isTaskSubmitted(task)) {
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
        // 文件上传型任务，打开上传对话框
        this.openSubmitDialog(task);
      }
    },

    // 打开提交作业对话框
    openSubmitDialog(task) {
      if (!task || !task.id) {
        return;
      }
      this.currentAssignment = task;
      this.studentSubmitForm = {
        files: "",
        remark: ""
      };
      this.submitDialogVisible = true;
    },

    // 提交上传作业
    handleSubmitUpload() {
      if (!this.studentSubmitForm.files) {
        this.$modal.msgError("请先上传作业文件");
        return;
      }

      this.submitting = true;
      const assignmentId = this.currentAssignment.id;

      uploadAssignment(assignmentId, {
        files: this.studentSubmitForm.files,
        remark: this.studentSubmitForm.remark
      }).then(() => {
        // 更新本地状态
        this.$set(this.submittedMap, assignmentId, {
          status: 1,
          submitTime: new Date().toISOString(),
          filePath: this.studentSubmitForm.files,
          content: this.studentSubmitForm.remark
        });
        this.$modal.msgSuccess("提交成功！");
        this.submitting = false;
        this.submitDialogVisible = false;
        // 重新加载任务列表以更新状态
        this.loadCourseTasks();
      }).catch(error => {
        console.error('提交失败:', error);
        this.$modal.msgError("提交失败，请稍后重试");
        this.submitting = false;
      });
    },
    handleDownload(resource) {
      // 乐观更新UI
      const res = this.resourceData.find(r => r.id === resource.id);
      if (res) {
        res.downloadCount = (res.downloadCount || 0) + 1;
      }

      // 记录资源下载行为
      this.recordDownloadBehavior(resource);

      // 使用自定义下载方法，调用正确的API
      this.downloadResource(resource);
    },

    /** 记录资源下载行为 */
    async recordDownloadBehavior(resource) {
      try {
        const courseId = this.courseId || resource.courseId;
        if (!courseId || !resource.id) {
          console.log('⚠️ 缺少courseId或resourceId，跳过记录下载行为');
          return;
        }
        await recordResourceDownload(courseId, resource.id);
        console.log('📝 资源下载行为已记录:', { courseId, resourceId: resource.id });
      } catch (error) {
        console.error('❌ 记录资源下载行为失败:', error);
      }
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
    },
    /** 判断是否可以预览 */
    canPreview(fileType) {
      const type = fileType ? fileType.toLowerCase() : '';
      const previewableTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'mp4', 'webm', 'mp3', 'wav', 'txt', 'md', 'json'];
      return previewableTypes.includes(type);
    },
    /** 处理预览事件 */
    handlePreview(resource) {
      this.currentPreviewResource = resource;
      this.previewLoading = true;
      this.previewOpen = true;
      this.previewTitle = "预览: " + resource.name;
      this.textContent = "";
      this.officePreviewNote = "";
      this.officeLoading = false;
      this.officeLoadError = false;
      this.excelSheets = [];
      this.excelHtml = '';
      this.currentSheetIndex = 0;

      getPreviewInfo(resource.id).then(response => {
        let previewType = response.previewType;
        this.previewUrl = response.previewUrl;
        this.officePreviewNote = response.officePreviewNote || "";

        // 细分 office 类型
        if (previewType === 'office') {
          const ext = (resource.fileType || '').toLowerCase();
          if (['doc', 'docx'].includes(ext)) {
            previewType = 'word';
          } else if (['xls', 'xlsx'].includes(ext)) {
            previewType = 'excel';
          } else if (['ppt', 'pptx'].includes(ext)) {
            previewType = 'ppt';
          }
        }
        this.previewType = previewType;

        // 根据预览类型调整对话框宽度
        if (this.previewType === 'image') {
          this.previewWidth = '60%';
        } else if (this.previewType === 'audio') {
          this.previewWidth = '50%';
        } else if (this.previewType === 'text') {
          this.previewWidth = '70%';
          this.loadTextContent(response.previewUrl);
        } else if (this.previewType === 'word' || this.previewType === 'excel') {
          this.previewWidth = '90%';
          this.loadOfficeDocument(response.previewUrl, this.previewType);
        } else {
          this.previewWidth = '90%';
        }

        this.previewLoading = false;
      }).catch(error => {
        console.error('获取预览信息失败:', error);
        this.$message.error('获取预览信息失败: ' + (error.message || '未知错误'));
        this.previewLoading = false;
        this.previewType = 'unsupported';
      });
    },

    /** 加载 Office 文档 */
    async loadOfficeDocument(url, type) {
      this.officeLoading = true;
      this.officeLoadError = false;

      try {
        const response = await fetch(url);
        if (!response.ok) throw new Error('文件加载失败');
        const arrayBuffer = await response.arrayBuffer();

        if (type === 'word') {
          await this.renderWord(arrayBuffer);
        } else if (type === 'excel') {
          this.renderExcel(arrayBuffer);
        }
      } catch (error) {
        console.error('加载Office文档失败:', error);
        this.officeLoadError = true;
      } finally {
        this.officeLoading = false;
      }
    },

    /** 渲染 Word 文档 */
    async renderWord(arrayBuffer) {
      try {
        const docxPreview = await import(/* webpackChunkName: "docx-preview" */ 'docx-preview');
        await this.$nextTick();
        const container = this.$refs.wordPreviewContainer;
        if (container) {
          container.innerHTML = '';
          await docxPreview.renderAsync(arrayBuffer, container, null, {
            className: 'docx-preview',
            inWrapper: true,
            ignoreWidth: false,
            ignoreHeight: false,
            ignoreFonts: false,
            breakPages: true,
            useBase64URL: true
          });
        }
      } catch (error) {
        console.error('docx-preview 库加载失败:', error);
        this.officeLoadError = true;
      }
    },

    /** 渲染 Excel 文档 */
    async renderExcel(arrayBuffer) {
      try {
        const XLSX = await import('xlsx');
        const workbook = XLSX.read(arrayBuffer, { type: 'array' });
        this.excelSheets = workbook.SheetNames.map(name => ({
          name,
          data: workbook.Sheets[name]
        }));
        this.xlsxLib = XLSX; // 保存引用供后续使用
        this.currentSheetIndex = 0;
        this.renderCurrentSheet();
      } catch (error) {
        console.error('xlsx 库加载失败:', error);
        this.officeLoadError = true;
      }
    },

    /** 渲染当前 Excel 工作表 */
    renderCurrentSheet() {
      if (this.excelSheets.length > 0 && this.xlsxLib) {
        const sheet = this.excelSheets[this.currentSheetIndex];
        this.excelHtml = this.xlsxLib.utils.sheet_to_html(sheet.data, { editable: false });
      }
    },

    /** 切换 Excel 工作表 */
    switchSheet(index) {
      this.currentSheetIndex = index;
      this.renderCurrentSheet();
    },
    /** 加载文本内容 */
    loadTextContent(url) {
      fetch(url)
        .then(response => {
          if (!response.ok) {
            throw new Error('文件加载失败');
          }
          return response.text();
        })
        .then(text => {
          this.textContent = text;
        })
        .catch(error => {
          console.error('加载文本内容失败:', error);
          this.textContent = '文本内容加载失败，请下载查看';
        });
    },
    /** 关闭预览 */
    closePreview() {
      this.previewOpen = false;
      this.previewUrl = "";
      this.previewType = "";
      this.currentPreviewResource = null;
      this.textContent = "";
      this.officePreviewNote = "";
    },

    /** 查看提交内容 */
    async viewSubmission(task) {
      this.currentViewTask = task;
      this.currentSubmission = null;
      this.currentSubmissionQuestions = [];
      this.viewSubmissionOpen = true;
      this.viewSubmissionLoading = true;
      // 重置内嵌预览
      this.closeInlinePreview();

      try {
        // 获取提交详情
        const response = await getSubmissionDetail(task.id);
        const data = response.data || {};

        // 兼容不同格式的字段名（驼峰和下划线）
        this.currentSubmission = {
          ...data,
          filePath: data.filePath || data.file_path || '',
          submitTime: data.submitTime || data.submit_time,
          gradeTime: data.gradeTime || data.grade_time
        };

        // 如果是答题型任务，获取题目信息
        if (task.mode === 'question') {
          try {
            const questionsResponse = await getAssignmentQuestions(task.id);
            const rawQuestions = questionsResponse.data || [];
            this.currentSubmissionQuestions = rawQuestions.map(q => ({
              questionId: q.question_id || q.questionId,
              questionTitle: q.question_title || q.questionTitle,
              questionType: q.question_type || q.questionType,
              score: q.score,
              options: q.options,
              difficulty: q.difficulty,
              correctAnswer: q.correct_answer || q.correctAnswer,
              explanation: q.explanation
            }));
          } catch (error) {
            console.error('获取题目信息失败:', error);
          }
        }

        this.viewSubmissionLoading = false;
      } catch (error) {
        console.error('获取提交详情失败:', error);
        this.$modal.msgError('获取提交详情失败');
        this.viewSubmissionLoading = false;
      }
    },

    /** 获取任务提交的文件路径 */
    getTaskSubmissionFilePath(task) {
      if (!task || !task.id) return null;
      const submission = this.submittedMap[task.id];
      if (!submission) return null;
      return submission.filePath || submission.file_path || null;
    },

    /** 直接下载任务提交的文件 */
    downloadTaskSubmission(task) {
      const filePath = this.getTaskSubmissionFilePath(task);
      if (filePath) {
        const files = this.parseFilePaths(filePath);
        if (files.length === 1) {
          this.downloadSubmissionFile(files[0]);
        } else if (files.length > 1) {
          // 多个文件，打开查看提交对话框
          this.viewSubmission(task);
        }
      } else {
        this.$modal.msgWarning('没有可下载的文件');
      }
    },

    /** 获取提交状态文字 */
    getSubmissionStatusText(status) {
      const statusMap = {
        0: '未提交',
        1: '已提交',
        2: '已批改',
        3: '已退回'
      };
      return statusMap[status] || '未知';
    },

    /** 获取提交状态标签类型 */
    getSubmissionStatusType(status) {
      const typeMap = {
        0: 'info',
        1: 'warning',
        2: 'success',
        3: 'danger'
      };
      return typeMap[status] || 'info';
    },

    /** 解析文件路径（多文件用逗号分隔） */
    parseFilePaths(filePath) {
      if (!filePath) return [];
      return filePath.split(',').filter(p => p.trim());
    },

    /** 获取文件名 */
    getFileName(filePath) {
      if (!filePath) return '';
      const parts = filePath.split('/');
      return parts[parts.length - 1];
    },

    /** 获取文件图标 */
    getFileIcon(filePath) {
      const ext = filePath.split('.').pop().toLowerCase();
      const iconMap = {
        'pdf': 'el-icon-document',
        'doc': 'el-icon-document',
        'docx': 'el-icon-document',
        'xls': 'el-icon-s-grid',
        'xlsx': 'el-icon-s-grid',
        'ppt': 'el-icon-data-board',
        'pptx': 'el-icon-data-board',
        'jpg': 'el-icon-picture',
        'jpeg': 'el-icon-picture',
        'png': 'el-icon-picture',
        'gif': 'el-icon-picture',
        'mp4': 'el-icon-video-camera',
        'mp3': 'el-icon-headset',
        'zip': 'el-icon-files',
        'rar': 'el-icon-files',
        'txt': 'el-icon-notebook-2'
      };
      return iconMap[ext] || 'el-icon-document';
    },

    /** 判断文件是否可预览 */
    canPreviewFile(filePath) {
      const ext = filePath.split('.').pop().toLowerCase();
      const previewableExts = ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'mp4', 'webm', 'mp3', 'wav', 'txt', 'md', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'];
      return previewableExts.includes(ext);
    },

    /** 显示内嵌预览 */
    showInlinePreview(filePath) {
      const ext = filePath.split('.').pop().toLowerCase();
      const fullUrl = this.buildFileUrl(filePath);
      console.log('内嵌预览 - 文件路径:', filePath);
      console.log('内嵌预览 - 完整URL:', fullUrl);
      console.log('内嵌预览 - 扩展名:', ext);

      this.inlinePreviewFile = filePath;
      this.inlinePreviewUrl = fullUrl;
      this.inlinePreviewText = '';

      // 判断文件类型
      if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].includes(ext)) {
        this.inlinePreviewType = 'image';
      } else if (ext === 'pdf') {
        this.inlinePreviewType = 'pdf';
      } else if (['mp4', 'webm', 'ogg', 'mov'].includes(ext)) {
        this.inlinePreviewType = 'video';
      } else if (['mp3', 'wav', 'ogg', 'aac'].includes(ext)) {
        this.inlinePreviewType = 'audio';
      } else if (['txt', 'md', 'json', 'xml', 'html', 'css', 'js'].includes(ext)) {
        this.inlinePreviewType = 'text';
        // 加载文本内容
        fetch(fullUrl)
          .then(response => response.text())
          .then(text => {
            this.inlinePreviewText = text;
          })
          .catch(() => {
            this.inlinePreviewText = '文本内容加载失败';
          });
      } else if (['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].includes(ext)) {
        this.inlinePreviewType = 'office';
      } else {
        this.inlinePreviewType = 'unsupported';
      }
    },

    /** 关闭内嵌预览 */
    closeInlinePreview() {
      this.inlinePreviewFile = null;
      this.inlinePreviewType = '';
      this.inlinePreviewUrl = '';
      this.inlinePreviewText = '';
    },

    /** 构建完整的文件URL */
    buildFileUrl(filePath) {
      if (!filePath) return '';
      // 如果已经是完整URL，直接返回
      if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
        return filePath;
      }
      // 若依的静态资源访问前缀是 /profile
      // 如果路径不是以 /profile 开头，需要添加
      let path = filePath;
      if (!path.startsWith('/profile') && !path.startsWith('profile')) {
        path = '/profile' + (path.startsWith('/') ? '' : '/') + path;
      }
      return this.backendHost + path;
    },

    /** 预览提交的文件 */
    previewSubmissionFile(filePath) {
      const fullUrl = this.buildFileUrl(filePath);
      console.log('预览文件URL:', fullUrl);
      console.log('原始文件路径:', filePath);
      const ext = filePath.split('.').pop().toLowerCase();
      console.log('文件扩展名:', ext);

      // 重置预览状态
      this.previewLoading = false;
      this.textContent = '';
      this.officePreviewFailed = false;

      // 图片
      if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].includes(ext)) {
        this.previewType = 'image';
        this.previewUrl = fullUrl;
        this.previewTitle = '图片预览';
        this.previewWidth = '60%';
        this.previewOpen = true;
        return;
      }
      // PDF
      if (ext === 'pdf') {
        this.previewType = 'pdf';
        this.previewUrl = fullUrl;
        this.previewTitle = 'PDF预览';
        this.previewWidth = '90%';
        this.previewOpen = true;
        return;
      }
      // Office 文档
      if (['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].includes(ext)) {
        this.previewType = 'office';
        this.previewUrl = 'https://view.officeapps.live.com/op/embed.aspx?src=' + encodeURIComponent(fullUrl);
        this.previewTitle = 'Office 文档预览';
        this.previewWidth = '90%';
        this.officePreviewNote = '如果预览失败，请下载文件后查看';
        this.previewOpen = true;
        return;
      }
      // 视频
      if (['mp4', 'webm', 'ogg', 'mov'].includes(ext)) {
        this.previewType = 'video';
        this.previewUrl = fullUrl;
        this.previewTitle = '视频预览';
        this.previewWidth = '80%';
        this.previewOpen = true;
        return;
      }
      // 音频
      if (['mp3', 'wav', 'ogg', 'aac'].includes(ext)) {
        this.previewType = 'audio';
        this.previewUrl = fullUrl;
        this.previewTitle = '音频预览';
        this.previewWidth = '50%';
        this.previewOpen = true;
        return;
      }
      // 文本
      if (['txt', 'md', 'json', 'xml', 'html', 'css', 'js', 'java', 'py', 'c', 'cpp', 'h'].includes(ext)) {
        this.previewType = 'text';
        this.previewUrl = fullUrl;
        this.previewTitle = '文本预览';
        this.previewWidth = '70%';
        this.loadTextContent(fullUrl);
        this.previewOpen = true;
        return;
      }
      // 其他文件：直接在新窗口打开尝试预览
      this.$confirm('该文件类型不支持在线预览，是否直接打开/下载？', '提示', {
        confirmButtonText: '打开',
        cancelButtonText: '取消',
        type: 'info'
      }).then(() => {
        window.open(fullUrl, '_blank');
      }).catch(() => {});
    },

    /** 下载提交的文件 */
    downloadSubmissionFile(filePath) {
      const fullUrl = this.buildFileUrl(filePath);
      console.log('下载文件URL:', fullUrl);
      const link = document.createElement('a');
      link.href = fullUrl;
      link.download = this.getFileName(filePath);
      link.target = '_blank';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    },

    /** 解析答案内容 */
    parseAnswerContent(content) {
      if (!content) {
        return [];
      }

      try {
        let answers = [];

        if (typeof content === 'string') {
          let trimmedContent = content.trim();
          if (!trimmedContent) {
            return [];
          }

          // 移除可能的 BOM 字符
          if (trimmedContent.charCodeAt(0) === 0xFEFF) {
            trimmedContent = trimmedContent.slice(1);
          }

          console.log('开始解析答题内容:', trimmedContent);

          // 检查是否是特殊格式（如：80299:A,80332:11,80337:111 或 80299:A;80332:11;80337:111）
          if (!trimmedContent.startsWith('[') && !trimmedContent.startsWith('{')) {
            // 解析格式：questionId:answer,questionId:answer,... 或 questionId:answer;questionId:answer;...
            // 先尝试用分号分割，如果只有一个元素，再尝试用逗号分割
            let pairs = trimmedContent.split(';');
            if (pairs.length === 1) {
              pairs = trimmedContent.split(',');
            }
            console.log('分割后的答案对:', pairs);

            answers = pairs.map(pair => {
              const [questionId, answer] = pair.split(':');
              const parsed = {
                questionId: parseInt(questionId.trim()),
                answer: answer ? answer.trim() : ''
              };
              console.log('解析答案对:', pair, '=>', parsed);
              return parsed;
            }).filter(item => item.questionId && item.answer);

            console.log('过滤后的答案数组:', answers);
          } else {
            // JSON 格式
            const firstBracket = trimmedContent.indexOf('[');
            const lastBracket = trimmedContent.lastIndexOf(']');

            if (firstBracket !== -1 && lastBracket !== -1 && lastBracket > firstBracket) {
              trimmedContent = trimmedContent.substring(firstBracket, lastBracket + 1);
            }

            answers = JSON.parse(trimmedContent);
          }
        } else if (Array.isArray(content)) {
          answers = content;
        } else if (typeof content === 'object') {
          answers = [content];
        } else {
          return [];
        }

        // 确保 answers 是数组
        if (!Array.isArray(answers)) {
          return [];
        }

        console.log('题目列表:', this.currentSubmissionQuestions);

        // 将答案与题目信息关联
        const result = answers.map((answerItem) => {
          const questionId = answerItem.questionId || answerItem.question_id;
          const question = this.currentSubmissionQuestions.find(q => q.questionId === questionId);

          console.log(`匹配题目 ID ${questionId}:`, question ? '找到' : '未找到', question);

          return {
            questionId: questionId,
            answer: answerItem.answer,
            score: answerItem.score,
            question: question || null
          };
        });

        console.log('最终结果:', result);
        return result;
      } catch (error) {
        console.error('解析答案内容失败:', error.message, error);
        return [];
      }
    },

    /** 格式化答案显示 */
    formatAnswer(answer) {
      if (!answer) return '';
      if (typeof answer === 'string') {
        // 判断题特殊处理
        if (answer === 'A') return '正确';
        if (answer === 'B') return '错误';
        return answer;
      }
      if (Array.isArray(answer)) {
        return answer.join(', ');
      }
      return String(answer);
    },

    /** 获取题目类型名称 */
    getQuestionTypeName(type) {
      const typeMap = {
        'single': '单选题',
        'multiple': '多选题',
        'true_false': '判断题',
        'short': '简答题',
        'code': '编程题'
      };
      return typeMap[type] || '未知类型';
    },

    /** 获取题目类型颜色 */
    getQuestionTypeColor(type) {
      const colorMap = {
        'single': 'primary',
        'multiple': 'success',
        'true_false': 'warning',
        'short': 'info',
        'code': 'danger'
      };
      return colorMap[type] || 'info';
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
        background: linear-gradient(90deg, #E6A23C 0%, #F5C06A 100%);
      }

      &.task-pending {
        background: linear-gradient(90deg, #909399 0%, #b3b3b3 100%);
      }

      &.task-expired {
        background: linear-gradient(90deg, #F56C6C 0%, #f78989 100%);
      }

      &.task-submitted {
        background: linear-gradient(90deg, #67C23A 0%, #85CE61 100%);
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
          background: #fdf6ec;
          color: #E6A23C;
        }

        &.status-task-pending {
          background: #f5f5f5;
          color: #909399;
        }

        &.status-task-expired {
          background: #fef0f0;
          color: #F56C6C;
        }

        &.status-task-submitted {
          background: #f0f9eb;
          color: #67C23A;
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
      display: flex;
      gap: 8px;
      flex-wrap: wrap;

      .el-button {
        flex: 1;
        min-width: 80px;
        border-radius: 8px;
        font-weight: 500;
        transition: all 0.3s;

        i {
          margin-right: 4px;
        }

        &:hover {
          transform: translateY(-2px);
        }
      }
    }
  }
}

/* ==================== 提交作业对话框样式 ==================== */
.assignment-dialog {
  ::v-deep .el-dialog__header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
      background: linear-gradient(135deg, #f8f9ff 0%, #eff6ff 100%);
      border-radius: 12px;
      padding: 20px;
      margin-bottom: 24px;
      border: 1px solid rgba(102, 126, 234, 0.2);

      .info-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
        padding-bottom: 12px;
        border-bottom: 1px solid rgba(102, 126, 234, 0.15);

        .info-title {
          margin: 0;
          font-size: 18px;
          font-weight: 600;
          color: #303133;
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
              color: #667eea;
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
            color: #667eea;
          }
        }

        .remark-textarea {
          ::v-deep textarea {
            border-radius: 8px;
            border-color: #dcdfe6;
            transition: all 0.3s;

            &:focus {
              border-color: #667eea;
              box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.1);
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
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border: none;

        &:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }
      }
    }
  }
}

/* 预览对话框样式 */
.preview-dialog {
  ::v-deep .el-dialog__body {
    padding: 10px 20px;
  }
}

.preview-container {
  min-height: 200px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.image-preview, .pdf-preview, .office-preview, .video-preview, .audio-preview, .text-preview {
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.office-preview {
  .office-download-box {
    text-align: center;
    padding: 60px 40px;
    background: linear-gradient(135deg, #f5f7fa 0%, #e4e7ed 100%);
    border-radius: 12px;
    border: 2px dashed #dcdfe6;
    max-width: 500px;
    margin: 0 auto;

    .office-icon {
      width: 100px;
      height: 100px;
      margin: 0 auto;
      background: #fff;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }
  }
}

/* Word 预览样式 */
.word-preview {
  width: 100%;

  .office-toolbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 15px;
    background: #f5f7fa;
    border-bottom: 1px solid #e4e7ed;
    border-radius: 4px 4px 0 0;

    span {
      font-weight: 500;
      color: #303133;

      i {
        margin-right: 8px;
        color: #409EFF;
      }
    }
  }

  .word-preview-container {
    width: 100%;
    min-height: 400px;
    max-height: 70vh;
    overflow: auto;
    background: #fff;
    border: 1px solid #e4e7ed;
    border-top: none;
    padding: 20px;

    ::v-deep .docx-preview {
      max-width: 100%;
    }

    .office-load-error {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 60px;
      color: #909399;

      i {
        font-size: 48px;
        color: #F56C6C;
        margin-bottom: 15px;
      }

      p {
        margin-bottom: 15px;
      }
    }
  }
}

/* Excel 预览样式 */
.excel-preview {
  width: 100%;

  .office-toolbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 15px;
    background: #f5f7fa;
    border-bottom: 1px solid #e4e7ed;
    border-radius: 4px 4px 0 0;
    flex-wrap: wrap;
    gap: 10px;

    span {
      font-weight: 500;
      color: #303133;

      i {
        margin-right: 8px;
        color: #67C23A;
      }
    }

    .excel-sheet-tabs {
      display: flex;
      gap: 5px;
      flex-wrap: wrap;
    }
  }

  .excel-preview-container {
    width: 100%;
    min-height: 400px;
    max-height: 70vh;
    overflow: auto;
    background: #fff;
    border: 1px solid #e4e7ed;
    border-top: none;

    .office-load-error {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 60px;
      color: #909399;

      i {
        font-size: 48px;
        color: #F56C6C;
        margin-bottom: 15px;
      }

      p {
        margin-bottom: 15px;
      }
    }

    .excel-table-wrapper {
      padding: 10px;

      ::v-deep table {
        border-collapse: collapse;
        width: 100%;
        font-size: 13px;

        td, th {
          border: 1px solid #e4e7ed;
          padding: 8px 12px;
          text-align: left;
          white-space: nowrap;
        }

        th {
          background: #f5f7fa;
          font-weight: 600;
          color: #303133;
        }

        tr:nth-child(even) {
          background: #fafafa;
        }

        tr:hover {
          background: #f0f9ff;
        }
      }
    }
  }
}

.text-preview {
  .text-content {
    width: 100%;
    max-height: 600px;
    overflow: auto;
    background-color: #f5f7fa;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
    padding: 15px;

    pre {
      margin: 0;
      white-space: pre-wrap;
      word-wrap: break-word;
      font-family: 'Courier New', Courier, monospace;
      font-size: 14px;
      line-height: 1.6;
      color: #303133;
    }
  }

  .text-loading {
    text-align: center;
    padding: 40px;
    color: #909399;

    i {
      font-size: 32px;
      margin-bottom: 10px;
    }
  }
}

.unsupported-preview {
  text-align: center;
  padding: 40px;
  color: #909399;

  p {
    margin: 20px 0;
    font-size: 16px;
  }
}

.preview-error-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(255, 255, 255, 0.95);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

/* ==================== 查看提交对话框样式 ==================== */
.submission-dialog {
  ::v-deep .el-dialog__header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 16px 20px;
    border-radius: 4px 4px 0 0;

    .el-dialog__title {
      color: #fff;
      font-weight: 600;
    }

    .el-dialog__headerbtn .el-dialog__close {
      color: #fff;
    }
  }
}

.submission-content {
  min-height: 200px;

  .submission-info {
    margin-bottom: 20px;

    h3 {
      font-size: 18px;
      font-weight: 600;
      color: #303133;
      margin: 0 0 12px 0;
    }

    .info-tags {
      display: flex;
      gap: 8px;
    }
  }

  .submission-meta {
    margin-bottom: 20px;

    .score-text {
      font-weight: 600;
      color: #67C23A;
      font-size: 16px;
    }

    .pending-text {
      color: #909399;
    }
  }

  .submission-files {
    h4 {
      font-size: 15px;
      font-weight: 600;
      color: #303133;
      margin: 0 0 12px 0;

      i {
        margin-right: 6px;
      }
    }

    .file-list {
      background: #f8f9fa;
      border-radius: 8px;
      padding: 12px;
    }

    .file-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 10px 12px;
      background: #fff;
      border-radius: 6px;
      margin-bottom: 8px;
      border: 1px solid #ebeef5;

      &:last-child {
        margin-bottom: 0;
      }

      .file-info {
        display: flex;
        align-items: center;
        gap: 10px;

        i {
          font-size: 20px;
          color: #409EFF;
        }

        .file-name {
          font-size: 14px;
          color: #303133;
          word-break: break-all;
        }
      }

      .file-actions {
        display: flex;
        gap: 8px;
        flex-shrink: 0;
      }
    }

    .submission-remark {
      margin-top: 16px;

      h4 {
        margin-bottom: 8px;
      }

      p {
        background: #f8f9fa;
        padding: 12px;
        border-radius: 6px;
        color: #606266;
        margin: 0;
        line-height: 1.6;
      }
    }

    .inline-preview-area {
      margin-top: 16px;
      border: 1px solid #e4e7ed;
      border-radius: 8px;
      overflow: hidden;

      .inline-preview-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 16px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: #fff;

        span {
          font-weight: 500;

          i {
            margin-right: 6px;
          }
        }

        .el-button--text {
          color: #fff;
          padding: 0;

          &:hover {
            color: rgba(255, 255, 255, 0.8);
          }
        }
      }

      .inline-preview-content {
        padding: 16px;
        background: #fafafa;
        min-height: 200px;
        max-height: 500px;
        overflow: auto;
        display: flex;
        justify-content: center;
        align-items: flex-start;

        .el-image {
          max-width: 100%;
        }

        iframe {
          border: 1px solid #ddd;
          border-radius: 4px;
        }

        video {
          max-width: 100%;
          border-radius: 4px;
        }

        audio {
          width: 100%;
        }

        .text-preview-content {
          width: 100%;
          margin: 0;
          padding: 16px;
          background: #fff;
          border: 1px solid #e4e7ed;
          border-radius: 4px;
          white-space: pre-wrap;
          word-break: break-all;
          font-family: 'Consolas', 'Monaco', monospace;
          font-size: 13px;
          line-height: 1.6;
          color: #303133;
          max-height: 400px;
          overflow: auto;
        }

        .office-preview-tip {
          width: 100%;
          text-align: center;
          padding: 40px 20px;
        }

        .image-error {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          padding: 40px;
          color: #909399;

          i {
            font-size: 48px;
            margin-bottom: 10px;
          }
        }
      }
    }
  }

  .submission-answers {
    h4 {
      font-size: 15px;
      font-weight: 600;
      color: #303133;
      margin: 0 0 12px 0;

      i {
        margin-right: 6px;
      }
    }

    .answers-list {
      max-height: 600px;
      overflow-y: auto;
    }

    .answer-item-card {
      background: #fff;
      border: 1px solid #e4e7ed;
      border-radius: 8px;
      padding: 16px;
      margin-bottom: 16px;
      transition: all 0.3s;

      &:hover {
        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
      }

      &:last-child {
        margin-bottom: 0;
      }

      .answer-item-header {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 12px;
        padding-bottom: 12px;
        border-bottom: 1px solid #ebeef5;

        .question-number {
          font-size: 15px;
          font-weight: 600;
          color: #409eff;
        }

        .question-score {
          margin-left: auto;
          color: #f56c6c;
          font-weight: 600;
          font-size: 14px;
        }
      }

      .answer-item-content {
        .question-title-text {
          font-size: 14px;
          color: #303133;
          line-height: 1.8;
          margin-bottom: 12px;

          strong {
            color: #606266;
          }
        }

        .question-options-display {
          background: #f8f9fa;
          border-radius: 6px;
          padding: 12px;
          margin-bottom: 12px;

          .option-item {
            padding: 6px 0;
            font-size: 14px;
            color: #606266;
            line-height: 1.6;

            .option-label {
              font-weight: 600;
              color: #409eff;
              margin-right: 8px;
            }

            .option-text {
              color: #303133;
            }
          }
        }

        .answer-row {
          display: flex;
          align-items: baseline;
          margin-bottom: 10px;
          font-size: 14px;

          .answer-label {
            font-weight: 600;
            color: #606266;
            min-width: 80px;
            flex-shrink: 0;
          }

          .answer-value {
            flex: 1;
            padding: 4px 12px;
            border-radius: 4px;

            &.user-answer {
              background: #e8f4ff;
              color: #409eff;
              font-weight: 500;
            }
          }
        }
      }
    }

  }
}
</style>
