<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="学生user.id" prop="studentUserId">
        <el-input
          v-model="queryParams.studentUserId"
          placeholder="请输入学生user.id"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="所属课程ID" prop="courseId">
        <el-input
          v-model="queryParams.courseId"
          placeholder="请输入所属课程ID"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="行为目标ID：视频→section.id，资源→course_resource.id，评论→section_comment.id" prop="targetId">
        <el-input
          v-model="queryParams.targetId"
          placeholder="请输入行为目标ID：视频→section.id，资源→course_resource.id，评论→section_comment.id"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="行为时长" prop="duration">
        <el-input
          v-model="queryParams.duration"
          placeholder="请输入行为时长"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="行为次数：视频重复观看次数/资源重复查看次数" prop="count">
        <el-input
          v-model="queryParams.count"
          placeholder="请输入行为次数：视频重复观看次数/资源重复查看次数"
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
          v-hasPermi="['system:lbehavior:add']"
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
          v-hasPermi="['system:lbehavior:edit']"
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
          v-hasPermi="['system:lbehavior:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['system:lbehavior:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="lbehaviorList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="行为ID" align="center" prop="id" />
      <el-table-column label="学生user.id" align="center" prop="studentUserId" />
      <el-table-column label="所属课程ID" align="center" prop="courseId" />
      <el-table-column label="行为类型：视频观看/资源查看/资源下载/评论" align="center" prop="behaviorType" />
      <el-table-column label="行为目标ID：视频→section.id，资源→course_resource.id，评论→section_comment.id" align="center" prop="targetId" />
      <el-table-column label="目标类型" align="center" prop="targetType" />
      <el-table-column label="行为时长" align="center" prop="duration" />
      <el-table-column label="行为次数：视频重复观看次数/资源重复查看次数" align="center" prop="count" />
      <el-table-column label="行为详情：视频→{"start_time":120,"end_time":300,"is_replay":1}" align="center" prop="detail" />
      <el-table-column label="软删除标记" align="center" prop="isDeleted" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['system:lbehavior:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['system:lbehavior:remove']"
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

    <!-- 添加或修改学生学习行为记录（视频/资源/互动行为）对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="学生user.id" prop="studentUserId">
          <el-input v-model="form.studentUserId" placeholder="请输入学生user.id" />
        </el-form-item>
        <el-form-item label="所属课程ID" prop="courseId">
          <el-input v-model="form.courseId" placeholder="请输入所属课程ID" />
        </el-form-item>
        <el-form-item label="行为目标ID：视频→section.id，资源→course_resource.id，评论→section_comment.id" prop="targetId">
          <el-input v-model="form.targetId" placeholder="请输入行为目标ID：视频→section.id，资源→course_resource.id，评论→section_comment.id" />
        </el-form-item>
        <el-form-item label="行为时长" prop="duration">
          <el-input v-model="form.duration" placeholder="请输入行为时长" />
        </el-form-item>
        <el-form-item label="行为次数：视频重复观看次数/资源重复查看次数" prop="count">
          <el-input v-model="form.count" placeholder="请输入行为次数：视频重复观看次数/资源重复查看次数" />
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
import { listLbehavior, getLbehavior, delLbehavior, addLbehavior, updateLbehavior } from "@/api/system/lbehavior"

export default {
  name: "Lbehavior",
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
      // 学生学习行为记录（视频/资源/互动行为）表格数据
      lbehaviorList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        studentUserId: null,
        courseId: null,
        behaviorType: null,
        targetId: null,
        targetType: null,
        duration: null,
        count: null,
        detail: null,
        isDeleted: null
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        studentUserId: [
          { required: true, message: "学生user.id不能为空", trigger: "blur" }
        ],
        courseId: [
          { required: true, message: "所属课程ID不能为空", trigger: "blur" }
        ],
        behaviorType: [
          { required: true, message: "行为类型：视频观看/资源查看/资源下载/评论不能为空", trigger: "change" }
        ],
        targetId: [
          { required: true, message: "行为目标ID：视频→section.id，资源→course_resource.id，评论→section_comment.id不能为空", trigger: "blur" }
        ],
        targetType: [
          { required: true, message: "目标类型不能为空", trigger: "change" }
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
    /** 查询学生学习行为记录（视频/资源/互动行为）列表 */
    getList() {
      this.loading = true
      listLbehavior(this.queryParams).then(response => {
        this.lbehaviorList = response.rows
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
        studentUserId: null,
        courseId: null,
        behaviorType: null,
        targetId: null,
        targetType: null,
        duration: null,
        count: null,
        detail: null,
        createTime: null,
        updateTime: null,
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
      this.title = "添加学生学习行为记录（视频/资源/互动行为）"
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getLbehavior(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = "修改学生学习行为记录（视频/资源/互动行为）"
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateLbehavior(this.form).then(response => {
              this.$modal.msgSuccess("修改成功")
              this.open = false
              this.getList()
            })
          } else {
            addLbehavior(this.form).then(response => {
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
      this.$modal.confirm('是否确认删除学生学习行为记录（视频/资源/互动行为）编号为"' + ids + '"的数据项？').then(function() {
        return delLbehavior(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess("删除成功")
      }).catch(() => {})
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('system/lbehavior/export', {
        ...this.queryParams
      }, `lbehavior_${new Date().getTime()}.xlsx`)
    }
  }
}
</script>
