<template>
  <div class="app-container" style="padding: 10px 20px;">
    <!-- 左右分栏布局 -->
    <el-row :gutter="20">
      <!-- 左侧：文件上传表单 -->
      <el-col :span="12">
        <el-card class="upload-card" style="height: 660px;">
          <el-form ref="uploadForm" :model="uploadForm" label-width="80px">
            <el-form-item label="选择课程" required v-if="!hideCourseSelect">
              <el-select 
                v-model="uploadForm.courseId" 
                placeholder="请选择课程" 
                style="width: 100%;"
                @change="handleCourseChange"
                filterable
              >
                <el-option
                  v-for="course in courseOptions"
                  :key="course.id"
                  :label="course.title"
                  :value="course.id"
                />
              </el-select>
            </el-form-item>

            <el-form-item label="选择小节" required>
              <el-cascader
                v-model="uploadForm.sectionPath"
                :options="chapterSectionOptions"
                :props="cascaderProps"
                placeholder="请选择章节和小节"
                style="width: 100%;"
                filterable
                clearable
                @change="handleSectionChange"
              />
            </el-form-item>
        
            <el-form-item label="资源描述">
              <el-input 
                v-model="uploadForm.description" 
                type="textarea" 
                placeholder="请输入资源描述（可选）"
                :rows="8"
                style="width: 100%;"
              />
            </el-form-item>
            
            <el-form-item label="选择文件" required>
              <el-upload
                ref="upload"
                :limit="1"
                :on-exceed="handleExceed"
                :auto-upload="false"
                :on-change="handleFileChange"
                :file-list="fileList"
                accept=".pdf,.doc,.docx,.mp4,.avi,.mov,.wmv,.flv,.mkv"
                action="#"
              >
                <el-button slot="trigger" size="small" type="primary">选取文件</el-button>
                <div slot="tip" class="el-upload__tip">
                  支持文档：PDF、Word（.pdf, .doc, .docx）<br/>
                  支持视频：MP4、AVI、MOV、WMV、FLV、MKV<br/>
                  单个文件不超过500MB（视频识别需要较长时间，请耐心等待）
                </div>
              </el-upload>
            </el-form-item>
            
            <el-form-item>
              <el-row :gutter="6">
                <el-col :span="8">
                  <el-button 
                    type="primary"
                    size="mini"
                    @click="handleAnalyze"
                    :loading="uploading"
                    :disabled="!selectedFile || !uploadForm.courseId || !uploadForm.sectionId"
                    style="width: 100%;"
                  >
                    智能分析
                  </el-button>
                </el-col>
                <el-col :span="8">
                  <el-button 
                    type="success"
                    size="mini"
                    @click="handleSave"
                    :disabled="saveButtonDisabled"
                    style="width: 100%;"
                  >
                    保存
                  </el-button>
                </el-col>
                <el-col :span="8">
                  <el-button
                    size="mini"
                    @click="handleCancel"
                    style="width: 100%;"
                  >
                    取消
                  </el-button>
                </el-col>
              </el-row>
              <div v-if="uploading" style="margin-top: 10px; color: #409EFF; text-align: center; font-size: 13px;">
                正在上传并调用DeepSeek API分析中，请稍候...
              </div>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>
      
      <!-- 右侧：AI推荐结果展示 -->
      <el-col :span="12">
        <el-card class="result-card" style="height: 660px;">
          <div slot="header">
            <span>知识点管理</span>
            <el-button 
              size="mini"
              type="primary"
              icon="el-icon-chat-dot-round"
              @click="openChatDialog"
              style="float: right;"
              :disabled="recommendations.length === 0"
            >
              与AI对话
            </el-button>
          </div>
          
          <div style="max-height: 600px; overflow-y: auto;">
            <!-- 1. 匹配知识点 -->
            <div style="margin-bottom: 20px; min-height: 180px;">
              <el-table 
                v-if="matchedKnowledgePoints.length > 0"
                :data="matchedKnowledgePoints" 
                border 
                size="small" 
                max-height="180" 
                @selection-change="handleMatchedSelectionChange"
              >
                <el-table-column type="selection" width="45" align="center" />
                
                <el-table-column label="匹配状态" width="100" align="center">
                  <template slot-scope="scope">
                    <el-tag type="success" size="mini">已匹配</el-tag>
                  </template>
                </el-table-column>
                
                <el-table-column label="知识点" min-width="150">
                  <template slot-scope="scope">
                    <div style="display: flex; align-items: center; justify-content: space-between;">
                      <span style="font-weight: bold; color: #303133;">{{ scope.row.extractedTitle }}</span>
                      <el-tag type="success" size="mini" effect="plain" style="margin-left: 10px;">
                        {{ (scope.row.similarity * 100).toFixed(1) }}%
                      </el-tag>
                    </div>
                  </template>
                </el-table-column>
                
                <el-table-column label="操作" width="80" align="center">
                  <template slot="header">
                    <span 
                      class="batch-action-header"
                      @click="handleBatchCancelMatch"
                      :style="{ cursor: 'pointer', color: matchedSelection.length > 0 ? '#F56C6C' : '#909399' }"
                    >
                      操作
                    </span>
                  </template>
                  <template slot-scope="scope">
                    <el-button 
                      type="text" 
                      icon="el-icon-close"
                      style="color: #F56C6C; font-size: 16px;"
                      @click="handleCancelMatch(scope.row)"
                    />
                  </template>
                </el-table-column>
              </el-table>
              <div v-else>
                <el-table :data="[]" border size="small" height="180">
                  <el-table-column type="selection" width="45" align="center" />
                  <el-table-column label="匹配状态" width="100" align="center" />
                  <el-table-column label="知识点" min-width="150" />
                  <el-table-column label="操作" width="80" align="center">
                    <template slot="header">
                      <span style="color: #909399;">操作</span>
                    </template>
                  </el-table-column>
                </el-table>
              </div>
            </div>

            <!-- 2. 新增知识点 -->
            <div style="margin-bottom: 20px; min-height: 180px;">
              <el-table 
                v-if="newKnowledgePoints.length > 0"
                :data="newKnowledgePoints" 
                border 
                size="small" 
                max-height="180" 
                @selection-change="handleNewSelectionChange"
              >
                <el-table-column type="selection" width="45" align="center" />
                
                <el-table-column label="匹配状态" width="100" align="center">
                  <template slot-scope="scope">
                    <el-tag type="warning" size="mini">新知识点</el-tag>
                  </template>
                </el-table-column>
                
                <el-table-column label="知识点" min-width="150">
                  <template slot-scope="scope">
                    <span style="font-weight: bold; color: #303133;">{{ scope.row.extractedTitle }}</span>
                  </template>
                </el-table-column>
                
                <el-table-column label="操作" width="80" align="center">
                  <template slot="header">
                    <span 
                      class="batch-action-header"
                      @click="handleBatchCreateNew"
                      :style="{ cursor: 'pointer', color: newSelection.length > 0 ? '#E6A23C' : '#909399' }"
                    >
                      操作
                    </span>
                  </template>
                  <template slot-scope="scope">
                    <el-button 
                      type="text" 
                      icon="el-icon-plus"
                      style="color: #E6A23C; font-size: 16px;"
                      @click="handleCreateSingleNew(scope.row)"
                    />
                  </template>
                </el-table-column>
              </el-table>
              <div v-else>
                <el-table :data="[]" border size="small" height="180">
                  <el-table-column type="selection" width="45" align="center" />
                  <el-table-column label="匹配状态" width="100" align="center" />
                  <el-table-column label="知识点" min-width="150" />
                  <el-table-column label="操作" width="80" align="center">
                    <template slot="header">
                      <span style="color: #909399;">操作</span>
                    </template>
                  </el-table-column>
                </el-table>
              </div>
            </div>

            <!-- 3. 已有知识点 -->
            <div style="margin-bottom: 20px; min-height: 180px;">
              <el-table 
                v-if="availableKnowledgePoints.length > 0"
                :data="availableKnowledgePoints" 
                border 
                size="small" 
                max-height="180" 
                @selection-change="handleAvailableSelectionChange"
              >
                <el-table-column type="selection" width="45" align="center" />
                
                <el-table-column label="匹配状态" width="100" align="center">
                  <template slot-scope="scope">
                    <el-tag type="info" size="mini">未匹配</el-tag>
                  </template>
                </el-table-column>
                
                <el-table-column label="知识点" min-width="150">
                  <template slot-scope="scope">
                    <span style="color: #606266;">{{ scope.row.title }}</span>
                  </template>
                </el-table-column>
                
                <el-table-column label="操作" width="80" align="center">
                  <template slot="header">
                    <span 
                      class="batch-action-header"
                      @click="handleBatchAddAvailable"
                      :style="{ cursor: 'pointer', color: availableSelection.length > 0 ? '#409EFF' : '#909399' }"
                    >
                      操作
                    </span>
                  </template>
                  <template slot-scope="scope">
                    <el-button 
                      type="text" 
                      icon="el-icon-plus"
                      style="color: #409EFF; font-size: 16px;"
                      @click="handleAddSingleAvailable(scope.row)"
                    />
                  </template>
                </el-table-column>
              </el-table>
              <div v-else>
                <el-table :data="[]" border size="small" height="180">
                  <el-table-column type="selection" width="45" align="center" />
                  <el-table-column label="匹配状态" width="100" align="center" />
                  <el-table-column label="知识点" min-width="150" />
                  <el-table-column label="操作" width="80" align="center">
                    <template slot="header">
                      <span style="color: #909399;">操作</span>
                    </template>
                  </el-table-column>
                </el-table>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- AI对话界面 (ChatGPT风格) -->
    <el-dialog
      title="🤖 与AI助手对话"
      :visible.sync="chatDialogVisible"
      width="800px"
      :close-on-click-modal="false"
      top="5vh"
      append-to-body
      :modal="true"
    >
      <div class="chat-container">
        <!-- 对话消息区域 -->
        <div class="chat-messages" ref="chatMessages">
          <div 
            v-for="(message, index) in chatMessages" 
            :key="index"
            :class="['message-item', message.role === 'user' ? 'user-message' : 'ai-message']"
          >
            <div class="message-avatar">
              <i :class="message.role === 'user' ? 'el-icon-user' : 'el-icon-chat-dot-round'"></i>
            </div>
            <div class="message-content">
              <div class="message-header">
                <span class="message-role">{{ message.role === 'user' ? '您' : 'AI助手' }}</span>
                <span class="message-time">{{ message.time }}</span>
              </div>
              <div class="message-text" v-html="formatMessage(message.content)"></div>
              <!-- 加载动画 -->
              <div v-if="message.loading" class="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 输入区域 -->
        <div class="chat-input-area">
          <el-input
            v-model="chatInput"
            type="textarea"
            :rows="3"
            placeholder="输入您的问题，例如：请解释一下提取的知识点、为什么没有匹配到某个知识点等..."
            @keydown.ctrl.enter.native="sendChatMessage"
            :disabled="chatSending"
          />
          <div class="chat-actions">
            <el-button 
              type="primary" 
              size="small"
              @click="sendChatMessage"
              :loading="chatSending"
              :disabled="!chatInput.trim()"
            >
              发送 (Ctrl+Enter)
            </el-button>
            <el-button 
              size="small"
              @click="clearChat"
              :disabled="chatMessages.length === 0"
            >
              清空对话
            </el-button>
          </div>
        </div>
      </div>
    </el-dialog>

    <!-- AI分析对话框 -->
    <el-dialog
      title="🤖 AI智能分析助手"
      :visible.sync="aiDialogVisible"
      width="70%"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
      append-to-body
      :modal="true"
    >
      <div class="ai-dialog-content">
        <!-- 分析步骤时间线 -->
        <el-timeline>
          <el-timeline-item
            v-for="step in aiSteps"
            :key="step.id"
            :timestamp="step.timestamp"
            :type="step.type"
            :icon="step.icon"
          >
            <h4>{{ step.title }}</h4>
            <p v-if="step.content">{{ step.content }}</p>
            
            <!-- 文档解析结果 -->
            <el-collapse v-if="step.id === 'parse' && step.data" accordion>
              <el-collapse-item title="📄 查看提取的文本内容" name="1">
                <div class="text-preview">
                  {{ step.data.text }}
                </div>
                <p style="color: #909399; margin-top: 10px;">
                  提取文本长度: {{ step.data.length }} 字符
                </p>
              </el-collapse-item>
            </el-collapse>

            <!-- AI提取的知识点 -->
            <div v-if="step.id === 'extract' && step.data" class="knowledge-points">
              <el-tag
                v-for="(kp, index) in step.data"
                :key="index"
                type="info"
                style="margin: 5px;"
              >
                {{ kp }}
              </el-tag>
              <p style="color: #409EFF; margin-top: 10px;">
                共提取 {{ step.data.length }} 个知识点
              </p>
            </div>

            <!-- 匹配结果统计 -->
            <div v-if="step.id === 'match' && step.data" class="match-result">
              <el-row :gutter="20">
                <el-col :span="8">
                  <el-card shadow="hover">
                    <div style="text-align: center;">
                      <i class="el-icon-check" style="font-size: 30px; color: #67C23A;"></i>
                      <h3>{{ step.data.matched }}</h3>
                      <p>成功匹配</p>
                    </div>
                  </el-card>
                </el-col>
                <el-col :span="8">
                  <el-card shadow="hover">
                    <div style="text-align: center;">
                      <i class="el-icon-warning" style="font-size: 30px; color: #E6A23C;"></i>
                      <h3>{{ step.data.unmatched }}</h3>
                      <p>待创建</p>
                    </div>
                  </el-card>
                </el-col>
                <el-col :span="8">
                  <el-card shadow="hover">
                    <div style="text-align: center;">
                      <i class="el-icon-s-data" style="font-size: 30px; color: #409EFF;"></i>
                      <h3>{{ step.data.total }}</h3>
                      <p>总计</p>
                    </div>
                  </el-card>
                </el-col>
              </el-row>
            </div>
          </el-timeline-item>
        </el-timeline>

        <!-- 底部操作按钮 -->
        <div style="text-align: center; margin-top: 20px;">
          <el-button @click="aiDialogVisible = false">关闭</el-button>
          <el-button 
            type="success"
            icon="el-icon-chat-dot-round"
            @click="openChatFromAnalysis"
            :disabled="!analysisCompleted"
          >
            与AI对话
          </el-button>
          <el-button 
            type="primary" 
            @click="handleViewRecommendations"
            :disabled="!analysisCompleted"
          >
            查看推荐结果
          </el-button>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { analyzeFileOnlyRenwu3, uploadAndAnalyzeRenwu3, saveResourceRenwu3, confirmKnowledgePointsRenwu3, chatWithAIRenwu3, delResourceRenwu3 } from '@/api/system/courseResourceRenwu3'
import { listCourse } from '@/api/course/course'
import { listKnowledgePointByCourse, addKnowledgePoint, batchAddKnowledgePoints } from '@/api/course/knowledgePoint'
import { listChapterByCourse } from '@/api/course/chapter'
import { listSectionByChapter, setSectionKnowledgePoints } from '@/api/course/section'

export default {
  name: 'ResourceTaggingRenwu3',
  props: {
    courseId: {
      type: Number,
      default: null
    },
    hideCourseSelect: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      // 课程选项
      courseOptions: [],
      
      // 课程所有知识点列表
      allCourseKnowledgePoints: [],
      
      // 章节小节选项
      chapterSectionOptions: [],
      
      // 级联选择器配置
      cascaderProps: {
        value: 'id',
        label: 'title',
        children: 'sections',
        emitPath: true // 返回完整路径[chapterId, sectionId]
      },
      
      // 上传表单
      uploadForm: {
        courseId: '',
        courseTitle: '',
        description: '',
        sectionPath: [], // [chapterId, sectionId]
        sectionId: null
      },
      
      // 文件相关
      fileList: [],
      selectedFile: null,
      uploading: false,
      
      // AI推荐结果
      recommendations: [],
      uploadResult: null,
      currentResourceId: null,
      tempResourceInfo: null, // 临时资源信息（未保存到数据库）

      // AI对话框相关
      aiDialogVisible: false,
      analysisCompleted: false,
      aiSteps: [],

      // AI对话界面相关
      chatDialogVisible: false,
      chatMessages: [],
      chatInput: '',
      chatSending: false,
      chatContext: null, // 存储当前分析上下文
      
      // 多选相关
      matchedSelection: [], // 匹配知识点的多选
      newSelection: [], // 新知识点的多选
      availableSelection: [] // 已有知识点的多选
    }
  },
  
  created() {
    this.loadCourses()
    // 如果传入了courseId，自动设置并加载数据
    if (this.courseId) {
      console.log('ResourceTagging created - courseId:', this.courseId, 'type:', typeof this.courseId)
      this.uploadForm.courseId = this.courseId
      this.handleCourseChange(this.courseId)
    }
  },
  
  computed: {
    // 1. AI匹配到的知识点（已匹配，默认全选）
    matchedKnowledgePoints() {
      return this.recommendations
        .filter(item => item.matched)
        .map(item => ({
          ...item,
          selected: true // 匹配的知识点默认选中
        }))
    },
    
    // 2. AI提取的新知识点（未匹配）
    newKnowledgePoints() {
      return this.recommendations.filter(item => !item.matched)
    },
    
    // 3. 课程中可用的知识点（排除已被AI匹配的）
    availableKnowledgePoints() {
      const matchedKpIds = this.matchedKnowledgePoints.map(item => item.kpId)
      return this.allCourseKnowledgePoints
        .filter(kp => !matchedKpIds.includes(kp.id))
        .map(kp => ({
          ...kp,
          selected: false
        }))
    },
    
    // 已选中的匹配知识点ID列表
    selectedKpIds() {
      return this.matchedKnowledgePoints
        .filter(item => item.selected && item.kpId)
        .map(item => item.kpId)
    },
    
    // 选中要创建的新知识点列表
    selectedNewKps() {
      return this.newKnowledgePoints
        .filter(item => item.selected)
        .map(item => item.extractedTitle)
    },
    
    // 选中要添加的已有知识点列表
    selectedAvailableKps() {
      return this.availableKnowledgePoints
        .filter(kp => kp.selected)
        .map(kp => kp.id)
    },
    
    // 总选中数量
    totalSelectedCount() {
      return this.selectedKpIds.length + this.selectedNewKps.length + this.selectedAvailableKps.length
    },
    
    // 保存按钮禁用条件
    saveButtonDisabled() {
      // 如果没有选择小节，禁用
      if (!this.uploadForm.sectionId) {
        return true
      }
      
      // 如果既没有临时资源信息，也没有资源ID，并且没有选中任何知识点，禁用
      if (!this.tempResourceInfo && !this.currentResourceId && this.totalSelectedCount === 0) {
        return true
      }
      
      // 如果有临时资源信息或资源ID，但没有选中任何知识点，禁用
      if ((this.tempResourceInfo || this.currentResourceId) && this.totalSelectedCount === 0) {
        return true
      }
      
      return false
    }
  },
  
  methods: {
    // 返回按钮
    handleBack() {
      this.$emit('back')
    },
    
    // 加载教师教授的课程列表
    async loadCourses() {
      try {
        // 获取当前登录用户的课程列表
        const response = await listCourse({})
        if (response.code === 200) {
          this.courseOptions = response.rows || []
        }
      } catch (error) {
        console.error('加载课程列表失败:', error)
        this.$message.error('加载课程列表失败')
      }
    },
    
    // 课程选择变化
    async handleCourseChange(courseId) {
      console.log('handleCourseChange called, courseId:', courseId)
      
      // 如果是通过props传入的courseId（课程详情页使用），不需要从courseOptions查找
      if (this.hideCourseSelect && courseId) {
        console.log('直接加载课程数据（hideCourseSelect=true）')
        // 直接加载课程的所有知识点
        await this.loadCourseKnowledgePoints(courseId)
        // 加载课程的章节和小节
        await this.loadChapterSections(courseId)
      } else {
        // 正常流程：从课程选择器选择
        const selectedCourse = this.courseOptions.find(c => c.id === courseId)
        if (selectedCourse) {
          this.uploadForm.courseTitle = selectedCourse.title
          // 加载课程的所有知识点
          await this.loadCourseKnowledgePoints(courseId)
          // 加载课程的章节和小节
          await this.loadChapterSections(courseId)
        }
      }
      // 清空小节选择
      this.uploadForm.sectionPath = []
      this.uploadForm.sectionId = null
    },
    
    // 加载课程的章节和小节（用于级联选择器）
    async loadChapterSections(courseId) {
      try {
        // 获取所有章节
        const chapterResponse = await listChapterByCourse(courseId)
        if (chapterResponse.code === 200) {
          const chapters = chapterResponse.data || []
          
          // 为每个章节加载小节
          const chapterSectionPromises = chapters.map(async (chapter) => {
            const sectionResponse = await listSectionByChapter(chapter.id)
            return {
              id: chapter.id,
              title: chapter.title,
              sections: (sectionResponse.data || []).map(section => ({
                id: section.id,
                title: section.title
              }))
            }
          })
          
          this.chapterSectionOptions = await Promise.all(chapterSectionPromises)
        }
      } catch (error) {
        console.error('加载章节小节失败:', error)
        this.$message.error('加载章节小节失败')
      }
    },
    
    // 小节选择变化
    handleSectionChange(value) {
      if (value && value.length === 2) {
        this.uploadForm.sectionId = value[1] // sectionId是路径的第二个值
      } else {
        this.uploadForm.sectionId = null
      }
    },
    
    // 加载课程的所有知识点
    async loadCourseKnowledgePoints(courseId) {
      try {
        console.log('开始加载课程知识点, courseId:', courseId)
        const response = await listKnowledgePointByCourse(courseId)
        console.log('知识点加载响应:', response)
        if (response.code === 200) {
          this.allCourseKnowledgePoints = response.data || []
          console.log('已加载知识点数量:', this.allCourseKnowledgePoints.length)
        }
      } catch (error) {
        console.error('加载课程知识点失败:', error)
      }
    },
    
    // 取消匹配
    handleCancelMatch(row) {
      this.$confirm('取消匹配后，该知识点将从匹配列表中移除，是否继续？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        // 从recommendations中移除该项
        const index = this.recommendations.findIndex(item => item.kpId === row.kpId)
        if (index !== -1) {
          this.recommendations.splice(index, 1)
        }
        this.$message.success('已取消匹配')
      }).catch(() => {})
    },
    
    // 匹配知识点多选变化
    handleMatchedSelectionChange(selection) {
      this.matchedSelection = selection
    },
    
    // 新知识点多选变化
    handleNewSelectionChange(selection) {
      this.newSelection = selection
    },
    
    // 已有知识点多选变化
    handleAvailableSelectionChange(selection) {
      this.availableSelection = selection
    },
    
    // 批量取消匹配
    handleBatchCancelMatch() {
      if (this.matchedSelection.length === 0) {
        this.$message.warning('请先选择要取消的知识点')
        return
      }
      
      this.$confirm(`确定要取消选中的 ${this.matchedSelection.length} 个匹配吗？`, '批量取消', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        const kpIds = this.matchedSelection.map(item => item.kpId)
        this.recommendations = this.recommendations.filter(item => !kpIds.includes(item.kpId))
        this.matchedSelection = []
        this.$message.success('批量取消成功')
      }).catch(() => {})
    },
    
    // 批量创建新知识点（只创建知识点，不关联资源）
    async handleBatchCreateNew() {
      if (this.newSelection.length === 0) {
        this.$message.warning('请先选择要创建的知识点')
        return
      }
      
      if (!this.uploadForm.courseId) {
        this.$message.error('请先选择课程')
        return
      }
      
      try {
        const kpTitles = this.newSelection.map(item => item.extractedTitle)
        
        // 构建知识点对象数组
        const knowledgePoints = kpTitles.map(title => ({
          courseId: this.uploadForm.courseId,
          title: title,
          level: 1 // 默认级别
        }))
        
        // 调用标准API批量创建知识点，不关联资源
        const response = await batchAddKnowledgePoints(knowledgePoints)
        
        console.log('批量创建知识点响应:', response) // 调试日志
        
        if (response.code === 200) {
          // 后端返回的是创建的知识点数组
          const createdKps = response.data || []
          
          this.$message.success(`成功创建 ${createdKps.length} 个知识点`)
          
          // 将创建的知识点移到匹配区域
          createdKps.forEach(kp => {
            if (kp && kp.id) {
              this.recommendations.push({
                extractedTitle: kp.title,
                kpId: kp.id,
                matched: true,
                similarity: 1.0 // 新创建的设置为100%
              })
            }
          })
          
          // 从新知识点列表中移除
          const createdTitles = new Set(kpTitles)
          this.recommendations = this.recommendations.filter(item => 
            !(item.matched === false && createdTitles.has(item.extractedTitle))
          )
          
          this.newSelection = []
          
          // 重新加载课程知识点
          await this.loadCourseKnowledgePoints(this.uploadForm.courseId)
        }
      } catch (error) {
        console.error('批量创建失败:', error)
        this.$message.error('批量创建失败')
      }
    },
    
    // 单个创建新知识点（只创建知识点，不关联资源）
    async handleCreateSingleNew(row) {
      if (!this.uploadForm.courseId) {
        this.$message.error('请先选择课程')
        return
      }
      
      try {
        // 调用标准API只创建知识点，不关联资源
        const response = await addKnowledgePoint({
          courseId: this.uploadForm.courseId,
          title: row.extractedTitle,
          level: 1 // 默认级别
        })
        
        console.log('创建知识点响应:', response) // 调试日志
        
        if (response.code === 200) {
          // 后端返回的是完整的知识点对象
          const createdKp = response.data
          
          if (!createdKp || !createdKp.id) {
            console.error('无法获取创建的知识点:', response)
            this.$message.error('创建成功但获取ID失败')
            return
          }
          
          this.$message.success(`成功创建知识点：${row.extractedTitle}`)
          
          // 将创建的知识点移到匹配区域（不关联资源）
          this.recommendations.push({
            extractedTitle: createdKp.title,
            kpId: createdKp.id,
            matched: true,
            similarity: 1.0 // 新创建的设置为100%
          })
          
          // 从新增列表中移除该项
          this.recommendations = this.recommendations.filter(item => 
            !(item.extractedTitle === row.extractedTitle && item.matched === false)
          )
          
          // 重新加载课程知识点
          await this.loadCourseKnowledgePoints(this.uploadForm.courseId)
        }
      } catch (error) {
        console.error('创建失败:', error)
        this.$message.error('创建失败')
      }
    },
    
    // 批量添加已有知识点（仅在前端移动，不调用API）
    handleBatchAddAvailable() {
      if (this.availableSelection.length === 0) {
        this.$message.warning('请先选择要添加的知识点')
        return
      }
      
      // 获取已匹配知识点的ID列表，避免重复添加
      const existingKpIds = this.matchedKnowledgePoints.map(item => item.kpId)
      
      // 过滤掉已经存在的知识点
      const toAdd = this.availableSelection.filter(kp => !existingKpIds.includes(kp.id))
      
      if (toAdd.length === 0) {
        this.$message.warning('选中的知识点已经在匹配区域中')
        return
      }
      
      // 将选中的知识点移到已匹配区域，设置100%匹配度
      toAdd.forEach(kp => {
        this.recommendations.push({
          extractedTitle: kp.title,
          kpId: kp.id,
          matched: true,
          similarity: 1.0 // 人工选择的设置为100%
        })
      })
      
      const skipped = this.availableSelection.length - toAdd.length
      if (skipped > 0) {
        this.$message.success(`已添加 ${toAdd.length} 个知识点，跳过 ${skipped} 个已存在的`)
      } else {
        this.$message.success(`已添加 ${toAdd.length} 个知识点到匹配区域`)
      }
      
      this.availableSelection = []
    },
    
    // 单个添加已有知识点（仅在前端移动，不调用API）
    handleAddSingleAvailable(row) {
      // 检查是否已经存在
      const exists = this.matchedKnowledgePoints.some(item => item.kpId === row.id)
      if (exists) {
        this.$message.warning(`知识点「${row.title}」已经在匹配区域中`)
        return
      }
      
      // 将知识点移到已匹配区域，设置100%匹配度
      this.recommendations.push({
        extractedTitle: row.title,
        kpId: row.id,
        matched: true,
        similarity: 1.0 // 人工选择的设置为100%
      })
      
      this.$message.success(`已添加知识点：${row.title}`)
    },
    
    // 文件选择变化
    handleFileChange(file, fileList) {
      this.selectedFile = file.raw
      this.fileList = fileList
    },
    
    // 超出文件数量限制
    handleExceed() {
      this.$message.warning('只能上传一个文件')
    },
    
    // 执行上传和智能分析（仅分析，不保存到数据库）
    async handleUpload() {
      // 验证表单
      if (!this.uploadForm.courseId) {
        this.$message.error('请选择课程')
        return
      }
      if (!this.selectedFile) {
        this.$message.error('请选择文件')
        return
      }
      
      // 初始化AI对话框
      this.initAiDialog()
      
      // 构建FormData
      const formData = new FormData()
      formData.append('file', this.selectedFile)
      formData.append('courseId', this.uploadForm.courseId)
      formData.append('courseTitle', this.uploadForm.courseTitle)
      if (this.uploadForm.description) {
        formData.append('description', this.uploadForm.description)
      }
      
      // 上传并分析（不保存到数据库）
      this.uploading = true
      try {
        // 步骤1: 上传文件用于分析
        this.updateAiStep('upload', 'success', '文件上传成功', '文件已上传，开始解析...')
        
        // 调用新的仅分析API
        const response = await analyzeFileOnlyRenwu3(formData)
        
        console.log('分析响应:', response) // 调试日志
        
        if (response.code === 200) {
          // 判断数据在response还是response.data中
          const data = response.data || response
          
          console.log('解析数据:', data) // 调试日志
          
          // 步骤2: 文档解析
          this.updateAiStep('parse', 'success', '文档解析完成', '成功提取文档文本内容', {
            text: data.extractedText || '文档内容已提取',
            length: data.textLength || 0
          })
          
          // 步骤3: AI提取知识点
          const extractedKps = (data.recommendations || []).map(r => r.extractedTitle)
          this.updateAiStep('extract', 'success', 'AI知识点提取完成', 
            `智谱AI成功提取了${extractedKps.length}个知识点`, extractedKps)
          
          // 步骤4: 知识点匹配
          const matched = data.recommendations.filter(r => r.matched).length
          const unmatched = data.recommendations.length - matched
          this.updateAiStep('match', 'success', '知识点匹配完成', 
            `匹配已完成,发现${matched}个已有知识点,${unmatched}个新知识点`, {
            matched: matched,
            unmatched: unmatched,
            total: data.recommendations.length
          })
          
          this.analysisCompleted = true
          
          // 保存临时资源信息（未保存到数据库）
          this.tempResourceInfo = data.tempResource
          
          // 保存分析结果
          this.uploadResult = {
            message: response.msg,
            recommendationCount: data.recommendationCount
          }
          
          // 显示推荐的知识点
          this.recommendations = (data.recommendations || []).map(item => ({
            ...item,
            selected: item.matched ? true : false // 默认选中已匹配的
          }))
          
          console.log('推荐列表已设置:', this.recommendations) // 调试日志
          console.log('选中的知识点ID:', this.selectedKpIds) // 调试日志
          console.log('临时资源信息:', this.tempResourceInfo) // 调试日志
          
          // 清空currentResourceId，因为还未保存
          this.currentResourceId = null
          
          // 保留文件显示，不清空文件列表
          // this.fileList = []
          // this.selectedFile = null
          
          this.$message.success('AI分析完成! 点击"保存"按钮保存资源和关联')
        } else {
          this.updateAiStep('error', 'danger', '分析失败', response.msg || '分析失败')
          this.$message.error(response.msg || '分析失败')
        }
      } catch (error) {
        console.error('分析失败:', error)
        console.error('错误详情:', error.response) // 打印完整响应
        this.updateAiStep('error', 'danger', '系统错误', error.message)
        this.$message.error('分析失败: ' + error.message)
      } finally {
        this.uploading = false
      }
    },
    
    // 智能分析按钮
    handleAnalyze() {
      this.handleUpload()
    },
    
    // 保存按钮
    async handleSave() {
      // 检查是否选择了小节
      if (!this.uploadForm.sectionId) {
        this.$message.warning('请选择要关联的小节')
        return
      }
      
      // 收集所有已选中的知识点ID（包括匹配的、已有的）
      const matchedKpIds = [
        ...this.selectedKpIds,
        ...this.selectedAvailableKps
      ].filter(id => id)
      
      if (matchedKpIds.length === 0) {
        this.$message.warning('请至少选择一个知识点')
        return
      }
      
      try {
        // 如果有文件但还未保存到数据库，则保存资源
        if (!this.currentResourceId && this.selectedFile) {
          // 第一步：保存资源到数据库
          // 如果有智能分析的临时信息就用，否则手动构建
          let resourceData
          if (this.tempResourceInfo) {
            // 使用智能分析后的临时信息
            resourceData = {
              courseId: this.uploadForm.courseId,
              fileName: this.tempResourceInfo.fileName,
              fileType: this.tempResourceInfo.fileType,
              fileSize: this.tempResourceInfo.fileSize,
              filePath: this.tempResourceInfo.filePath,
              description: this.uploadForm.description || this.tempResourceInfo.description || ''
            }
          } else {
            // 手动匹配的情况：先上传文件
            const formData = new FormData()
            formData.append('file', this.selectedFile)
            formData.append('courseId', this.uploadForm.courseId)
            formData.append('courseTitle', this.uploadForm.courseTitle)
            if (this.uploadForm.description) {
              formData.append('description', this.uploadForm.description)
            }
            
            this.$message.info('正在上传文件...')
            const uploadResponse = await uploadAndAnalyzeRenwu3(formData)
            
            if (uploadResponse.code !== 200) {
              this.$message.error('文件上传失败')
              return
            }
            
            // 获取上传后的资源信息
            const uploadedResource = uploadResponse.resource || uploadResponse.data?.resource
            if (!uploadedResource) {
              this.$message.error('上传成功但获取资源信息失败')
              return
            }
            
            this.currentResourceId = uploadedResource.id
            console.log('手动上传资源已保存，ID:', this.currentResourceId)
            
            // 直接跳到关联知识点步骤
            // 不需要再调用saveResourceRenwu3，因为uploadAndAnalyzeRenwu3已经保存了
          }
          
          // 如果是智能分析后的资源（有tempResourceInfo），调用saveResourceRenwu3
          if (resourceData && !this.currentResourceId) {
            const saveResponse = await saveResourceRenwu3(resourceData)
            
            console.log('保存资源响应:', saveResponse)
            
            if (saveResponse.code !== 200) {
              this.$message.error('保存资源失败: ' + (saveResponse.msg || ''))
              return
            }
            
            const resource = saveResponse.resource || (saveResponse.data && saveResponse.data.resource)
            if (!resource || !resource.id) {
              console.error('无法获取资源ID:', saveResponse)
              this.$message.error('保存成功但获取资源ID失败')
              return
            }
            
            this.currentResourceId = resource.id
            console.log('资源已保存，ID:', this.currentResourceId)
          }
        }
        
        // 第二步：如果有资源ID，将资源关联到课程资源知识点表
        if (this.currentResourceId) {
          const resourceResponse = await confirmKnowledgePointsRenwu3({
            resourceId: this.currentResourceId,
            kpIds: matchedKpIds
          })
          
          if (resourceResponse.code !== 200) {
            this.$message.error('资源关联知识点失败')
            return
          }
        }
        
        // 第三步：将知识点关联到小节
        const sectionResponse = await setSectionKnowledgePoints({
          sectionId: this.uploadForm.sectionId,
          kpIds: matchedKpIds
        })
        
        if (sectionResponse.code === 200) {
          const message = this.currentResourceId 
            ? `资源已保存，关联了 ${matchedKpIds.length} 个知识点到课程资源和小节`
            : `已关联 ${matchedKpIds.length} 个知识点到小节`
          this.$message.success(message)
          // 发送上传成功事件
          this.$emit('upload-success')
          // 清空表单和临时数据
          this.uploadForm = {
            courseId: this.hideCourseSelect ? this.courseId : '',
            courseTitle: '',
            description: '',
            sectionPath: [],
            sectionId: null
          }
          this.fileList = []
          this.selectedFile = null
          this.recommendations = []
          this.currentResourceId = null
          this.tempResourceInfo = null
          this.uploadResult = null
          this.matchedKnowledgePoints = []
        } else {
          this.$message.warning('资源已保存，但小节关联知识点失败')
        }
      } catch (error) {
        console.error('保存失败:', error)
        this.$message.error('保存失败')
      }
    },
    
    // 取消按钮
    async handleCancel() {
      const hasUnsaved = this.tempResourceInfo || this.currentResourceId
      const confirmMessage = hasUnsaved 
        ? '确定要取消吗？已分析的结果和未保存的知识点关联将被清除。' 
        : '确定要取消吗？'
        
      this.$confirm(confirmMessage, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async () => {
        // 如果已经保存了资源到数据库，删除它
        if (this.currentResourceId) {
          try {
            await delResourceRenwu3(this.currentResourceId)
            console.log('已删除资源:', this.currentResourceId)
          } catch (error) {
            console.error('删除资源失败:', error)
          }
        }
        
        // 清空表单和临时数据
        this.uploadForm = {
          courseId: this.hideCourseSelect ? this.courseId : '',
          courseTitle: '',
          description: '',
          sectionPath: [],
          sectionId: null
        }
        this.fileList = []
        this.selectedFile = null
        this.recommendations = []
        this.currentResourceId = null
        this.tempResourceInfo = null
        this.uploadResult = null
        this.$message.info('已取消')
        
        // 如果在课程详情页，返回列表
        if (this.hideCourseSelect) {
          this.$emit('back')
        }
      }).catch(() => {})
    },

    // 初始化AI对话框
    initAiDialog() {
      this.aiDialogVisible = true
      this.analysisCompleted = false
      this.aiSteps = [
        {
          id: 'upload',
          title: '📤 上传文件',
          timestamp: this.getCurrentTime(),
          type: 'primary',
          icon: 'el-icon-loading',
          content: '正在上传文件到服务器...'
        }
      ]
    },

    // 更新AI步骤
    updateAiStep(stepId, type, title, content, data = null) {
      const existingIndex = this.aiSteps.findIndex(s => s.id === stepId)
      const step = {
        id: stepId,
        title: title,
        timestamp: this.getCurrentTime(),
        type: type,
        icon: type === 'success' ? 'el-icon-check' : (type === 'danger' ? 'el-icon-close' : 'el-icon-loading'),
        content: content,
        data: data
      }
      
      if (existingIndex >= 0) {
        this.$set(this.aiSteps, existingIndex, step)
      } else {
        this.aiSteps.push(step)
      }
    },

    // 获取当前时间
    getCurrentTime() {
      const now = new Date()
      return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`
    },

    // 查看推荐结果
    handleViewRecommendations() {
      this.aiDialogVisible = false
      // 滚动到推荐结果区域
      this.$nextTick(() => {
        const resultCard = document.querySelector('.result-card')
        if (resultCard) {
          resultCard.scrollIntoView({ behavior: 'smooth', block: 'start' })
        }
      })
    },
    
    // 从分析对话框打开AI对话
    openChatFromAnalysis() {
      this.aiDialogVisible = false
      this.openChatDialog()
    },
    
    // 选择状态变化
    handleSelectionChange() {
      console.log('选择状态变化, 当前推荐列表:', this.recommendations) // 调试日志
      console.log('当前选中的ID:', this.selectedKpIds) // 调试日志
      // 仅用于更新计算属性
    },
    
    // 确认选中的知识点关联
    async handleConfirmSelected() {
      console.log('点击确认按钮, selectedKpIds:', this.selectedKpIds) // 调试日志
      console.log('selectedNewKps:', this.selectedNewKps) // 调试日志
      console.log('selectedAvailableKps:', this.selectedAvailableKps) // 调试日志
      console.log('currentResourceId:', this.currentResourceId) // 调试日志
      
      if (this.totalSelectedCount === 0) {
        this.$message.warning('请至少选择一个知识点')
        return
      }
      
      try {
        let successCount = 0
        
        // 1. 关联已匹配的知识点
        if (this.selectedKpIds.length > 0) {
          console.log('准备关联已匹配的知识点...') // 调试日志
          const response = await confirmKnowledgePointsRenwu3({
            resourceId: this.currentResourceId,
            kpIds: this.selectedKpIds
          })
          
          console.log('关联接口响应:', response) // 调试日志
          
          if (response.code === 200) {
            successCount += this.selectedKpIds.length
          }
        }
        
        // 2. 关联手动添加的已有知识点
        if (this.selectedAvailableKps.length > 0) {
          console.log('准备关联手动添加的知识点...') // 调试日志
          const response = await confirmKnowledgePointsRenwu3({
            resourceId: this.currentResourceId,
            kpIds: this.selectedAvailableKps
          })
          
          console.log('手动添加关联接口响应:', response) // 调试日志
          
          if (response.code === 200) {
            successCount += this.selectedAvailableKps.length
          }
        }
        
        // 3. 创建新知识点（目前只提示，实际创建需要后端接口）
        if (this.selectedNewKps.length > 0) {
          console.log('需要创建的新知识点:', this.selectedNewKps)
          this.$message.info(`待创建${this.selectedNewKps.length}个新知识点：${this.selectedNewKps.join('、')}`)
          // TODO: 调用后端创建新知识点的接口
        }
        
        if (successCount > 0 || this.selectedNewKps.length > 0) {
          this.$message.success(`成功！已关联${successCount}个知识点，待创建${this.selectedNewKps.length}个新知识点`)
        }
      } catch (error) {
        console.error('操作失败:', error)
        this.$message.error('操作失败: ' + error.message)
      }
    },
    
    // 打开AI对话界面
    openChatDialog() {
      this.chatDialogVisible = true
      
      // 初始化对话上下文
      if (this.chatMessages.length === 0) {
        this.chatContext = {
          courseTitle: this.uploadForm.courseTitle,
          resourceName: this.uploadResult?.resource?.name || '',
          recommendations: this.recommendations,
          totalCount: this.recommendations.length,
          matchedCount: this.recommendations.filter(r => r.matched).length
        }
        
        // 添加欢迎消息
        this.addAIMessage(
          `您好！我是AI智能分析助手。\n\n` +
          `我刚刚完成了对《${this.chatContext.courseTitle}》课程资源的分析，` +
          `共提取了${this.chatContext.totalCount}个知识点，其中${this.chatContext.matchedCount}个已匹配到数据库中的知识点。\n\n` +
          `您可以问我：\n` +
          `• 为什么提取了某个知识点？\n` +
          `• 为什么没有匹配到某个知识点？\n` +
          `• 如何改进匹配准确度？\n` +
          `• 关于这些知识点的任何疑问\n\n` +
          `请随时提问！`
        )
      }
    },

    // 发送对话消息
    async sendChatMessage() {
      if (!this.chatInput.trim()) {
        return
      }

      const userMessage = this.chatInput.trim()
      this.chatInput = ''

      // 添加用户消息
      this.addUserMessage(userMessage)

      // 添加AI加载消息
      const loadingMessageIndex = this.chatMessages.length
      this.chatMessages.push({
        role: 'ai',
        content: '',
        time: this.getCurrentTime(),
        loading: true
      })

      this.chatSending = true
      
      try {
        // TODO: 调用后端AI对话API
        // 这里需要发送用户问题和当前分析上下文给大模型
        // const response = await chatWithAI({
        //   message: userMessage,
        //   context: this.chatContext,
        //   resourceId: this.currentResourceId,
        //   history: this.chatMessages.slice(0, -1) // 发送历史对话
        // })
        
        // 模拟AI响应（实际应该调用后端API）
        await this.simulateAIResponse(userMessage, loadingMessageIndex)
        
      } catch (error) {
        console.error('AI对话失败:', error)
        this.chatMessages[loadingMessageIndex].loading = false
        this.chatMessages[loadingMessageIndex].content = '抱歉，我遇到了一些问题，请稍后再试。'
      } finally {
        this.chatSending = false
        this.scrollToBottom()
      }
    },

    // 模拟AI响应（实际应该替换为后端API调用）
    async simulateAIResponse(userMessage, messageIndex) {
      try {
        // 调用真实的后端AI对话API
        const response = await chatWithAIRenwu3({
          message: userMessage,
          resourceId: this.currentResourceId,
          courseTitle: this.chatContext?.courseTitle || this.uploadForm.courseTitle,
          recommendationCount: this.chatContext?.totalCount || 0,
          matchedCount: this.chatContext?.matchedCount || 0
        })
        
        // 移除加载状态并设置响应内容
        this.chatMessages[messageIndex].loading = false
        
        if (response.code === 200) {
          this.chatMessages[messageIndex].content = response.data || response.msg
        } else {
          this.chatMessages[messageIndex].content = '抱歉，AI回复失败：' + (response.msg || '未知错误')
        }
      } catch (error) {
        console.error('AI对话API调用失败:', error)
        this.chatMessages[messageIndex].loading = false
        
        // 更友好的错误提示
        if (error.message && error.message.includes('timeout')) {
          this.chatMessages[messageIndex].content = '😅 AI思考时间有点长，请稍后再试一次吧~'
        } else if (error.message && error.message.includes('Network Error')) {
          this.chatMessages[messageIndex].content = '🌐 网络似乎不太稳定，请检查网络连接后重试。'
        } else {
          this.chatMessages[messageIndex].content = '😔 抱歉，我暂时无法回答。您可以：\n1. 稍后重试\n2. 检查网络连接\n3. 联系技术支持'
        }
      }
    },

    // 添加用户消息
    addUserMessage(content) {
      this.chatMessages.push({
        role: 'user',
        content: content,
        time: this.getCurrentTime(),
        loading: false
      })
      this.scrollToBottom()
    },

    // 添加AI消息
    addAIMessage(content) {
      this.chatMessages.push({
        role: 'ai',
        content: content,
        time: this.getCurrentTime(),
        loading: false
      })
      this.scrollToBottom()
    },

    // 清空对话
    clearChat() {
      this.$confirm('确定要清空所有对话记录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.chatMessages = []
        this.$message.success('对话已清空')
      }).catch(() => {})
    },

    // 格式化消息内容（支持换行等）
    formatMessage(content) {
      return content.replace(/\n/g, '<br>')
    },

    // 滚动到底部
    scrollToBottom() {
      this.$nextTick(() => {
        const chatMessages = this.$refs.chatMessages
        if (chatMessages) {
          chatMessages.scrollTop = chatMessages.scrollHeight
        }
      })
    }
  }
}
</script>

<style scoped>
.app-container {
  padding: 20px;
}

.upload-card, .result-card {
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.1);
}

.el-upload__tip {
  color: #909399;
  font-size: 12px;
  margin-top: 7px;
}

/* AI对话框样式 */
.ai-dialog-content {
  max-height: 600px;
  overflow-y: auto;
}

.text-preview {
  background: #f5f7fa;
  padding: 15px;
  border-radius: 4px;
  max-height: 300px;
  overflow-y: auto;
  white-space: pre-wrap;
  word-break: break-all;
  font-size: 13px;
  line-height: 1.6;
  color: #606266;
}

.knowledge-points {
  margin-top: 10px;
}

.match-result {
  margin-top: 15px;
}

.match-result h3 {
  font-size: 28px;
  margin: 10px 0;
  color: #303133;
}

.match-result p {
  color: #909399;
  font-size: 14px;
}

/* 时间线样式优化 */
::v-deep .el-timeline-item__timestamp {
  color: #909399;
  font-size: 13px;
}

::v-deep .el-timeline-item__wrapper h4 {
  margin: 0 0 8px 0;
  font-size: 16px;
  color: #303133;
}

::v-deep .el-timeline-item__wrapper p {
  margin: 5px 0;
  color: #606266;
  font-size: 14px;
}

/* AI对话界面样式 */
.chat-container {
  display: flex;
  flex-direction: column;
  height: 65vh;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: #f5f7fa;
  border-radius: 4px;
  margin-bottom: 15px;
}

.message-item {
  display: flex;
  margin-bottom: 20px;
  animation: fadeIn 0.3s ease-in;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.user-message {
  flex-direction: row-reverse;
}

.message-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;
}

.user-message .message-avatar {
  background: #409EFF;
  color: white;
  margin-left: 10px;
}

.ai-message .message-avatar {
  background: #67C23A;
  color: white;
  margin-right: 10px;
}

.message-content {
  max-width: 70%;
  background: white;
  border-radius: 8px;
  padding: 12px 16px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.user-message .message-content {
  background: #409EFF;
  color: white;
}

.message-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 12px;
}

.user-message .message-header {
  color: rgba(255,255,255,0.9);
}

.ai-message .message-header {
  color: #909399;
}

.message-role {
  font-weight: bold;
}

.message-time {
  opacity: 0.8;
}

.message-text {
  line-height: 1.6;
  word-wrap: break-word;
}

.user-message .message-text {
  color: white;
}

.ai-message .message-text {
  color: #303133;
}

/* 打字指示器 */
.typing-indicator {
  display: flex;
  gap: 4px;
  padding: 8px 0;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #409EFF;
  animation: typing 1.4s infinite;
}

.typing-indicator span:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-indicator span:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typing {
  0%, 60%, 100% {
    transform: translateY(0);
    opacity: 0.7;
  }
  30% {
    transform: translateY(-10px);
    opacity: 1;
  }
}

.chat-input-area {
  border-top: 1px solid #DCDFE6;
  padding-top: 15px;
}

.chat-actions {
  margin-top: 10px;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

/* 滚动条美化 */
.chat-messages::-webkit-scrollbar {
  width: 6px;
}

.chat-messages::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* 批量操作表头样式 */
.batch-action-header {
  transition: all 0.3s;
  user-select: none;
}

.batch-action-header:hover {
  font-weight: bold;
}

/* 表格行高优化 */
::v-deep .el-table--small .el-table__cell {
  padding: 4px 0;
}

::v-deep .el-table--small td,
::v-deep .el-table--small th {
  padding: 4px 0;
}
</style>
