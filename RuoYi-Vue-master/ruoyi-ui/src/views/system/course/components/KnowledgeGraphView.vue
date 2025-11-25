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

        const graph = graphs[graphs.length - 1]
        this.graphInfo = graph

        try {
          const graphData = JSON.parse(graph.graphData)
          this.renderGraph(graphData)
        } catch (e) {
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

      this.nodeCount = nodes.length
      this.edgeCount = edges.length

      const chartNodes = nodes.map(node => ({
        id: node.id,
        name: node.label,
        symbolSize: Math.max(30, 50 + (node.confidence || 0) * 50),
        value: node.confidence || 0,
        category: this.getCategoryByConfidence(node.confidence),
        itemStyle: {
          color: this.getColorByConfidence(node.confidence),
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: true,
          fontSize: 12,
          fontWeight: 'bold'
        },
        rawData: node
      }))

      const chartLinks = edges.map(edge => ({
        source: edge.source,
        target: edge.target,
        label: {
          show: true,
          formatter: this.getRelationLabel(edge.type),
          fontSize: 10
        },
        lineStyle: {
          curveness: 0.2,
          color: this.getEdgeColor(edge.type),
          width: 2
        }
      }))

      const categories = [
        { name: '高置信度' },
        { name: '中置信度' },
        { name: '低置信度' }
      ]

      const option = {
        backgroundColor: '#fafafa',
        title: {
          text: this.selectedGraphType === 'COURSE' ? '课程知识图谱' : '章节知识图谱',
          left: 'center',
          top: 20,
          textStyle: {
            fontSize: 18,
            fontWeight: 'bold',
            color: '#333'
          }
        },
        tooltip: {
          trigger: 'item',
          backgroundColor: 'rgba(0,0,0,0.8)',
          borderColor: '#777',
          textStyle: {
            color: '#fff'
          },
          formatter: (params) => {
            if (params.dataType === 'node') {
              const data = params.data.rawData
              return `<div style="padding: 10px;">
                        <div style="font-size: 14px; font-weight: bold; margin-bottom: 8px;">${data.label}</div>
                        <div style="margin-bottom: 5px;">定义: ${data.definition || '暂无定义'}</div>
                        <div>置信度: ${Math.round((data.confidence || 0) * 100)}%</div>
                      </div>`
            } else if (params.dataType === 'edge') {
              return `关系类型: ${this.getRelationLabel(params.data.label.formatter)}`
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
            fontSize: 11
          },
          force: {
            repulsion: 1000,
            edgeLength: [100, 300],
            gravity: 0.1,
            friction: 0.6
          },
          emphasis: {
            focus: 'adjacency',
            lineStyle: {
              width: 4
            },
            itemStyle: {
              shadowBlur: 10,
              shadowColor: 'rgba(0,0,0,0.3)'
            }
          }
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
    getColorByConfidence(confidence) {
      if (confidence >= 0.7) return '#67C23A'
      if (confidence >= 0.4) return '#E6A23C'
      return '#F56C6C'
    },
    getConfidenceColor(confidence) {
      if (confidence >= 0.7) return '#67C23A'
      if (confidence >= 0.4) return '#E6A23C'
      return '#F56C6C'
    },
    getEdgeColor(type) {
      const colorMap = {
        'prerequisite_of': '#409EFF',
        'similar_to': '#67C23A',
        'extension_of': '#E6A23C',
        'derived_from': '#909399',
        'related': '#909399'
      }
      return colorMap[type] || '#909399'
    },
    getRelationLabel(type) {
      const labelMap = {
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
  margin-bottom: 20px;
  border: 1px solid #e4e7ed;
}

.graph-info-card {
  margin-bottom: 20px;
  border: 1px solid #e4e7ed;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.graph-title {
  font-size: 16px;
  font-weight: bold;
  color: #303133;
}

.info-item {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.info-item i {
  margin-right: 8px;
  color: #909399;
}

.update-time {
  text-align: center;
}

.graph-card {
  margin-bottom: 20px;
  border: 1px solid #e4e7ed;
}

.knowledge-graph-chart {
  width: 100%;
  height: 600px;
  background: #fafafa;
  border-radius: 4px;
}

.empty-state {
  height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.legend-card {
  border: 1px solid #e4e7ed;
}

.legend-item {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.legend-node {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  margin-right: 8px;
  border: 2px solid #fff;
}

.legend-node.high-confidence {
  background-color: #67C23A;
}

.legend-node.medium-confidence {
  background-color: #E6A23C;
}

.legend-node.low-confidence {
  background-color: #F56C6C;
}

.legend-edge {
  width: 30px;
  height: 3px;
  margin-right: 8px;
  border-radius: 2px;
}

.legend-edge.prerequisite {
  background-color: #409EFF;
}

.legend-edge.similar {
  background-color: #67C23A;
}

.legend-edge.extension {
  background-color: #E6A23C;
}

.legend-edge.related {
  background-color: #909399;
}

.node-dialog .el-dialog__body {
  padding: 20px;
}
</style>