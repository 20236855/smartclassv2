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
      <el-form-item label="知识点ID" prop="kpId">
        <el-input
          v-model="queryParams.kpId"
          placeholder="请输入知识点ID"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="答对次数" prop="correctCount">
        <el-input
          v-model="queryParams.correctCount"
          placeholder="请输入答对次数"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="总答题次数" prop="totalCount">
        <el-input
          v-model="queryParams.totalCount"
          placeholder="请输入总答题次数"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="正确率" prop="accuracy">
        <el-input
          v-model="queryParams.accuracy"
          placeholder="请输入正确率"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="最近一次测试得分" prop="lastTestScore">
        <el-input
          v-model="queryParams.lastTestScore"
          placeholder="请输入最近一次测试得分"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="最近测试时间" prop="lastTestTime">
        <el-date-picker clearable
          v-model="queryParams.lastTestTime"
          type="date"
          value-format="yyyy-MM-dd"
          placeholder="请选择最近测试时间">
        </el-date-picker>
      </el-form-item>
      <el-form-item label="掌握指标" prop="masteryScore">
        <el-input
          v-model="queryParams.masteryScore"
          placeholder="请输入掌握指标"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="最后更新来源：system/ai/job" prop="lastUpdatedBy">
        <el-input
          v-model="queryParams.lastUpdatedBy"
          placeholder="请输入最后更新来源：system/ai/job"
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
          v-hasPermi="['system:mastery:add']"
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
          v-hasPermi="['system:mastery:edit']"
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
          v-hasPermi="['system:mastery:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['system:mastery:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="masteryList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="记录ID" align="center" prop="id" />
      <el-table-column label="学生user.id" align="center" prop="studentUserId" />
      <el-table-column label="所属课程ID" align="center" prop="courseId" />
      <el-table-column label="知识点ID" align="center" prop="kpId" />
      <el-table-column label="答对次数" align="center" prop="correctCount" />
      <el-table-column label="总答题次数" align="center" prop="totalCount" />
      <el-table-column label="正确率" align="center" prop="accuracy" />
      <el-table-column label="最近一次测试得分" align="center" prop="lastTestScore" />
      <el-table-column label="最近测试时间" align="center" prop="lastTestTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.lastTestTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="趋势" align="center" prop="trend" />
      <el-table-column label="掌握指标" align="center" prop="masteryScore" />
      <el-table-column label="掌握状态：未学习/学习中/已掌握/薄弱点" align="center" prop="masteryStatus" />
      <el-table-column label="权重因子明细：{"exam_score":0.4,"video_behavior":0.3,"resource_behavior":0.2,"homework_score":0.1}" align="center" prop="weightFactors" />
      <el-table-column label="最后更新来源：system/ai/job" align="center" prop="lastUpdatedBy" />
      <el-table-column label="软删除标记" align="center" prop="isDeleted" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['system:mastery:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['system:mastery:remove']"
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

    <!-- 添加或修改学生知识点掌握情况（支撑知识图谱状态标识）对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="学生user.id" prop="studentUserId">
          <el-input v-model="form.studentUserId" placeholder="请输入学生user.id" />
        </el-form-item>
        <el-form-item label="所属课程ID" prop="courseId">
          <el-input v-model="form.courseId" placeholder="请输入所属课程ID" />
        </el-form-item>
        <el-form-item label="知识点ID" prop="kpId">
          <el-input v-model="form.kpId" placeholder="请输入知识点ID" />
        </el-form-item>
        <el-form-item label="答对次数" prop="correctCount">
          <el-input v-model="form.correctCount" placeholder="请输入答对次数" />
        </el-form-item>
        <el-form-item label="总答题次数" prop="totalCount">
          <el-input v-model="form.totalCount" placeholder="请输入总答题次数" />
        </el-form-item>
        <el-form-item label="正确率" prop="accuracy">
          <el-input v-model="form.accuracy" placeholder="请输入正确率" />
        </el-form-item>
        <el-form-item label="最近一次测试得分" prop="lastTestScore">
          <el-input v-model="form.lastTestScore" placeholder="请输入最近一次测试得分" />
        </el-form-item>
        <el-form-item label="最近测试时间" prop="lastTestTime">
          <el-date-picker clearable
            v-model="form.lastTestTime"
            type="date"
            value-format="yyyy-MM-dd"
            placeholder="请选择最近测试时间">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="掌握指标" prop="masteryScore">
          <el-input v-model="form.masteryScore" placeholder="请输入掌握指标" />
        </el-form-item>
        <el-form-item label="最后更新来源：system/ai/job" prop="lastUpdatedBy">
          <el-input v-model="form.lastUpdatedBy" placeholder="请输入最后更新来源：system/ai/job" />
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
import { listMastery, getMastery, delMastery, addMastery, updateMastery } from "@/api/system/mastery"

export default {
  name: "Mastery",
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
      // 学生知识点掌握情况（支撑知识图谱状态标识）表格数据
      masteryList: [],
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
        kpId: null,
        correctCount: null,
        totalCount: null,
        accuracy: null,
        lastTestScore: null,
        lastTestTime: null,
        trend: null,
        masteryScore: null,
        masteryStatus: null,
        weightFactors: null,
        lastUpdatedBy: null,
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
        kpId: [
          { required: true, message: "知识点ID不能为空", trigger: "blur" }
        ],
        masteryScore: [
          { required: true, message: "掌握指标不能为空", trigger: "blur" }
        ],
        masteryStatus: [
          { required: true, message: "掌握状态：未学习/学习中/已掌握/薄弱点不能为空", trigger: "change" }
        ],
        lastUpdatedBy: [
          { required: true, message: "最后更新来源：system/ai/job不能为空", trigger: "blur" }
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
    /** 查询学生知识点掌握情况（支撑知识图谱状态标识）列表 */
    getList() {
      this.loading = true
      listMastery(this.queryParams).then(response => {
        this.masteryList = response.rows
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
        kpId: null,
        correctCount: null,
        totalCount: null,
        accuracy: null,
        lastTestScore: null,
        lastTestTime: null,
        trend: null,
        masteryScore: null,
        masteryStatus: null,
        weightFactors: null,
        lastUpdatedBy: null,
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
      this.title = "添加学生知识点掌握情况（支撑知识图谱状态标识）"
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getMastery(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = "修改学生知识点掌握情况（支撑知识图谱状态标识）"
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateMastery(this.form).then(response => {
              this.$modal.msgSuccess("修改成功")
              this.open = false
              this.getList()
            })
          } else {
            addMastery(this.form).then(response => {
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
      this.$modal.confirm('是否确认删除学生知识点掌握情况（支撑知识图谱状态标识）编号为"' + ids + '"的数据项？').then(function() {
        return delMastery(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess("删除成功")
      }).catch(() => {})
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('system/mastery/export', {
        ...this.queryParams
      }, `mastery_${new Date().getTime()}.xlsx`)
    }
  }
}
</script>
