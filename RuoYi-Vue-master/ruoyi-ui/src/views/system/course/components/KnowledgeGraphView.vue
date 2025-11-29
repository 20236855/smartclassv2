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
    <el-dialog :title="nodeDetail.label" :visible.sync="nodeDialogVisible" width="600px" class="node-dialog">
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
    </el-dialog>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import { listGraph, extractCourseGraph, extractChapterGraph } from '@/api/system/graph'
import { listChapter } from '@/api/system/chapter'

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
          color: this.getEdgeColor(edge.type),
          padding: [2, 4]
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
            fontWeight: 600
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
        }
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
  height: 650px;
  background: #fafafa;
  position: relative;
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
</style>