<template>
  <div class="app-container">
    <div class="page-header">
      <h2>AI个性化学习推荐</h2>
      <p>基于学生知识点掌握情况，智能推荐学习资源和提升方案（支持查看历史推荐）</p>
    </div>

    <el-card shadow="hover" class="search-card">
      <el-form :model="searchForm" :inline="true" label-width="100px" size="small">
        <el-form-item label="学生ID" required>
          <el-input v-model.number="searchForm.studentUserId" placeholder="如：24" type="number" style="width: 180px;" />
        </el-form-item>
        <el-form-item label="课程ID" required>
          <el-input v-model.number="searchForm.courseId" placeholder="如：123" type="number" style="width: 180px;" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchRecommendData" :disabled="loading">获取推荐</el-button>
          <el-button @click="resetForm" :disabled="loading">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never" class="result-card" :body-style="{ padding: '20px' }">
      
      <!-- Loading 动画 -->
      <div v-if="loading" class="ai-loading-container">
        <div class="ai-spinner">
          <div class="circle inner"></div>
          <div class="circle outer"></div>
        </div>
        <h3 class="loading-title">AI 正在为您定制学习方案</h3>
        <div class="loading-steps">
          <div class="step-item" :class="{ active: loadingStep >= 1, completed: loadingStep > 1 }">
            <i class="el-icon-cpu"></i> 分析知识薄弱点...
          </div>
          <div class="step-item" :class="{ active: loadingStep >= 2, completed: loadingStep > 2 }">
            <i class="el-icon-connection"></i> 检索关联学习资源...
          </div>
          <div class="step-item" :class="{ active: loadingStep >= 3, completed: loadingStep > 3 }">
            <i class="el-icon-magic-stick"></i> 生成个性化推荐策略...
          </div>
        </div>
      </div>

      <!-- 无数据 / 错误状态 -->
      <div v-else-if="!recommendResult && !loading" class="no-data">
        <img src="https://img.icons8.com/ios/100/cccccc/search--v1.png" alt="search" style="opacity:0.5; width:60px; margin-bottom:10px;">
        <p>请输入学生ID和课程ID，点击「获取推荐」按钮</p>
      </div>

      <div v-else-if="recommendResult && recommendResult.avatarStatus === 'error'" class="error-data">
        <i class="el-icon-warning error-icon"></i>
        <p>{{ recommendResult.recommendContent || '推荐获取失败' }}</p>
      </div>

      <!-- 成功展示 -->
      <div v-else-if="recommendResult && recommendResult.avatarStatus === 'completed'" class="result-content-wrapper">
        
        <!-- 关联知识点标签 -->
        <div class="result-section" v-if="statusTags.length > 0">
          <div class="section-header">
            <i class="el-icon-pie-chart" style="color: #409EFF; margin-right: 5px;"></i>
            <span>关联知识点状态</span>
          </div>
          <div class="status-tags">
            <el-tag 
              v-for="(tag, index) in statusTags" 
              :key="index"
              type="warning"
              effect="plain"
              size="small"
              class="kp-tag"
            >
              {{ tag.kpName }}
            </el-tag>
          </div>
        </div>

        <!-- 折叠式推荐批次 -->
        <div class="result-section">
          <div class="section-header" style="margin-top: 20px;">
            <i class="el-icon-collection-tag" style="color: #409EFF; margin-right: 5px;"></i>
            <span>历史推荐记录（按批次展示）</span>
          </div>
          
          <div v-if="recommendBatches.length === 0" class="no-data-mini">暂无推荐记录</div>

          <el-collapse v-else accordion v-model="activeBatchName" class="custom-collapse">
            <el-collapse-item 
              v-for="(batch, batchIndex) in recommendBatches" 
              :key="batch.batchId"
              :name="batch.batchId"
            >
              <template slot="title">
                <div class="collapse-title">
                  <span class="batch-tag">第 {{ recommendBatches.length - batchIndex }} 批</span>
                  <span class="batch-time">{{ formatTime(batch.createTime) }}</span>
                  <span class="batch-count">共 {{ batch.items.length }} 条建议</span>
                </div>
              </template>

              <div class="batch-content">
                <el-card 
                  v-for="(item, index) in batch.items" 
                  :key="item.id"
                  class="recommend-card"
                  shadow="hover"
                  :body-style="{ padding: '0' }" 
                >
                  <div class="card-header">
                    <div class="header-left">
                      <span class="index-badge">{{ index + 1 }}</span>
                      <!-- 标题区 -->
                      <h4 class="action-title">{{ extractRecommendAction(item.recommendReason, item.recommendType) }}</h4>
                    </div>
                    <el-tag :type="getStatusTagType(item.status)" size="mini" effect="dark" class="status-tag-right">
                      {{ getStatusText(item.status) }}
                    </el-tag>
                  </div>
                  
                  <div class="card-body">
                    <!-- 正文区 -->
                    <div class="content-text" v-html="cleanAndFormatContent(item.recommendReason)"></div>
                    
                    <div class="card-footer">
                      <div class="footer-item">
                        <i class="el-icon-price-tag"></i> 关联：{{ formatKpIds(item.relatedKpIds, item) }}
                      </div>
                      <div class="footer-item">
                        <i class="el-icon-aim"></i> 目标ID：{{ item.targetId }}
                      </div>
                    </div>
                  </div>
                </el-card>
              </div>
            </el-collapse-item>
          </el-collapse>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script>
import { getRecommendResult } from '@/api/learning/aiRecommend'

export default {
  name: 'AiRecommend',
  data() {
    return {
      searchForm: { studentUserId: '', courseId: '' },
      recommendResult: null,
      loading: false,
      loadingStep: 0,
      loadingTimer: null,
      statusTags: [],
      recommendBatches: [],
      activeBatchName: ''
    }
  },
  beforeDestroy() {
    this.clearLoadingTimer()
  },
  methods: {
    fetchRecommendData() {
      if (!this.searchForm.studentUserId) return this.$message.warning('请输入学生ID')
      if (!this.searchForm.courseId) return this.$message.warning('请输入课程ID')

      this.startLoadingProcess()
      this.statusTags = []
      this.recommendBatches = []
      this.recommendResult = null

      getRecommendResult(this.searchForm)
        .then(response => {
          setTimeout(() => {
            if (response && response.data) {
              this.recommendResult = response.data
              this.handleRecommendItemList(response.data.recommendItemList || [])
              this.extractTagsFromRecommendations(response.data.recommendItemList || [])
              
              if (this.recommendBatches.length > 0) {
                this.activeBatchName = this.recommendBatches[0].batchId
              }
              
              this.$message.success('AI 推荐方案生成完毕')
            } else {
              this.recommendResult = { avatarStatus: 'error', recommendContent: '后端返回数据格式异常' }
            }
            this.stopLoadingProcess()
          }, 1000) 
        })
        .catch(error => {
          this.recommendResult = { avatarStatus: 'error', recommendContent: '加载失败：' + (error.msg || error.message || '网络异常') }
          this.stopLoadingProcess()
        })
    },

    startLoadingProcess() {
      this.loading = true
      this.loadingStep = 1
      this.clearLoadingTimer()
      this.loadingTimer = setInterval(() => {
        if (this.loadingStep < 3) {
          this.loadingStep++
        }
      }, 800)
    },
    stopLoadingProcess() {
      this.loadingStep = 3
      this.clearLoadingTimer()
      this.loading = false
    },
    clearLoadingTimer() {
      if (this.loadingTimer) {
        clearInterval(this.loadingTimer)
        this.loadingTimer = null
      }
    },

    resetForm() {
      this.searchForm = { studentUserId: '', courseId: '' }
      this.recommendResult = null
      this.statusTags = []
      this.recommendBatches = []
    },

    handleRecommendItemList(itemList) {
      if (!itemList.length) {
        this.recommendBatches = []
        return
      }
      const batchMap = new Map()
      itemList.forEach(item => {
        const batchId = item.batchId
        if (!batchMap.has(batchId)) {
          batchMap.set(batchId, {
            batchId: batchId,
            createTime: item.createTime,
            items: []
          })
        }
        batchMap.get(batchId).items.push(item)
      })
      this.recommendBatches = Array.from(batchMap.values())
        .sort((a, b) => new Date(b.createTime) - new Date(a.createTime))
    },

    extractRecommendAction(content, type) {
      if (!content) return this.getActionTypeName(type)
      const actionRegex = /(?:推荐动作|建议动作|Action)[\*]*[:：]\s*(.+?)(\n|$|<br>)/i
      let match = content.match(actionRegex)
      if (match && match[1]) {
        return match[1].replace(/[\*#]/g, '').trim() 
      }
      const lines = content.split('\n').map(l => l.trim()).filter(l => l)
      if (lines.length > 0) {
        const firstLine = lines[0].replace(/^[\d\.\s\*]+/, '')
        if (firstLine.length < 20) {
           return firstLine.replace(/[:：]$/, '')
        }
      }
      return this.getActionTypeName(type)
    },

    cleanAndFormatContent(content) {
      if (!content) return ''
      // 移除标题行
      content = content.replace(/^[\d\.\s\*]*(推荐动作|Action)[\*]*[:：].+?(\n|$)/gim, '')
      // 移除行首序号
      content = content.replace(/^\s*[\d]+[、.]\s*/gm, '')
      return this.formatContent(content)
    },

    // ============ 核心美化逻辑 ============
    formatContent(content) {
      if (!content) return ''
      
      // 1. 关键字段美化：去掉前面的横线和星号，直接匹配关键字并加粗
      // 匹配模式：(换行或开头) + (可能的横线/空格) + 关键词 + 冒号
      const fieldRegex = /(?:^|\n|%%BR%%)\s*[-]*\s*[\*]*(推荐动作|视频位置|视频URL|重点关注内容|对应错题|执行建议)[\*]*[：:]/g
      
      // 替换为：换行 + 加粗带颜色的标签Span
      content = content.replace(fieldRegex, '<br><span class="label-strong">$1：</span>')

      // 如果开头多了一个BR，去掉它
      if (content.startsWith('<br>')) {
        content = content.substring(4);
      }

      // 2. 作业名称
      const assignmentRegex = /作业《([^》]+)》（ID：([^）]+)）/g
      content = content.replace(assignmentRegex, 
        '<span class="assignment-tag">作业《$1》</span><span class="assignment-id-tag">（ID：$2）</span>'
      )
      
      // 3. 剩余符号清理
      content = content.replace(/\*/g, '').replace(/-{3,}/g, '')
      
      // 4. 标签
      content = content.replace(/【(.+?)】/g, '<span class="inline-tag">$1</span>')
      
      // 5. 链接
      content = content.replace(/(http:\/\/\S+(\.mp4|\.html|\.pdf)?)/g, '<a href="$1" target="_blank" class="content-link"><i class="el-icon-link"></i> 点击查看资源</a>')
      
      return content || '<span style="color:#ccc">暂无详细描述</span>'
    },

    extractTagsFromRecommendations(itemList) {
      const tags = []
      const seenIds = new Set()
      itemList.forEach(item => {
        const ids = (item.relatedKpIds || '').split(',')
        let names = []
        if (item.relatedKpNames) {
           names = item.relatedKpNames.split(/[,，、]/)
        }
        ids.forEach((idStr, index) => {
          const id = idStr.trim()
          if (id && id !== '无' && !seenIds.has(id)) {
            const name = (names[index] && names[index].trim()) ? names[index].trim() : `知识点${id}`
            tags.push({ kpId: id, kpName: name })
            seenIds.add(id)
          }
        })
      })
      this.statusTags = tags
    },

    formatTime(timeStr) {
      if (!timeStr) return ''
      const date = new Date(timeStr)
      return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
    },

    getActionTypeName(type) {
      const typeMap = {
        'video': '观看视频学习',
        'exercise': '习题训练',
        'resource': '资料补充学习',
        'kp_review': '知识点复盘巩固'
      }
      return typeMap[type] || '个性化提升'
    },

    getStatusText(status) {
      const statusMap = { 'pending': '待处理', 'viewed': '已查看', 'completed': '已完成', 'expired': '已过期' }
      return statusMap[status] || '未知状态'
    },
    getStatusTagType(status) {
      const typeMap = { 'pending': 'danger', 'viewed': 'primary', 'completed': 'success', 'expired': 'info' }
      return typeMap[status] || 'info'
    },

    formatKpIds(kpIdsStr, item) {
      if (item && item.relatedKpNames) {
        return item.relatedKpNames.replace(/[,，]/g, '、')
      }
      if (!kpIdsStr || kpIdsStr === '无') return '暂无关联'
      return kpIdsStr.split(',').map(kpId => `知识点${kpId.trim()}`).join('、')
    }
  }
}
</script>

<style scoped>
.app-container { padding: 20px; background-color: #f5f7fa; min-height: 100vh; }
.page-header { margin-bottom: 20px; }
.page-header h2 { font-size: 22px; color: #303133; font-weight: 700; margin-bottom: 8px; }
.page-header p { color: #909399; font-size: 13px; }
.search-card { border-radius: 8px; margin-bottom: 15px; border: none; }
.result-card { border-radius: 8px; border: none; min-height: 400px; position: relative; }

/* Loading (保持原有) */
.ai-loading-container { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 60px 0; }
.ai-spinner { position: relative; width: 80px; height: 80px; margin-bottom: 25px; }
.circle { position: absolute; border-radius: 50%; border: 3px solid transparent; }
.circle.outer { width: 100%; height: 100%; border-top-color: #409EFF; border-bottom-color: #409EFF; animation: spin 1.5s linear infinite; }
.circle.inner { width: 60%; height: 60%; top: 20%; left: 20%; border-left-color: #67C23A; border-right-color: #67C23A; animation: spin-reverse 1s linear infinite; }
@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
@keyframes spin-reverse { 0% { transform: rotate(0deg); } 100% { transform: rotate(-360deg); } }
.loading-title { font-size: 18px; color: #303133; margin-bottom: 20px; font-weight: 600; }
.loading-steps { text-align: left; width: 240px; }
.step-item { margin-bottom: 12px; color: #C0C4CC; font-size: 14px; transition: all 0.3s; display: flex; align-items: center; }
.step-item i { margin-right: 8px; }
.step-item.active { color: #409EFF; font-weight: 600; transform: translateX(5px); }
.step-item.completed { color: #67C23A; }

.section-header { font-size: 15px; font-weight: 600; color: #303133; margin-bottom: 12px; display: flex; align-items: center; }
.kp-tag { margin: 0 8px 8px 0; }

/* 增强样式的部分 */
::v-deep .assignment-tag { color: #409EFF; font-weight: 600; background: #ecf5ff; padding: 0 4px; border-radius: 2px; }
::v-deep .assignment-id-tag { color: #909399; font-size: 12px; margin-left: 4px; }

/* Collapse */
.custom-collapse { border: none; }
::v-deep .el-collapse-item__header { background-color: #f9fafc; border-radius: 6px; margin-bottom: 10px; border: 1px solid #ebeef5; padding: 0 15px; height: 50px; line-height: 50px; font-size: 14px; }
::v-deep .el-collapse-item__header.is-active { border-bottom-left-radius: 0; border-bottom-right-radius: 0; border-bottom: 1px solid #ebeef5; }
::v-deep .el-collapse-item__wrap { border-bottom: none; background-color: transparent; }
::v-deep .el-collapse-item__content { padding: 15px 5px 5px 5px; }

.collapse-title { width: 100%; display: flex; align-items: center; }
.batch-tag { background: #e6a23c; color: #fff; padding: 2px 8px; border-radius: 4px; font-size: 12px; margin-right: 10px; }
.batch-time { font-weight: 600; margin-right: 15px; }
.batch-count { color: #909399; font-size: 12px; }

/* Cards */
.recommend-card { border: 1px solid #e4e7ed; margin-bottom: 15px; overflow: visible; }
.card-header { background: linear-gradient(to right, #fdf6ec, #fff); padding: 12px 15px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #faecd8; }
.header-left { display: flex; align-items: center; }
.index-badge { background: #e6a23c; color: #fff; width: 22px; height: 22px; line-height: 22px; text-align: center; border-radius: 50%; font-size: 12px; margin-right: 8px; font-weight: bold; }
.action-title { margin: 0; font-size: 15px; color: #303133; font-weight: 600; }
.card-body { padding: 18px 20px; } /* 增加内边距 */

.content-text {
  font-size: 14px;
  color: #555; /* 字体颜色稍微加深 */
  line-height: 1.8; /* 增加行高，阅读更舒适 */
}

/* 关键：美化 Label Strong 样式 */
::v-deep .label-strong {
  color: #303133;      /* 深黑色 */
  font-weight: 700;    /* 粗体 */
  margin-right: 3px;   /* 右侧间距 */
  font-size: 14px;     /* 字号 */
  display: inline-block;
  margin-top: 4px;     /* 增加段前距 */
}

::v-deep .inline-tag { display: inline-block; background: #ecf5ff; color: #409EFF; font-size: 12px; padding: 0 6px; border-radius: 3px; margin-right: 5px; }
::v-deep .content-link { color: #409EFF; text-decoration: none; font-weight: 500; }
::v-deep .content-link:hover { text-decoration: underline; }

.card-footer { margin-top: 15px; padding-top: 12px; border-top: 1px dashed #ebeef5; display: flex; gap: 20px; font-size: 13px; color: #909399; }
.footer-item i { margin-right: 4px; }

.no-data { text-align: center; padding: 60px 0; }
.no-data p { margin-top: 10px; color: #909399; }
.no-data-mini { text-align: center; color: #c0c4cc; padding: 20px; }
</style>