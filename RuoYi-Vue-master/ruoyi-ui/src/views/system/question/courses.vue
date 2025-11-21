<template>
  <div class="course-practice-container">
    <!-- 课程选择视图 -->
    <div v-if="!selectedCourse" class="course-selection-view">
      <!-- 页面标题 -->
      <div class="page-header">
        <h2 class="page-title">
          <i class="el-icon-reading"></i>
          选择课程开始练习
        </h2>
        <p class="page-subtitle">请选择一门课程，查看对应的题目</p>
      </div>

      <!-- 课程筛选 -->
      <div class="filter-section">
        <el-radio-group v-model="selectedType" @change="handleTypeChange" size="medium">
          <el-radio-button label="all">全部课程</el-radio-button>
          <el-radio-button label="必修课">必修课</el-radio-button>
          <el-radio-button label="选修课">选修课</el-radio-button>
        </el-radio-group>
      </div>

      <!-- 课程卡片列表 -->
      <div v-loading="loading" class="course-grid">
        <div
          v-for="course in filteredCourses"
          :key="course.id"
          class="course-card"
          @click="enterCourse(course)"
        >
          <div class="course-cover">
            <img
              v-if="course.coverImage"
              :src="course.coverImage"
              :alt="course.title"
              @error="handleImageError"
            />
            <div v-else class="cover-placeholder">
              <i class="el-icon-reading"></i>
            </div>
            <div class="course-type-badge" :class="course.courseType === '必修课' ? 'required' : 'elective'">
              {{ course.courseType }}
            </div>
          </div>

          <div class="course-content">
            <h3 class="course-title">{{ course.title }}</h3>
            <p class="course-description">{{ course.description || '暂无描述' }}</p>

            <div class="course-stats">
              <div class="stat-item">
                <i class="el-icon-document"></i>
                <span>{{ course.questionCount || 0 }} 道题目</span>
              </div>
              <div class="stat-item">
                <i class="el-icon-user"></i>
                <span>{{ course.studentCount || 0 }} 人学习</span>
              </div>
              <div class="stat-item">
                <i class="el-icon-star-on"></i>
                <span>{{ course.credit || 0 }} 学分</span>
              </div>
            </div>

            <div class="course-footer">
              <el-tag :type="getStatusType(course.status)" size="small">
                {{ course.status }}
              </el-tag>
              <el-button type="primary" size="small" icon="el-icon-right">
                查看题目
              </el-button>
            </div>
          </div>
        </div>
      </div>

      <!-- 空状态 -->
      <el-empty
        v-if="!loading && filteredCourses.length === 0"
        description="暂无课程"
      ></el-empty>
    </div>

    <!-- 题目练习视图 -->
    <div v-else class="question-practice-view">
      <!-- 返回按钮和课程标题 -->
      <div class="practice-header">
        <el-button
          type="text"
          icon="el-icon-back"
          @click="backToCourseList"
          class="back-button"
        >
          返回课程列表
        </el-button>
        <div class="header-content">
          <h2 class="course-title-header">
            📚 {{ selectedCourse.title }}
          </h2>
          <div class="practice-stats">
            <span class="stat-item">
              <i class="el-icon-document"></i>
              共 {{ questionList.length }} 题
            </span>
            <span class="stat-item">
              <i class="el-icon-circle-check"></i>
              已答 {{ answeredCount }} 题
            </span>
          </div>
        </div>
      </div>

      <!-- 题目列表 -->
      <div v-loading="questionsLoading" class="questions-container">
        <el-empty
          v-if="!questionsLoading && questionList.length === 0"
          description="该课程暂无题目"
        ></el-empty>

        <div v-else class="question-list">
          <div
            v-for="(question, index) in questionList"
            :key="question.id"
            class="question-card"
            :class="{ 'answered': hasAnswer(question.id) }"
          >
            <div class="question-header">
              <span class="question-number">第 {{ index + 1 }} 题</span>
              <el-tag :type="getQuestionTypeColor(question.questionType)" size="small">
                {{ getQuestionTypeText(question.questionType) }}
              </el-tag>
              <el-tag :type="getDifficultyColor(question.difficulty)" size="small">
                {{ getDifficultyText(question.difficulty) }}
              </el-tag>
              <el-tag v-if="hasAnswer(question.id)" type="success" size="small">
                <i class="el-icon-check"></i> 已答
              </el-tag>
            </div>

            <div class="question-content">
              <div class="question-title">{{ question.title }}</div>

              <!-- 单选题 -->
              <div v-if="question.questionType === 'single'" class="answer-area">
                <el-radio-group v-model="userAnswers[question.id]">
                  <el-radio
                    v-for="option in parseOptions(question.options)"
                    :key="option.key"
                    :label="option.key"
                    class="answer-option"
                  >
                    <span class="option-key">{{ option.key }}.</span>
                    <span class="option-value">{{ option.value }}</span>
                  </el-radio>
                </el-radio-group>
              </div>

              <!-- 多选题 -->
              <div v-if="question.questionType === 'multiple'" class="answer-area">
                <el-checkbox-group
                  :value="userAnswers[question.id] || []"
                  @input="val => $set(userAnswers, question.id, val)"
                >
                  <el-checkbox
                    v-for="option in parseOptions(question.options)"
                    :key="option.key"
                    :label="option.key"
                    class="answer-option"
                  >
                    <span class="option-key">{{ option.key }}.</span>
                    <span class="option-value">{{ option.value }}</span>
                  </el-checkbox>
                </el-checkbox-group>
              </div>

              <!-- 判断题 -->
              <div v-if="question.questionType === 'true_false'" class="answer-area">
                <el-radio-group v-model="userAnswers[question.id]">
                  <el-radio label="正确" class="answer-option">
                    <i class="el-icon-check"></i> 正确
                  </el-radio>
                  <el-radio label="错误" class="answer-option">
                    <i class="el-icon-close"></i> 错误
                  </el-radio>
                </el-radio-group>
              </div>

              <!-- 填空题 -->
              <div v-if="question.questionType === 'blank'" class="answer-area">
                <el-input
                  v-model="userAnswers[question.id]"
                  type="textarea"
                  :rows="2"
                  placeholder="请输入答案"
                  class="answer-input"
                />
              </div>

              <!-- 简答题 -->
              <div v-if="question.questionType === 'short'" class="answer-area">
                <el-input
                  v-model="userAnswers[question.id]"
                  type="textarea"
                  :rows="6"
                  placeholder="请输入你的答案..."
                  class="answer-input"
                />
              </div>

              <!-- 编程题 -->
              <div v-if="question.questionType === 'code'" class="answer-area">
                <el-input
                  v-model="userAnswers[question.id]"
                  type="textarea"
                  :rows="10"
                  placeholder="请输入代码..."
                  class="answer-input code-input"
                />
              </div>

              <!-- 答案区域（可展开） -->
              <div class="answer-section">
                <el-button
                  type="text"
                  @click="toggleAnswer(question.id)"
                  class="toggle-answer-btn"
                >
                  <i :class="showAnswers[question.id] ? 'el-icon-arrow-up' : 'el-icon-arrow-down'"></i>
                  {{ showAnswers[question.id] ? '隐藏答案' : '查看答案' }}
                </el-button>

                <div v-show="showAnswers[question.id]" class="answer-content">
                  <div class="answer-item">
                    <span class="answer-label">正确答案：</span>
                    <span class="answer-value correct">{{ question.correctAnswer }}</span>
                  </div>
                  <div v-if="userAnswers[question.id]" class="answer-item">
                    <span class="answer-label">你的答案：</span>
                    <span class="answer-value user-answer" :class="{ 'correct-answer': isAnswerCorrect(question), 'wrong-answer': !isAnswerCorrect(question) }">
                      {{ formatUserAnswer(question) }}
                    </span>
                    <el-tag v-if="isAnswerCorrect(question)" type="success" size="mini">
                      <i class="el-icon-check"></i> 正确
                    </el-tag>
                    <el-tag v-else type="danger" size="mini">
                      <i class="el-icon-close"></i> 错误
                    </el-tag>
                  </div>
                  <div v-if="question.explanation" class="answer-item">
                    <span class="answer-label">答案解析：</span>
                    <span class="answer-value">{{ question.explanation }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 提交按钮 -->
        <div v-if="questionList.length > 0" class="submit-section">
          <el-button
            type="primary"
            size="large"
            @click="submitPractice"
            :disabled="answeredCount === 0"
          >
            <i class="el-icon-check"></i>
            提交练习 ({{ answeredCount }}/{{ questionList.length }})
          </el-button>
          <el-button
            size="large"
            @click="clearAllAnswers"
          >
            <i class="el-icon-refresh-left"></i>
            清空答案
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { listCourse } from "@/api/system/course"
import { listQuestion } from "@/api/system/question"

export default {
  name: "CourseSelection",
  data() {
    return {
      loading: true,
      courseList: [],
      selectedType: 'all',
      // 当前选中的课程
      selectedCourse: null,
      // 题目列表
      questionList: [],
      // 题目加载状态
      questionsLoading: false,
      // 显示答案的题目ID集合
      showAnswers: {},
      // 用户答案（key: questionId, value: 答案）
      userAnswers: {}
    }
  },
  computed: {
    filteredCourses() {
      if (this.selectedType === 'all') {
        return this.courseList
      }
      return this.courseList.filter(course => course.courseType === this.selectedType)
    },
    // 已答题数量
    answeredCount() {
      let count = 0
      for (const questionId of Object.keys(this.userAnswers)) {
        const answer = this.userAnswers[questionId]
        if (answer === undefined || answer === null || answer === '') {
          continue
        }
        if (Array.isArray(answer) && answer.length === 0) {
          continue
        }
        count++
      }
      return count
    }
  },
  created() {
    this.getCourseList()
  },
  methods: {
    // 获取课程列表
    getCourseList() {
      this.loading = true
      listCourse({ status: '进行中', isDeleted: 0 }).then(response => {
        this.courseList = response.rows || []
        // 获取每个课程的题目数量
        this.getQuestionCounts()
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },
    // 获取题目数量
    async getQuestionCounts() {
      // 使用SQL查询获取每个课程的题目数量
      // 由于后端可能没有专门的API，我们可以通过题目列表API获取
      const { listQuestion } = await import("@/api/system/question")

      for (const course of this.courseList) {
        try {
          const response = await listQuestion({
            courseId: course.id,
            isDeleted: 0,
            pageNum: 1,
            pageSize: 1
          })
          this.$set(course, 'questionCount', response.total || 0)
        } catch (error) {
          console.error(`获取课程${course.id}的题目数量失败:`, error)
          this.$set(course, 'questionCount', 0)
        }
      }
    },
    // 筛选类型改变
    handleTypeChange() {
      // 筛选逻辑在computed中处理
    },
    // 进入课程练习
    enterCourse(course) {
      if (!course.questionCount || course.questionCount === 0) {
        this.$modal.msgWarning("该课程暂无题目")
        return
      }
      // 设置选中的课程
      this.selectedCourse = course
      // 加载该课程的题目
      this.loadCourseQuestions(course.id)
    },
    // 返回课程列表
    backToCourseList() {
      // 如果有未提交的答案，提示用户
      if (this.answeredCount > 0) {
        this.$confirm('你还有未提交的答案，确定要返回吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          this.resetPracticeView()
        }).catch(() => {})
      } else {
        this.resetPracticeView()
      }
    },
    // 重置练习视图
    resetPracticeView() {
      this.selectedCourse = null
      this.questionList = []
      this.showAnswers = {}
      this.userAnswers = {}
    },
    // 加载课程题目
    async loadCourseQuestions(courseId) {
      this.questionsLoading = true
      try {
        const response = await listQuestion({
          courseId: courseId,
          isDeleted: 0,
          pageNum: 1,
          pageSize: 1000 // 加载所有题目
        })
        this.questionList = response.rows || []
      } catch (error) {
        console.error('加载题目失败:', error)
        this.$modal.msgError("加载题目失败")
        this.questionList = []
      } finally {
        this.questionsLoading = false
      }
    },
    // 切换答案显示
    toggleAnswer(questionId) {
      this.$set(this.showAnswers, questionId, !this.showAnswers[questionId])
    },
    // 解析选项字符串
    parseOptions(optionsStr) {
      if (!optionsStr) return []
      const options = []
      const parts = optionsStr.split('||')
      parts.forEach(part => {
        const [key, value] = part.split(':')
        if (key && value) {
          options.push({ key: key.trim(), value: value.trim() })
        }
      })
      return options
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
    // 获取题型颜色
    getQuestionTypeColor(type) {
      const colorMap = {
        'single': 'primary',
        'multiple': 'success',
        'true_false': 'warning',
        'blank': 'info',
        'short': 'danger',
        'code': ''
      }
      return colorMap[type] || ''
    },
    // 获取难度文本
    getDifficultyText(difficulty) {
      const difficultyMap = {
        1: '简单',
        2: '中等',
        3: '困难'
      }
      return difficultyMap[difficulty] || '未知'
    },
    // 获取难度颜色
    getDifficultyColor(difficulty) {
      const colorMap = {
        1: 'success',
        2: 'warning',
        3: 'danger'
      }
      return colorMap[difficulty] || 'info'
    },
    // 获取状态标签类型
    getStatusType(status) {
      const typeMap = {
        '进行中': 'success',
        '未开始': 'info',
        '已结束': 'danger'
      }
      return typeMap[status] || 'info'
    },
    // 图片加载失败处理
    handleImageError(e) {
      e.target.style.display = 'none'
    },
    // 检查是否已答题
    hasAnswer(questionId) {
      if (!this.userAnswers.hasOwnProperty(questionId)) {
        return false
      }
      const answer = this.userAnswers[questionId]
      if (answer === '' || answer === null || answer === undefined) {
        return false
      }
      if (Array.isArray(answer)) {
        return answer.length > 0
      }
      return true
    },
    // 判断答案是否正确
    isAnswerCorrect(question) {
      const userAnswer = this.userAnswers[question.id]
      if (!userAnswer) return false

      const correctAnswer = question.correctAnswer

      // 多选题：需要排序后比较
      if (question.questionType === 'multiple') {
        if (!Array.isArray(userAnswer)) return false
        const userSorted = userAnswer.sort().join(',')
        const correctSorted = correctAnswer.split(',').map(s => s.trim()).sort().join(',')
        return userSorted === correctSorted
      }

      // 其他题型：直接比较（忽略大小写和空格）
      return String(userAnswer).trim().toLowerCase() === String(correctAnswer).trim().toLowerCase()
    },
    // 格式化用户答案显示
    formatUserAnswer(question) {
      const answer = this.userAnswers[question.id]
      if (!answer) return '未作答'

      // 多选题：数组转字符串
      if (Array.isArray(answer)) {
        return answer.join(', ')
      }

      return answer
    },
    // 提交练习
    submitPractice() {
      if (this.answeredCount === 0) {
        this.$modal.msgWarning("请至少回答一道题目")
        return
      }

      // 统计答题情况
      let correctCount = 0
      let wrongCount = 0
      let unansweredCount = 0

      this.questionList.forEach(question => {
        if (this.userAnswers[question.id]) {
          if (this.isAnswerCorrect(question)) {
            correctCount++
          } else {
            wrongCount++
          }
        } else {
          unansweredCount++
        }
      })

      const totalCount = this.questionList.length
      const accuracy = totalCount > 0 ? ((correctCount / totalCount) * 100).toFixed(1) : 0

      // 显示结果
      this.$alert(
        `<div style="text-align: left; line-height: 2;">
          <p><strong>📊 练习统计</strong></p>
          <p>总题数：${totalCount} 题</p>
          <p>已答题：${this.answeredCount} 题</p>
          <p>未答题：${unansweredCount} 题</p>
          <p style="color: #67C23A;">✓ 正确：${correctCount} 题</p>
          <p style="color: #F56C6C;">✗ 错误：${wrongCount} 题</p>
          <p><strong>正确率：${accuracy}%</strong></p>
        </div>`,
        '练习结果',
        {
          dangerouslyUseHTMLString: true,
          confirmButtonText: '查看详情',
          callback: () => {
            // 展开所有答案
            this.questionList.forEach(question => {
              this.$set(this.showAnswers, question.id, true)
            })
            // 滚动到第一题
            this.$nextTick(() => {
              const firstQuestion = document.querySelector('.question-card')
              if (firstQuestion) {
                firstQuestion.scrollIntoView({ behavior: 'smooth', block: 'start' })
              }
            })
          }
        }
      )
    },
    // 清空所有答案
    clearAllAnswers() {
      this.$confirm('确定要清空所有答案吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.userAnswers = {}
        this.showAnswers = {}
        this.$modal.msgSuccess("已清空所有答案")
      }).catch(() => {})
    }
  }
}
</script>

<style scoped>
  .course-practice-container {
    padding: 20px;
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
    min-height: calc(100vh - 84px);
  }

  .course-selection-view {
    width: 100%;
  }

  .page-header {
    text-align: center;
    margin-bottom: 40px;
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
    color: #64b5f6;
    margin-right: 10px;
  }

  .page-subtitle {
    font-size: 16px;
    color: #7c8a9d;
    margin: 0;
  }

  .filter-section {
    margin-bottom: 30px;
    text-align: center;
  }

  .course-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 24px;
    margin-bottom: 30px;
  }

  .course-card {
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
    transition: all 0.3s ease;
    cursor: pointer;
  }

  .course-card:hover {
    transform: translateY(-8px);
    box-shadow: 0 8px 24px rgba(100, 181, 246, 0.3);
  }

  .course-cover {
    position: relative;
    width: 100%;
    height: 180px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    overflow: hidden;
  }

  .course-cover img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .cover-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 64px;
    color: rgba(255, 255, 255, 0.8);
  }

  .course-type-badge {
    position: absolute;
    top: 12px;
    right: 12px;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 500;
    color: white;
  }

  .course-type-badge.required {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  }

  .course-type-badge.elective {
    background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  }

  .course-content {
    padding: 20px;
  }

  .course-title {
    font-size: 18px;
    font-weight: 600;
    color: #2c3e50;
    margin: 0 0 10px 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .course-description {
    font-size: 14px;
    color: #7c8a9d;
    margin: 0 0 15px 0;
    line-height: 1.6;
    height: 44px;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
  }

  .course-stats {
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
    padding: 12px 0;
    border-top: 1px solid #f0f0f0;
    border-bottom: 1px solid #f0f0f0;
  }

  .stat-item {
    display: flex;
    align-items: center;
    font-size: 13px;
    color: #7c8a9d;
  }

  .stat-item i {
    margin-right: 4px;
    color: #64b5f6;
  }

  .course-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  @media (max-width: 768px) {
    .course-grid {
      grid-template-columns: 1fr;
    }

    .page-title {
      font-size: 24px;
    }
  }

  /* 题目练习视图样式 */
  .question-practice-view {
    width: 100%;
  }

  .practice-header {
    background: white;
    padding: 20px;
    border-radius: 12px;
    margin-bottom: 20px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  }

  .back-button {
    font-size: 14px;
    color: #64b5f6;
    padding: 8px 0;
    margin-bottom: 10px;
  }

  .back-button:hover {
    color: #1976d2;
  }

  .header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .course-title-header {
    font-size: 28px;
    color: #2c3e50;
    margin: 0;
    font-weight: 600;
  }

  .practice-stats {
    display: flex;
    gap: 20px;
  }

  .practice-stats .stat-item {
    font-size: 14px;
    color: #6c757d;
  }

  .practice-stats .stat-item i {
    margin-right: 4px;
    color: #64b5f6;
  }

  .questions-container {
    min-height: 400px;
  }

  .question-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  .question-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
    transition: all 0.3s ease;
    border-left: 4px solid transparent;
  }

  .question-card:hover {
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  }

  .question-card.answered {
    border-left-color: #67C23A;
    background: #f0f9ff;
  }

  .question-header {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 2px solid #f0f2f5;
  }

  .question-number {
    font-size: 16px;
    font-weight: 600;
    color: #2c3e50;
  }

  .question-content {
    margin-top: 16px;
  }

  .question-title {
    font-size: 16px;
    color: #2c3e50;
    line-height: 1.8;
    margin-bottom: 20px;
    font-weight: 500;
  }

  /* 答题区域样式 */
  .answer-area {
    margin: 20px 0;
    padding: 20px;
    background: #fafbfc;
    border-radius: 8px;
    border: 2px dashed #e1e4e8;
  }

  .answer-option {
    display: flex !important;
    align-items: flex-start;
    padding: 12px 16px;
    margin-bottom: 12px;
    background: white;
    border-radius: 8px;
    border: 2px solid #e1e4e8;
    transition: all 0.2s ease;
    width: 100%;
  }

  .answer-option:hover {
    border-color: #64b5f6;
    background: #f0f9ff;
  }

  .answer-option.is-checked {
    border-color: #64b5f6;
    background: #e3f2fd;
  }

  .option-key {
    font-weight: 600;
    color: #64b5f6;
    margin-right: 8px;
    min-width: 24px;
  }

  .option-value {
    flex: 1;
    color: #495057;
    line-height: 1.6;
  }

  .answer-input {
    width: 100%;
  }

  .answer-input.code-input >>> textarea {
    font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
    font-size: 14px;
  }

  .answer-section {
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px dashed #dee2e6;
  }

  .toggle-answer-btn {
    color: #64b5f6;
    font-size: 14px;
    padding: 0;
  }

  .toggle-answer-btn:hover {
    color: #1976d2;
  }

  .answer-content {
    margin-top: 16px;
    padding: 16px;
    background: #f0f9ff;
    border-left: 4px solid #64b5f6;
    border-radius: 4px;
  }

  .answer-item {
    margin-bottom: 12px;
    line-height: 1.8;
  }

  .answer-item:last-child {
    margin-bottom: 0;
  }

  .answer-label {
    font-weight: 600;
    color: #495057;
    margin-right: 8px;
  }

  .answer-value {
    color: #6c757d;
  }

  .answer-value.correct {
    color: #28a745;
    font-weight: 600;
    font-size: 16px;
  }

  .answer-value.user-answer {
    font-weight: 600;
  }

  .answer-value.correct-answer {
    color: #67C23A;
  }

  .answer-value.wrong-answer {
    color: #F56C6C;
  }

  /* 提交按钮区域 */
  .submit-section {
    margin-top: 30px;
    padding: 24px;
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
    text-align: center;
  }

  .submit-section .el-button {
    min-width: 160px;
    margin: 0 10px;
  }

  /* 响应式调整 */
  @media (max-width: 768px) {
    .header-content {
      flex-direction: column;
      align-items: flex-start;
    }

    .practice-stats {
      margin-top: 10px;
    }

    .answer-option {
      flex-direction: column;
    }

    .submit-section .el-button {
      width: 100%;
      margin: 5px 0;
    }
  }
</style>

