<template>
  <div class="app-container assignment-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="page-title-wrapper">
        <div class="page-icon">
          <i class="el-icon-document-checked"></i>
        </div>
        <div class="page-text">
          <h2 class="page-title">📝 我的作业与考试</h2>
          <p class="page-subtitle">按时完成作业和考试，掌握学习进度，提升学习效果</p>
        </div>
      </div>
      <div class="page-extra">
        <el-button type="text" @click="viewMode = 'card'" :class="{ 'active-view': viewMode === 'card' }">
          <i class="el-icon-menu"></i> 卡片视图
        </el-button>
        <el-button type="text" @click="viewMode = 'timeline'" :class="{ 'active-view': viewMode === 'timeline' }">
          <i class="el-icon-time"></i> 时间轴
        </el-button>
        <el-button type="text" @click="viewMode = 'table'" :class="{ 'active-view': viewMode === 'table' }">
          <i class="el-icon-s-grid"></i> 列表视图
        </el-button>
        <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
      </div>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card stat-card-blue">
          <div class="stat-icon">
            <i class="el-icon-document"></i>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ total }}</div>
            <div class="stat-label">作业总数</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card stat-card-green">
          <div class="stat-icon">
            <i class="el-icon-circle-check"></i>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ submittedCount }}</div>
            <div class="stat-label">已提交</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card stat-card-orange">
          <div class="stat-icon">
            <i class="el-icon-warning"></i>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ pendingCount }}</div>
            <div class="stat-label">待提交</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card stat-card-red">
          <div class="stat-icon">
            <i class="el-icon-close"></i>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ expiredCount }}</div>
            <div class="stat-label">已截止</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 快速筛选 -->
    <el-card class="filter-card" shadow="never">
      <div class="filter-section">
        <span class="filter-label">状态筛选：</span>
        <el-tag
          :type="selectedPhase === 'all' ? 'primary' : 'info'"
          @click.native="filterByPhase('all')"
          class="filter-tag"
        >全部</el-tag>
        <el-tag
          :type="selectedPhase === 'ongoing' ? 'success' : 'info'"
          @click.native="filterByPhase('ongoing')"
          class="filter-tag"
        >进行中</el-tag>
        <el-tag
          :type="selectedPhase === 'upcoming' ? 'info' : 'info'"
          @click.native="filterByPhase('upcoming')"
          class="filter-tag"
        >未开始</el-tag>
        <el-tag
          :type="selectedPhase === 'expired' ? 'danger' : 'info'"
          @click.native="filterByPhase('expired')"
          class="filter-tag"
        >已截止</el-tag>
      </div>
      <div class="filter-section">
        <span class="filter-label">类型筛选：</span>
        <el-tag
          :type="selectedMode === 'all' ? 'primary' : 'info'"
          @click.native="filterByMode('all')"
          class="filter-tag"
        >全部</el-tag>
        <el-tag
          :type="selectedMode === 'question' ? 'warning' : 'info'"
          @click.native="filterByMode('question')"
          class="filter-tag"
        >答题型</el-tag>
        <el-tag
          :type="selectedMode === 'file' ? 'primary' : 'info'"
          @click.native="filterByMode('file')"
          class="filter-tag"
        >上传型</el-tag>
      </div>
    </el-card>

    <!-- 搜索卡片 -->
    <el-card class="search-card" shadow="never" v-show="showSearch">
      <el-form
        :model="queryParams"
        ref="queryForm"
        size="small"
        :inline="true"
        label-width="110px"
        class="search-form"
      >
        <el-form-item label="作业或考试标题" prop="title">
          <el-input
            v-model="queryParams.title"
            placeholder="请输入作业或考试标题"
            clearable
            @keyup.enter.native="handleQuery"
          />
        </el-form-item>
        <el-form-item label="课程编号" prop="courseId">
          <el-input
            v-model="queryParams.courseId"
            placeholder="请输入课程编号"
            clearable
            @keyup.enter.native="handleQuery"
          />
        </el-form-item>
        <el-form-item label="发布者 user.id" prop="publisherUserId">
          <el-input
            v-model="queryParams.publisherUserId"
            placeholder="请输入发布者 user.id"
            clearable
            @keyup.enter.native="handleQuery"
          />
        </el-form-item>
        <el-form-item label="开始时间" prop="startTime">
          <el-date-picker
            clearable
            v-model="queryParams.startTime"
            type="date"
            value-format="yyyy-MM-dd"
            placeholder="请选择开始时间"
          >
          </el-date-picker>
        </el-form-item>
        <el-form-item label="结束时间" prop="endTime">
          <el-date-picker
            clearable
            v-model="queryParams.endTime"
            type="date"
            value-format="yyyy-MM-dd"
            placeholder="请选择结束时间"
          >
          </el-date-picker>
        </el-form-item>
        
        <el-form-item class="search-actions">
          <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 卡片视图 -->
    <div v-if="viewMode === 'card'" v-loading="loading" class="card-view">
      <el-row :gutter="16">
        <el-col :xs="24" :sm="12" :lg="8" v-for="assignment in filteredAssignmentList" :key="assignment.id">
          <div class="assignment-card" :class="getCardClass(assignment)">
            <div class="assignment-card-header">
              <div class="header-left">
                <el-tag size="medium" :type="assignment.mode === 'question' ? 'warning' : 'primary'">
                  {{ assignment.mode === 'question' ? '📝 答题型' : '📎 上传型' }}
                </el-tag>
                <el-tag size="medium" :type="getAssignmentPhaseType(assignment)">
                  {{ getAssignmentPhaseText(assignment) }}
                </el-tag>
              </div>
              <el-tag size="medium" :type="isSubmitted(assignment) ? 'success' : 'info'">
                {{ isSubmitted(assignment) ? '✓ 已提交' : '待提交' }}
              </el-tag>
            </div>
            <div class="assignment-card-body">
              <h3 class="assignment-title">{{ assignment.title }}</h3>
              <div class="assignment-meta">
                <div class="meta-row">
                  <span class="meta-item">
                    <i class="el-icon-folder-opened"></i>
                    课程：{{ assignment.courseId }}
                  </span>
                  <span class="meta-item">
                    <i class="el-icon-user"></i>
                    发布者：{{ assignment.publisherUserId }}
                  </span>
                </div>
                <div class="meta-row">
                  <span class="meta-item">
                    <i class="el-icon-time"></i>
                    开始：{{ parseTime(assignment.startTime, '{y}-{m}-{d}') }}
                  </span>
                </div>
                <div class="meta-row deadline-row">
                  <span class="meta-item deadline-item">
                    <i class="el-icon-alarm-clock"></i>
                    截止：{{ parseTime(assignment.endTime, '{y}-{m}-{d}') }}
                  </span>
                  <span v-if="!isExpired(assignment)" class="countdown">
                    {{ getCountdown(assignment) }}
                  </span>
                </div>
              </div>
            </div>
            <div class="assignment-card-footer">
              <el-button
                type="primary"
                size="small"
                :disabled="isExpired(assignment)"
                @click="openSubmitDialog(assignment)"
                class="submit-btn"
              >
                <i :class="assignment.mode === 'question' ? 'el-icon-edit' : (isSubmitted(assignment) ? 'el-icon-refresh' : 'el-icon-upload')"></i>
                {{ assignment.mode === 'question' ? '开始答题' : (isSubmitted(assignment) ? '重新提交' : '提交作业') }}
              </el-button>
            </div>
          </div>
        </el-col>
      </el-row>
      <el-empty v-if="!loading && filteredAssignmentList.length === 0" description="暂无作业数据"></el-empty>

      <!-- 分页组件 -->
      <div class="pagination-wrapper">
        <pagination
          v-show="total>0"
          :total="total"
          :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize"
          @pagination="getList"
        />
      </div>
    </div>

    <!-- 时间轴视图 -->
    <div v-else-if="viewMode === 'timeline'" v-loading="loading" class="timeline-view">
      <el-timeline>
        <el-timeline-item
          v-for="assignment in filteredAssignmentList"
          :key="assignment.id"
          :timestamp="parseTime(assignment.endTime, '{y}-{m}-{d} {h}:{i}')"
          placement="top"
          :type="getTimelineType(assignment)"
          :icon="getTimelineIcon(assignment)"
        >
          <el-card class="timeline-card">
            <div class="timeline-card-header">
              <h3>{{ assignment.title }}</h3>
              <div class="timeline-tags">
                <el-tag size="small" :type="assignment.mode === 'question' ? 'warning' : 'primary'">
                  {{ assignment.mode === 'question' ? '答题型' : '上传型' }}
                </el-tag>
                <el-tag size="small" :type="getAssignmentPhaseType(assignment)">
                  {{ getAssignmentPhaseText(assignment) }}
                </el-tag>
                <el-tag size="small" :type="isSubmitted(assignment) ? 'success' : 'info'">
                  {{ isSubmitted(assignment) ? '已提交' : '未提交' }}
                </el-tag>
              </div>
            </div>
            <div class="timeline-card-body">
              <p class="timeline-meta">
                <i class="el-icon-folder-opened"></i> 课程：{{ assignment.courseId }} |
                <i class="el-icon-user"></i> 发布者：{{ assignment.publisherUserId }}
              </p>
              <p class="timeline-time">
                <i class="el-icon-time"></i> 开始时间：{{ parseTime(assignment.startTime, '{y}-{m}-{d}') }}
              </p>
              <p class="timeline-deadline" :class="{ 'expired': isExpired(assignment) }">
                <i class="el-icon-alarm-clock"></i> 截止时间：{{ parseTime(assignment.endTime, '{y}-{m}-{d}') }}
                <span v-if="!isExpired(assignment)" class="countdown-inline">（{{ getCountdown(assignment) }}）</span>
              </p>
            </div>
            <div class="timeline-card-footer">
              <el-button
                type="primary"
                size="small"
                :disabled="isExpired(assignment)"
                @click="openSubmitDialog(assignment)"
              >
                {{ assignment.mode === 'question' ? '开始答题' : (isSubmitted(assignment) ? '重新提交' : '提交作业') }}
              </el-button>
            </div>
          </el-card>
        </el-timeline-item>
      </el-timeline>
      <el-empty v-if="!loading && filteredAssignmentList.length === 0" description="暂无作业数据"></el-empty>

      <!-- 分页组件 -->
      <div class="pagination-wrapper">
        <pagination
          v-show="total>0"
          :total="total"
          :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize"
          @pagination="getList"
        />
      </div>
    </div>

    <!-- 列表视图 -->
    <el-card v-else-if="viewMode === 'table'" class="content-card" shadow="always">
      <el-table
        v-loading="loading"
        :data="filteredAssignmentList"
        @selection-change="handleSelectionChange"
        border
        class="assignment-table"
      >
        <el-table-column label="作业或考试标题" align="left" prop="title" min-width="260" show-overflow-tooltip />
        <el-table-column label="课程编号" align="center" prop="courseId" width="120" />
        <el-table-column label="发布者" align="center" prop="publisherUserId" width="120" />
        <el-table-column label="开始时间" align="center" prop="startTime" width="150">
          <template slot-scope="scope">
            <span>{{ parseTime(scope.row.startTime, '{y}-{m}-{d}') }}</span>
          </template>
        </el-table-column>
        <el-table-column label="结束时间" align="center" prop="endTime" width="150">
          <template slot-scope="scope">
            <span>{{ parseTime(scope.row.endTime, '{y}-{m}-{d}') }}</span>
          </template>
        </el-table-column>
        <el-table-column label="发布状态" align="center" prop="status" width="110">
          <template slot-scope="scope">
            <el-tag
              size="mini"
              :type="Number(scope.row.status) === 1 ? 'success' : 'info'"
            >{{ Number(scope.row.status) === 1 ? '已发布' : '未发布' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="作业模式" align="center" prop="mode" width="120">
          <template slot-scope="scope">
            <el-tag size="mini" type="warning" v-if="scope.row.mode === 'question'">答题型</el-tag>
            <el-tag size="mini" type="primary" v-else-if="scope.row.mode === 'file'">上传型</el-tag>
            <el-tag size="mini" type="info" v-else>{{ scope.row.mode }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="当前状态" align="center" width="110">
          <template slot-scope="scope">
            <el-tag size="mini" :type="getAssignmentPhaseType(scope.row)">
              {{ getAssignmentPhaseText(scope.row) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="提交状态" align="center" width="110">
          <template slot-scope="scope">
            <el-tag size="mini" :type="isSubmitted(scope.row) ? 'success' : 'info'">
              {{ isSubmitted(scope.row) ? '已提交' : '未提交' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="180">
          <template slot-scope="scope">
            <el-button
              size="mini"
              type="primary"
              :disabled="isExpired(scope.row)"
              @click="openSubmitDialog(scope.row)"
            >{{ scope.row.mode === 'question' ? '开始答题' : (isSubmitted(scope.row) ? '重新提交' : '提交作业') }}</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <pagination
          v-show="total>0"
          :total="total"
          :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize"
          @pagination="getList"
        />
      </div>
    </el-card>

    <!-- 提交作业对话框 -->
    <el-dialog
      :visible.sync="submitDialogVisible"
      width="650px"
      append-to-body
      class="assignment-dialog"
      :close-on-click-modal="false"
    >
      <div slot="title" class="dialog-title-custom">
        <i :class="currentAssignment && currentAssignment.mode === 'question' ? 'el-icon-edit' : 'el-icon-upload'"></i>
        <span>{{ currentAssignment && currentAssignment.mode === 'question' ? '开始答题' : '提交作业' }}</span>
      </div>
      <div v-if="currentAssignment" class="submit-wrapper">
        <!-- 作业信息卡片 -->
        <div class="submit-info-card">
          <div class="info-header">
            <h3 class="info-title">{{ currentAssignment.title }}</h3>
            <el-tag :type="currentAssignment.mode === 'question' ? 'warning' : 'primary'">
              {{ currentAssignment.mode === 'question' ? '📝 答题型' : '📎 上传型' }}
            </el-tag>
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
              <span v-if="!isExpired(currentAssignment)" class="countdown-badge">
                {{ getCountdown(currentAssignment) }}
              </span>
            </div>
            <div v-if="currentAssignment.mode === 'question'" class="meta-item-row">
              <span class="meta-label">
                <i class="el-icon-document"></i>
                题目数量：
              </span>
              <span class="meta-value">{{ assignmentQuestions.length }} 题</span>
            </div>
            <div v-if="currentAssignment.mode === 'question' && currentAssignment.duration" class="meta-item-row">
              <span class="meta-label">
                <i class="el-icon-timer"></i>
                建议用时：
              </span>
              <span class="meta-value">{{ currentAssignment.duration }} 分钟</span>
            </div>
          </div>
        </div>

        <!-- 答题型：显示题目列表 -->
        <div v-if="currentAssignment.mode === 'question'" class="question-list-section" v-loading="questionsLoading">
          <div v-if="assignmentQuestions.length === 0 && !questionsLoading" class="no-questions">
            <el-empty description="暂无题目"></el-empty>
          </div>
          <div v-else class="questions-container">
            <div
              v-for="(item, index) in assignmentQuestions"
              :key="item.questionId"
              class="question-item"
            >
              <div class="question-header">
                <span class="question-number">第 {{ index + 1 }} 题</span>
                <el-tag size="mini" :type="getQuestionTypeTag(item.question.questionType)">
                  {{ getQuestionTypeText(item.question.questionType) }}
                </el-tag>
                <el-tag size="mini" type="info">{{ item.score }} 分</el-tag>
                <el-rate
                  v-model="item.question.difficulty"
                  disabled
                  show-score
                  text-color="#ff9900"
                  score-template="{value}星"
                  class="question-difficulty"
                />
              </div>
              <div class="question-title">
                {{ item.question.title }}
              </div>

              <!-- 单选题 -->
              <div v-if="item.question.questionType === 'single'" class="question-options">
                <el-radio-group v-model="studentAnswers[item.questionId]">
                  <el-radio
                    v-for="option in item.options"
                    :key="option.optionLabel"
                    :label="option.optionLabel"
                    class="option-radio"
                  >
                    <span class="option-label">{{ option.optionLabel }}.</span>
                    <span class="option-text">{{ option.optionText }}</span>
                  </el-radio>
                </el-radio-group>
              </div>

              <!-- 多选题 -->
              <div v-if="item.question.questionType === 'multiple'" class="question-options">
                <el-checkbox-group v-model="studentAnswers[item.questionId]">
                  <el-checkbox
                    v-for="option in item.options"
                    :key="option.optionLabel"
                    :label="option.optionLabel"
                    class="option-checkbox"
                  >
                    <span class="option-label">{{ option.optionLabel }}.</span>
                    <span class="option-text">{{ option.optionText }}</span>
                  </el-checkbox>
                </el-checkbox-group>
              </div>

              <!-- 判断题 -->
              <div v-if="item.question.questionType === 'true_false'" class="question-options">
                <el-radio-group v-model="studentAnswers[item.questionId]">
                  <el-radio
                    v-for="option in item.options"
                    :key="option.optionLabel"
                    :label="option.optionLabel"
                    class="option-radio"
                  >
                    <span class="option-label">{{ option.optionLabel }}.</span>
                    <span class="option-text">{{ option.optionText }}</span>
                  </el-radio>
                </el-radio-group>
              </div>

              <!-- 简答题、填空题、编程题 -->
              <div v-if="['short', 'blank', 'code'].includes(item.question.questionType)" class="question-answer">
                <el-input
                  v-model="studentAnswers[item.questionId]"
                  type="textarea"
                  :rows="item.question.questionType === 'code' ? 10 : 4"
                  :placeholder="getAnswerPlaceholder(item.question.questionType)"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- 上传型：显示文件上传 -->
        <div v-else class="submit-form-section">
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
          v-if="isSubmitted(currentAssignment)"
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
        <el-button type="primary" @click="handleSubmitAssignment" size="medium" :loading="submitting">
          <i class="el-icon-check"></i> {{ currentAssignment && currentAssignment.mode === 'question' ? '提交答案' : '确认提交' }}
        </el-button>
      </div>
    </el-dialog>

    <!-- 添加或修改作业或考试对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="600px" append-to-body class="assignment-dialog">
      <el-form ref="form" :model="form" :rules="rules" label-width="110px" class="dialog-form">
        <el-form-item label="作业或考试标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入作业或考试标题" />
        </el-form-item>
        <el-form-item label="课程编号" prop="courseId">
          <el-input v-model="form.courseId" placeholder="请输入课程编号" />
        </el-form-item>
        <el-form-item label="发布者 user.id" prop="publisherUserId">
          <el-input v-model="form.publisherUserId" placeholder="请输入发布者 user.id" />
        </el-form-item>
        <el-form-item label="任务类型" prop="type">
          <el-input v-model="form.type" placeholder="请输入任务类型" />
        </el-form-item>
        <el-form-item label="作业模式" prop="mode">
          <el-select v-model="form.mode" placeholder="请选择作业模式">
            <el-option label="答题型" value="question" />
            <el-option label="上传型" value="file" />
          </el-select>
        </el-form-item>
        <el-form-item label="发布状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择发布状态">
            <el-option label="未发布" :value="0" />
            <el-option label="已发布" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item label="作业内容" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入内容" />
        </el-form-item>
        <el-form-item label="开始时间" prop="startTime">
          <el-date-picker
            clearable
            v-model="form.startTime"
            type="date"
            value-format="yyyy-MM-dd"
            placeholder="请选择开始时间"
          >
          </el-date-picker>
        </el-form-item>
        <el-form-item label="结束时间" prop="endTime">
          <el-date-picker
            clearable
            v-model="form.endTime"
            type="date"
            value-format="yyyy-MM-dd"
            placeholder="请选择结束时间"
          >
          </el-date-picker>
        </el-form-item>
        <el-form-item label="时间限制" prop="timeLimit">
          <el-input v-model="form.timeLimit" placeholder="请输入时间限制" />
        </el-form-item>
        <el-form-item label="总分" prop="totalScore">
          <el-input v-model="form.totalScore" placeholder="请输入总分" />
        </el-form-item>
        <el-form-item label="任务时长" prop="duration">
          <el-input v-model="form.duration" placeholder="请输入任务时长" />
        </el-form-item>
        <el-form-item label="允许的文件类型" prop="allowedFileTypes">
          <el-input v-model="form.allowedFileTypes" type="textarea" placeholder="请输入内容" />
        </el-form-item>
        <el-form-item label="是否删除" prop="isDeleted">
          <el-input v-model="form.isDeleted" placeholder="请输入是否删除" />
        </el-form-item>
        <el-form-item label="删除时间" prop="deleteTime">
          <el-date-picker
            clearable
            v-model="form.deleteTime"
            type="date"
            value-format="yyyy-MM-dd"
            placeholder="请选择删除时间"
          >
          </el-date-picker>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listAssignment, getAssignment, delAssignment, addAssignment, updateAssignment, getAssignmentQuestions } from "@/api/system/assignment"

export default {
  name: "Assignment",
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
      // 作业或考试表格数据
      assignmentList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 学生提交作业对话框是否显示
      submitDialogVisible: false,
      // 当前选中的作业
      currentAssignment: null,
      // 学生提交表单（仅前端状态）
      studentSubmitForm: {
        files: "",
        remark: ""
      },
      // 已提交作业记录（仅前端状态，用于展示）
      submittedAssignmentMap: {},
      // 答题型作业的题目列表
      assignmentQuestions: [],
      // 题目加载状态
      questionsLoading: false,
      // 学生答案（key: questionId, value: 答案）
      studentAnswers: {},
      // 提交中状态
      submitting: false,
      // 视图模式：card, timeline, table
      viewMode: 'card',
      // 选中的阶段筛选
      selectedPhase: 'all',
      // 选中的模式筛选
      selectedMode: 'all',
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        title: null,
        courseId: null,
        publisherUserId: null,
        type: null,
        description: null,
        startTime: null,
        endTime: null,
        status: null,
        mode: null,
        timeLimit: null,
        totalScore: null,
        duration: null,
        allowedFileTypes: null,
        attachments: null,
        isDeleted: null,
        deleteTime: null
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        title: [
          { required: true, message: "作业或考试标题不能为空", trigger: "blur" }
        ],
        courseId: [
          { required: true, message: "课程编号不能为空", trigger: "blur" }
        ],
        publisherUserId: [
          { required: true, message: "发布者 user.id不能为空", trigger: "blur" }
        ],
        status: [
          { required: true, message: "发布状态：0未发布，1已发布不能为空", trigger: "change" }
        ],
        mode: [
          { required: true, message: "作业模式：question-答题型，file-上传型不能为空", trigger: "blur" }
        ],
        isDeleted: [
          { required: true, message: "是否删除不能为空", trigger: "blur" }
        ],
      }
    }
  },
  computed: {
    // 已提交数量
    submittedCount() {
      return Object.keys(this.submittedAssignmentMap).length
    },
    // 待提交数量
    pendingCount() {
      return this.assignmentList.filter(item =>
        !this.isSubmitted(item) && !this.isExpired(item)
      ).length
    },
    // 已截止数量
    expiredCount() {
      return this.assignmentList.filter(item => this.isExpired(item)).length
    },
    // 过滤后的作业列表
    filteredAssignmentList() {
      let list = this.assignmentList

      // 按阶段筛选
      if (this.selectedPhase !== 'all') {
        if (this.selectedPhase === 'ongoing') {
          list = list.filter(item => {
            const now = new Date()
            const start = item.startTime ? new Date(item.startTime) : null
            const end = item.endTime ? new Date(item.endTime) : null
            return (!start || now >= start) && (!end || now <= end)
          })
        } else if (this.selectedPhase === 'upcoming') {
          list = list.filter(item => {
            const now = new Date()
            const start = item.startTime ? new Date(item.startTime) : null
            return start && now < start
          })
        } else if (this.selectedPhase === 'expired') {
          list = list.filter(item => this.isExpired(item))
        }
      }

      return list
    }
  },
  created() {
    this.getList()
  },
  methods: {
    /** 查询作业或考试列表 */
    getList() {
      this.loading = true
      listAssignment(this.queryParams).then(response => {
        this.assignmentList = response.rows
        this.total = response.total
        this.loading = false
      })
    },
    // 根据作业状态返回卡片样式类
    getCardClass(assignment) {
      if (this.isExpired(assignment)) {
        return 'card-expired'
      }
      if (this.isSubmitted(assignment)) {
        return 'card-submitted'
      }
      return 'card-pending'
    },
    // 获取倒计时文本
    getCountdown(assignment) {
      if (!assignment || !assignment.endTime) return ''
      const now = new Date().getTime()
      const end = new Date(assignment.endTime).getTime()
      const diff = end - now

      if (diff <= 0) return '已截止'

      const days = Math.floor(diff / (1000 * 60 * 60 * 24))
      const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))

      if (days > 0) {
        return `剩余 ${days} 天 ${hours} 小时`
      } else if (hours > 0) {
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
        return `剩余 ${hours} 小时 ${minutes} 分钟`
      } else {
        const minutes = Math.floor(diff / (1000 * 60))
        return `剩余 ${minutes} 分钟`
      }
    },
    // 获取时间轴类型
    getTimelineType(assignment) {
      if (this.isExpired(assignment)) return 'danger'
      if (this.isSubmitted(assignment)) return 'success'
      return 'primary'
    },
    // 获取时间轴图标
    getTimelineIcon(assignment) {
      if (this.isExpired(assignment)) return 'el-icon-close'
      if (this.isSubmitted(assignment)) return 'el-icon-check'
      return 'el-icon-time'
    },
    // 阶段筛选
    filterByPhase(phase) {
      this.selectedPhase = phase
      // 使用计算属性 filteredAssignmentList 进行前端过滤，不需要重新请求后端
    },
    // 模式筛选
    filterByMode(mode) {
      this.selectedMode = mode
      this.queryParams.mode = mode === 'all' ? null : mode
      this.handleQuery()
    },
    // 取消按钮
    cancel() {
      this.open = false
      this.reset()
    },
    // 表单重置
    reset() {
      this.form = {
        id: null,
        title: null,
        courseId: null,
        publisherUserId: null,
        type: null,
        description: null,
        startTime: null,
        endTime: null,
        createTime: null,
        status: null,
        updateTime: null,
        mode: null,
        timeLimit: null,
        totalScore: null,
        duration: null,
        allowedFileTypes: null,
        attachments: null,
        isDeleted: null,
        deleteTime: null
      }
      this.resetForm("form")
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm")
      this.handleQuery()
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset()
      this.open = true
      this.title = "添加作业或考试"
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getAssignment(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = "修改作业或考试"
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateAssignment(this.form).then(response => {
              this.$modal.msgSuccess("修改成功")
              this.open = false
              this.getList()
            })
          } else {
            addAssignment(this.form).then(response => {
              this.$modal.msgSuccess("新增成功")
              this.open = false
              this.getList()
            })
          }
        }
      })
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids
      this.$modal.confirm('是否确认删除作业或考试编号为"' + ids + '"的数据项？').then(function() {
        return delAssignment(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess("删除成功")
      }).catch(() => {})
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('system/assignment/export', {
        ...this.queryParams
      }, `assignment_${new Date().getTime()}.xlsx`)
    },
    // 学生端：打开提交作业对话框
    openSubmitDialog(row) {
      if (!row || !row.id) {
        return
      }
      this.currentAssignment = row
      this.submitForm = {
        files: "",
        remark: ""
      }
      this.studentAnswers = {}
      this.assignmentQuestions = []

      // 如果是答题型作业，加载题目列表
      if (row.mode === 'question') {
        this.loadAssignmentQuestions(row.id)
      }

      this.submitDialogVisible = true
    },
    // 学生端：加载作业的题目列表
    loadAssignmentQuestions(assignmentId) {
      this.questionsLoading = true

      getAssignmentQuestions(assignmentId).then(response => {
        // 处理后端返回的数据
        const rawData = response.data || []
        this.assignmentQuestions = rawData.map(item => {
          // 解析选项字符串 "A:选项内容||B:选项内容||C:选项内容"
          const options = []
          if (item.options) {
            const optionPairs = item.options.split('||')
            optionPairs.forEach(pair => {
              const [label, text] = pair.split(':')
              if (label && text) {
                options.push({
                  optionLabel: label.trim(),
                  optionText: text.trim()
                })
              }
            })
          }

          return {
            assignmentQuestionId: item.assignment_question_id,
            questionId: item.question_id,
            score: item.score,
            sequence: item.sequence,
            question: {
              id: item.question_id,
              title: item.question_title,
              questionType: item.question_type,
              difficulty: item.difficulty,
              correctAnswer: item.correct_answer,
              explanation: item.explanation,
              knowledgePoint: item.knowledge_point
            },
            options: options
          }
        })

        // 初始化学生答案
        this.assignmentQuestions.forEach(item => {
          // 多选题初始化为空数组
          if (item.question.questionType === 'multiple') {
            this.$set(this.studentAnswers, item.questionId, [])
          } else {
            this.$set(this.studentAnswers, item.questionId, '')
          }
        })

        this.questionsLoading = false
      }).catch(error => {
        console.error('加载题目失败:', error)
        this.$modal.msgError("加载题目失败")
        this.questionsLoading = false
      })
    },
    // 学生端：判断作业是否已提交（仅前端状态）
    isSubmitted(row) {
      return row && row.id && !!this.submittedAssignmentMap[row.id]
    },
    // 学生端：判断作业是否已截止
    isExpired(row) {
      if (!row || !row.endTime) {
        return false
      }
      const end = new Date(row.endTime)
      return new Date().getTime() > end.getTime()
    },
    // 学生端：根据时间计算当前阶段文案
    getAssignmentPhaseText(row) {
      if (!row) return "未知"
      const now = new Date()
      const start = row.startTime ? new Date(row.startTime) : null
      const end = row.endTime ? new Date(row.endTime) : null
      if (end && now.getTime() > end.getTime()) {
        return "已截止"
      }
      if (start && now.getTime() < start.getTime()) {
        return "未开始"
      }
      return "进行中"
    },
    // 学生端：根据阶段返回标签类型
    getAssignmentPhaseType(row) {
      const text = this.getAssignmentPhaseText(row)
      if (text === "进行中") {
        return "success"
      }
      if (text === "未开始") {
        return "info"
      }
      return "danger"
    },
    // 学生端：提交作业（演示用，仅前端状态）
    handleSubmitAssignment() {
      // 答题型作业
      if (this.currentAssignment && this.currentAssignment.mode === 'question') {
        // 检查是否所有题目都已作答
        const unansweredCount = this.assignmentQuestions.filter(item => {
          const answer = this.studentAnswers[item.questionId]
          return !answer || (Array.isArray(answer) && answer.length === 0)
        }).length

        if (unansweredCount > 0) {
          this.$modal.confirm(`还有 ${unansweredCount} 道题未作答，确定要提交吗？`).then(() => {
            this.submitAnswers()
          }).catch(() => {})
        } else {
          this.submitAnswers()
        }
      }
      // 上传型作业
      else {
        if (!this.studentSubmitForm.files) {
          this.$modal.msgError("请先上传作业文件")
          return
        }
        if (this.currentAssignment && this.currentAssignment.id != null) {
          this.$set(this.submittedAssignmentMap, this.currentAssignment.id, true)
        }
        this.$modal.msgSuccess("提交成功")
        this.submitDialogVisible = false
      }
    },
    // 学生端：提交答案
    submitAnswers() {
      this.submitting = true

      // 格式化答案数据
      const answers = Object.keys(this.studentAnswers).map(questionId => {
        let answer = this.studentAnswers[questionId]
        // 如果是多选题（数组），转换为逗号分隔的字符串
        if (Array.isArray(answer)) {
          answer = answer.sort().join(',')
        }
        return {
          questionId: parseInt(questionId),
          answer: answer || ''
        }
      })

      console.log('提交答案:', {
        assignmentId: this.currentAssignment.id,
        answers: answers
      })

      // TODO: 调用后端API提交答案
      // submitAssignmentAnswers(this.currentAssignment.id, answers).then(response => {...})

      // 模拟提交
      setTimeout(() => {
        if (this.currentAssignment && this.currentAssignment.id != null) {
          this.$set(this.submittedAssignmentMap, this.currentAssignment.id, true)
        }
        this.$modal.msgSuccess("提交成功！")
        this.submitting = false
        this.submitDialogVisible = false
      }, 1000)
    },
    // 获取题型标签类型
    getQuestionTypeTag(type) {
      const typeMap = {
        'single': 'primary',
        'multiple': 'success',
        'true_false': 'warning',
        'blank': 'info',
        'short': 'info',
        'code': 'danger'
      }
      return typeMap[type] || 'info'
    },
    // 获取题型文本
    getQuestionTypeText(type) {
      const typeMap = {
        'single': '单选题',
        'multiple': '多选题',
        'true_false': '判断题',
        'blank': '填空题',
        'short': '简答题',
        'code': '编程题'
      }
      return typeMap[type] || type
    },
    // 获取答案输入框占位符
    getAnswerPlaceholder(type) {
      const placeholderMap = {
        'short': '请输入您的答案...',
        'blank': '请输入答案...',
        'code': '请输入代码...'
      }
      return placeholderMap[type] || '请输入答案...'
    }
  }
}
</script>

<style scoped>
  .assignment-page {
    background: #f5f7fa;
    min-height: 100vh;
    padding: 20px;
  }

  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;
    background: #ffffff;
    padding: 24px 28px;
    border-radius: 16px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    border: 1px solid #e8eaed;
  }

  .page-title-wrapper {
    display: flex;
    align-items: center;
  }

  .page-icon {
    width: 56px;
    height: 56px;
    border-radius: 14px;
    background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: #f57c00;
    margin-right: 16px;
    font-size: 28px;
    box-shadow: 0 4px 12px rgba(245, 124, 0, 0.15);
  }

  .page-title {
    font-size: 24px;
    font-weight: 700;
    color: #2c3e50;
    margin: 0;
  }

  .page-subtitle {
    margin: 6px 0 0;
    font-size: 14px;
    color: #7c8a9d;
  }

  .page-extra {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .page-extra .el-button--text {
    padding: 8px 16px;
    border-radius: 8px;
    transition: all 0.3s;
    color: #5a6c7d;
    background: #f5f7fa;
  }

  .page-extra .el-button--text:hover {
    background: #fff3e0;
    color: #f57c00;
  }

  .page-extra .el-button--text.active-view {
    background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
    color: #f57c00;
    font-weight: 600;
  }

  /* 统计卡片 */
  .stats-row {
    margin-bottom: 20px;
  }

  .stat-card {
    background: #ffffff;
    border-radius: 16px;
    padding: 24px;
    display: flex;
    align-items: center;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    transition: all 0.3s;
    margin-bottom: 16px;
    border: 1px solid #e8eaed;
  }

  .stat-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  }

  .stat-icon {
    width: 64px;
    height: 64px;
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 30px;
    margin-right: 18px;
  }

  .stat-card-blue {
    border-left: 4px solid #64b5f6;
  }

  .stat-card-blue .stat-icon {
    background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
    color: #1976d2;
  }

  .stat-card-green {
    border-left: 4px solid #81c784;
  }

  .stat-card-green .stat-icon {
    background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
    color: #388e3c;
  }

  .stat-card-orange {
    border-left: 4px solid #ffb74d;
  }

  .stat-card-orange .stat-icon {
    background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
    color: #f57c00;
  }

  .stat-card-red {
    border-left: 4px solid #e57373;
  }

  .stat-card-red .stat-icon {
    background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
    color: #d32f2f;
  }

  .stat-content {
    flex: 1;
  }

  .stat-value {
    font-size: 32px;
    font-weight: 700;
    color: #2c3e50;
    line-height: 1;
    margin-bottom: 8px;
  }

  .stat-label {
    font-size: 14px;
    color: #7c8a9d;
    font-weight: 500;
  }

  /* 筛选卡片 */
  .filter-card {
    border-radius: 16px;
    border: 1px solid #e8eaed;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    margin-bottom: 20px;
    background: #ffffff;
  }

  .filter-section {
    margin-bottom: 12px;
    display: flex;
    align-items: center;
    flex-wrap: wrap;
  }

  .filter-section:last-child {
    margin-bottom: 0;
  }

  .filter-label {
    font-size: 14px;
    font-weight: 600;
    color: #2c3e50;
    margin-right: 12px;
    display: flex;
    align-items: center;
  }

  .filter-label::before {
    content: '🔍';
    margin-right: 6px;
    font-size: 16px;
  }

  .filter-tag {
    margin-right: 8px;
    margin-bottom: 8px;
    cursor: pointer;
    transition: all 0.3s;
    padding: 8px 16px;
    border-radius: 20px;
    border: 1px solid #e0e0e0;
    background: #fafafa;
    user-select: none;
  }

  .filter-tag:hover {
    transform: translateY(-2px);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .filter-tag:active {
    transform: translateY(0);
  }

  /* 搜索卡片 */
  .search-card {
    border-radius: 16px;
    border: 1px solid #e8eaed;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    margin-bottom: 20px;
    background: #ffffff;
  }

  .search-form ::v-deep .el-form-item {
    margin-bottom: 8px;
  }

  .search-actions {
    padding-left: 12px;
  }

  /* 卡片视图 */
  .card-view {
    min-height: 400px;
  }

  .assignment-card {
    background: #ffffff;
    border-radius: 16px;
    padding: 22px;
    margin-bottom: 16px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    transition: all 0.3s;
    border-left: 4px solid transparent;
    border: 1px solid #e8eaed;
  }

  .assignment-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  }

  .assignment-card.card-pending {
    border-left: 4px solid #64b5f6;
    background: linear-gradient(to right, #e3f2fd 0%, #ffffff 10%);
  }

  .assignment-card.card-submitted {
    border-left: 4px solid #81c784;
    background: linear-gradient(to right, #e8f5e9 0%, #ffffff 10%);
  }

  .assignment-card.card-expired {
    border-left: 4px solid #e57373;
    background: linear-gradient(to right, #ffebee 0%, #ffffff 10%);
    opacity: 0.8;
  }

  .assignment-card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
  }

  .header-left {
    display: flex;
    gap: 8px;
  }

  .assignment-card-body {
    margin-bottom: 16px;
  }

  .assignment-title {
    font-size: 18px;
    font-weight: 600;
    color: #2c3e50;
    margin: 0 0 12px 0;
    line-height: 1.6;
  }

  .assignment-meta {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .meta-row {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .meta-item {
    font-size: 13px;
    color: #7c8a9d;
    display: flex;
    align-items: center;
    background: #f5f7fa;
    padding: 4px 10px;
    border-radius: 12px;
  }

  .meta-item i {
    margin-right: 4px;
    color: #ffb74d;
  }

  .deadline-row {
    justify-content: space-between;
  }

  .deadline-item {
    color: #e57373;
    font-weight: 500;
  }

  .countdown {
    font-size: 12px;
    color: #f57c00;
    background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
    padding: 6px 12px;
    border-radius: 12px;
    font-weight: 600;
    border: 1px solid #ffcc80;
  }

  .assignment-card-footer {
    padding-top: 16px;
    border-top: 1px solid #f0f2f5;
    display: flex;
    justify-content: flex-end;
  }

  .submit-btn {
    width: 100%;
  }

  /* 时间轴视图 */
  .timeline-view {
    background: #ffffff;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    min-height: 400px;
    border: 1px solid #e8eaed;
  }

  .timeline-card {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
    border-radius: 12px;
    border: 1px solid #f0f2f5;
  }

  .timeline-card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
  }

  .timeline-card-header h3 {
    font-size: 16px;
    font-weight: 600;
    color: #2c3e50;
    margin: 0;
  }

  .timeline-tags {
    display: flex;
    gap: 8px;
  }

  .timeline-card-body {
    margin-bottom: 12px;
  }

  .timeline-meta,
  .timeline-time {
    font-size: 13px;
    color: #7c8a9d;
    margin: 8px 0;
    background: #f5f7fa;
    padding: 4px 10px;
    border-radius: 12px;
    display: inline-block;
  }

  .timeline-deadline {
    font-size: 13px;
    color: #f56c6c;
    font-weight: 500;
    margin: 8px 0;
  }

  .timeline-deadline.expired {
    color: #909399;
  }

  .countdown-inline {
    color: #f093fb;
    font-weight: 600;
  }

  .timeline-card-footer {
    display: flex;
    justify-content: flex-end;
  }

  /* 列表视图 */
  .content-card {
    border-radius: 16px;
    border: 1px solid #e8eaed;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    background: #ffffff;
  }

  .table-toolbar {
    margin-bottom: 8px;
  }

  .assignment-table {
    margin-top: 4px;
  }

  .assignment-page ::v-deep .el-table {
    border-radius: 12px;
    overflow: hidden;
  }

  .assignment-page ::v-deep .el-table th {
    background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
    color: #f57c00;
    font-weight: 600;
  }

  .assignment-page ::v-deep .el-table td {
    color: #2c3e50;
  }

  .assignment-page ::v-deep .el-table--border::after,
  .assignment-page ::v-deep .el-table--group::after,
  .assignment-page ::v-deep .el-table::before {
    background-color: #e8eaed;
  }

  .pagination-wrapper {
    margin-top: 16px;
    text-align: right;
  }

  /* 对话框样式 */
  .assignment-dialog ::v-deep .el-dialog {
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  }

  .assignment-dialog ::v-deep .el-dialog__header {
    background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
    padding: 20px 24px;
    border-bottom: 1px solid #e8eaed;
  }

  .dialog-title-custom {
    color: #f57c00;
    font-size: 18px;
    font-weight: 600;
    display: flex;
    align-items: center;
  }

  .dialog-title-custom i {
    margin-right: 8px;
    font-size: 20px;
  }

  .assignment-dialog ::v-deep .el-dialog__body {
    padding: 24px;
    background: #fafbfc;
  }

  .submit-wrapper {
    max-height: 60vh;
    overflow-y: auto;
  }

  .submit-info-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
    border: 1px solid #e8eaed;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  }

  .info-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
  }

  .info-title {
    font-size: 18px;
    font-weight: 600;
    color: #2c3e50;
    margin: 0;
  }

  .info-meta {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .meta-item-row {
    display: flex;
    align-items: center;
    font-size: 14px;
  }

  .meta-label {
    color: #7c8a9d;
    display: flex;
    align-items: center;
    min-width: 100px;
  }

  .meta-label i {
    margin-right: 6px;
    color: #ffb74d;
  }

  .meta-value {
    color: #2c3e50;
    font-weight: 500;
  }

  .deadline-meta {
    background: #f5f7fa;
    padding: 8px 12px;
    border-radius: 8px;
    margin-top: 4px;
  }

  .countdown-badge {
    margin-left: 12px;
    background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
    color: #f57c00;
    padding: 6px 12px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    border: 1px solid #ffcc80;
  }

  .submit-form-section {
    background: #ffffff;
    border-radius: 12px;
    padding: 20px;
    border: 1px solid #e8eaed;
    margin-bottom: 16px;
  }

  .form-tip {
    font-size: 12px;
    color: #909399;
    margin-top: 8px;
    display: flex;
    align-items: center;
  }

  .form-tip i {
    margin-right: 4px;
  }

  .remark-textarea ::v-deep .el-textarea__inner {
    border-radius: 8px;
    border: 1px solid #e0e0e0;
    font-size: 14px;
    line-height: 1.6;
    background: #fafbfc;
  }

  .remark-textarea ::v-deep .el-textarea__inner:focus {
    border-color: #ffb74d;
    background: #ffffff;
  }

  .dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    padding-top: 16px;
    border-top: 1px solid #e8eaed;
  }

  .dialog-footer .el-button {
    padding: 10px 24px;
    border-radius: 8px;
    font-weight: 500;
  }

  .dialog-footer .el-button--primary {
    background: linear-gradient(135deg, #ffb74d 0%, #ffa726 100%);
    border: none;
  }

  .dialog-footer .el-button--primary:hover {
    background: linear-gradient(135deg, #ffa726 0%, #ff9800 100%);
  }

  /* 响应式设计 */
  @media (max-width: 768px) {
    .assignment-page {
      padding: 12px;
    }

    .page-header {
      flex-direction: column;
      align-items: flex-start;
    }

    .page-extra {
      margin-top: 12px;
      width: 100%;
      justify-content: space-between;
    }

    .stats-row .el-col {
      margin-bottom: 12px;
    }

    .assignment-card {
      padding: 16px;
    }

    .assignment-title {
      font-size: 16px;
    }

    .timeline-card-header {
      flex-direction: column;
      align-items: flex-start;
    }

    .timeline-tags {
      margin-top: 8px;
    }
  }

  /* 答题区域样式 */
  .question-list-section {
    max-height: 500px;
    overflow-y: auto;
    padding: 10px 0;
  }

  .questions-container {
    padding: 0 10px;
  }

  .question-item {
    background: #f8f9fa;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
    border-left: 4px solid #ffb74d;
  }

  .question-header {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 15px;
    flex-wrap: wrap;
  }

  .question-number {
    font-weight: bold;
    color: #f57c00;
    font-size: 16px;
  }

  .question-difficulty {
    margin-left: auto;
  }

  .question-title {
    font-size: 15px;
    line-height: 1.6;
    color: #2c3e50;
    margin-bottom: 15px;
    font-weight: 500;
  }

  .question-options {
    padding-left: 10px;
  }

  .option-radio,
  .option-checkbox {
    display: flex !important;
    align-items: flex-start;
    margin-bottom: 12px;
    padding: 12px;
    background: white;
    border-radius: 6px;
    border: 1px solid #e0e0e0;
    transition: all 0.3s;
  }

  .option-radio:hover,
  .option-checkbox:hover {
    border-color: #ffb74d;
    background: #fff8f0;
  }

  .option-label {
    font-weight: bold;
    color: #f57c00;
    margin-right: 8px;
    min-width: 25px;
  }

  .option-text {
    flex: 1;
    color: #2c3e50;
    line-height: 1.5;
  }

  .question-answer {
    padding: 10px 0;
  }

  .question-answer .el-textarea {
    width: 100%;
  }

  .no-questions {
    padding: 40px 0;
    text-align: center;
  }
</style>
