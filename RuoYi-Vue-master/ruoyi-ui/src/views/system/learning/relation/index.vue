<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="能力点ID" prop="competencyId">
        <el-input
          v-model="queryParams.competencyId"
          placeholder="请输入能力点ID"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="知识点ID" prop="kpId">
        <el-input
          v-model="queryParams.kpId"
          placeholder="请输入知识点ID"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="知识点对能力点的贡献度" prop="contributionRate">
        <el-input
          v-model="queryParams.contributionRate"
          placeholder="请输入知识点对能力点的贡献度"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="软删除标记" prop="isDeleted">
        <el-input
          v-model="queryParams.isDeleted"
          placeholder="请输入软删除标记"
          clearable
          @keyup.enter.native="handleQuery"
        />
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
          v-hasPermi="['learning:relation:add']"
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
          v-hasPermi="['learning:relation:edit']"
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
          v-hasPermi="['learning:relation:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['learning:relation:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="relationList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="关联ID" align="center" prop="id" />
      <el-table-column label="能力点ID" align="center" prop="competencyId" />
      <el-table-column label="知识点ID" align="center" prop="kpId" />
      <el-table-column label="知识点对能力点的贡献度" align="center" prop="contributionRate" />
      <el-table-column label="软删除标记" align="center" prop="isDeleted" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['learning:relation:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['learning:relation:remove']"
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

    <!-- 添加或修改能力点-知识点关联（支撑能力模型与知识点的映射）对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="能力点ID" prop="competencyId">
          <el-input v-model="form.competencyId" placeholder="请输入能力点ID" />
        </el-form-item>
        <el-form-item label="知识点ID" prop="kpId">
          <el-input v-model="form.kpId" placeholder="请输入知识点ID" />
        </el-form-item>
        <el-form-item label="知识点对能力点的贡献度" prop="contributionRate">
          <el-input v-model="form.contributionRate" placeholder="请输入知识点对能力点的贡献度" />
        </el-form-item>
        <el-form-item label="软删除标记" prop="isDeleted">
          <el-input v-model="form.isDeleted" placeholder="请输入软删除标记" />
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
import { listRelation, getRelation, delRelation, addRelation, updateRelation } from "@/api/learning/relation"

export default {
  name: "Relation",
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
      // 能力点-知识点关联（支撑能力模型与知识点的映射）表格数据
      relationList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        competencyId: null,
        kpId: null,
        contributionRate: null,
        isDeleted: null
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        competencyId: [
          { required: true, message: "能力点ID不能为空", trigger: "blur" }
        ],
        kpId: [
          { required: true, message: "知识点ID不能为空", trigger: "blur" }
        ],
        isDeleted: [
          { required: true, message: "软删除标记不能为空", trigger: "blur" }
        ]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    /** 查询能力点-知识点关联（支撑能力模型与知识点的映射）列表 */
    getList() {
      this.loading = true
      listRelation(this.queryParams).then(response => {
        this.relationList = response.rows
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
        competencyId: null,
        kpId: null,
        contributionRate: null,
        createTime: null,
        isDeleted: null
      }
      this.resetForm("form")
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    /** 重置按钮操作 */
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
      this.title = "添加能力点-知识点关联（支撑能力模型与知识点的映射）"
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getRelation(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = "修改能力点-知识点关联（支撑能力模型与知识点的映射）"
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateRelation(this.form).then(response => {
              this.$modal.msgSuccess("修改成功")
              this.open = false
              this.getList()
            })
          } else {
            addRelation(this.form).then(response => {
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
      this.$modal.confirm('是否确认删除能力点-知识点关联（支撑能力模型与知识点的映射）编号为"' + ids + '"的数据项？').then(function() {
        return delRelation(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess("删除成功")
      }).catch(() => {})
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('learning/relation/export', {
        ...this.queryParams
      }, `relation_${new Date().getTime()}.xlsx`)
    }
  }
}
</script>
