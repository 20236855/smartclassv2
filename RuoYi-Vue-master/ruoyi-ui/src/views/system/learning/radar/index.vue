<template>
  <div class="app-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h2>学生学习数据中心</h2>
      <p>整合能力雷达图与数字分身，全方位展示学生学习情况</p>
    </div>

    <!-- 搜索表单 -->
    <el-card shadow="hover" class="search-card">
      <el-form :model="searchForm" :inline="true" label-width="100px">
        <el-form-item label="学生ID" required>
          <el-input
            v-model.number="searchForm.studentId"
            placeholder="请输入学生ID（如：24）"
            type="number"
            style="width: 200px;"
          />
        </el-form-item>
        <el-form-item label="课程ID" required>
          <el-input
            v-model.number="searchForm.courseId"
            placeholder="请输入课程ID（如：123）"
            type="number"
            style="width: 200px;"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">查询数据</el-button>
          <el-button @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Tab切换：雷达图 + 数字分身 -->
    <el-tabs v-model="activeTab" type="card" class="data-tabs" v-loading="loading">
      
      <!-- Tab 1: 能力雷达图 -->
      <el-tab-pane label="能力雷达图" name="radar">
        <el-card shadow="hover" class="radar-card">
          <h3 class="chart-title">能力掌握情况雷达图</h3>
          <div class="chart-wrapper">
            <div id="radarChart" class="radar-chart-container"></div>
          </div>
          <div class="no-data" v-if="!loading && radarData.length === 0">
            暂无雷达图数据，请输入正确的学生ID和课程ID查询
          </div>
        </el-card>
      </el-tab-pane>

      <!-- Tab 2: 数字分身 -->
      <el-tab-pane label="数字分身" name="twin">
        <div class="result-container">
          <div class="no-data" v-if="!loading && !digitalTwinResult">
            暂无数字分身数据，请输入正确的学生ID和课程ID查询
          </div>

          <div v-if="!loading && digitalTwinResult" class="result-content">
            
            <!-- ================= 1. 新增：全家福展示栏 (Top Bar) ================= -->
            <div class="twins-preview-bar">
              <div class="bar-title">探索学习分身类型</div>
              <div class="twins-row">
                <div 
                  v-for="type in ['稳步积累型', '逻辑攻坚型', '高效突击型', '查漏补缺型']" 
                  :key="type" 
                  class="mini-twin-item"
                  :class="{ 'is-active': digitalTwinResult.twinType === type }"
                >
                  <!-- 选中标记 -->
                  <div v-if="digitalTwinResult.twinType === type" class="current-badge">我的</div>
                  
                  <!-- 迷你头像 SVG -->
                  <div class="mini-avatar-circle" :style="{ borderColor: getDebugColor(type) }">
                    <svg class="avatar-mini" viewBox="0 0 200 200">
                      <defs><clipPath :id="'clip-mini-' + type"><circle cx="100" cy="100" r="90" /></clipPath></defs>
                      
                      <!-- 1. 稳步 (蓝) -->
                      <g v-if="type === '稳步积累型'">
                        <circle cx="100" cy="100" r="90" fill="#ecf5ff" />
                        <rect x="85" y="110" width="30" height="40" fill="#ffdec7" />
                        <rect x="70" y="60" width="60" height="80" rx="25" ry="25" fill="#ffdec7" />
                        <path d="M50 190 L50 160 Q50 140 100 140 Q150 140 150 160 L150 190 Z" fill="#409EFF" :clip-path="'url(#clip-mini-' + type + ')'"/>
                        <path d="M90 140 L100 190 L110 140 Z" fill="#fff" />
                        <path d="M95 140 L100 170 L105 140 Z" fill="#303133" />
                        <!-- 头发加厚 v7 -->
                        <path d="M68 91 Q68 61 100 61 Q132 61 132 91 L132 85 Q132 61 100 61 Q68 61 68 85 Z" fill="#303133" />
                        <circle cx="85" cy="95" r="3" fill="#303133" />
                        <circle cx="115" cy="95" r="3" fill="#303133" />
                        <path d="M95 110 Q100 113 105 110" stroke="#c08e70" stroke-width="2" fill="none" />
                      </g>
                      <!-- 2. 逻辑 (绿) -->
                      <g v-else-if="type === '逻辑攻坚型'">
                        <circle cx="100" cy="100" r="90" fill="#f0f9eb" />
                        <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" fill="#67C23A" :clip-path="'url(#clip-mini-' + type + ')'" />
                        <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" />
                        <path d="M68 100 Q68 60 100 60 Q132 60 132 100 L132 80 Q100 60 68 80 Z" fill="#5e4636" />
                        <circle cx="85" cy="95" r="3" fill="#303133" />
                        <circle cx="115" cy="95" r="3" fill="#303133" />
                        <path d="M97 110 L103 110" stroke="#c08e70" stroke-width="2" />
                        <circle cx="125" cy="130" r="12" fill="#ffdec7" stroke="#f0f9eb" stroke-width="2" />
                        <g><path d="M145 60 Q155 40 165 60 Q165 70 155 70 L150 70 Z" fill="#E6A23C" /></g>
                      </g>
                      <!-- 3. 高效 (橙) -->
                      <g v-else-if="type === '高效突击型'">
                        <circle cx="100" cy="100" r="90" fill="#fdf6ec" />
                        <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" fill="#E6A23C" :clip-path="'url(#clip-mini-' + type + ')'" />
                        <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" />
                        <rect x="68" y="78" width="64" height="12" fill="#F56C6C" rx="3" />
                        <path d="M68 78 Q68 75 100 75 Q132 75 132 78 L135 75 L100 58 L65 75 Z" fill="#303133" />
                        <circle cx="85" cy="98" r="3" fill="#303133" />
                        <circle cx="115" cy="98" r="3" fill="#303133" />
                        <path d="M95 115 Q100 110 105 115" stroke="#c08e70" stroke-width="2" fill="none" />
                      </g>
                      <!-- 4. 查漏 (灰) -->
                      <g v-else>
                        <circle cx="100" cy="100" r="90" fill="#f4f4f5" />
                        <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" fill="#909399" :clip-path="'url(#clip-mini-' + type + ')'" />
                        <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" />
                        <path d="M68 90 Q68 55 100 55 Q132 55 132 90 L132 80 Q100 60 68 80 Z" fill="#303133" />
                        <circle cx="85" cy="95" r="3" fill="#303133" />
                        <circle cx="115" cy="95" r="3" fill="#303133" />
                        <path d="M98 112 Q100 114 102 112" stroke="#c08e70" stroke-width="2" fill="none" />
                        <circle cx="120" cy="110" r="15" fill="none" stroke="#303133" stroke-width="2" />
                        <line x1="120" y1="125" x2="120" y2="135" stroke="#303133" stroke-width="3" />
                      </g>
                    </svg>
                  </div>
                  <div class="mini-label">{{ type.substring(0, 2) }}型</div>
                </div>
              </div>
            </div>
            <!-- ================= 全家福 END ================= -->

            <!-- 2. 正式展示区域 (Main Avatar) -->
            <div class="twin-character-container">
              <div class="avatar-circle" :style="{ borderColor: twinColor + '40' }">
                <svg class="avatar-base" viewBox="0 0 200 200" :key="'real-svg-v7-' + digitalTwinResult.twinType">
                  <defs><clipPath id="avatar-clip-real"><circle cx="100" cy="100" r="90" /></clipPath></defs>
                  
                  <!-- 1. 稳步积累型 (头发加厚 v7) -->
                  <g v-if="digitalTwinResult.twinType === '稳步积累型'" class="avatar-group steady-type">
                    <circle cx="100" cy="100" r="90" fill="#ecf5ff" />
                    <rect x="85" y="110" width="30" height="40" fill="#ffdec7" />
                    <rect x="70" y="60" width="60" height="80" rx="25" ry="25" fill="#ffdec7" />
                    <path d="M50 190 L50 160 Q50 140 100 140 Q150 140 150 160 L150 190 Z" :fill="twinColor" clip-path="url(#avatar-clip-real)"/>
                    <path d="M90 140 L100 190 L110 140 Z" fill="#fff" />
                    <path d="M95 140 L100 170 L105 140 Z" fill="#303133" />
                    <!-- 关键修正：头发加厚 -->
                    <path d="M68 91 Q68 61 100 61 Q132 61 132 91 L132 85 Q132 61 100 61 Q68 61 68 85 Z" fill="#303133" />
                    <circle cx="85" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <circle cx="115" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <g stroke="#303133" stroke-width="1.5" fill="none" opacity="0.8">
                       <rect x="78" y="88" width="14" height="10" rx="2" />
                       <rect x="108" y="88" width="14" height="10" rx="2" />
                       <line x1="92" y1="93" x2="108" y2="93" />
                    </g>
                    <path d="M95 110 Q100 113 105 110" stroke="#c08e70" stroke-width="2" fill="none" stroke-linecap="round" />
                  </g>

                  <!-- 2. 逻辑攻坚型 -->
                  <g v-else-if="digitalTwinResult.twinType === '逻辑攻坚型'" class="avatar-group logic-type">
                    <circle cx="100" cy="100" r="90" fill="#f0f9eb" />
                    <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" :fill="twinColor" clip-path="url(#avatar-clip-real)" />
                    <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" />
                    <path d="M68 100 Q68 60 100 60 Q132 60 132 100 L132 80 Q100 60 68 80 Z" fill="#5e4636" />
                    <circle cx="85" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <circle cx="115" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <path d="M97 110 L103 110" stroke="#c08e70" stroke-width="2" stroke-linecap="round" />
                    <circle cx="125" cy="130" r="12" fill="#ffdec7" stroke="#f0f9eb" stroke-width="2" />
                    <g class="idea-bulb">
                      <path d="M145 60 Q155 40 165 60 Q165 70 155 70 L150 70 Z" fill="#E6A23C" />
                      <line x1="140" y1="50" x2="135" y2="45" stroke="#E6A23C" stroke-width="2" />
                      <line x1="170" y1="50" x2="175" y2="45" stroke="#E6A23C" stroke-width="2" />
                      <line x1="155" y1="35" x2="155" y2="30" stroke="#E6A23C" stroke-width="2" />
                    </g>
                  </g>

                  <!-- 3. 高效突击型 -->
                  <g v-else-if="digitalTwinResult.twinType === '高效突击型'" class="avatar-group efficient-type">
                    <circle cx="100" cy="100" r="90" fill="#fdf6ec" />
                    <path d="M20 100 L180 100 M40 50 L160 50" stroke="#faecd8" stroke-width="2" class="bg-speed-lines" />
                    <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" :fill="twinColor" clip-path="url(#avatar-clip-real)" />
                    <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" class="face-tilt" />
                    <rect x="68" y="78" width="64" height="12" fill="#F56C6C" rx="3" class="face-tilt" />
                    <path d="M68 78 Q68 75 100 75 Q132 75 132 78 L135 75 L100 58 L65 75 Z" fill="#303133" class="face-tilt" />
                    <g class="face-tilt">
                      <line x1="80" y1="90" x2="90" y2="92" stroke="#303133" stroke-width="2" />
                      <line x1="110" y1="92" x2="120" y2="90" stroke="#303133" stroke-width="2" />
                      <circle cx="85" cy="98" r="3" fill="#303133" />
                      <circle cx="115" cy="98" r="3" fill="#303133" />
                      <path d="M95 115 Q100 110 105 115" stroke="#c08e70" stroke-width="2" fill="none" />
                    </g>
                  </g>

                  <!-- 4. 查漏补缺型 -->
                  <g v-else class="avatar-group gap-type">
                    <circle cx="100" cy="100" r="90" fill="#f4f4f5" />
                    <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" :fill="twinColor" clip-path="url(#avatar-clip-real)" />
                    <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" />
                    <path d="M68 90 Q68 55 100 55 Q132 55 132 90 L132 80 Q100 60 68 80 Z" fill="#303133" />
                    <circle cx="85" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <circle cx="115" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <path d="M98 112 Q100 114 102 112" stroke="#c08e70" stroke-width="2" fill="none" />
                    <g class="magnifier-float">
                      <circle cx="120" cy="110" r="15" fill="rgba(255,255,255,0.3)" stroke="#303133" stroke-width="2" />
                      <line x1="120" y1="125" x2="120" y2="145" stroke="#303133" stroke-width="3" stroke-linecap="round" />
                    </g>
                  </g>
                </svg>
              </div>
              
              <div class="character-info">
                <div class="info-header">
                   <h2 :style="{ color: twinColor }">{{ digitalTwinResult.twinType }}</h2>
                   <el-tag size="small" effect="plain" :type="twinTypeTagType" class="ai-badge">AI 智能画像</el-tag>
                </div>
                <p class="info-text">
                  <i class="el-icon-chat-dot-round" style="color: #909399; margin-right: 4px;"></i>
                  学习风格如同<strong>{{ getCharacterDesc(digitalTwinResult.twinType) }}</strong>
                </p>
                <div class="advice-box" :style="{ borderLeftColor: twinColor }">
                  <strong>💡 提升建议：</strong>{{ getAdvice(digitalTwinResult.twinType) }}
                </div>
              </div>
            </div>

            <!-- 3. 数字分身概览卡片 -->
            <el-card shadow="hover" class="overview-card">
              <div class="overview-header">
                <h3 class="card-title">数字分身概览</h3>
                <el-tag :type="twinTypeTagType" size="large" class="twin-type-tag">
                  {{ digitalTwinResult.twinType }}
                </el-tag>
              </div>
              <div class="overview-body">
                <div class="score-item">
                  <span class="label">匹配分数：</span>
                  <span class="score" :style="{ color: twinColor }">{{ digitalTwinResult.score }}分</span>
                  <span class="total-score">（满分25分）</span>
                </div>
                <div class="feature-title">核心特征：</div>
                <div class="feature-tags">
                  <el-tag 
                    v-for="(feature, index) in digitalTwinResult.features" 
                    :key="index" 
                    type="info" 
                    effect="plain"
                    class="feature-tag"
                  >
                    {{ feature }}
                  </el-tag>
                </div>
              </div>
            </el-card>

            <!-- 4. 得分明细表格 -->
            <el-card shadow="hover" class="detail-card">
              <h3 class="card-title">各分身得分明细</h3>
              <el-table 
                :data="digitalTwinResult.scoreDetails" 
                border 
                stripe 
                style="width: 100%;"
                :header-cell-style="{ 'background-color': '#f5f7fa', 'font-weight': 600 }"
              >
                <el-table-column label="分身类型" prop="twinType" width="180" align="center">
                  <template #default="scope">
                    <el-tag :type="getTagType(scope.row.twinType)" size="medium">
                      {{ scope.row.twinType }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="匹配分数" prop="score" width="120" align="center">
                  <template #default="scope">
                    <span class="table-score">{{ scope.row.score }}分</span>
                  </template>
                </el-table-column>
 <el-table-column label="规则匹配情况" prop="ruleMatches">
  <template #default="scope">
    <div class="rule-matches">
      <div v-for="(rule, index) in scope.row.ruleMatches" :key="index" class="rule-item">
        <!-- 修复逻辑：只有包含'符合' 且 不包含'不符合' 时才打勾 -->
        <i class="el-icon-circle-check" v-if="rule.includes('符合') && !rule.includes('不符合')"></i>
        <!-- 其他情况（包含'不符合'）打叉 -->
        <i class="el-icon-circle-close" v-else></i>
        <span class="rule-text">{{ rule }}</span>
      </div>
    </div>
  </template>
</el-table-column>
              </el-table>
            </el-card>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
// 引入接口（请确保路径与您项目一致）
import { getRadarData } from '@/api/learning/radar'
import { calculateDigitalTwin } from '@/api/learning/digitalTwin'
import * as echarts from 'echarts'

export default {
  name: 'StudentLearningDataCenter',
  data() {
    return {
      searchForm: { 
        studentId: '', 
        courseId: '', 
        assignmentId: '' 
      },
      activeTab: 'radar',
      radarData: [],
      digitalTwinResult: null,
      loading: false,
      radarChart: null
    }
  },
  mounted() {
    this.initRadarChart()
    window.addEventListener('resize', this.resizeChart)
  },
  beforeDestroy() {
    if (this.radarChart) this.radarChart.dispose()
    window.removeEventListener('resize', this.resizeChart)
  },
  computed: {
    // 标签颜色类型
    twinTypeTagType() {
      if (!this.digitalTwinResult) return 'primary'
      const type = this.digitalTwinResult.twinType
      switch (type) {
        case '稳步积累型': return 'primary'
        case '逻辑攻坚型': return 'success'
        case '高效突击型': return 'warning'
        case '查漏补缺型': return 'info'
        default: return 'primary'
      }
    },
    // 分身主色调（小人衣服 + 文字颜色）
    twinColor() {
      if (!this.digitalTwinResult) return '#409EFF'
      const type = this.digitalTwinResult.twinType
      switch (type) {
        case '稳步积累型': return '#409EFF' // 蓝
        case '逻辑攻坚型': return '#67C23A' // 绿
        case '高效突击型': return '#E6A23C' // 橙
        case '查漏补缺型': return '#909399' // 灰
        default: return '#409EFF'
      }
    }
  },
  methods: {
    getDebugColor(type) {
      const map = {
        '稳步积累型': '#409EFF',
        '逻辑攻坚型': '#67C23A',
        '高效突击型': '#E6A23C',
        '查漏补缺型': '#909399'
      }
      return map[type] || '#409EFF'
    },

    // ----------------- 辅助文字生成方法 -----------------
    getCharacterDesc(type) {
      const map = {
        '稳步积累型': '一位登山者，一步一个脚印踏实前行',
        '逻辑攻坚型': '一位侦探，善于抽丝剥茧发现逻辑真相',
        '高效突击型': '一位短跑健将，在短时间内爆发力极强',
        '查漏补缺型': '一位质检员，细致入微不放过任何知识瑕疵'
      }
      return map[type] || '一位知识探索者'
    },
    getAdvice(type) {
      const map = {
        '稳步积累型': '保持当前节奏，尝试挑战更高难度的综合题，突破舒适区。',
        '逻辑攻坚型': '继续发挥逻辑优势，同时注意提升解题速度，平衡深思与效率。',
        '高效突击型': '注意基础知识的沉淀，避免粗心丢分，欲速则不达。',
        '查漏补缺型': '建立错题本，定期回顾盲点知识，将短板转化为潜力板。'
      }
      return map[type] || '制定合理的学习计划。'
    },

    // ----------------- 雷达图逻辑 -----------------
    initRadarChart() {
      const chartDom = document.getElementById('radarChart')
      if (!chartDom) return
      this.radarChart = echarts.init(chartDom)
      this.radarChart.setOption({ radar: { indicator: [] }, series: [{ type: 'radar', data: [] }] })
    },

    updateRadarChart() {
      if (!this.radarChart) return
      if (this.radarData.length === 0) {
        this.radarChart.clear()
        return
      }

      const option = {
        grid: { top: 0, left: 0, right: 0, bottom: 0, containLabel: true },
        radar: {
          indicator: this.radarData.map(item => ({ name: item.competencyName, max: 100 })),
          radius: '65%',
          center: ['50%', '50%'],
          name: {
            textStyle: { fontSize: 13, fontWeight: 600, color: '#2c3e50', padding: [4, 8] },
            formatter: value => value.length > 8 ? value.substring(0, 8) + '\n' + value.substring(8) : value
          },
          splitNumber: 5,
          shape: 'polygon',
          splitLine: { lineStyle: { color: '#e8e8e8', width: 1.5 } },
          splitArea: { show: true, areaStyle: { color: ['rgba(114, 172, 209, 0.05)', 'rgba(114, 172, 209, 0.1)'] } },
          axisLine: { lineStyle: { color: '#d0d0d0', width: 2 } }
        },
        series: [{
          type: 'radar',
          data: [{
            value: this.radarData.map(item => item.competencyScore),
            name: `学生${this.searchForm.studentId}能力评分`
          }],
          symbol: 'circle',
          symbolSize: 8,
          areaStyle: { 
            opacity: 0.3,
            color: '#409EFF'
          },
          lineStyle: { width: 2, color: '#409EFF' },
          itemStyle: { color: '#409EFF' },
          label: { show: true, fontSize: 12, color: '#409EFF' }
        }],
        tooltip: { trigger: 'item' }
      }
      this.radarChart.setOption(option)
    },

    resizeChart() {
      this.radarChart && this.radarChart.resize()
    },

    // ----------------- 基础逻辑 -----------------
    getTagType(twinType) {
      switch (twinType) {
        case '稳步积累型': return 'primary'
        case '逻辑攻坚型': return 'success'
        case '高效突击型': return 'warning'
        case '查漏补缺型': return 'info'
        default: return 'default'
      }
    },

    resetForm() {
      this.searchForm = { studentId: '', courseId: '', assignmentId: '' }
      this.radarData = []
      this.digitalTwinResult = null
      if (this.radarChart) this.radarChart.clear()
    },

    fetchData() {
      if (!this.searchForm.studentId) return this.$message.warning('请输入学生ID')
      if (!this.searchForm.courseId) return this.$message.warning('请输入课程ID')

      this.loading = true
      
      if (this.activeTab === 'radar') {
        getRadarData(this.searchForm)
          .then(response => {
            this.radarData = response.data
            this.$nextTick(() => this.updateRadarChart())
            this.$message.success('雷达图数据查询成功！')
          })
          .catch(error => this.$message.error('雷达图查询失败'))
          .finally(() => this.loading = false)
      } else {
        calculateDigitalTwin({
          userId: this.searchForm.studentId,
          courseId: this.searchForm.courseId
        })
          .then(response => {
            this.digitalTwinResult = response.data
            this.$message.success('数字分身查询成功！')
          })
          .catch(error => {
            this.$message.error('数字分身查询失败：' + (error.msg || error.message))
            this.digitalTwinResult = null
          })
          .finally(() => this.loading = false)
      }
    }
  },
  watch: {
    activeTab(val) {
      if (val === 'radar') {
        this.$nextTick(() => {
          this.resizeChart()
          if (this.radarData.length > 0) this.updateRadarChart()
        })
      } else if (val === 'twin') {
        if (!this.digitalTwinResult && this.searchForm.studentId && this.searchForm.courseId) {
          this.fetchData()
        }
      }
    }
  }
}
</script>

<style scoped>
.app-container {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 20px;
}
.page-header h2 {
  font-size: 24px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0 0 8px 0;
}
.page-header p {
  font-size: 14px;
  color: #606266;
  margin: 0;
}
.search-card {
  margin-bottom: 20px;
}
.search-card >>> .el-card__body {
  padding: 16px;
}

/* 雷达图样式 */
.radar-card {
  background: #fff;
  border-radius: 8px;
}
.chart-title {
  text-align: center;
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0 0 16px 0;
  padding-bottom: 12px;
  border-bottom: 2px solid #e4e7ed;
}
.chart-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 500px;
}
.radar-chart-container {
  width: 100%;
  height: 500px;
  max-width: 700px;
}

/* ================= 数字分身样式 (新版) ================= */
.result-container {
  min-height: 600px;
}
.no-data {
  font-size: 15px;
  color: #909399;
  text-align: center;
  padding: 80px 0;
  background: #f5f7fa;
  border-radius: 8px;
}
.result-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* --- 1. 新增：全家福展示栏样式 --- */
.twins-preview-bar {
  background: #f9fafc;
  border-radius: 8px;
  padding: 12px 20px;
  border: 1px solid #ebeef5;
  text-align: center;
}

.bar-title {
  font-size: 14px;
  color: #606266;
  font-weight: 600;
  margin-bottom: 12px;
  text-align: left;
}

.twins-row {
  display: flex;
  justify-content: space-around;
  align-items: flex-end;
  max-width: 800px;
  margin: 0 auto;
}

.mini-twin-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  opacity: 0.5;
  transform: scale(0.9);
  transition: all 0.3s ease;
}

/* 激活状态：完全不透明，稍微放大 */
.mini-twin-item.is-active {
  opacity: 1;
  transform: scale(1.1);
  z-index: 2;
}

.mini-twin-item.is-active .mini-label {
  color: #303133;
  font-weight: bold;
}

.current-badge {
  position: absolute;
  top: -8px;
  right: -5px;
  background: #F56C6C;
  color: white;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 10px;
  z-index: 3;
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
  animation: bounce 2s infinite;
}

.mini-avatar-circle {
  width: 60px; /* 迷你尺寸 */
  height: 60px;
  border-radius: 50%;
  border: 2px solid #ddd;
  background: #fff;
  overflow: hidden;
  margin-bottom: 6px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.is-active .mini-avatar-circle {
  border-width: 3px;
  box-shadow: 0 4px 8px rgba(0,0,0,0.15);
}

.mini-avatar-circle svg {
  width: 100%;
  height: 100%;
}

.mini-label {
  font-size: 12px;
  color: #909399;
}

/* --- 2. 主体数字分身展示卡片 (Container) --- */
.twin-character-container {
  display: flex;
  align-items: center;
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 12px;
  padding: 32px;
  margin-bottom: 10px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.04);
  transition: all 0.3s ease;
}

.twin-character-container:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.06);
}

/* 左侧：头像圆圈 */
.avatar-circle {
  width: 140px;
  height: 140px;
  border-radius: 50%;
  border: 4px solid; /* 颜色在HTML中动态绑定 */
  padding: 5px;
  margin-right: 35px;
  flex-shrink: 0;
  background: #fff;
}

.avatar-base {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  overflow: hidden; /* 圆形裁剪 */
}

/* 右侧：文字信息 */
.character-info {
  flex: 1;
  text-align: left;
}

.info-header {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  gap: 12px;
}

.character-info h2 {
  margin: 0;
  font-size: 26px;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.ai-badge {
  font-weight: normal;
  border-radius: 4px;
}

.info-text {
  font-size: 15px;
  color: #505255;
  margin: 0 0 16px 0;
  line-height: 1.5;
  display: flex;
  align-items: center;
}
.info-text strong {
  color: #303133;
  font-weight: 600;
  margin-left: 4px;
}

.advice-box {
  background: #f9f9fa;
  padding: 12px 16px;
  border-radius: 6px;
  border-left: 4px solid #ccc;
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
}

/* ============ 动画微交互 (Avatar Animations) ============ */
/* 1. 眨眼 */
.blink-eye {
  animation: blink 4s infinite;
  transform-origin: center;
}
@keyframes blink {
  0%, 48%, 52%, 100% { transform: scaleY(1); }
  50% { transform: scaleY(0.1); }
}

/* 2. 闪烁 (灯泡) */
.idea-bulb {
  animation: flash 2s infinite alternate;
  transform-origin: center;
}
@keyframes flash {
  from { opacity: 0.4; transform: scale(0.9); }
  to { opacity: 1; transform: scale(1.1); }
}

/* 3. 晃动头部 & 速度线 */
.face-tilt {
  animation: tiltHead 2s infinite ease-in-out;
  transform-origin: 100px 200px;
}
@keyframes tiltHead {
  0%, 100% { transform: rotate(0deg); }
  50% { transform: rotate(3deg); }
}
.bg-speed-lines {
  animation: speedMove 1s linear infinite;
  stroke-dasharray: 10;
}
@keyframes speedMove {
  from { stroke-dashoffset: 20; }
  to { stroke-dashoffset: 0; }
}

/* 4. 悬浮 (放大镜) */
.magnifier-float {
  animation: floatMag 3s ease-in-out infinite;
}
@keyframes floatMag {
  0%, 100% { transform: translateY(0) rotate(0); }
  50% { transform: translateY(-5px) rotate(-5deg); }
}

/* 弹跳徽章动画 */
@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-3px); }
}

/* 2. 概览卡片 */
.overview-card {
  background: #fff;
}
.overview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.card-title {
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0;
  padding-bottom: 8px;
  border-bottom: 2px solid #e4e7ed;
}
.score-item {
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 12px;
}
.score-item .score {
  font-size: 28px;
  font-weight: 700;
}
.feature-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

/* 3. 表格卡片 */
.detail-card {
  background: #fff;
}
.table-score {
  font-size: 16px;
  font-weight: 600;
  color: #67C23A;
}
.rule-item {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  font-size: 13px;
  margin-bottom: 4px;
}
.rule-item .el-icon-circle-check { color: #67C23A; margin-top: 2px; }
.rule-item .el-icon-circle-close { color: #F56C6C; margin-top: 2px; }

/* 响应式适配 */
@media (max-width: 768px) {
  .app-container { padding: 12px; }
  .twin-character-container { flex-direction: column; text-align: center; padding: 20px; }
  .avatar-circle { margin-right: 0; margin-bottom: 20px; }
  .info-header { justify-content: center; }
  .overview-header { flex-direction: column; align-items: flex-start; gap: 12px; }
  .twins-row { overflow-x: auto; justify-content: flex-start; gap: 15px; padding-bottom: 10px; }
}
</style>