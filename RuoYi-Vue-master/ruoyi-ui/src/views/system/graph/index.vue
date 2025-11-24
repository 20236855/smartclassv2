<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="图谱标题" prop="title">
        <el-input
          v-model="queryParams.title"
          placeholder="请输入图谱标题"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="关联课程ID" prop="courseId">
        <el-input
          v-model="queryParams.courseId"
          placeholder="请输入关联课程ID"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="创建者ID" prop="creatorId">
        <el-input
          v-model="queryParams.creatorId"
          placeholder="请输入创建者ID"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="${comment}" prop="isDeleted">
        <el-input
          v-model="queryParams.isDeleted"
          placeholder="请输入${comment}"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="${comment}" prop="deleteTime">
        <el-date-picker clearable
          v-model="queryParams.deleteTime"
          type="date"
          value-format="yyyy-MM-dd"
          placeholder="请选择${comment}">
        </el-date-picker>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['system:graph:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-edit"
          size="mini"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['system:graph:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['system:graph:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['system:graph:export']"
        >导出</el-button>
      </el-col>
      <el-col :span="2">
        <el-button
          type="info"
          plain
          icon="el-icon-s-operation"
          size="mini"
          @click="handleGenerateForCourse"
          v-hasPermi="['system:graph:generate']"
        >为课程生成图谱</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="graphList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="知识图谱ID" align="center" prop="id" />
      <el-table-column label="图谱标题" align="center" prop="title" />
      <el-table-column label="图谱描述" align="center" prop="description" />
      <el-table-column label="关联课程ID" align="center" prop="courseId" />
      <el-table-column label="图谱类型：COURSE-课程图谱，CHAPTER-章节图谱" align="center" prop="graphType" />
      <el-table-column label="图谱数据" align="center" prop="graphData" />
      <el-table-column label="创建者ID" align="center" prop="creatorId" />
      <el-table-column label="状态：active-活跃，archived-归档" align="center" prop="status" />
      <el-table-column label="${comment}" align="center" prop="isDeleted" />
      <el-table-column label="${comment}" align="center" prop="deleteTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.deleteTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['system:graph:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['system:graph:remove']"
          >删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 添加或修改知识图谱对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="图谱标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入图谱标题" />
        </el-form-item>
        <el-form-item label="图谱描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入内容" />
        </el-form-item>
        <el-form-item label="关联课程ID" prop="courseId">
          <el-input v-model="form.courseId" placeholder="请输入关联课程ID" />
        </el-form-item>
        <el-form-item label="图谱数据" prop="graphData">
          <el-input v-model="form.graphData" type="textarea" placeholder="请输入内容" />
        </el-form-item>
        <el-form-item label="创建者ID" prop="creatorId">
          <el-input v-model="form.creatorId" placeholder="请输入创建者ID" />
        </el-form-item>
        <el-form-item label="${comment}" prop="isDeleted">
          <el-input v-model="form.isDeleted" placeholder="请输入${comment}" />
        </el-form-item>
        <el-form-item label="${comment}" prop="deleteTime">
          <el-date-picker clearable
            v-model="form.deleteTime"
            type="date"
            value-format="yyyy-MM-dd"
            placeholder="请选择${comment}">
          </el-date-picker>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listGraph, getGraph, delGraph, addGraph, updateGraph, extractCourseGraph } from "@/api/system/graph"

export default {
  name: "Graph",
  data() {
    return {
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 知识图谱表格数据
      graphList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        title: null,
        description: null,
        courseId: null,
        graphType: null,
        graphData: null,
        creatorId: null,
        status: null,
        isDeleted: null,
        deleteTime: null
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        title: [
          { required: true, message: "图谱标题不能为空", trigger: "blur" }
        ],
        courseId: [
          { required: true, message: "关联课程ID不能为空", trigger: "blur" }
        ],
        creatorId: [
          { required: true, message: "创建者ID不能为空", trigger: "blur" }
        ],
        isDeleted: [
          { required: true, message: "$comment不能为空", trigger: "blur" }
        ],
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    /** 查询知识图谱列表 */
    getList() {
      this.loading = true
      listGraph(this.queryParams).then(response => {
        this.graphList = response.rows
        this.total = response.total
        this.loading = false
      })
    },
    // 取消按钮
    cancel() {
      this.open = false
      this.reset()
    },
    // 表单重置
    reset() {
      this.form = {
        id: null,
        title: null,
        description: null,
        courseId: null,
        graphType: null,
        graphData: null,
        creatorId: null,
        status: null,
        createTime: null,
        updateTime: null,
        isDeleted: null,
        deleteTime: null
      }
      this.resetForm("form")
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    /** 重置按钮操作 */
    /** 为指定课程触发生成知识图谱 */
    handleGenerateForCourse() {
      this.$prompt('请输入要生成图谱的课程ID', '生成课程知识图谱', {
        confirmButtonText: '生成',
        cancelButtonText: '取消',
        inputPattern: /^\d+$/,
        inputErrorMessage: '课程ID 必须为数字'
      }).then(({ value }) => {
        this.$modal.confirm('确认为课程 ID ' + value + ' 生成知识图谱吗？').then(() => {
          extractCourseGraph(value).then(() => {
            this.$modal.msgSuccess('已提交生成任务，完成后请刷新列表查看')
          }).catch(err => {
            this.$modal.msgError('生成任务提交失败：' + (err.msg || err))
          })
        })
      }).catch(() => {})
    },
    resetQuery() {
      this.resetForm("queryForm")
      this.handleQuery()
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset()
      this.open = true
      this.title = "添加知识图谱"
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getGraph(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = "修改知识图谱"
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateGraph(this.form).then(response => {
              this.$modal.msgSuccess("修改成功")
              this.open = false
              this.getList()
            })
          } else {
            addGraph(this.form).then(response => {
              this.$modal.msgSuccess("新增成功")
              this.open = false
              this.getList()
            })
          }
        }
      })
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids
      this.$modal.confirm('是否确认删除知识图谱编号为"' + ids + '"的数据项？').then(function() {
        return delGraph(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess("删除成功")
      }).catch(() => {})
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('system/graph/export', {
        ...this.queryParams
      }, `graph_${new Date().getTime()}.xlsx`)
    }
  }
}
</script>
