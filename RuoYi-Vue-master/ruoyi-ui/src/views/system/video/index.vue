<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="课程ID" prop="courseId">
        <el-input
          v-model="queryParams.courseId"
          placeholder="请输入课程ID"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="视频标题" prop="title">
        <el-input
          v-model="queryParams.title"
          placeholder="请输入视频标题"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="文件大小" prop="fileSize">
        <el-input
          v-model="queryParams.fileSize"
          placeholder="请输入文件大小"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="分辨率" prop="resolution">
        <el-input
          v-model="queryParams.resolution"
          placeholder="请输入分辨率"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="观看次数" prop="viewCount">
        <el-input
          v-model="queryParams.viewCount"
          placeholder="请输入观看次数"
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
          v-hasPermi="['system:video:add']"
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
          v-hasPermi="['system:video:edit']"
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
          v-hasPermi="['system:video:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['system:video:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="videoList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="视频ID" align="center" prop="id" />
      <el-table-column label="课程ID" align="center" prop="courseId" />
      <el-table-column label="视频标题" align="center" prop="title" />
      <el-table-column label="视频描述" align="center" prop="description" />
      <el-table-column label="视频文件路径" align="center" prop="filePath" />
      <el-table-column label="文件大小" align="center" prop="fileSize">
        <template slot-scope="scope">
          {{ formatFileSize(scope.row.fileSize) }}
        </template>
      </el-table-column>
      <el-table-column label="时长" align="center" prop="duration" />
      <el-table-column label="封面图片路径" align="center" prop="coverImage" width="100">
        <template slot-scope="scope">
          <image-preview :src="scope.row.coverImage" :width="50" :height="50"/>
        </template>
      </el-table-column>
      <el-table-column label="分辨率" align="center" prop="resolution" />
      <el-table-column label="关联的知识点ID列表" align="center" prop="knowledgePointIds" />
      <el-table-column label="观看次数" align="center" prop="viewCount" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['system:video:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['system:video:remove']"
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

    <!-- 添加或修改视频对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="课程ID" prop="courseId">
          <el-input v-model="form.courseId" placeholder="请输入课程ID" />
        </el-form-item>
        <el-form-item label="视频标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入视频标题" />
        </el-form-item>
        <el-form-item label="视频描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入内容" />
        </el-form-item>
        <el-form-item label="视频文件" prop="filePath">
          <video-upload
            v-model="form.filePath"
            :file-size="1000"
            :file-type="['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv']"
            @upload-success="handleVideoUploadSuccess"
          />
        </el-form-item>
        <el-form-item label="文件大小" prop="fileSize">
          <el-input v-model="fileSizeDisplay" placeholder="自动获取" disabled />
        </el-form-item>
        <el-form-item label="时长(秒)" prop="duration">
          <el-input v-model="form.duration" placeholder="请输入时长(秒)" />
        </el-form-item>
        <el-form-item label="封面图片路径" prop="coverImage">
          <image-upload v-model="form.coverImage"/>
        </el-form-item>
        <el-form-item label="分辨率" prop="resolution">
          <el-input v-model="form.resolution" placeholder="请输入分辨率" />
        </el-form-item>
        <el-form-item label="观看次数" prop="viewCount">
          <el-input v-model="form.viewCount" placeholder="请输入观看次数" />
        </el-form-item>
        <el-form-item label="上传者ID" prop="uploadedBy">
          <el-input v-model="form.uploadedBy" placeholder="请输入上传者ID" />
        </el-form-item>
        <el-form-item label="" prop="createdAt">
          <el-date-picker clearable
            v-model="form.createdAt"
            type="date"
            value-format="yyyy-MM-dd"
            placeholder="请选择">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="" prop="updatedAt">
          <el-date-picker clearable
            v-model="form.updatedAt"
            type="date"
            value-format="yyyy-MM-dd"
            placeholder="请选择">
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
import { listVideo, getVideo, delVideo, addVideo, updateVideo } from "@/api/system/video"

export default {
  name: "Video",
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
      // 视频表格数据
      videoList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        courseId: null,
        title: null,
        description: null,
        filePath: null,
        fileSize: null,
        coverImage: null,
        resolution: null,
        knowledgePointIds: null,
        viewCount: null,
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        courseId: [
          { required: true, message: "课程ID不能为空", trigger: "blur" }
        ],
        title: [
          { required: true, message: "视频标题不能为空", trigger: "blur" }
        ],
        filePath: [
          { required: true, message: "视频文件路径不能为空", trigger: "blur" }
        ],
        coverImage: [
          { required: true, message: "封面图片路径不能为空", trigger: "blur" }
        ],
      }
    }
  },
  computed: {
    // 文件大小显示（用于界面显示）
    fileSizeDisplay() {
      if (this.form.fileSize) {
        const sizeInMB = (this.form.fileSize / 1024 / 1024).toFixed(2)
        return sizeInMB + ' MB'
      }
      return ''
    }
  },
  created() {
    this.getList()
  },
  methods: {
    /** 查询视频列表 */
    getList() {
      this.loading = true
      listVideo(this.queryParams).then(response => {
        this.videoList = response.rows
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
        courseId: null,
        title: null,
        description: null,
        filePath: null,
        fileSize: null,
        duration: null,
        coverImage: null,
        resolution: null,
        knowledgePointIds: null,
        status: null,
        viewCount: null,
        uploadedBy: null,
        createdAt: null,
        updatedAt: null
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
      this.title = "添加视频"
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getVideo(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = "修改视频"
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateVideo(this.form).then(response => {
              this.$modal.msgSuccess("修改成功")
              this.open = false
              this.getList()
            })
          } else {
            addVideo(this.form).then(response => {
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
      this.$modal.confirm('是否确认删除视频编号为"' + ids + '"的数据项？').then(function() {
        return delVideo(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess("删除成功")
      }).catch(() => {})
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('system/video/export', {
        ...this.queryParams
      }, `video_${new Date().getTime()}.xlsx`)
    },
    /** 视频上传成功回调 */
    handleVideoUploadSuccess(fileInfo) {
      // 自动填充文件大小（保存为字节数，Long类型）
      if (fileInfo.size) {
        this.form.fileSize = fileInfo.size
      }
    },
    /** 格式化文件大小显示 */
    formatFileSize(bytes) {
      if (!bytes || bytes === 0) return '0 B'
      const k = 1024
      const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return (bytes / Math.pow(k, i)).toFixed(2) + ' ' + sizes[i]
    }
  }
}
</script>
