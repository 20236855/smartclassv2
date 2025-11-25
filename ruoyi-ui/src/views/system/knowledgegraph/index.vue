<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="课程" prop="courseId">
        <el-select v-model="queryParams.courseId" placeholder="请选择课程" clearable>
          <el-option v-for="course in courseList" :key="course.id" :label="course.title" :value="course.id"/>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd">新增</el-button>
      </el-col>
    </el-row>

    <!-- 知识图谱列表 -->
    <el-table v-loading="loading" :data="knowledgeGraphList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="标题" align="center" prop="title" />
      <el-table-column label="类型" align="center" prop="graphType" />
      <el-table-column label="状态" align="center" prop="status" />
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="handleView(scope.row)">查看图谱</el-button>
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 知识图谱可视化对话框 -->
    <el-dialog title="知识图谱可视化" :visible.sync="graphVisible" width="90%" top="5vh">
      <div id="knowledgeGraphChart" style="width: 100%; height: 600px;"></div>
    </el-dialog>

    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList"/>
  </div>
</template>

<script>
import { listKnowledgeGraph, getKnowledgeGraph, delKnowledgeGraph } from "@/api/system/knowledgegraph";
import { listCourse } from "@/api/system/course";
import * as echarts from 'echarts';

export default {
  name: "KnowledgeGraph",
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      knowledgeGraphList: [],
      courseList: [],
      title: "",
      open: false,
      graphVisible: false,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        courseId: null
      },
      chart: null
    };
  },
  created() {
    this.getList();
    this.getCourseList();
  },
  methods: {
    getList() {
      this.loading = true;
      listKnowledgeGraph(this.queryParams).then(response => {
        this.knowledgeGraphList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    getCourseList() {
      listCourse().then(response => {
        this.courseList = response.rows;
      });
    },
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },
    handleView(row) {
      this.graphVisible = true;
      this.$nextTick(() => {
        this.renderGraph(row.graphData);
      });
    },
    renderGraph(graphData) {
      const chartDom = document.getElementById('knowledgeGraphChart');
      if (this.chart) {
        this.chart.dispose();
      }
      this.chart = echarts.init(chartDom);
      
      let data;
      try {
        data = typeof graphData === 'string' ? JSON.parse(graphData) : graphData;
      } catch (e) {
        this.$modal.msgError('图谱数据格式错误');
        return;
      }

      const option = {
        title: {
          text: '知识图谱',
          left: 'center'
        },
        tooltip: {
          formatter: function (params) {
            if (params.dataType === 'node') {
              return `<strong>${params.data.label}</strong><br/>
                      定义: ${params.data.definition || '暂无'}<br/>
                      置信度: ${(params.data.confidence * 100).toFixed(1)}%`;
            } else if (params.dataType === 'edge') {
              return `关系: ${params.data.type}<br/>
                      置信度: ${(params.data.confidence * 100).toFixed(1)}%`;
            }
          }
        },
        series: [{
          type: 'graph',
          layout: 'force',
          data: data.nodes.map(node => ({
            id: node.id,
            name: node.label,
            label: node.label,
            definition: node.definition,
            confidence: node.confidence,
            symbolSize: Math.max(30, node.confidence * 50),
            itemStyle: {
              color: this.getNodeColor(node.confidence)
            }
          })),
          links: data.edges.map(edge => ({
            source: edge.source,
            target: edge.target,
            type: edge.type,
            confidence: edge.confidence,
            lineStyle: {
              width: Math.max(1, edge.confidence * 3),
              color: this.getEdgeColor(edge.type)
            }
          })),
          roam: true,
          label: {
            show: true,
            position: 'right',
            formatter: '{b}'
          },
          force: {
            repulsion: 1000,
            gravity: 0.1,
            edgeLength: 150,
            layoutAnimation: true
          },
          emphasis: {
            focus: 'adjacency',
            lineStyle: {
              width: 5
            }
          }
        }]
      };

      this.chart.setOption(option);
    },
    getNodeColor(confidence) {
      if (confidence >= 0.8) return '#67C23A'; // 绿色 - 高置信度
      if (confidence >= 0.6) return '#E6A23C'; // 橙色 - 中置信度
      return '#F56C6C'; // 红色 - 低置信度
    },
    getEdgeColor(type) {
      const colorMap = {
        'prerequisite_of': '#409EFF', // 蓝色 - 前置关系
        'similar_to': '#67C23A',      // 绿色 - 相似关系
        'related': '#909399',         // 灰色 - 相关关系
        'contains': '#E6A23C'         // 橙色 - 包含关系
      };
      return colorMap[type] || '#909399';
    }
  },
  beforeDestroy() {
    if (this.chart) {
      this.chart.dispose();
    }
  }
};
</script>