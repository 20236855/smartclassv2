<template>
  <div class="exam-container">
    <!-- 顶部导航栏 -->
    <div class="exam-header">
      <div class="header-left">
        <el-button icon="el-icon-arrow-left" @click="handleBack" size="small">返回</el-button>
        <div class="exam-info">
          <h3>{{ assignmentInfo.title }}</h3>
          <el-tag :type="assignmentInfo.type === 'homework' ? 'success' : 'warning'" size="small">
            {{ assignmentInfo.type === 'homework' ? '作业' : '考试' }}
          </el-tag>
        </div>
      </div>
      <div class="header-right">
        <div class="timer" v-if="assignmentInfo.duration">
          <i class="el-icon-time"></i>
          <span>剩余时间：{{ formatTime(remainingTime) }}</span>
        </div>
        <el-button type="primary" @click="handleSubmit" size="small">提交答卷</el-button>
      </div>
    </div>

    <!-- 主体内容 -->
    <div class="exam-body" v-loading="loading">
      <el-row :gutter="20">
        <!-- 左侧：题目列表 -->
        <el-col :span="18">
          <div class="questions-panel">
            <div
              v-for="(question, index) in questions"
              :key="question.questionId"
              class="question-card"
              :id="'question-' + index"
            >
              <!-- 题目头部 -->
              <div class="question-header">
                <span class="question-number">第 {{ index + 1 }} 题</span>
                <el-tag size="mini" :type="getQuestionTypeColor(question.questionType)">
                  {{ getQuestionTypeName(question.questionType) }}
                </el-tag>
                <span class="question-score">{{ question.score }} 分</span>
              </div>

              <!-- 题目内容 -->
              <div class="question-content">
                <p class="question-title">{{ question.questionTitle }}</p>

                <!-- 单选题 -->
                <el-radio-group
                  v-if="question.questionType === 'single'"
                  v-model="answers[question.questionId]"
                  class="question-options"
                >
                  <el-radio
                    v-for="option in parseOptions(question.options)"
                    :key="option.label"
                    :label="option.label"
                    class="question-option"
                  >
                    {{ option.label }}. {{ option.text }}
                  </el-radio>
                </el-radio-group>

                <!-- 多选题 -->
                <el-checkbox-group
                  v-if="question.questionType === 'multiple'"
                  v-model="answers[question.questionId]"
                  class="question-options"
                >
                  <el-checkbox
                    v-for="option in parseOptions(question.options)"
                    :key="option.label"
                    :label="option.label"
                    class="question-option"
                  >
                    {{ option.label }}. {{ option.text }}
                  </el-checkbox>
                </el-checkbox-group>

                <!-- 判断题 -->
                <el-radio-group
                  v-if="question.questionType === 'true_false'"
                  v-model="answers[question.questionId]"
                  class="question-options"
                >
                  <el-radio label="A" class="question-option">正确</el-radio>
                  <el-radio label="B" class="question-option">错误</el-radio>
                </el-radio-group>

                <!-- 简答题 -->
                <el-input
                  v-if="question.questionType === 'short'"
                  v-model="answers[question.questionId]"
                  type="textarea"
                  :rows="6"
                  placeholder="请输入你的答案..."
                  class="question-textarea"
                ></el-input>
              </div>
            </div>

            <!-- 无题目提示 -->
            <el-empty v-if="!loading && questions.length === 0" description="暂无题目"></el-empty>
          </div>
        </el-col>

        <!-- 右侧：答题卡 -->
        <el-col :span="6">
          <div class="answer-card-panel">
            <div class="answer-card-header">
              <i class="el-icon-document"></i>
              <span>答题卡</span>
            </div>
            <div class="answer-card-body">
              <div class="answer-card-grid">
                <div
                  v-for="(question, index) in questions"
                  :key="question.questionId"
                  class="answer-card-item"
                  :class="{
                    'answered': isAnswered(question.questionId),
                    'active': currentQuestion === index
                  }"
                  @click="scrollToQuestion(index)"
                >
                  {{ index + 1 }}
                </div>
              </div>
              <div class="answer-card-stats">
                <div class="stat-item">
                  <span class="stat-label">已答：</span>
                  <span class="stat-value">{{ answeredCount }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">未答：</span>
                  <span class="stat-value">{{ questions.length - answeredCount }}</span>
                </div>
              </div>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script>
import { getAssignmentQuestions } from "@/api/system/assignment";

export default {
  name: "AssignmentExam",
  data() {
    return {
      loading: false,
      assignmentId: null,
      courseId: null,
      assignmentInfo: {},
      questions: [],
      answers: {}, // { questionId: answer }
      currentQuestion: 0,
      remainingTime: 0, // 剩余时间（秒）
      timer: null
    };
  },
  computed: {
    answeredCount() {
      return Object.keys(this.answers).filter(key => {
        const answer = this.answers[key];
        if (Array.isArray(answer)) {
          return answer.length > 0;
        }
        return answer !== null && answer !== undefined && answer !== '';
      }).length;
    }
  },
  created() {
    this.assignmentId = this.$route.query.assignmentId;
    this.courseId = this.$route.query.courseId;

    if (this.assignmentId) {
      this.loadAssignmentData();
    } else {
      this.$modal.msgError("缺少作业ID");
      this.$router.back();
    }
  },
  beforeDestroy() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  },
  methods: {
    // 加载作业数据
    async loadAssignmentData() {
      this.loading = true;
      try {
        // 获取题目列表
        const response = await getAssignmentQuestions(this.assignmentId);
        const rawQuestions = response.data || [];

        console.log('📚 原始题目数据:', rawQuestions);

        // 处理字段名（后端返回的是下划线命名，需要转换为驼峰命名）
        this.questions = rawQuestions.map(q => ({
          questionId: q.question_id || q.questionId,
          questionTitle: q.question_title || q.questionTitle,
          questionType: q.question_type || q.questionType,
          score: q.score,
          options: q.options,
          difficulty: q.difficulty,
          correctAnswer: q.correct_answer || q.correctAnswer,
          explanation: q.explanation
        }));

        console.log('✅ 处理后的题目数据:', this.questions);

        // 初始化答案对象
        this.questions.forEach(q => {
          if (q.questionType === 'multiple') {
            this.$set(this.answers, q.questionId, []);
          } else {
            this.$set(this.answers, q.questionId, '');
          }
        });

        // 从路由参数获取作业信息
        this.assignmentInfo = {
          title: this.$route.query.title || '答题',
          type: this.$route.query.type || 'homework',
          duration: parseInt(this.$route.query.duration) || 0
        };

        // 如果有时间限制，启动计时器
        if (this.assignmentInfo.duration > 0) {
          this.remainingTime = this.assignmentInfo.duration * 60; // 转换为秒
          this.startTimer();
        }
      } catch (error) {
        console.error('加载作业数据失败:', error);
        this.$modal.msgError('加载作业数据失败');
      } finally {
        this.loading = false;
      }
    },

    // 启动计时器
    startTimer() {
      this.timer = setInterval(() => {
        if (this.remainingTime > 0) {
          this.remainingTime--;
        } else {
          clearInterval(this.timer);
          this.$modal.msgWarning('时间到，自动提交答卷');
          this.handleSubmit();
        }
      }, 1000);
    },

    // 格式化时间
    formatTime(seconds) {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      const secs = seconds % 60;

      if (hours > 0) {
        return `${hours}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
      }
      return `${minutes}:${String(secs).padStart(2, '0')}`;
    },

    // 解析选项
    parseOptions(optionsStr) {
      console.log('🔍 解析选项，原始数据:', optionsStr, '类型:', typeof optionsStr);

      if (!optionsStr) {
        console.log('⚠️ 选项为空');
        return [];
      }

      const options = [];
      const parts = optionsStr.split('||');

      console.log('📋 分割后的选项:', parts);

      parts.forEach(part => {
        const colonIndex = part.indexOf(':');
        if (colonIndex > 0) {
          const label = part.substring(0, colonIndex).trim();
          const text = part.substring(colonIndex + 1).trim();
          if (label && text) {
            options.push({ label, text });
          }
        }
      });

      console.log('✅ 解析后的选项:', options);
      return options;
    },

    // 获取题型名称
    getQuestionTypeName(type) {
      const typeMap = {
        'single': '单选题',
        'multiple': '多选题',
        'true_false': '判断题',
        'short': '简答题'
      };
      return typeMap[type] || '未知';
    },

    // 获取题型颜色
    getQuestionTypeColor(type) {
      const colorMap = {
        'single': 'primary',
        'multiple': 'success',
        'true_false': 'warning',
        'short': 'info'
      };
      return colorMap[type] || '';
    },

    // 判断是否已答
    isAnswered(questionId) {
      const answer = this.answers[questionId];
      if (Array.isArray(answer)) {
        return answer.length > 0;
      }
      return answer !== null && answer !== undefined && answer !== '';
    },

    // 滚动到指定题目
    scrollToQuestion(index) {
      this.currentQuestion = index;
      const element = document.getElementById('question-' + index);
      if (element) {
        element.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    },

    // 返回
    handleBack() {
      this.$confirm('确定要退出答题吗？未提交的答案将丢失', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        if (this.timer) {
          clearInterval(this.timer);
        }
        this.$router.back();
      }).catch(() => {});
    },

    // 提交答卷
    handleSubmit() {
      // 检查是否有未答题目
      const unansweredCount = this.questions.length - this.answeredCount;

      if (unansweredCount > 0) {
        this.$confirm(`还有 ${unansweredCount} 道题未作答，确定要提交吗？`, '提示', {
          confirmButtonText: '确定提交',
          cancelButtonText: '继续答题',
          type: 'warning'
        }).then(() => {
          this.submitAnswers();
        }).catch(() => {});
      } else {
        this.submitAnswers();
      }
    },

    // 提交答案
    submitAnswers() {
      // 停止计时器
      if (this.timer) {
        clearInterval(this.timer);
      }

      // 格式化答案数据
      const answerData = [];
      this.questions.forEach(q => {
        let answer = this.answers[q.questionId];

        // 多选题答案转换为字符串
        if (Array.isArray(answer)) {
          answer = answer.sort().join(',');
        }

        answerData.push({
          questionId: q.questionId,
          answer: answer || '',
          score: q.score
        });
      });

      console.log('提交的答案:', answerData);

      // TODO: 调用提交API
      this.$modal.msgSuccess('提交成功！');

      // 跳转到结果页面或返回
      setTimeout(() => {
        this.$router.back();
      }, 1500);
    }
  }
};
</script>

<style scoped lang="scss">
.exam-container {
  min-height: 100vh;
  background: #f5f7fa;
}

.exam-header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: #fff;
  padding: 16px 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: space-between;
  align-items: center;

  .header-left {
    display: flex;
    align-items: center;
    gap: 16px;

    .exam-info {
      display: flex;
      align-items: center;
      gap: 12px;

      h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
        color: #303133;
      }
    }
  }

  .header-right {
    display: flex;
    align-items: center;
    gap: 20px;

    .timer {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 8px 16px;
      background: #fff3e0;
      border-radius: 6px;
      color: #ff9800;
      font-weight: 600;

      i {
        font-size: 18px;
      }
    }
  }
}

.exam-body {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.questions-panel {
  .question-card {
    background: #fff;
    border-radius: 8px;
    padding: 24px;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    transition: all 0.3s;

    &:hover {
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }

    .question-header {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 16px;
      padding-bottom: 12px;
      border-bottom: 1px solid #ebeef5;

      .question-number {
        font-size: 16px;
        font-weight: 600;
        color: #409eff;
      }

      .question-score {
        margin-left: auto;
        color: #f56c6c;
        font-weight: 600;
      }
    }

    .question-content {
      .question-title {
        font-size: 15px;
        line-height: 1.8;
        color: #303133;
        margin-bottom: 20px;
        font-weight: 500;
      }

      .question-options {
        display: flex;
        flex-direction: column;
        gap: 12px;

        .question-option {
          padding: 12px 16px;
          background: #f5f7fa;
          border-radius: 6px;
          transition: all 0.3s;
          margin: 0;

          &:hover {
            background: #e8f4ff;
          }

          ::v-deep .el-radio__label,
          ::v-deep .el-checkbox__label {
            color: #606266;
            font-size: 14px;
            line-height: 1.6;
          }
        }
      }

      .question-textarea {
        margin-top: 12px;

        ::v-deep textarea {
          border-radius: 6px;
          font-size: 14px;
          line-height: 1.6;
        }
      }
    }
  }
}

.answer-card-panel {
  position: sticky;
  top: 90px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  overflow: hidden;

  .answer-card-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff;
    padding: 16px;
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 600;
    font-size: 16px;

    i {
      font-size: 18px;
    }
  }

  .answer-card-body {
    padding: 20px;

    .answer-card-grid {
      display: grid;
      grid-template-columns: repeat(5, 1fr);
      gap: 10px;
      margin-bottom: 20px;

      .answer-card-item {
        aspect-ratio: 1;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2px solid #dcdfe6;
        border-radius: 6px;
        cursor: pointer;
        font-weight: 600;
        color: #909399;
        transition: all 0.3s;

        &:hover {
          border-color: #409eff;
          color: #409eff;
          transform: scale(1.05);
        }

        &.answered {
          background: #67c23a;
          border-color: #67c23a;
          color: #fff;
        }

        &.active {
          border-color: #409eff;
          box-shadow: 0 0 0 3px rgba(64, 158, 255, 0.2);
        }
      }
    }

    .answer-card-stats {
      padding-top: 16px;
      border-top: 1px dashed #dcdfe6;
      display: flex;
      justify-content: space-around;

      .stat-item {
        text-align: center;

        .stat-label {
          color: #909399;
          font-size: 13px;
        }

        .stat-value {
          color: #303133;
          font-size: 20px;
          font-weight: 600;
          margin-left: 4px;
        }
      }
    }
  }
}
</style>

