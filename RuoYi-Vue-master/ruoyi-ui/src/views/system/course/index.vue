<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="课程名称" prop="title">
        <el-input
          v-model="queryParams.title"
          placeholder="请输入课程名称"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="课程编码" prop="courseCode">
        <el-input
          v-model="queryParams.courseCode"
          placeholder="请输入课程编码"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="课程类型" prop="courseType">
        <el-select v-model="queryParams.courseType" placeholder="请选择课程类型" clearable>
          <el-option
            v-for="dict in dict.type.course_type"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
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
          v-hasPermi="['system:course:add']"
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
          v-hasPermi="['system:course:edit']"
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
          v-hasPermi="['system:course:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['system:course:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="courseList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="课程ID" align="center" prop="id" />
      <el-table-column label="课程名称" align="center" prop="title" />
      <el-table-column label="课程编码" align="center" prop="courseCode" />
      <el-table-column label="学分" align="center" prop="credits" />
      <el-table-column label="学时" align="center" prop="hours" />
      <el-table-column label="课程类型" align="center" prop="courseType">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.course_type" :value="scope.row.courseType"/>
        </template>
      </el-table-column>
      <el-table-column label="开课学期" align="center" prop="semester" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['system:course:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-share"
            @click="handleKnowledgeGraph(scope.row)"
            style="color: #67C23A"
          >知识图谱</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['system:course:remove']"
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

    <!-- 添加或修改课程对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="1200px" append-to-body>
      <el-tabs v-model="activeTab" v-if="title.includes('知识图谱')">
        <el-tab-pane label="课程信息" name="basic">
          <el-descriptions :column="2" border>
            <el-descriptions-item label="课程名称">{{ form.title }}</el-descriptions-item>
            <el-descriptions-item label="课程编码">{{ form.courseCode }}</el-descriptions-item>
            <el-descriptions-item label="学分">{{ form.credits }}</el-descriptions-item>
            <el-descriptions-item label="学时">{{ form.hours }}</el-descriptions-item>
            <el-descriptions-item label="课程类型">
              <dict-tag :options="dict.type.course_type" :value="form.courseType"/>
            </el-descriptions-item>
            <el-descriptions-item label="开课学期">{{ form.semester }}</el-descriptions-item>
            <el-descriptions-item label="先修课程" :span="2">{{ form.prerequisites || '无' }}</el-descriptions-item>
            <el-descriptions-item label="课程描述" :span="2">{{ form.description }}</el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>
        <el-tab-pane label="知识图谱" name="graph">
          <knowledge-graph-view :course-id="form.id" v-if="form.id"></knowledge-graph-view>
        </el-tab-pane>
      </el-tabs>
      <el-form v-else ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="课程名称" prop="title">
          <el-input v-model="form.title" placeholder="请输入课程名称" />
        </el-form-item>
        <el-form-item label="课程编码" prop="courseCode">
          <el-input v-model="form.courseCode" placeholder="请输入课程编码" />
        </el-form-item>
        <el-form-item label="学分" prop="credits">
          <el-input-number v-model="form.credits" :min="0" :max="10" />
        </el-form-item>
        <el-form-item label="学时" prop="hours">
          <el-input-number v-model="form.hours" :min="0" :max="200" />
        </el-form-item>
        <el-form-item label="课程类型" prop="courseType">
          <el-select v-model="form.courseType" placeholder="请选择课程类型">
            <el-option
              v-for="dict in dict.type.course_type"
              :key="dict.value"
              :label="dict.label"
              :value="dict.value"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="开课学期" prop="semester">
          <el-input v-model="form.semester" placeholder="请输入开课学期" />
        </el-form-item>
        <el-form-item label="先修课程" prop="prerequisites">
          <el-input v-model="form.prerequisites" placeholder="请输入先修课程" />
        </el-form-item>
        <el-form-item label="课程描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入课程描述" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer" v-if="!title.includes('知识图谱')">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
      <div slot="footer" class="dialog-footer" v-else>
        <el-button @click="cancel">关 闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listCourse, joinCourse } from "@/api/system/course";
// 确认 applyRequest 是从 request.js 中导入的
import { applyRequest } from "@/api/system/request";

export default {
  name: "Course",
  dicts: ['course_type'],
  components: {
    KnowledgeGraphView
  },
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
      // 课程表格数据
      courseList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 活动标签页
      activeTab: 'basic',
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        title: null,
        courseCode: null,
        courseType: null,
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        title: [
          { required: true, message: "课程名称不能为空", trigger: "blur" }
        ],
        courseCode: [
          { required: true, message: "课程编码不能为空", trigger: "blur" }
        ],
        credits: [
          { required: true, message: "学分不能为空", trigger: "blur" }
        ],
        hours: [
          { required: true, message: "学时不能为空", trigger: "blur" }
        ],
        courseType: [
          { required: true, message: "课程类型不能为空", trigger: "change" }
        ],
        semester: [
          { required: true, message: "开课学期不能为空", trigger: "blur" }
        ]
      }
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询课程列表 */
    getList() {
      this.loading = true;
      listCourse(this.queryParams).then(response => {
        this.courseList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        id: null,
        title: null,
        courseCode: null,
        credits: null,
        hours: null,
        courseType: null,
        semester: null,
        prerequisites: null,
        description: null
      };
      this.activeTab = 'basic';
      this.resetForm("form");
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    /** 判断课程是否已结束 */
    isCourseEnded(course) {
      if (!course.endTime) return false;
      const now = new Date();
      const endTime = new Date(course.endTime);
      return endTime < now;
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加课程";
    },

    /** 获取课程按钮图标 */
    getCourseButtonIcon(course) {
      return this.isCourseEnded(course) ? 'el-icon-check' : 'el-icon-plus';
    },

    /** 获取课程按钮文本 */
    getCourseButtonText(course) {
      return this.isCourseEnded(course) ? '直接加入' : '申请选课';
    },

    /** 智能课程操作 */
    handleCourseAction(course) {
      if (!course || !course.id) return;

      if (this.isCourseEnded(course)) {
        // 课程已结束，直接加入
        this.handleDirectJoin(course);
      } else {
        // 课程未结束，申请选课
        this.handleApply(course);
      }
    },

    /** 直接加入课程（已结束课程） */
    handleDirectJoin(course) {
      this.$modal.confirm(`课程《${course.title}》已结束，确认要直接加入我的课程吗？`).then(() => {
        this.applyLoadingId = course.id;
        return joinCourse(course.id);
      }).then(() => {
        this.$modal.msgSuccess("课程已直接加入您的课程列表");
        if(this.drawerVisible) {
          this.drawerVisible = false;
        }
      }).catch(() => {
        // 用户点击取消，不做任何事
      }).finally(() => {
        this.applyLoadingId = null;
      });
    },

    /** 申请选课（未结束课程） */
    handleApply(course) {
      if (!course || !course.id) return;
      this.$modal.confirm(`确认要申请选修《${course.title}》这门课程吗？`).then(() => {
        this.applyLoadingId = course.id;
        //【关键修改】: 第一个参数是ID，第二个是请求体
        return applyRequest(course.id, {});
      }).then(() => {
        this.$modal.msgSuccess("选课申请已提交，请等待审核");
        if(this.drawerVisible) {
          this.drawerVisible = false;
        }
      }).catch(() => {
        // 用户点击取消，不做任何事
      }).finally(() => {
        this.applyLoadingId = null;
      });
    },
    /** 显示课程详情抽屉 */
    showCourseDetail(course) {
      this.selectedCourse = course;
      this.drawerVisible = true;
    }
  }
};
</script>
