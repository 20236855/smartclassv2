<template>
  <div class="knowledge-graph-container">
    <!-- 控制面板 -->
    <el-card class="control-panel" shadow="never">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-select v-model="selectedGraphType" placeholder="选择图谱类型" @change="handleTypeChange">
            <el-option label="课程总图谱" value="COURSE"></el-option>
            <el-option label="章节图谱" value="CHAPTER"></el-option>
          </el-select>
        </el-col>
        <el-col :span="6" v-if="selectedGraphType === 'CHAPTER'">
          <el-select v-model="selectedChapterId" placeholder="选择章节" @change="loadGraph">
            <el-option
              v-for="chapter in chapterList"
              :key="chapter.id"
              :label="chapter.title"
              :value="chapter.id">
            </el-option>
          </el-select>
        </el-col>
        <el-col :span="4">
          <el-button type="primary" icon="el-icon-refresh" @click="loadGraph" :loading="loading">
            {{ loading ? '加载中' : '刷新图谱' }}
          </el-button>
        </el-col>
        <el-col :span="4">
          <el-button type="success" icon="el-icon-magic-stick" @click="handleGenerate" :loading="generating">
            {{ generating ? '生成中' : '重新生成' }}
          </el-button>
        </el-col>
        <el-col :span="4">
          <el-button type="info" icon="el-icon-download" @click="handleExport">导出图片</el-button>
        </el-col>
      </el-row>
    </el-card>

    <!-- 图谱信息卡片 -->
    <el-card v-if="graphInfo" class="graph-info-card" shadow="hover">
      <div slot="header" class="card-header">
        <span class="graph-title">{{ graphInfo.title }}</span>
        <el-tag :type="graphInfo.graphType === 'COURSE' ? 'primary' : 'success'" size="medium">
          {{ graphInfo.graphType === 'COURSE' ? '课程图谱' : '章节图谱' }}
        </el-tag>
      </div>
      <el-row :gutter="20">
        <el-col :span="12">
          <div class="info-item">
            <i class="el-icon-document"></i>
            <span>{{ graphInfo.description || '暂无描述' }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <el-row :gutter="10">
            <el-col :span="8">
              <el-statistic title="知识点" :value="nodeCount" suffix="个">
                <template slot="prefix">
                  <i class="el-icon-collection" style="color: #409eff"></i>
                </template>
              </el-statistic>
            </el-col>
            <el-col :span="8">
              <el-statistic title="关系" :value="edgeCount" suffix="条">
                <template slot="prefix">
                  <i class="el-icon-share" style="color: #67c23a"></i>
                </template>
              </el-statistic>
            </el-col>
            <el-col :span="8">
              <div class="update-time">
                <div style="font-size: 12px; color: #909399;">更新时间</div>
                <div style="font-size: 14px;">{{ formatTime(graphInfo.updateTime) }}</div>
              </div>
            </el-col>
          </el-row>
        </el-col>
      </el-row>
    </el-card>

    <!-- 图谱可视化区域 -->
    <el-card class="graph-card" shadow="hover">
      <div ref="chart" class="knowledge-graph-chart" v-loading="loading"></div>
      
      <!-- 空状态 -->
      <div v-if="!graphInfo && !loading" class="empty-state">
        <el-empty description="暂无知识图谱数据">
          <el-button type="primary" @click="handleGenerate">生成知识图谱</el-button>
        </el-empty>
      </div>
    </el-card>

    <!-- 图例说明 -->
    <el-card class="legend-card" shadow="never">
      <div slot="header">
        <span>图例说明</span>
      </div>
      <el-row :gutter="20">
        <el-col :span="8">
          <div class="legend-item">
            <div class="legend-node high-confidence"></div>
            <span>高置信度知识点 (≥70%)</span>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="legend-item">
            <div class="legend-node medium-confidence"></div>
            <span>中置信度知识点 (40%-70%)</span>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="legend-item">
            <div class="legend-node low-confidence"></div>
            <span>低置信度知识点 (<40%)</span>
          </div>
        </el-col>
      </el-row>
      <el-divider></el-divider>
      <el-row :gutter="20">
        <el-col :span="6">
          <div class="legend-item">
            <div class="legend-edge prerequisite"></div>
            <span>前置关系</span>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="legend-item">
            <div class="legend-edge similar"></div>
            <span>相似关系</span>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="legend-item">
            <div class="legend-edge extension"></div>
            <span>扩展关系</span>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="legend-item">
            <div class="legend-edge related"></div>
            <span>相关关系</span>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <!-- 节点详情对话框 -->
    <el-dialog :title="nodeDetail.label" :visible.sync="nodeDialogVisible" width="700px" class="node-dialog">
      <div v-loading="masteryLoading">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="知识点名称">
            <el-tag size="medium">{{ nodeDetail.label }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="定义">
            {{ nodeDetail.definition || '暂无定义' }}
          </el-descriptions-item>
          <el-descriptions-item label="置信度">
            <el-progress
              :percentage="Math.round(nodeDetail.confidence * 100)"
              :color="getConfidenceColor(nodeDetail.confidence)"
              :stroke-width="8">
            </el-progress>
          </el-descriptions-item>
          <el-descriptions-item label="知识点ID" v-if="nodeDetail.kpId">
            <el-tag type="info" size="small">{{ nodeDetail.kpId }}</el-tag>
          </el-descriptions-item>
        </el-descriptions>

        <!-- 学生掌握情况 -->
        <el-divider content-position="left">
          <i class="el-icon-data-analysis"></i> 我的掌握情况
        </el-divider>

        <div v-if="masteryData" class="mastery-section">
          <el-row :gutter="20">
            <el-col :span="12">
              <div class="mastery-card">
                <div class="mastery-label">掌握状态</div>
                <div class="mastery-value">
                  <el-tag :type="getMasteryStatusType(masteryData.masteryStatus)" size="large">
                    {{ getMasteryStatusText(masteryData.masteryStatus) }}
                  </el-tag>
                </div>
              </div>
            </el-col>
            <el-col :span="12">
              <div class="mastery-card">
                <div class="mastery-label">掌握指标</div>
                <div class="mastery-value">
                  <span class="score-text" :style="{ color: getMasteryScoreColor(masteryData.masteryScore) }">
                    {{ masteryData.masteryScore || 0 }}分
                  </span>
                  <span class="score-total">/100</span>
                </div>
              </div>
            </el-col>
          </el-row>

          <el-row :gutter="20" style="margin-top: 15px;">
            <el-col :span="8">
              <div class="mastery-card">
                <div class="mastery-label">正确率</div>
                <div class="mastery-value">
                  <el-progress
                    type="circle"
                    :percentage="parseFloat(masteryData.accuracy) || 0"
                    :width="80"
                    :color="getAccuracyColor(parseFloat(masteryData.accuracy))">
                  </el-progress>
                </div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="mastery-card">
                <div class="mastery-label">答题统计</div>
                <div class="mastery-value">
                  <div class="stat-item">
                    <i class="el-icon-success" style="color: #67C23A;"></i>
                    答对 {{ masteryData.correctCount || 0 }} 次
                  </div>
                  <div class="stat-item">
                    <i class="el-icon-document"></i>
                    总计 {{ masteryData.totalCount || 0 }} 次
                  </div>
                </div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="mastery-card">
                <div class="mastery-label">学习趋势</div>
                <div class="mastery-value">
                  <el-tag :type="getTrendType(masteryData.trend)" effect="plain">
                    {{ getTrendText(masteryData.trend) }}
                  </el-tag>
                </div>
              </div>
            </el-col>
          </el-row>

          <div v-if="masteryData.lastTestTime" class="last-test-info">
            <i class="el-icon-time"></i>
            最近测试：{{ masteryData.lastTestTime }}
            <span v-if="masteryData.lastTestScore" style="margin-left: 10px;">
              得分：<strong>{{ masteryData.lastTestScore }}</strong>
            </span>
          </div>
        </div>

        <div v-else class="no-mastery-data">
          <i class="el-icon-info"></i>
          <span>暂无学习数据，开始学习后将显示掌握情况</span>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import { listGraph, extractCourseGraph, extractChapterGraph } from '@/api/system/graph'
import { listChapter } from '@/api/system/chapter'
import { listMastery } from '@/api/learning/mastery'

export default {
  name: 'KnowledgeGraphView',
  props: {
    courseId: {
      type: [String, Number],
      required: true
    }
  },
  data() {
    return {
      chart: null,
      loading: false,
      generating: false,
      selectedGraphType: 'COURSE',
      selectedChapterId: null,
      chapterList: [],
      graphInfo: null,
      nodeCount: 0,
      edgeCount: 0,
      nodeDialogVisible: false,
      nodeDetail: {
        label: '',
        definition: '',
        confidence: 0,
        kpId: null
      },
      masteryLoading: false,
      masteryData: null
    }
  },
  mounted() {
    this.initChart()
    this.loadChapters()
    this.loadGraph()
  },
  beforeDestroy() {
    if (this.chart) {
      this.chart.dispose()
      this.chart = null
    }
    window.removeEventListener('resize', this.handleResize)
  },
  methods: {
    initChart() {
      this.chart = echarts.init(this.$refs.chart)
      window.addEventListener('resize', this.handleResize)
    },
    handleResize() {
      if (this.chart) {
        this.chart.resize()
      }
    },
    loadChapters() {
      listChapter({ courseId: this.courseId }).then(response => {
        this.chapterList = response.rows || []
        // 如果当前是章节图谱模式且没有选中章节，自动选择第一个
        if (this.selectedGraphType === 'CHAPTER' && !this.selectedChapterId && this.chapterList.length > 0) {
          this.selectedChapterId = this.chapterList[0].id
          console.log(`自动选择第一个章节：id=${this.selectedChapterId}, title=${this.chapterList[0].title}`)
        }
      })
    },
    handleTypeChange() {
      this.selectedChapterId = null
      // 如果切换到章节模式且有章节数据，自动选择第一个
      if (this.selectedGraphType === 'CHAPTER' && this.chapterList.length > 0) {
        this.selectedChapterId = this.chapterList[0].id
        console.log(`切换到章节模式，自动选择第一个章节：id=${this.selectedChapterId}, title=${this.chapterList[0].title}`)
      }
      this.loadGraph()
    },
    loadGraph() {
      this.loading = true
      const query = {
        courseId: this.courseId,
        graphType: this.selectedGraphType
      }
      
      if (this.selectedGraphType === 'CHAPTER' && this.selectedChapterId) {
        query.chapterId = this.selectedChapterId
      }

      listGraph(query).then(response => {
        const graphs = response.rows || []
        if (graphs.length === 0) {
          this.graphInfo = null
          this.nodeCount = 0
          this.edgeCount = 0
          this.chart.clear()
          this.loading = false
          return
        }

        // 【修改】如果是章节图谱，根据 chapterId 过滤
        let filteredGraphs = graphs
        if (this.selectedGraphType === 'CHAPTER' && this.selectedChapterId) {
          filteredGraphs = graphs.filter(g => {
            try {
              const graphData = JSON.parse(g.graphData)
              return graphData.chapterId === this.selectedChapterId
            } catch (e) {
              return false
            }
          })

          if (filteredGraphs.length === 0) {
            this.graphInfo = null
            this.nodeCount = 0
            this.edgeCount = 0
            this.chart.clear()
            this.loading = false
            this.$message.warning('该章节暂无知识图谱数据')
            return
          }
        }

        const graph = filteredGraphs[filteredGraphs.length - 1]
        this.graphInfo = graph

        try {
          const graphData = JSON.parse(graph.graphData)
          console.log('📊 图谱数据:', graphData)
          console.log('📊 节点数量:', graphData.nodes?.length || 0)
          console.log('📊 边数量:', graphData.edges?.length || 0)
          console.log('📊 章节ID:', graphData.chapterId)
          this.renderGraph(graphData)
        } catch (e) {
          console.error('❌ 图谱数据解析失败:', e)
          this.$message.error('图谱数据解析失败：' + e.message)
        }
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },
    renderGraph(graphData) {
      const nodes = graphData.nodes || []
      const edges = graphData.edges || []

      console.log('🎨 开始渲染图谱，节点数:', nodes.length, '边数:', edges.length)

      this.nodeCount = nodes.length
      this.edgeCount = edges.length

      if (nodes.length === 0) {
        console.warn('⚠️ 没有节点数据，无法渲染图谱')
        this.$message.warning('该图谱没有知识点数据')
        return
      }

      const chartNodes = nodes.map(node => {
        const confidence = node.confidence || 0
        const size = Math.max(40, 60 + confidence * 60)
        return {
          id: node.id,
          name: node.label,
          symbolSize: size,
          value: confidence,
          category: this.getCategoryByConfidence(confidence),
          itemStyle: {
            color: {
              type: 'radial',
              x: 0.5,
              y: 0.5,
              r: 0.5,
              colorStops: [{
                offset: 0,
                color: this.getColorByConfidence(confidence, 0.9)
              }, {
                offset: 1,
                color: this.getColorByConfidence(confidence, 1)
              }]
            },
            borderColor: '#ffffff',
            borderWidth: 3,
            shadowBlur: 15,
            shadowColor: this.getColorByConfidence(confidence, 0.4),
            shadowOffsetX: 0,
            shadowOffsetY: 4
          },
          label: {
            show: true,
            fontSize: 13,
            fontWeight: 600,
            color: '#ffffff',
            textShadowColor: 'rgba(0, 0, 0, 0.5)',
            textShadowBlur: 4,
            textShadowOffsetX: 0,
            textShadowOffsetY: 1
          },
          emphasis: {
            itemStyle: {
              borderWidth: 4,
              shadowBlur: 25,
              shadowColor: this.getColorByConfidence(confidence, 0.6)
            },
            label: {
              fontSize: 15,
              fontWeight: 700
            }
          },
          rawData: node
        }
      })

      const chartLinks = edges.map(edge => ({
        source: edge.source,
        target: edge.target,
        label: {
          show: true,
          formatter: this.getRelationLabel(edge.type),
          fontSize: 11,
          fontWeight: 500,
          color: '#606266',
          backgroundColor: 'rgba(255, 255, 255, 0.9)',
          padding: [4, 8],
          borderRadius: 6,
          borderColor: this.getEdgeColor(edge.type),
          borderWidth: 1.5
        },
        lineStyle: {
          curveness: 0.25,
          color: this.getEdgeColor(edge.type),
          width: 2.5,
          shadowBlur: 8,
          shadowColor: this.getEdgeColor(edge.type, 0.3),
          shadowOffsetY: 2
        },
        emphasis: {
          lineStyle: {
            width: 4,
            shadowBlur: 15,
            shadowColor: this.getEdgeColor(edge.type, 0.5)
          },
          label: {
            fontSize: 12,
            fontWeight: 600,
            borderWidth: 2
          }
        }
      }))

      const categories = [
        { name: '高置信度' },
        { name: '中置信度' },
        { name: '低置信度' }
      ]

      const option = {
        backgroundColor: 'transparent',
        title: {
          text: this.selectedGraphType === 'COURSE' ? '📚 课程知识图谱' : '📖 章节知识图谱',
          left: 'center',
          top: 20,
          textStyle: {
            fontSize: 24,
            fontWeight: 700,
            color: '#667eea',
            textShadowColor: 'rgba(102, 126, 234, 0.2)',
            textShadowBlur: 10,
            textShadowOffsetX: 0,
            textShadowOffsetY: 2
          }
        },
        tooltip: {
          trigger: 'item',
          backgroundColor: 'rgba(255, 255, 255, 0.95)',
          borderColor: '#667eea',
          borderWidth: 2,
          borderRadius: 12,
          padding: [16, 20],
          textStyle: {
            color: '#333',
            fontSize: 13
          },
          extraCssText: 'box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15); backdrop-filter: blur(10px);',
          formatter: (params) => {
            if (params.dataType === 'node') {
              const data = params.data.rawData
              const confidencePercent = Math.round((data.confidence || 0) * 100)
              const confidenceColor = data.confidence >= 0.7 ? '#67C23A' : data.confidence >= 0.4 ? '#E6A23C' : '#F56C6C'
              return `<div style="max-width: 300px;">
                        <div style="font-size: 16px; font-weight: 700; margin-bottom: 12px; color: #667eea; border-bottom: 2px solid #667eea; padding-bottom: 8px;">
                          ${data.label}
                        </div>
                        <div style="margin-bottom: 10px; line-height: 1.6; color: #606266;">
                          <strong style="color: #303133;">定义：</strong>${data.definition || '暂无定义'}
                        </div>
                        <div style="display: flex; align-items: center; gap: 8px;">
                          <strong style="color: #303133;">置信度：</strong>
                          <span style="color: ${confidenceColor}; font-weight: 700; font-size: 15px;">${confidencePercent}%</span>
                          <div style="flex: 1; height: 6px; background: #e4e7ed; border-radius: 3px; overflow: hidden;">
                            <div style="width: ${confidencePercent}%; height: 100%; background: ${confidenceColor}; border-radius: 3px; transition: width 0.3s ease;"></div>
                          </div>
                        </div>
                      </div>`
            } else if (params.dataType === 'edge') {
              const relationLabel = this.getRelationLabel(params.data.label.formatter)
              const edgeColor = this.getEdgeColor(params.data.label.formatter)
              return `<div style="padding: 4px 8px;">
                        <span style="display: inline-block; width: 30px; height: 3px; background: ${edgeColor}; border-radius: 2px; margin-right: 8px; vertical-align: middle;"></span>
                        <strong style="color: #303133;">${relationLabel}</strong>
                      </div>`
            }
          }
        },
        series: [{
          type: 'graph',
          layout: 'force',
          data: chartNodes,
          links: chartLinks,
          categories: categories,
          roam: true,
          focusNodeAdjacency: true,
          draggable: true,
          symbol: 'circle',
          label: {
            position: 'inside',
            formatter: '{b}',
            fontSize: 12
          },
          force: {
            repulsion: 1500,
            edgeLength: [120, 350],
            gravity: 0.08,
            friction: 0.5,
            layoutAnimation: true
          },
          emphasis: {
            focus: 'adjacency',
            scale: 1.15,
            lineStyle: {
              width: 5
            },
            itemStyle: {
              shadowBlur: 20,
              shadowColor: 'rgba(102, 126, 234, 0.5)'
            }
          },
          animation: true,
          animationDuration: 1500,
          animationEasing: 'cubicOut',
          animationDelay: (idx) => idx * 10
        }]
      }

      this.chart.setOption(option, true)

      // 点击节点显示详情
      this.chart.off('click')
      this.chart.on('click', (params) => {
        if (params.dataType === 'node') {
          const data = params.data.rawData
          this.nodeDetail = {
            label: data.label,
            definition: data.definition || '暂无定义',
            confidence: data.confidence || 0,
            kpId: data.kpId
          }
          this.nodeDialogVisible = true

          // 加载学生掌握情况
          if (data.kpId) {
            this.loadMasteryData(data.kpId)
          } else {
            this.masteryData = null
          }
        }
      })
    },

    // 加载学生对该知识点的掌握情况
    loadMasteryData(kpId) {
      this.masteryLoading = true
      this.masteryData = null

      const studentId = this.$store.getters.userId

      listMastery({
        studentUserId: studentId,
        courseId: this.courseId,
        kpId: kpId
      }).then(response => {
        if (response.rows && response.rows.length > 0) {
          this.masteryData = response.rows[0]
          console.log('知识点掌握情况:', this.masteryData)
        } else {
          this.masteryData = null
        }
      }).catch(error => {
        console.error('加载掌握情况失败:', error)
        this.masteryData = null
      }).finally(() => {
        this.masteryLoading = false
      })
    },
    handleGenerate() {
      // 如果是章节图谱但没有选择章节，提示用户
      if (this.selectedGraphType === 'CHAPTER' && !this.selectedChapterId) {
        this.$message.warning('请先选择章节')
        return
      }

      this.generating = true

      // 显示当前生成的是哪个章节
      if (this.selectedGraphType === 'CHAPTER') {
        const chapter = this.chapterList.find(c => c.id === this.selectedChapterId)
        const chapterTitle = chapter ? chapter.title : `章节${this.selectedChapterId}`
        console.log(`正在生成章节图谱：courseId=${this.courseId}, chapterId=${this.selectedChapterId}, title=${chapterTitle}`)
        this.$message.info(`正在生成"${chapterTitle}"的知识图谱...`)
      } else {
        console.log(`正在生成课程图谱：courseId=${this.courseId}`)
        this.$message.info('正在生成课程总图谱...')
      }

      const promise = this.selectedGraphType === 'CHAPTER' && this.selectedChapterId
        ? extractChapterGraph(this.courseId, this.selectedChapterId)
        : extractCourseGraph(this.courseId)

      promise.then(() => {
        this.$message.success('知识图谱生成任务已提交，请稍后刷新查看')
        setTimeout(() => {
          this.loadGraph()
        }, 3000)
      }).catch(() => {
        this.$message.error('生成失败，请重试')
      }).finally(() => {
        this.generating = false
      })
    },
    handleExport() {
      if (!this.chart) {
        this.$message.warning('请先加载知识图谱')
        return
      }
      const url = this.chart.getDataURL({
        type: 'png',
        pixelRatio: 2,
        backgroundColor: '#fff'
      })
      const link = document.createElement('a')
      link.href = url
      link.download = `knowledge-graph-${this.courseId}-${Date.now()}.png`
      link.click()
      this.$message.success('图片导出成功')
    },
    getCategoryByConfidence(confidence) {
      if (confidence >= 0.7) return 0
      if (confidence >= 0.4) return 1
      return 2
    },
    getColorByConfidence(confidence, alpha = 1) {
      let baseColor
      if (confidence >= 0.7) baseColor = '103, 194, 58'  // #67C23A
      else if (confidence >= 0.4) baseColor = '230, 162, 60'  // #E6A23C
      else baseColor = '245, 108, 108'  // #F56C6C

      return `rgba(${baseColor}, ${alpha})`
    },
    getConfidenceColor(confidence) {
      if (confidence >= 0.7) return '#67C23A'
      if (confidence >= 0.4) return '#E6A23C'
      return '#F56C6C'
    },
    getEdgeColor(type, alpha = 1) {
      const colorMap = {
        'PREREQUISITE': '64, 158, 255',       // #409EFF 蓝色 - 前置关系
        'BELONGS_TO': '144, 147, 153',        // #909399 灰色 - 从属关系
        'EXAMPLE': '245, 108, 108',           // #F56C6C 红色 - 示例关系
        'EXTENSION': '230, 162, 60',          // #E6A23C 橙色 - 扩展关系
        'SIMILAR': '103, 194, 58',            // #67C23A 绿色 - 相似关系
        // 兼容旧格式
        'prerequisite_of': '64, 158, 255',
        'similar_to': '103, 194, 58',
        'extension_of': '230, 162, 60',
        'derived_from': '144, 147, 153',
        'related': '144, 147, 153'
      }
      const rgb = colorMap[type] || '144, 147, 153'
      return `rgba(${rgb}, ${alpha})`
    },
    getRelationLabel(type) {
      const labelMap = {
        'PREREQUISITE': '前置关系',
        'BELONGS_TO': '从属关系',
        'EXAMPLE': '示例关系',
        'EXTENSION': '扩展关系',
        'SIMILAR': '相似关系',
        // 兼容旧格式
        'prerequisite_of': '前置关系',
        'similar_to': '相似关系',
        'extension_of': '扩展关系',
        'derived_from': '派生关系',
        'related': '相关关系'
      }
      return labelMap[type] || '相关关系'
    },
    formatTime(time) {
      if (!time) return '未知'
      return new Date(time).toLocaleString()
    },

    // 掌握状态相关方法
    getMasteryStatusType(status) {
      const map = {
        'mastered': 'success',
        'learning': 'warning',
        'weak': 'danger',
        'not_started': 'info'
      }
      return map[status] || 'info'
    },

    getMasteryStatusText(status) {
      const map = {
        'mastered': '已掌握',
        'learning': '学习中',
        'weak': '薄弱点',
        'not_started': '未学习'
      }
      return map[status] || '未知'
    },

    getMasteryScoreColor(score) {
      if (score >= 80) return '#67C23A'
      if (score >= 60) return '#E6A23C'
      if (score >= 40) return '#F56C6C'
      return '#909399'
    },

    getAccuracyColor(accuracy) {
      if (accuracy >= 80) return '#67C23A'
      if (accuracy >= 60) return '#E6A23C'
      return '#F56C6C'
    },

    getTrendType(trend) {
      const map = {
        'up': 'success',
        'stable': 'warning',
        'down': 'danger'
      }
      return map[trend] || 'info'
    },

    getTrendText(trend) {
      const map = {
        'up': '上升 ↑',
        'stable': '稳定 →',
        'down': '下降 ↓'
      }
      return map[trend] || '暂无'
    }
  }
}
</script>

<style scoped>
.knowledge-graph-container {
  padding: 0;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
}

.control-panel {
  margin-bottom: 24px;
  border: none;
  border-radius: 12px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.08);
  background: #ffffff;
  transition: all 0.3s ease;
}

.control-panel:hover {
  box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.graph-info-card {
  margin-bottom: 24px;
  border: none;
  border-radius: 12px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.08);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
  transition: all 0.3s ease;
}

.graph-info-card:hover {
  box-shadow: 0 8px 24px 0 rgba(102, 126, 234, 0.4);
  transform: translateY(-4px);
}

.graph-info-card >>> .el-card__header {
  background: rgba(255, 255, 255, 0.1);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
}

.graph-info-card >>> .el-card__body {
  background: transparent;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.graph-title {
  font-size: 20px;
  font-weight: 600;
  color: #ffffff;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.info-item {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  color: rgba(255, 255, 255, 0.95);
}

.info-item i {
  margin-right: 10px;
  color: rgba(255, 255, 255, 0.8);
  font-size: 18px;
}

.update-time {
  text-align: center;
  color: rgba(255, 255, 255, 0.9);
}

.graph-card {
  margin-bottom: 24px;
  border: none;
  border-radius: 16px;
  box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.1);
  background: #ffffff;
  overflow: hidden;
  transition: all 0.3s ease;
}

.graph-card:hover {
  box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.15);
}

.knowledge-graph-chart {
  width: 100%;
  height: 700px;
  background: linear-gradient(135deg, #fdfbfb 0%, #ebedee 100%);
  border-radius: 12px;
  position: relative;
}

.knowledge-graph-chart::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at 20% 50%, rgba(102, 126, 234, 0.05) 0%, transparent 50%),
              radial-gradient(circle at 80% 80%, rgba(118, 75, 162, 0.05) 0%, transparent 50%);
  pointer-events: none;
}

.empty-state {
  height: 500px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #fdfbfb 0%, #ebedee 100%);
  border-radius: 12px;
}

.legend-card {
  border: none;
  border-radius: 12px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.08);
  background: #ffffff;
  transition: all 0.3s ease;
}

.legend-card:hover {
  box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.12);
}

.legend-card >>> .el-card__header {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: #ffffff;
  font-weight: 600;
  border-radius: 12px 12px 0 0;
}

.legend-item {
  display: flex;
  align-items: center;
  margin-bottom: 14px;
  padding: 8px 12px;
  border-radius: 8px;
  transition: all 0.2s ease;
  cursor: default;
}

.legend-item:hover {
  background: rgba(102, 126, 234, 0.05);
  transform: translateX(4px);
}

.legend-node {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  margin-right: 12px;
  border: 3px solid #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  transition: all 0.2s ease;
}

.legend-item:hover .legend-node {
  transform: scale(1.2);
}

.legend-node.high-confidence {
  background: linear-gradient(135deg, #67C23A 0%, #85ce61 100%);
}

.legend-node.medium-confidence {
  background: linear-gradient(135deg, #E6A23C 0%, #ebb563 100%);
}

.legend-node.low-confidence {
  background: linear-gradient(135deg, #F56C6C 0%, #f78989 100%);
}

.legend-edge {
  width: 40px;
  height: 4px;
  margin-right: 12px;
  border-radius: 2px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: all 0.2s ease;
}

.legend-item:hover .legend-edge {
  width: 50px;
}

.legend-edge.prerequisite {
  background: linear-gradient(90deg, #409EFF 0%, #66b1ff 100%);
}

.legend-edge.similar {
  background: linear-gradient(90deg, #67C23A 0%, #85ce61 100%);
}

.legend-edge.extension {
  background: linear-gradient(90deg, #E6A23C 0%, #ebb563 100%);
}

.legend-edge.related {
  background: linear-gradient(90deg, #909399 0%, #a6a9ad 100%);
}

.node-dialog >>> .el-dialog {
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 12px 48px rgba(0, 0, 0, 0.2);
}

.node-dialog >>> .el-dialog__header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
  padding: 20px 24px;
}

.node-dialog >>> .el-dialog__title {
  color: #ffffff;
  font-weight: 600;
  font-size: 18px;
}

.node-dialog >>> .el-dialog__headerbtn .el-dialog__close {
  color: #ffffff;
  font-size: 20px;
}

.node-dialog >>> .el-dialog__body {
  padding: 24px;
  background: #fafafa;
}

/* 按钮美化 */
.control-panel >>> .el-button--primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  padding: 10px 20px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.control-panel >>> .el-button--primary:hover {
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.control-panel >>> .el-button--success {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  border: none;
  border-radius: 8px;
  padding: 10px 20px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.control-panel >>> .el-button--success:hover {
  background: linear-gradient(135deg, #f5576c 0%, #f093fb 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(240, 147, 251, 0.4);
}

/* 选择器美化 */
.control-panel >>> .el-select .el-input__inner {
  border-radius: 8px;
  border: 2px solid #e4e7ed;
  transition: all 0.3s ease;
}

.control-panel >>> .el-select .el-input__inner:focus {
  border-color: #667eea;
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.1);
}

/* 统计数字美化 */
.graph-info-card >>> .el-statistic__head {
  color: rgba(255, 255, 255, 0.8);
  font-weight: 500;
}

.graph-info-card >>> .el-statistic__content {
  color: #ffffff;
  font-weight: 700;
}

/* 节点详情对话框样式 */
.node-dialog >>> .el-dialog__body {
  padding: 20px;
}

.mastery-section {
  margin-top: 20px;
}

.mastery-card {
  background: #f5f7fa;
  border-radius: 8px;
  padding: 15px;
  text-align: center;
  height: 100%;
  transition: all 0.3s;
}

.mastery-card:hover {
  background: #ecf5ff;
  transform: translateY(-2px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.mastery-label {
  font-size: 13px;
  color: #909399;
  margin-bottom: 10px;
}

.mastery-value {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.score-text {
  font-size: 28px;
  font-weight: 700;
}

.score-total {
  font-size: 14px;
  color: #909399;
  margin-left: 4px;
}

.stat-item {
  font-size: 14px;
  margin: 5px 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
}

.last-test-info {
  margin-top: 15px;
  padding: 12px;
  background: #f0f9ff;
  border-left: 3px solid #409EFF;
  border-radius: 4px;
  font-size: 13px;
  color: #606266;
}

.no-mastery-data {
  text-align: center;
  padding: 40px 20px;
  color: #909399;
  font-size: 14px;
}

.no-mastery-data i {
  font-size: 48px;
  display: block;
  margin-bottom: 10px;
  opacity: 0.5;
}
</style>