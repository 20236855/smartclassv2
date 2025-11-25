<template>
  <div class="app-container question-page">
    <!-- 返回课程列表按钮 -->
    <div class="back-button-wrapper">
      <el-button
        type="text"
        icon="el-icon-back"
        @click="backToCourseList"
        class="back-button"
      >
        返回课程列表
      </el-button>
    </div>

    <!-- 页面头部 -->
    <div class="page-header">
      <div class="page-title-wrapper">
        <div class="page-icon">
          <i class="el-icon-notebook-2"></i>
        </div>
        <div class="page-text">
          <h2 class="page-title">
            📚 {{ currentCourseTitle || '题目练习' }}
          </h2>
          <p class="page-subtitle">在线练习题目，巩固知识点，提升学习效果</p>
        </div>
      </div>
      <div class="page-extra">
        <el-button type="text" @click="viewMode = 'card'" :class="{ 'active-view': viewMode === 'card' }">
          <i class="el-icon-menu"></i> 卡片视图
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
            <div class="stat-label">题目总数</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card stat-card-green">
          <div class="stat-icon">
            <i class="el-icon-circle-check"></i>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ answeredCount }}</div>
            <div class="stat-label">已完成</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card stat-card-orange">
          <div class="stat-icon">
            <i class="el-icon-warning"></i>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ total - answeredCount }}</div>
            <div class="stat-label">待完成</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card stat-card-purple">
          <div class="stat-icon">
            <i class="el-icon-trophy"></i>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ completionRate }}%</div>
            <div class="stat-label">完成率</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 快速筛选标签 -->
    <el-card class="filter-card" shadow="never">
      <div class="filter-section">
        <span class="filter-label">难度筛选：</span>
        <el-tag
          :type="selectedDifficulty === '' ? 'primary' : 'info'"
          @click.native="filterByDifficulty('')"
          class="filter-tag"
        >全部</el-tag>
        <el-tag
          v-for="level in 5"
          :key="level"
          :type="selectedDifficulty === level ? 'warning' : 'info'"
          @click.native="filterByDifficulty(level)"
          class="filter-tag"
        >
          <i class="el-icon-star-on"></i> {{ level }}星
        </el-tag>
      </div>
      <div class="filter-section">
        <span class="filter-label">状态筛选：</span>
        <el-tag
          :type="selectedStatus === 'all' ? 'primary' : 'info'"
          @click.native="filterByStatus('all')"
          class="filter-tag"
        >全部</el-tag>
        <el-tag
          :type="selectedStatus === 'answered' ? 'success' : 'info'"
          @click.native="filterByStatus('answered')"
          class="filter-tag"
        >已作答</el-tag>
        <el-tag
          :type="selectedStatus === 'unanswered' ? 'warning' : 'info'"
          @click.native="filterByStatus('unanswered')"
          class="filter-tag"
        >未作答</el-tag>
      </div>
    </el-card>

    <!-- 搜索卡片 -->
    <el-card class="search-card" shadow="never" v-show="showSearch">
      <el-form
        :model="queryParams"
        ref="queryForm"
        size="small"
        :inline="true"
        label-width="100px"
        class="search-form"
      >
        <el-form-item label="知识点" prop="knowledgePoint">
          <el-input
            v-model="queryParams.knowledgePoint"
            placeholder="请输入知识点"
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
        <el-form-item label="章节号" prop="chapterId">
          <el-input
            v-model="queryParams.chapterId"
            placeholder="请输入章节号"
            clearable
            @keyup.enter.native="handleQuery"
          />
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
        <el-col :xs="24" :sm="12" :lg="8" v-for="question in filteredQuestionList" :key="question.id">
          <div class="question-card" @click="openAnswerDialog(question)">
            <div class="question-card-header">
              <el-tag size="small" :type="getQuestionTypeColor(question.questionType)">
                {{ question.questionType || '未分类' }}
              </el-tag>
              <el-tag size="small" :type="isQuestionAnswered(question) ? 'success' : 'info'">
                {{ isQuestionAnswered(question) ? '✓ 已完成' : '待完成' }}
              </el-tag>
            </div>
            <div class="question-card-body">
              <h3 class="question-title">{{ question.title }}</h3>
              <div class="question-meta">
                <span class="meta-item">
                  <i class="el-icon-collection-tag"></i>
                  {{ question.knowledgePoint || '暂无' }}
                </span>
                <span class="meta-item">
                  <i class="el-icon-folder-opened"></i>
                  第{{ question.chapterId }}章
                </span>
              </div>
            </div>
            <div class="question-card-footer">
              <div class="difficulty-stars">
                <span class="difficulty-label">难度：</span>
                <el-rate
                  :value="Number(question.difficulty) || 0"
                  disabled
                  :max="5"
                  text-color="#FFB300"
                />
              </div>
              <el-button type="primary" size="mini" plain>
                {{ isQuestionAnswered(question) ? '查看答案' : '开始作答' }}
              </el-button>
            </div>
          </div>
        </el-col>
      </el-row>
      <el-empty v-if="!loading && filteredQuestionList.length === 0" description="暂无题目数据"></el-empty>

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
        :data="filteredQuestionList"
        @selection-change="handleSelectionChange"
        border
        class="question-table"
      >
        <el-table-column label="题干内容" align="left" prop="title" min-width="260" show-overflow-tooltip />
        <el-table-column label="题型" align="center" prop="questionType" width="110" />
        <el-table-column label="难度" align="center" prop="difficulty" width="160">
          <template slot-scope="scope">
            <el-rate
              :value="Number(scope.row.difficulty) || 0"
              disabled
              :max="5"
              show-score
              text-color="#FFB300"
              score-template="{value} 星"
            />
          </template>
        </el-table-column>
        <el-table-column label="知识点" align="center" prop="knowledgePoint" width="140" />
        <el-table-column label="课程编号" align="center" prop="courseId" width="120" />
        <el-table-column label="章节号" align="center" prop="chapterId" width="120" />
        <el-table-column label="出题教师ID" align="center" prop="createdBy" width="120" />
        <el-table-column label="作答状态" align="center" width="110">
          <template slot-scope="scope">
            <el-tag size="mini" :type="isQuestionAnswered(scope.row) ? 'success' : 'info'">
              {{ isQuestionAnswered(scope.row) ? '已作答' : '未作答' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="150">
          <template slot-scope="scope">
            <el-button
              size="mini"
              type="primary"
              @click="openAnswerDialog(scope.row)"
            >{{ isQuestionAnswered(scope.row) ? '查看作答' : '开始作答' }}</el-button>
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

    <!-- 答题对话框 -->
    <el-dialog
      :visible.sync="answerDialogVisible"
      width="750px"
      append-to-body
      class="question-dialog"
      :close-on-click-modal="false"
    >
      <div slot="title" class="dialog-title-custom">
        <i class="el-icon-edit-outline"></i>
        <span>{{ isQuestionAnswered(currentQuestion) ? '查看作答' : '题目作答' }}</span>
      </div>
      <div v-if="currentQuestion" class="question-detail-wrapper">
        <!-- 题目信息卡片 -->
        <div class="question-info-card">
          <div class="question-header-row">
            <el-tag size="medium" :type="getQuestionTypeColor(currentQuestion.questionType)">
              {{ currentQuestion.questionType || '未分类' }}
            </el-tag>
            <div class="difficulty-display">
              <span class="difficulty-text">难度：</span>
              <el-rate
                :value="Number(currentQuestion.difficulty) || 0"
                disabled
                :max="5"
                text-color="#FFB300"
              />
            </div>
          </div>
          <h3 class="question-content">{{ currentQuestion.title }}</h3>
          <div class="question-meta-row">
            <span class="meta-badge">
              <i class="el-icon-collection-tag"></i>
              知识点：{{ currentQuestion.knowledgePoint || '暂无' }}
            </span>
            <span class="meta-badge">
              <i class="el-icon-folder-opened"></i>
              课程：{{ currentQuestion.courseId || '—' }}
            </span>
            <span class="meta-badge">
              <i class="el-icon-document"></i>
              章节：第{{ currentQuestion.chapterId }}章
            </span>
          </div>
        </div>

        <!-- 答题区域 -->
        <div class="answer-section">
          <div class="section-title">
            <i class="el-icon-edit"></i>
            <span>我的答案</span>
          </div>
          <el-input
            v-model="answerForm.answer"
            type="textarea"
            :rows="6"
            placeholder="请在此输入你的答案..."
            :disabled="isQuestionAnswered(currentQuestion)"
            class="answer-textarea"
          />

          <!-- 已作答时显示提交时间 -->
          <div v-if="isQuestionAnswered(currentQuestion)" class="answer-info">
            <el-alert
              title="您已完成此题作答"
              type="success"
              :closable="false"
              show-icon
            >
            </el-alert>
          </div>
        </div>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="answerDialogVisible = false" size="medium">
          <i class="el-icon-close"></i> 关闭
        </el-button>
        <el-button
          v-if="!isQuestionAnswered(currentQuestion)"
          type="primary"
          @click="handleSubmitAnswer"
          size="medium"
        >
          <i class="el-icon-check"></i> 提交答案
        </el-button>
      </div>
    </el-dialog>

    <!-- 添加或修改题目对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="600px" append-to-body class="question-dialog">
      <el-form ref="form" :model="form" :rules="rules" label-width="100px" class="dialog-form">
        <el-form-item label="题干内容" prop="title">
          <el-input v-model="form.title" type="textarea" placeholder="请输入内容" />
        </el-form-item>
        <el-form-item label="难度等级" prop="difficulty">
          <el-input v-model="form.difficulty" placeholder="请输入难度等级，1~5整数" />
        </el-form-item>
        <el-form-item label="题型" prop="questionType">
          <el-input v-model="form.questionType" placeholder="请输入题型" />
        </el-form-item>
        <el-form-item label="标准答案" prop="correctAnswer">
          <el-input v-model="form.correctAnswer" type="textarea" placeholder="请输入内容" />
        </el-form-item>
        <el-form-item label="答案解析" prop="explanation">
          <el-input v-model="form.explanation" type="textarea" placeholder="请输入内容" />
        </el-form-item>
        <el-form-item label="知识点" prop="knowledgePoint">
          <el-input v-model="form.knowledgePoint" placeholder="请输入知识点" />
        </el-form-item>
        <el-form-item label="课程编号" prop="courseId">
          <el-input v-model="form.courseId" placeholder="请输入课程编号" />
        </el-form-item>
        <el-form-item label="章节号" prop="chapterId">
          <el-input v-model="form.chapterId" placeholder="请输入章节号" />
        </el-form-item>
        <el-form-item label="出题教师ID" prop="createdBy">
          <el-input v-model="form.createdBy" placeholder="请输入出题教师ID" />
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
import { listQuestion, getQuestion, delQuestion, addQuestion, updateQuestion } from "@/api/system/question"

export default {
  name: "Question",
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
      // 题目表格数据
      questionList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 学生作答对话框
      answerDialogVisible: false,
      // 当前选中的题目
      currentQuestion: null,
      // 学生作答表单（仅前端状态）
      answerForm: {
        answer: ""
      },
      // 已作答题目记录（仅前端状态）
      questionAnswerMap: {},
      // 视图模式：card 或 table
      viewMode: 'card',
      // 选中的难度筛选
      selectedDifficulty: '',
      // 选中的状态筛选
      selectedStatus: 'all',
      // 当前课程ID
      currentCourseId: null,
      // 当前课程标题
      currentCourseTitle: '',
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        title: null,
        questionType: null,
        difficulty: null,
        correctAnswer: null,
        explanation: null,
        knowledgePoint: null,
        courseId: null,
        chapterId: null,
        createdBy: null,
        isDeleted: null,
        deleteTime: null
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        title: [
          { required: true, message: "题干内容不能为空", trigger: "blur" }
        ],
        questionType: [
          { required: true, message: "题型不能为空", trigger: "change" }
        ],
        difficulty: [
          { required: true, message: "难度等级，1~5整数不能为空", trigger: "blur" }
        ],
        courseId: [
          { required: true, message: "课程编号不能为空", trigger: "blur" }
        ],
        chapterId: [
          { required: true, message: "章节号不能为空", trigger: "blur" }
        ],
        createdBy: [
          { required: true, message: "出题教师ID不能为空", trigger: "blur" }
        ],
        isDeleted: [
          { required: true, message: "是否删除不能为空", trigger: "blur" }
        ],
      }
    }
  },
  computed: {
    // 已作答题目数量
    answeredCount() {
      return Object.keys(this.questionAnswerMap).length
    },
    // 完成率
    completionRate() {
      if (this.total === 0) return 0
      return Math.round((this.answeredCount / this.total) * 100)
    },
    // 过滤后的题目列表
    filteredQuestionList() {
      if (this.selectedStatus === 'all') {
        return this.questionList
      } else if (this.selectedStatus === 'answered') {
        return this.questionList.filter(q => this.isQuestionAnswered(q))
      } else if (this.selectedStatus === 'unanswered') {
        return this.questionList.filter(q => !this.isQuestionAnswered(q))
      }
      return this.questionList
    }
  },
  created() {
    // 从路由获取课程ID和标题
    this.currentCourseId = this.$route.query.courseId
    this.currentCourseTitle = this.$route.query.courseTitle || '题目练习'

    // 如果没有课程ID，跳转到课程选择页面
    if (!this.currentCourseId) {
      this.$router.replace('/system/question/courses')
      return
    }

    // 设置查询参数中的课程ID
    this.queryParams.courseId = this.currentCourseId
    this.getList()
  },
  methods: {
    /** 查询题目列表 */
    getList() {
      this.loading = true
      listQuestion(this.queryParams).then(response => {
        this.questionList = response.rows
        this.total = response.total
        this.loading = false
      })
    },
    // 返回课程列表
    backToCourseList() {
      this.$router.push('/system/question/courses')
    },
    // 根据题型返回颜色
    getQuestionTypeColor(type) {
      const colorMap = {
        '单选题': 'primary',
        '多选题': 'success',
        '判断题': 'warning',
        '填空题': 'info',
        '简答题': 'danger'
      }
      return colorMap[type] || ''
    },
    // 难度筛选
    filterByDifficulty(level) {
      this.selectedDifficulty = level
      this.queryParams.difficulty = level === '' ? null : level
      this.handleQuery()
    },
    // 状态筛选
    filterByStatus(status) {
      this.selectedStatus = status
      // 使用计算属性 filteredQuestionList 进行前端过滤，不需要重新请求后端
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
        questionType: null,
        difficulty: null,
        correctAnswer: null,
        explanation: null,
        knowledgePoint: null,
        courseId: null,
        chapterId: null,
        createdBy: null,
        createTime: null,
        updateTime: null,
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
      this.title = "添加题目"
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getQuestion(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = "修改题目"
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateQuestion(this.form).then(response => {
              this.$modal.msgSuccess("修改成功")
              this.open = false
              this.getList()
            })
          } else {
            addQuestion(this.form).then(response => {
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
      this.$modal.confirm('是否确认删除题目编号为"' + ids + '"的数据项？').then(function() {
        return delQuestion(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess("删除成功")
      }).catch(() => {})
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('system/question/export', {
        ...this.queryParams
      }, `question_${new Date().getTime()}.xlsx`)
    },
    // 学生端：打开作答对话框
    openAnswerDialog(row) {
      if (!row || !row.id) {
        return
      }
      this.currentQuestion = row
      this.answerForm = {
        answer: this.questionAnswerMap[row.id] || ""
      }
      this.answerDialogVisible = true
    },
    // 学生端：题目是否已作答
    isQuestionAnswered(row) {
      return row && row.id && !!this.questionAnswerMap[row.id]
    },
    // 学生端：提交答案（演示用，仅前端状态）
    handleSubmitAnswer() {
      if (!this.answerForm.answer) {
        this.$modal.msgError("请先填写答案")
        return
      }
      if (this.currentQuestion && this.currentQuestion.id != null) {
        this.$set(this.questionAnswerMap, this.currentQuestion.id, this.answerForm.answer)
      }
      this.$modal.msgSuccess("提交成功")
      this.answerDialogVisible = false
    }
  }
}
</script>

<style scoped>
  .question-page {
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
    background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: #1976d2;
    margin-right: 16px;
    font-size: 28px;
    box-shadow: 0 4px 12px rgba(25, 118, 210, 0.15);
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
    background: #e8f4fd;
    color: #1976d2;
  }

  .page-extra .el-button--text.active-view {
    background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
    color: #1976d2;
    font-weight: 600;
  }

  /* 返回按钮 */
  .back-button-wrapper {
    margin-bottom: 16px;
  }

  .back-button {
    font-size: 14px;
    color: #64b5f6;
    padding: 8px 0;
  }

  .back-button:hover {
    color: #1976d2;
  }

  .back-button i {
    margin-right: 4px;
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

  .stat-card-purple {
    border-left: 4px solid #ba68c8;
  }

  .stat-card-purple .stat-icon {
    background: linear-gradient(135deg, #f3e5f5 0%, #e1bee7 100%);
    color: #7b1fa2;
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

  .question-card {
    background: #ffffff;
    border-radius: 16px;
    padding: 22px;
    margin-bottom: 16px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    transition: all 0.3s;
    cursor: pointer;
    border: 1px solid #e8eaed;
    position: relative;
    overflow: hidden;
  }

  .question-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 4px;
    height: 100%;
    background: linear-gradient(180deg, #64b5f6 0%, #42a5f5 100%);
    opacity: 0;
    transition: opacity 0.3s;
  }

  .question-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    border-color: #64b5f6;
  }

  .question-card:hover::before {
    opacity: 1;
  }

  .question-card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
  }

  .question-card-body {
    margin-bottom: 16px;
  }

  .question-title {
    font-size: 16px;
    font-weight: 600;
    color: #2c3e50;
    margin: 0 0 12px 0;
    line-height: 1.6;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .question-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
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
    color: #64b5f6;
  }

  .question-card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 16px;
    border-top: 1px solid #f0f2f5;
  }

  .difficulty-stars {
    display: flex;
    align-items: center;
  }

  .difficulty-label {
    font-size: 13px;
    color: #7c8a9d;
    margin-right: 8px;
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

  .question-table {
    margin-top: 4px;
  }

  .question-page ::v-deep .el-table {
    border-radius: 12px;
    overflow: hidden;
  }

  .question-page ::v-deep .el-table th {
    background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
    color: #1976d2;
    font-weight: 600;
  }

  .question-page ::v-deep .el-table td {
    color: #2c3e50;
  }

  .question-page ::v-deep .el-table--border::after,
  .question-page ::v-deep .el-table--group::after,
  .question-page ::v-deep .el-table::before {
    background-color: #e8eaed;
  }

  .pagination-wrapper {
    margin-top: 16px;
    text-align: right;
  }

  /* 对话框样式 */
  .question-dialog ::v-deep .el-dialog {
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  }

  .question-dialog ::v-deep .el-dialog__header {
    background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
    padding: 20px 24px;
    border-bottom: 1px solid #e8eaed;
  }

  .dialog-title-custom {
    color: #1976d2;
    font-size: 18px;
    font-weight: 600;
    display: flex;
    align-items: center;
  }

  .dialog-title-custom i {
    margin-right: 8px;
    font-size: 20px;
  }

  .question-dialog ::v-deep .el-dialog__body {
    padding: 24px;
    background: #fafbfc;
  }

  .question-detail-wrapper {
    max-height: 60vh;
    overflow-y: auto;
  }

  .question-info-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
    border: 1px solid #e8eaed;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  }

  .question-header-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
  }

  .difficulty-display {
    display: flex;
    align-items: center;
    background: #f5f7fa;
    padding: 6px 12px;
    border-radius: 20px;
  }

  .difficulty-text {
    font-size: 14px;
    color: #7c8a9d;
    margin-right: 8px;
  }

  .question-content {
    font-size: 18px;
    font-weight: 600;
    color: #2c3e50;
    line-height: 1.6;
    margin: 0 0 16px 0;
  }

  .question-meta-row {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
  }

  .meta-badge {
    font-size: 13px;
    color: #2c3e50;
    background: #f5f7fa;
    padding: 8px 14px;
    border-radius: 20px;
    display: flex;
    align-items: center;
    border: 1px solid #e8eaed;
  }

  .meta-badge i {
    margin-right: 6px;
    color: #64b5f6;
  }

  .answer-section {
    background: #ffffff;
    border-radius: 12px;
    padding: 20px;
    border: 1px solid #e8eaed;
  }

  .section-title {
    font-size: 16px;
    font-weight: 600;
    color: #2c3e50;
    margin-bottom: 16px;
    display: flex;
    align-items: center;
  }

  .section-title i {
    margin-right: 8px;
    color: #64b5f6;
    font-size: 18px;
  }

  .answer-textarea ::v-deep .el-textarea__inner {
    border-radius: 8px;
    border: 1px solid #e0e0e0;
    font-size: 14px;
    line-height: 1.6;
    background: #fafbfc;
  }

  .answer-textarea ::v-deep .el-textarea__inner:focus {
    border-color: #64b5f6;
    background: #ffffff;
  }

  .answer-info {
    margin-top: 16px;
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
    background: linear-gradient(135deg, #64b5f6 0%, #42a5f5 100%);
    border: none;
  }

  .dialog-footer .el-button--primary:hover {
    background: linear-gradient(135deg, #42a5f5 0%, #1e88e5 100%);
  }

  /* 响应式设计 */
  @media (max-width: 768px) {
    .question-page {
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

    .question-card {
      padding: 16px;
    }

    .question-title {
      font-size: 15px;
    }
  }
</style>
