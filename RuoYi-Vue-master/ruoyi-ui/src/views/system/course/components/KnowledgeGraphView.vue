<template>
  <div class="knowledge-graph-container">
    <!-- 控制面板 -->
    <el-card class="control-panel" shadow="never">
      <el-row :gutter="20" type="flex" align="middle">
        <el-col :span="6">
          <el-select v-model="selectedGraphType" placeholder="选择图谱类型" @change="handleTypeChange" class="graph-select">
            <el-option label="课程总图谱" value="COURSE"></el-option>
            <el-option label="章节图谱" value="CHAPTER"></el-option>
          </el-select>
        </el-col>
        <el-col :span="6" v-if="selectedGraphType === 'CHAPTER'">
          <el-select v-model="selectedChapterId" placeholder="选择章节" @change="loadGraph" class="graph-select">
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
          <el-button type="primary" icon="el-icon-download" @click="handleExport" plain>导出图片</el-button>
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
    <div class="legend-bar">
      <span class="legend-title">图例说明</span>
      <div class="legend-item">
        <div class="legend-edge prerequisite"></div>
        <span>前置关系</span>
      </div>
      <div class="legend-item">
        <div class="legend-edge similar"></div>
        <span>相似关系</span>
      </div>
      <div class="legend-item">
        <div class="legend-edge extension"></div>
        <span>扩展关系</span>
      </div>
      <div class="legend-item">
        <div class="legend-edge related"></div>
        <span>相关关系</span>
      </div>
    </div>

    <!-- 置信度说明 -->
    <div class="confidence-legend">
      <span class="legend-title">置信度说明</span>
      <div class="confidence-desc">
        <i class="el-icon-info"></i>
        <span>置信度表示AI对知识点识别的准确程度，数值越高表示越可靠</span>
      </div>
      <div class="confidence-levels">
        <div class="confidence-item">
          <div class="confidence-dot high"></div>
          <span>高置信度 (≥70%)</span>
          <span class="confidence-hint">知识点识别准确，可直接使用</span>
        </div>
        <div class="confidence-item">
          <div class="confidence-dot medium"></div>
          <span>中置信度 (40%-70%)</span>
          <span class="confidence-hint">建议人工复核后使用</span>
        </div>
        <div class="confidence-item">
          <div class="confidence-dot low"></div>
          <span>低置信度 (&lt;40%)</span>
          <span class="confidence-hint">需要人工审核确认</span>
        </div>
      </div>
    </div>

    <!-- 节点详情对话框 -->
    <el-dialog :title="nodeDetail.label" :visible.sync="nodeDialogVisible" width="650px" class="node-dialog">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="名称">
          <el-tag size="medium">{{ nodeDetail.label }}</el-tag>
          <el-tag v-if="nodeDetail.nodeType" size="small" type="info" style="margin-left: 8px;">{{ nodeDetail.nodeType }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="描述/定义">
          {{ nodeDetail.definition || '暂无描述' }}
        </el-descriptions-item>

        <!-- AI知识点的置信度 -->
        <el-descriptions-item label="置信度" v-if="nodeDetail.confidence > 0">
          <el-progress
            :percentage="Math.round(nodeDetail.confidence * 100)"
            :color="getConfidenceColor(nodeDetail.confidence)"
            :stroke-width="8">
          </el-progress>
        </el-descriptions-item>

        <!-- 知识点ID -->
        <el-descriptions-item label="知识点ID" v-if="nodeDetail.kpId">
          <el-tag type="info" size="small">{{ nodeDetail.kpId }}</el-tag>
        </el-descriptions-item>

        <!-- 掌握情况（对所有知识点显示，没有记录则显示"未学习"） -->
        <el-descriptions-item label="掌握情况" v-if="nodeDetail.kpId">
          <div class="mastery-info">
            <el-tag :type="getMasteryTagType(nodeDetail.mastery ? nodeDetail.mastery.masteryStatus : 'not_started')">
              {{ getMasteryStatusText(nodeDetail.mastery ? nodeDetail.mastery.masteryStatus : 'not_started') }}
            </el-tag>
            <span v-if="nodeDetail.mastery && nodeDetail.mastery.totalCount > 0" style="margin-left: 12px;">
              正确率: {{ nodeDetail.mastery.accuracy || 0 }}%
              ({{ nodeDetail.mastery.correctCount || 0 }}/{{ nodeDetail.mastery.totalCount || 0 }})
            </span>
            <span v-else style="margin-left: 12px; color: #909399;">暂无学习记录</span>
          </div>
        </el-descriptions-item>

        <!-- 小节的知识点列表 -->
        <el-descriptions-item label="包含知识点" v-if="nodeDetail.knowledgePoints && nodeDetail.knowledgePoints.length > 0">
          <div class="kp-list">
            <el-tag
              v-for="kp in nodeDetail.knowledgePoints"
              :key="kp.id"
              size="small"
              type="primary"
              style="margin: 4px;">
              {{ kp.title }}
            </el-tag>
          </div>
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import { listGraph, extractCourseGraph, extractChapterGraph } from '@/api/system/graph'
import { listChapter } from '@/api/system/chapter'
import { listMastery } from '@/api/learning/mastery'
import { getPoint } from '@/api/system/point'

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
      masteryMap: {}, // kpId -> mastery data
      nodeDetail: {
        label: '',
        definition: '',
        confidence: 0,
        kpId: null,
        nodeType: '',
        mastery: null,
        knowledgePoints: []
      }
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
          // 兼容 edges 和 links 两种字段名
          console.log('📊 边数量 (edges):', graphData.edges?.length || 0)
          console.log('📊 边数量 (links):', graphData.links?.length || 0)
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
    async renderGraph(graphData) {
      const nodes = graphData.nodes || []
      // 兼容 edges 和 links 两种字段名
      const edges = graphData.edges || graphData.links || []

      console.log('🎨 开始渲染图谱，节点数:', nodes.length, '边数:', edges.length)
      console.log('📊 节点示例:', nodes.length > 0 ? nodes[0] : 'N/A')

      this.nodeCount = nodes.length
      this.edgeCount = edges.length

      if (nodes.length === 0) {
        console.warn('⚠️ 没有节点数据，无法渲染图谱')
        this.$message.warning('该图谱没有知识点数据')
        return
      }

      // 批量加载所有知识点的掌握情况
      await this.loadAllMasteryData()
      console.log('📊 掌握情况数据:', Object.keys(this.masteryMap).length, '个知识点')

      // 检测是否为层级结构数据（包含 nodeType 字段）
      const isHierarchicalData = nodes.some(n => n.nodeType !== undefined)
      console.log('📊 数据格式:', isHierarchicalData ? '层级结构数据（课程→章节→小节→知识点）' : '简单知识点数据')

      // 定义章节颜色（与后端一致）
      const chapterColors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de',
                             '#9a60b4', '#ea7ccc', '#3ba272', '#fc8452', '#4876FF']

      const chartNodes = nodes.map(node => {
        const nodeName = node.name || node.label || '未命名'
        const nodeId = node.id
        const nodeType = node.nodeType || 'kp'
        const chapterIndex = node.chapterIndex || 0
        const color = node.color || chapterColors[chapterIndex % chapterColors.length]

        // 根据节点类型设置样式
        let symbolSize = node.symbolSize || 22
        let fontSize = 11
        let fontWeight = 'normal'
        let labelPosition = 'right'

        if (nodeType === 'course') {
          symbolSize = 70
          fontSize = 16
          fontWeight = 'bold'
          labelPosition = 'inside'
        } else if (nodeType === 'chapter') {
          symbolSize = 50
          fontSize = 13
          fontWeight = 'bold'
          labelPosition = 'right'
        } else if (nodeType === 'section') {
          symbolSize = 35
          fontSize = 11
          labelPosition = 'right'
        }

        return {
          id: nodeId,
          name: nodeName,
          symbolSize: symbolSize,
          value: node.category || chapterIndex,
          category: node.category !== undefined ? node.category : chapterIndex,
          itemStyle: {
            color: nodeType === 'course' ? '#303133' : color,
            borderColor: '#fff',
            borderWidth: nodeType === 'course' ? 4 : 2,
            shadowBlur: nodeType === 'course' ? 15 : 6,
            shadowColor: 'rgba(0,0,0,0.15)'
          },
          label: {
            show: true,
            formatter: nodeName,
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: nodeType === 'course' ? '#fff' : '#333',
            position: labelPosition,
            distance: 5
          },
          emphasis: {
            itemStyle: { borderWidth: 3, shadowBlur: 12 },
            label: { fontSize: fontSize + 2, fontWeight: 'bold' }
          },
          rawData: node
        }
      })

      console.log('📊 边数据:', edges.length > 0 ? edges[0] : 'N/A', '边总数:', edges.length)

      // 创建节点ID集合，用于验证边的有效性
      const nodeIdSet = new Set(nodes.map(n => n.id))

      const chartLinks = edges.filter(edge => {
        const isValid = nodeIdSet.has(edge.source) && nodeIdSet.has(edge.target)
        if (!isValid) {
          console.warn('⚠️ 无效边:', edge.source, '->', edge.target)
        }
        return isValid
      }).map(edge => {
        const edgeType = edge.type || edge.relationType || 'RELATED'
        // 层级边（CONTAINS/COVERS）使用灰色，知识点关系边使用蓝色
        const isHierarchyEdge = ['CONTAINS', 'COVERS'].includes(edgeType)
        return {
          source: edge.source,
          target: edge.target,
          label: { show: false },
          lineStyle: {
            curveness: isHierarchyEdge ? 0 : 0.2,
            color: isHierarchyEdge ? '#c0c4cc' : '#91cc75',
            width: isHierarchyEdge ? 1.5 : 1,
            opacity: isHierarchyEdge ? 0.6 : 0.4
          },
          emphasis: {
            lineStyle: { width: 2.5, opacity: 1, color: '#409EFF' },
            label: { show: true, formatter: this.getRelationLabel(edgeType), fontSize: 11, color: '#333' }
          }
        }
      })

      console.log('📊 有效边数:', chartLinks.length)

      // 动态生成章节分类（用于图例）
      const chapterNodes = nodes.filter(n => n.nodeType === 'chapter')
      const categories = [
        { name: '课程', itemStyle: { color: '#303133' } },
        ...chapterNodes.map((ch, idx) => ({
          name: ch.label || ch.name || `章节${idx + 1}`,
          itemStyle: { color: chapterColors[idx % chapterColors.length] }
        }))
      ]

      const option = {
        backgroundColor: '#fafbfc',
        title: {
          text: this.selectedGraphType === 'COURSE' ? '课程知识图谱' : '章节知识图谱',
          left: 'center',
          top: 12,
          textStyle: { fontSize: 18, fontWeight: 600, color: '#303133' }
        },
        legend: {
          data: categories.map(c => c.name),
          orient: 'horizontal',
          left: 'center',
          bottom: 10,
          textStyle: { fontSize: 12, color: '#606266' },
          icon: 'circle',
          itemWidth: 12,
          itemHeight: 12
        },
        tooltip: {
          trigger: 'item',
          backgroundColor: 'rgba(255, 255, 255, 0.98)',
          borderColor: '#e4e7ed',
          borderWidth: 1,
          borderRadius: 6,
          padding: [10, 14],
          textStyle: { color: '#333', fontSize: 12 },
          extraCssText: 'box-shadow: 0 2px 8px rgba(0,0,0,0.08);',
          formatter: (params) => {
            if (params.dataType === 'node') {
              const data = params.data.rawData
              const nodeName = data.name || data.label || '未命名'
              const nodeType = data.nodeType || 'kp'
              const definition = data.definition || ''
              const typeLabels = { 'course': '课程', 'chapter': '章节', 'section': '小节', 'kp': '知识点' }
              const typeLabel = typeLabels[nodeType] || '知识点'

              // 知识点显示掌握情况
              let masteryHtml = ''
              if (nodeType === 'kp' && data.kpId) {
                const mastery = this.masteryMap[data.kpId]
                const masteryStatus = mastery?.masteryStatus || 'not_started'
                const masteryLabels = { 'mastered': '已掌握', 'learning': '学习中', 'weak': '薄弱', 'not_started': '未学习' }
                const masteryColors = { 'mastered': '#67C23A', 'learning': '#E6A23C', 'weak': '#F56C6C', 'not_started': '#909399' }
                const masteryLabel = masteryLabels[masteryStatus] || '未学习'
                const masteryColor = masteryColors[masteryStatus] || '#909399'
                const accuracy = mastery?.accuracy || 0
                masteryHtml = `<div style="margin-top: 4px;"><span style="color: ${masteryColor}; font-size: 11px; padding: 2px 6px; background: ${masteryColor}20; border-radius: 3px;">${masteryLabel}</span>`
                if (mastery && mastery.totalCount > 0) {
                  masteryHtml += `<span style="margin-left: 8px; color: #606266; font-size: 11px;">正确率: ${accuracy}%</span>`
                }
                masteryHtml += '</div>'
              }

              return `<div style="max-width: 280px;">
                <div style="font-size: 14px; font-weight: 600; color: #303133; margin-bottom: 6px;">${nodeName}</div>
                <div style="margin-bottom: 4px;"><span style="color: #409EFF; font-size: 11px; padding: 2px 6px; background: #409EFF20; border-radius: 3px;">${typeLabel}</span></div>
                ${masteryHtml}
                ${definition ? `<div style="color: #606266; line-height: 1.4; font-size: 12px; margin-top: 6px;">${definition}</div>` : ''}
              </div>`
            }
            return ''
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
          label: { position: 'right', formatter: '{b}', fontSize: 10, color: '#333' },
          force: {
            repulsion: 800,
            edgeLength: [80, 200],
            gravity: 0.1,
            friction: 0.6,
            layoutAnimation: true
          },
          emphasis: {
            focus: 'adjacency',
            scale: 1.08,
            lineStyle: { width: 2.5 },
            itemStyle: { shadowBlur: 10, shadowColor: 'rgba(0,0,0,0.15)' }
          },
          animation: true,
          animationDuration: 1000,
          animationEasing: 'cubicOut'
        }]
      }

      this.chart.setOption(option, true)

      // 点击节点显示详情
      this.chart.off('click')
      this.chart.on('click', (params) => {
        if (params.dataType === 'node') {
          const data = params.data.rawData

          // 判断节点类型
          const nodeId = data.id || ''
          let nodeType = '知识点'
          if (nodeId.startsWith('course-')) nodeType = '课程'
          else if (nodeId.startsWith('chapter-')) nodeType = '章节'
          else if (nodeId.startsWith('section-')) nodeType = '小节'
          else if (nodeId.startsWith('kp-') || nodeId.startsWith('kp_')) nodeType = '知识点'

          // 提取小节中的知识点列表
          const knowledgePoints = data.sectionData?.knowledgePoints || []

          // 获取描述信息
          let definition = data.definition || data.sectionData?.description || ''

          this.nodeDetail = {
            label: data.name || data.label || '未命名',
            definition: definition,
            confidence: data.confidence || 0,
            kpId: data.kpId,
            nodeType: nodeType,
            mastery: this.masteryMap[data.kpId] || null,
            knowledgePoints: knowledgePoints
          }

          // 如果是知识点且有kpId
          if (data.kpId) {
            // 加载掌握情况
            if (!this.masteryMap[data.kpId]) {
              this.loadMasteryForKp(data.kpId)
            }
            // 如果没有描述，从数据库加载知识点详情
            if (!definition) {
              this.loadKnowledgePointDetail(data.kpId)
            }
          }

          this.nodeDialogVisible = true
        }
      })
    },
    // 加载知识点详情（包括描述）
    loadKnowledgePointDetail(kpId) {
      getPoint(kpId).then(response => {
        if (response.data && response.data.description) {
          this.nodeDetail.definition = response.data.description
        }
      }).catch(err => {
        console.warn('加载知识点详情失败:', err)
      })
    },
    // 批量加载所有知识点的掌握情况
    async loadAllMasteryData() {
      try {
        const response = await listMastery({ courseId: this.courseId })
        if (response.rows && response.rows.length > 0) {
          // 将掌握情况按 kpId 建立映射
          response.rows.forEach(mastery => {
            if (mastery.kpId) {
              this.masteryMap[mastery.kpId] = mastery
            }
          })
          console.log('📊 已加载掌握情况:', response.rows.length, '条记录')
        }
      } catch (err) {
        console.warn('批量加载掌握情况失败:', err)
      }
    },
    // 加载知识点掌握情况（单个）
    loadMasteryForKp(kpId) {
      listMastery({ kpId: kpId, courseId: this.courseId }).then(response => {
        if (response.rows && response.rows.length > 0) {
          this.masteryMap[kpId] = response.rows[0]
          // 更新当前显示的节点详情
          if (this.nodeDetail.kpId === kpId) {
            this.nodeDetail.mastery = response.rows[0]
          }
        }
      }).catch(err => {
        console.warn('加载掌握情况失败:', err)
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
    // 掌握状态Tag类型
    getMasteryTagType(status) {
      const typeMap = {
        'mastered': 'success',
        'learning': 'warning',
        'weak': 'danger',
        'not_started': 'info'
      }
      return typeMap[status] || 'info'
    },
    // 掌握状态文本
    getMasteryStatusText(status) {
      const textMap = {
        'mastered': '已掌握',
        'learning': '学习中',
        'weak': '薄弱',
        'not_started': '未开始'
      }
      return textMap[status] || '未知'
    }
  }
}
</script>

<style scoped>
.knowledge-graph-container {
  padding: 0;
}

.control-panel {
  margin-bottom: 12px;
  border: none;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  background: #ffffff;
}

.graph-card {
  margin-bottom: 0;
  border: none;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  background: #ffffff;
  overflow: hidden;
}

.knowledge-graph-chart {
  width: 100%;
  height: 700px;
  background: linear-gradient(135deg, #fafbfc 0%, #f5f7fa 100%);
  position: relative;
  border-radius: 0 0 8px 8px;
}

.empty-state {
  height: 500px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fafafa;
}

/* 图例说明样式 */
.legend-bar {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 50px;
  padding: 14px 20px;
  margin-top: 12px;
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.legend-title {
  font-size: 14px;
  font-weight: 600;
  color: #667eea;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #606266;
}

.legend-edge {
  width: 28px;
  height: 3px;
  border-radius: 2px;
}

.legend-edge.prerequisite {
  background: #409EFF;
}

.legend-edge.similar {
  background: #67C23A;
}

.legend-edge.extension {
  background: #E6A23C;
}

.legend-edge.related {
  background: #909399;
}

/* 置信度说明样式 */
.confidence-legend {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 16px 20px;
  margin-top: 12px;
  background: linear-gradient(135deg, #f8f9ff 0%, #f0f4ff 100%);
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  border: 1px solid rgba(102, 126, 234, 0.1);
}

.confidence-desc {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #909399;
  padding: 8px 12px;
  background: rgba(255, 255, 255, 0.7);
  border-radius: 6px;
}

.confidence-desc i {
  color: #667eea;
  font-size: 16px;
}

.confidence-levels {
  display: flex;
  justify-content: space-around;
  gap: 20px;
}

.confidence-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 12px 16px;
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
  flex: 1;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.confidence-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.confidence-dot {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.confidence-dot.high {
  background: linear-gradient(135deg, #67C23A 0%, #85ce61 100%);
}

.confidence-dot.medium {
  background: linear-gradient(135deg, #E6A23C 0%, #f5c78a 100%);
}

.confidence-dot.low {
  background: linear-gradient(135deg, #F56C6C 0%, #f89898 100%);
}

.confidence-item span:first-of-type {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.confidence-hint {
  font-size: 12px;
  color: #909399;
  text-align: center;
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

.control-panel >>> .el-button--primary.is-plain {
  background: transparent;
  border: 2px solid #667eea;
  color: #667eea;
}

.control-panel >>> .el-button--primary.is-plain:hover {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
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

/* 知识点列表样式 */
.kp-list {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

/* 掌握情况样式 */
.mastery-info {
  display: flex;
  align-items: center;
}

/* 节点对话框样式增强 */
.node-dialog >>> .el-descriptions-item__label {
  width: 120px;
  font-weight: 600;
  color: #606266;
}

.node-dialog >>> .el-descriptions-item__content {
  color: #303133;
}
</style>