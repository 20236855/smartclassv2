<template>
  <div class="knowledge-graph-container" :class="{ 'fullscreen-mode': isFullscreen }">
    <!-- 控制面板 -->
    <el-card class="control-panel" shadow="never" v-if="!isFullscreen">
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
    <el-card class="graph-card" :class="{ 'fullscreen': isFullscreen }" shadow="hover">
      <!-- 全屏按钮 -->
      <div class="fullscreen-btn" @click="toggleFullscreen" v-if="graphInfo">
        <i :class="isFullscreen ? 'el-icon-close' : 'el-icon-full-screen'"></i>
        <span>{{ isFullscreen ? '退出全屏' : '全屏查看' }}</span>
      </div>

      <!-- 缩放控制按钮 -->
      <div class="zoom-controls" v-if="graphInfo && !loading">
        <el-button-group>
          <el-button size="mini" icon="el-icon-plus" @click="zoomIn" title="放大"></el-button>
          <el-button size="mini" icon="el-icon-minus" @click="zoomOut" title="缩小"></el-button>
          <el-button size="mini" @click="resetZoom" title="重置">
            <i class="el-icon-refresh-left"></i>
          </el-button>
        </el-button-group>
      </div>

      <!-- 统计信息面板（全屏时显示） -->
      <div class="stats-panel" v-if="isFullscreen && graphInfo">
        <div class="stat-item">
          <i class="el-icon-connection"></i>
          <div class="stat-content">
            <div class="stat-value">{{ nodeCount }}</div>
            <div class="stat-label">知识点</div>
          </div>
        </div>
        <div class="stat-item">
          <i class="el-icon-share"></i>
          <div class="stat-content">
            <div class="stat-value">{{ edgeCount }}</div>
            <div class="stat-label">关系</div>
          </div>
        </div>
        <div class="stat-item">
          <i class="el-icon-zoom-in"></i>
          <div class="stat-content">
            <div class="stat-value">{{ Math.round(currentZoom * 100) }}%</div>
            <div class="stat-label">缩放</div>
          </div>
        </div>
      </div>

      <div ref="chart" class="knowledge-graph-chart" v-loading="loading">
        <!-- 操作提示 -->
        <div class="operation-hint" v-if="graphInfo && !loading">
          <i class="el-icon-info"></i>
          <span>💡 操作提示：拖拽节点可移动 | 鼠标滚轮可缩放 | 点击节点查看详情 | 右上角可全屏查看</span>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-if="!graphInfo && !loading && !isFullscreen" class="empty-state">
        <el-empty description="暂无知识图谱数据">
          <el-button type="primary" @click="handleGenerate">生成知识图谱</el-button>
        </el-empty>
      </div>
    </el-card>

    <!-- 图例说明 -->
    <div class="legend-bar" v-if="!isFullscreen">
      <span class="legend-title">🔗 关系类型说明</span>
      <div class="legend-item">
        <div class="legend-edge prerequisite"></div>
        <span>🔵 前置关系</span>
      </div>
      <div class="legend-item">
        <div class="legend-edge similar"></div>
        <span>🟢 相似关系</span>
      </div>
      <div class="legend-item">
        <div class="legend-edge extension"></div>
        <span>🟠 扩展关系</span>
      </div>
      <div class="legend-item">
        <div class="legend-edge example"></div>
        <span>🔴 示例关系</span>
      </div>
      <div class="legend-item">
        <div class="legend-edge related"></div>
        <span>🔷 相关关系</span>
      </div>
      <div class="legend-item">
        <div class="legend-edge hierarchy"></div>
        <span>⚪ 层级关系</span>
      </div>
    </div>

    <!-- 置信度说明 -->
    <div class="confidence-legend" v-if="!isFullscreen">
      <span class="legend-title">🎯 知识点颜色说明（按置信度区分）</span>
      <div class="confidence-desc">
        <i class="el-icon-info"></i>
        <span>知识点节点颜色根据AI识别的置信度自动设置，置信度越高表示识别越准确</span>
      </div>
      <div class="confidence-levels">
        <div class="confidence-item">
          <div class="confidence-dot high"></div>
          <span>🟢 高置信度 (≥70%)</span>
          <span class="confidence-hint">识别准确，可直接使用</span>
        </div>
        <div class="confidence-item">
          <div class="confidence-dot medium"></div>
          <span>🟠 中置信度 (40%-70%)</span>
          <span class="confidence-hint">建议人工复核</span>
        </div>
        <div class="confidence-item">
          <div class="confidence-dot low"></div>
          <span>🔴 低置信度 (&lt;40%)</span>
          <span class="confidence-hint">需要人工审核</span>
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
      currentGraphData: null, // 保存当前渲染的图谱数据（已解析的对象）
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
      },
      isFullscreen: false,
      currentZoom: 1
    }
  },
  mounted() {
    this.initChart()
    this.loadChapters()
    this.loadGraph()
    // 监听ESC键退出全屏
    document.addEventListener('keydown', this.handleEscKey)
  },
  beforeDestroy() {
    if (this.chart) {
      this.chart.dispose()
      this.chart = null
    }
    // 恢复body滚动
    document.body.style.overflow = ''
    window.removeEventListener('resize', this.handleResize)
    document.removeEventListener('keydown', this.handleEscKey)
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

          // 保存当前图谱数据
          this.currentGraphData = graphData
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
      console.log('🎨 renderGraph 被调用')
      console.log('🎨 graphData:', graphData)
      console.log('🎨 chart 实例存在:', !!this.chart)
      console.log('🎨 chart 容器存在:', !!this.$refs.chart)

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
        const confidence = node.confidence || 0

        // 🔥 根据置信度确定颜色（仅对知识点节点）
        let color
        if (nodeType === 'kp' && confidence > 0) {
          // 知识点根据置信度设置颜色
          if (confidence >= 0.7) {
            color = '#67C23A'  // 绿色 - 高置信度
          } else if (confidence >= 0.4) {
            color = '#E6A23C'  // 橙色 - 中置信度
          } else {
            color = '#F56C6C'  // 红色 - 低置信度
          }
        } else {
          // 其他节点使用章节颜色
          color = node.color || chapterColors[chapterIndex % chapterColors.length]
        }

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
          _baseSymbolSize: symbolSize,  // 保存基础大小用于缩放
          value: node.category || chapterIndex,
          category: node.category !== undefined ? node.category : chapterIndex,
          itemStyle: {
            color: nodeType === 'course' ? '#67C23A' : color,  // 🔥 课程节点使用绿色，其他节点根据置信度或章节
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
            color: '#333',  // 🔥 所有节点文字都使用黑色
            position: labelPosition,
            distance: 5,
            _baseFontSize: fontSize  // 保存基础字体大小用于缩放
          },
          emphasis: {
            itemStyle: { borderWidth: 3, shadowBlur: 12 },
            label: { fontSize: fontSize + 2, fontWeight: 'bold' }
          },
          rawData: node
        }
      })

      console.log('📊 边数据:', edges.length > 0 ? edges[0] : 'N/A', '边总数:', edges.length)

      // 创建节点ID到颜色的映射
      const nodeColorMap = {}
      nodes.forEach(node => {
        const nodeType = node.nodeType || 'kp'
        const chapterIndex = node.chapterIndex || 0
        const confidence = node.confidence || 0

        let color
        // 根据节点类型和置信度确定颜色
        if (nodeType === 'course') {
          color = '#67C23A'  // 课程节点绿色
        } else if (nodeType === 'kp' && confidence > 0) {
          // 知识点根据置信度
          if (confidence >= 0.7) color = '#67C23A'
          else if (confidence >= 0.4) color = '#E6A23C'
          else color = '#F56C6C'
        } else {
          // 其他节点使用章节颜色
          color = node.color || chapterColors[chapterIndex % chapterColors.length]
        }

        nodeColorMap[node.id] = color
      })

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
        const isHierarchyEdge = ['CONTAINS', 'COVERS'].includes(edgeType)
        const baseWidth = isHierarchyEdge ? 5 : 4  // 🔥 更粗的线条：层级边5px，关系边4px

        // 🔥 根据图谱类型确定边的颜色
        let lineColor = '#5470c6'  // 默认深蓝色

        // 判断是总图谱还是章节图谱
        const isCourseGraph = this.selectedGraphType === 'COURSE'

        if (isCourseGraph) {
          // 🔥 总图谱：线条颜色根据连接的节点颜色变化
          if (isHierarchyEdge) {
            // 层级边使用目标节点（子节点）的颜色
            lineColor = nodeColorMap[edge.target] || '#909399'
          } else {
            // 知识点关系边使用源节点的颜色
            lineColor = nodeColorMap[edge.source] || nodeColorMap[edge.target] || '#73c0de'
          }
        } else {
          // 🔥 章节图谱：线条颜色根据关系类型设置
          if (isHierarchyEdge) {
            lineColor = '#909399'  // 层级边使用灰色
          } else {
            // 知识点关系边根据关系类型设置颜色
            const relationColorMap = {
              'PREREQUISITE': '#409EFF',        // 蓝色 - 前置关系
              'prerequisite_of': '#409EFF',
              'SIMILAR': '#67C23A',             // 绿色 - 相似关系
              'similar_to': '#67C23A',
              'EXTENSION': '#E6A23C',           // 橙色 - 扩展关系
              'extension_of': '#E6A23C',
              'EXAMPLE': '#F56C6C',             // 红色 - 示例关系
              'BELONGS_TO': '#909399',          // 灰色 - 从属关系
              'derived_from': '#9a60b4',        // 紫色 - 派生关系
              'related': '#73c0de',             // 青色 - 相关关系
              'RELATED': '#73c0de'
            }
            lineColor = relationColorMap[edgeType] || '#73c0de'
          }
        }

        return {
          source: edge.source,
          target: edge.target,
          label: { show: false },
          lineStyle: {
            curveness: isHierarchyEdge ? 0 : 0.2,
            color: lineColor,
            width: baseWidth,
            _baseWidth: baseWidth,  // 保存基础宽度用于缩放
            opacity: isHierarchyEdge ? 0.75 : 0.65  // 🔥 提高不透明度，让线条更明显
          },
          emphasis: {
            lineStyle: { width: 7, opacity: 1, color: '#ff6b6b' },  // 🔥 悬停时更粗，使用红色高亮
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

      // 监听缩放事件，让字体跟随缩放
      this.chart.off('georoam')
      this.chart.on('georoam', (params) => {
        if (params.zoom != null) {
          this.currentZoom = params.zoom
          this.applyZoom()
        }
      })

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
    },
    // 全屏切换
    toggleFullscreen() {
      this.isFullscreen = !this.isFullscreen
      console.log('🖥️ 全屏状态切换:', this.isFullscreen)

      // 切换body滚动
      if (this.isFullscreen) {
        document.body.style.overflow = 'hidden'
        console.log('✅ 进入全屏模式')
      } else {
        document.body.style.overflow = ''
        console.log('❌ 退出全屏模式')
      }

      // 延迟调整图表大小，确保DOM已更新
      this.$nextTick(() => {
        setTimeout(() => {
          if (!this.$refs.chart) {
            console.error('❌ 图表容器不存在')
            return
          }

          const container = this.$refs.chart
          console.log('📊 开始调整图表大小...')
          console.log('📊 容器尺寸:', container.offsetWidth, 'x', container.offsetHeight)

          // 销毁旧实例，重新初始化
          if (this.chart) {
            console.log('🔄 销毁旧图表实例')
            this.chart.dispose()
            this.chart = null
          }

          // 重新初始化图表
          console.log('🆕 创建新图表实例')
          this.chart = echarts.init(container)

          // 重新渲染图谱
          if (this.currentGraphData) {
            console.log('📊 重新渲染图谱，节点数:', this.currentGraphData.nodes?.length || 0)
            this.renderGraph(this.currentGraphData)
          } else {
            console.error('❌ 没有图谱数据可渲染')
          }
        }, 200)
      })
    },
    // ESC键退出全屏
    handleEscKey(e) {
      if (e.key === 'Escape' && this.isFullscreen) {
        this.isFullscreen = false
        document.body.style.overflow = ''
        this.$nextTick(() => {
          if (this.chart) {
            this.chart.resize()
          }
        })
      }
    },
    // 放大
    zoomIn() {
      if (!this.chart) return
      this.currentZoom = Math.min(this.currentZoom * 1.2, 5)
      this.applyZoom()
    },
    // 缩小
    zoomOut() {
      if (!this.chart) return
      this.currentZoom = Math.max(this.currentZoom / 1.2, 0.2)
      this.applyZoom()
    },
    // 重置缩放
    resetZoom() {
      if (!this.chart) return
      this.currentZoom = 1
      this.applyZoom()
    },
    // 应用缩放
    applyZoom() {
      if (!this.chart) return

      const option = this.chart.getOption()
      if (!option || !option.series || !option.series[0]) return

      const series = option.series[0]
      const baseNodeSize = series.data.map(node => node._baseSymbolSize || node.symbolSize)
      const baseFontSize = series.data.map(node => node.label?._baseFontSize || node.label?.fontSize || 10)

      // 更新节点大小和字体大小
      series.data.forEach((node, index) => {
        if (!node._baseSymbolSize) {
          node._baseSymbolSize = node.symbolSize
        }
        if (!node.label._baseFontSize) {
          node.label._baseFontSize = node.label.fontSize
        }

        node.symbolSize = node._baseSymbolSize * this.currentZoom
        node.label.fontSize = Math.round(node.label._baseFontSize * this.currentZoom)
      })

      // 更新边的宽度
      if (series.links) {
        series.links.forEach(link => {
          if (!link.lineStyle._baseWidth) {
            link.lineStyle._baseWidth = link.lineStyle.width || 1
          }
          link.lineStyle.width = link.lineStyle._baseWidth * this.currentZoom
        })
      }

      this.chart.setOption(option)
    }
  }
}
</script>

<style scoped>
.knowledge-graph-container {
  padding: 0;
  position: relative;
}

/* 全屏模式容器 */
.knowledge-graph-container.fullscreen-mode {
  position: fixed !important;
  top: 0 !important;
  left: 0 !important;
  right: 0 !important;
  bottom: 0 !important;
  width: 100vw !important;
  height: 100vh !important;
  z-index: 99999 !important;
  background: #ffffff !important;
  padding: 0 !important;
  margin: 0 !important;
  overflow: hidden !important;
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
  position: relative;
  transition: all 0.3s ease;
  height: auto;
}

/* 全屏模式 */
.fullscreen-mode .graph-card {
  position: relative !important;
  width: 100vw !important;
  height: 100vh !important;
  margin: 0 !important;
  border-radius: 0 !important;
  box-shadow: none !important;
  max-width: none !important;
  display: flex !important;
  flex-direction: column !important;
}

.fullscreen-mode .graph-card >>> .el-card__body {
  padding: 0 !important;
  height: 100% !important;
  flex: 1 !important;
  display: flex !important;
  flex-direction: column !important;
  overflow: hidden !important;
}

.fullscreen-mode .knowledge-graph-chart {
  width: 100% !important;
  height: 100% !important;
  flex: 1 !important;
  border-radius: 0 !important;
  min-height: 0 !important;
}

/* 全屏按钮 */
.fullscreen-btn {
  position: absolute;
  top: 16px;
  right: 16px;
  z-index: 100;
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  animation: slideInRight 0.5s ease-out;
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.fullscreen-btn:hover {
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.4);
}

.fullscreen-btn:active {
  transform: translateY(0) scale(0.98);
}

.fullscreen-btn i {
  font-size: 16px;
  transition: transform 0.3s ease;
}

.fullscreen-btn:hover i {
  transform: rotate(90deg);
}

/* 缩放控制按钮 */
.zoom-controls {
  position: absolute;
  top: 70px;
  right: 16px;
  z-index: 100;
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  padding: 4px;
}

.zoom-controls >>> .el-button-group {
  display: flex;
  flex-direction: column;
}

.zoom-controls >>> .el-button {
  margin: 0;
  border-radius: 6px;
  border: none;
  background: #f5f7fa;
  color: #606266;
  transition: all 0.2s ease;
}

.zoom-controls >>> .el-button:hover {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
  transform: scale(1.05);
}

.zoom-controls >>> .el-button + .el-button {
  margin-top: 4px;
  margin-left: 0;
}

/* 统计信息面板 */
.stats-panel {
  position: absolute;
  top: 16px;
  left: 16px;
  z-index: 100;
  display: flex;
  gap: 12px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  padding: 12px 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 12px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 8px;
  transition: all 0.3s ease;
}

.stat-item:hover {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.stat-item:hover i,
.stat-item:hover .stat-value,
.stat-item:hover .stat-label {
  color: #ffffff;
}

.stat-item i {
  font-size: 24px;
  color: #667eea;
  transition: color 0.3s ease;
}

.stat-content {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.stat-value {
  font-size: 20px;
  font-weight: 700;
  color: #303133;
  line-height: 1;
  transition: color 0.3s ease;
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin-top: 2px;
  transition: color 0.3s ease;
}

/* 操作提示 */
.operation-hint {
  position: absolute;
  bottom: 16px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  font-size: 13px;
  color: #606266;
  z-index: 10;
  animation: fadeInUp 0.6s ease-out;
  transition: all 0.3s ease;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateX(-50%) translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateX(-50%) translateY(0);
  }
}

.operation-hint:hover {
  background: rgba(102, 126, 234, 0.95);
  color: #ffffff;
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.3);
}

.operation-hint i {
  font-size: 16px;
  color: #667eea;
  transition: color 0.3s ease;
}

.operation-hint:hover i {
  color: #ffffff;
}

.knowledge-graph-chart {
  width: 100%;
  height: 700px;
  background: linear-gradient(135deg, #fafbfc 0%, #f5f7fa 100%);
  position: relative;
  border-radius: 0 0 8px 8px;
  transition: height 0.3s ease;
}

.fullscreen-mode .knowledge-graph-chart {
  border-radius: 0;
  background: linear-gradient(135deg, #f0f2f5 0%, #e4e7ed 100%);
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
  background: #409EFF;  /* 蓝色 - 前置关系 */
}

.legend-edge.similar {
  background: #67C23A;  /* 绿色 - 相似关系 */
}

.legend-edge.extension {
  background: #E6A23C;  /* 橙色 - 扩展关系 */
}

.legend-edge.example {
  background: #F56C6C;  /* 红色 - 示例关系 */
}

.legend-edge.related {
  background: #73c0de;  /* 青色 - 相关关系 */
}

.legend-edge.hierarchy {
  background: #909399;  /* 灰色 - 层级关系 */
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