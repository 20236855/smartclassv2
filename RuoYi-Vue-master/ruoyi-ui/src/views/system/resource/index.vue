<template>
  <div class="app-container course-resource-page">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <!-- 搜索栏 -->
      <el-form-item label="所属课程ID" prop="courseId">
        <el-input v-model="queryParams.courseId" placeholder="请输入所属课程ID" clearable @keyup.enter.native="handleQuery"/>
      </el-form-item>
      <el-form-item label="资源名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入资源名称" clearable @keyup.enter.native="handleQuery"/>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <!-- 管理员操作按钮 -->
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd" v-hasPermi="['system:resource:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="el-icon-edit" size="mini" :disabled="single" @click="handleUpdate" v-hasPermi="['system:resource:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete" v-hasPermi="['system:resource:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="el-icon-download" size="mini" @click="handleExport" v-hasPermi="['system:resource:export']">导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <!-- 卡片式布局 -->
    <el-row v-loading="loading" :gutter="20" class="resource-list">
      <el-col :xs="24" :sm="12" :md="8" :lg="6" v-for="resource in resourceList" :key="resource.id" class="resource-card-col">
        <el-card shadow="hover" class="resource-card">
          <div class="card-content">
            <div class="file-icon" :style="{ color: getFileIcon(resource.fileType).color }">
              <i :class="getFileIcon(resource.fileType).icon"></i>
            </div>
            <div class="file-info">
              <div class="file-name" :title="resource.name">{{ resource.name }}</div>
              <div class="file-meta">
                <span>{{ formatFileSize(resource.fileSize) }}</span>
                <span class="divider">|</span>
                <span>{{ parseTime(resource.createTime, '{y}-{m}-{d}') }}</span>
              </div>
            </div>
          </div>
          <div class="card-actions">
            <el-button type="success" icon="el-icon-view" size="mini" @click="handlePreview(resource)" :disabled="!canPreview(resource.fileType)">预览</el-button>
            <el-button type="primary" icon="el-icon-download" size="mini" @click="handleDownload(resource)">下载 ({{ resource.downloadCount }})</el-button>
            <div class="admin-actions">
              <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(resource)" v-hasPermi="['system:resource:edit']"></el-button>
              <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(resource)" v-hasPermi="['system:resource:remove']"></el-button>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col v-if="!loading && resourceList.length === 0" style="width: 100%;">
        <el-empty description="暂无课程资源"></el-empty>
      </el-col>
    </el-row>

    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList"/>

    <!-- 资源预览对话框 -->
    <el-dialog :title="previewTitle" :visible.sync="previewOpen" :width="previewWidth" append-to-body :before-close="closePreview" class="preview-dialog">
      <div class="preview-container" v-loading="previewLoading">
        <!-- 图片预览 -->
        <div v-if="previewType === 'image'" class="image-preview">
          <el-image :src="previewUrl" fit="contain" :preview-src-list="[previewUrl]" style="max-width: 100%; max-height: 70vh;">
            <div slot="error" class="image-error">
              <i class="el-icon-picture-outline"></i>
              <span>图片加载失败</span>
            </div>
          </el-image>
        </div>
        <!-- PDF预览 -->
        <div v-else-if="previewType === 'pdf'" class="pdf-preview">
          <iframe :src="previewUrl" width="100%" height="600px" frameborder="0"></iframe>
        </div>
        <!-- Office文档预览 -->
        <div v-else-if="previewType === 'office'" class="office-preview">
          <el-alert
            title="本地环境无法预览 Office 文档"
            type="warning"
            :closable="false"
            style="margin-bottom: 15px;">
            <div slot="default">
              <p style="margin: 0 0 10px 0;">
                <i class="el-icon-info"></i>
                Office 文档预览需要公网可访问的 URL，本地开发环境（localhost）无法使用微软在线预览服务。
              </p>
              <p style="margin: 0; font-weight: bold; color: #E6A23C;">
                <i class="el-icon-download"></i>
                建议：点击下方"下载文件"按钮，下载到本地后使用 Office 软件打开查看。
              </p>
            </div>
          </el-alert>

          <!-- 下载按钮 - 放在显眼位置 -->
          <div style="text-align: center; padding: 30px 0 20px 0;">
            <el-button
              type="primary"
              size="large"
              icon="el-icon-download"
              @click="handleDownload(currentPreviewResource)">
              下载文件到本地查看
            </el-button>
            <p style="margin-top: 10px; color: #909399; font-size: 13px;">
              下载后使用 Microsoft Word、Excel 或 PowerPoint 打开
            </p>
          </div>

          <!-- 尝试显示预览（通常会失败） -->
          <el-divider>或尝试在线预览（可能失败）</el-divider>
          <div style="position: relative;">
            <iframe :src="previewUrl" width="100%" height="500px" frameborder="0" style="border: 1px solid #ddd;"></iframe>
            <!-- 如果iframe加载失败，显示遮罩 -->
            <div v-if="officePreviewFailed" class="preview-error-overlay">
              <i class="el-icon-warning-outline" style="font-size: 48px; color: #F56C6C;"></i>
              <p style="margin-top: 15px; font-size: 16px;">在线预览失败</p>
              <p style="color: #909399;">请使用上方的"下载文件"按钮</p>
            </div>
          </div>
        </div>
        <!-- 视频预览 -->
        <div v-else-if="previewType === 'video'" class="video-preview">
          <video :src="previewUrl" controls style="max-width: 100%; max-height: 70vh;">
            您的浏览器不支持视频播放
          </video>
        </div>
        <!-- 音频预览 -->
        <div v-else-if="previewType === 'audio'" class="audio-preview">
          <audio :src="previewUrl" controls style="width: 100%;">
            您的浏览器不支持音频播放
          </audio>
        </div>
        <!-- 文本预览 -->
        <div v-else-if="previewType === 'text'" class="text-preview">
          <div v-if="textContent" class="text-content">
            <pre>{{ textContent }}</pre>
          </div>
          <div v-else class="text-loading">
            <i class="el-icon-loading"></i>
            <span>正在加载文本内容...</span>
          </div>
        </div>
        <!-- 不支持预览 -->
        <div v-else class="unsupported-preview">
          <i class="el-icon-document" style="font-size: 64px; color: #909399;"></i>
          <p>该文件类型暂不支持在线预览</p>
          <el-button type="primary" @click="handleDownload(currentPreviewResource)">下载查看</el-button>
        </div>
      </div>
    </el-dialog>

    <!-- 添加或修改课程资源对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="所属课程ID" prop="courseId">
          <el-input v-model="form.courseId" placeholder="请输入所属课程ID" />
        </el-form-item>
        <el-form-item label="资源名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入资源名称" />
        </el-form-item>
        <el-form-item label="文件类型" prop="fileType">
          <el-select v-model="form.fileType" placeholder="请选择文件类型">
            <el-option v-for="dict in dict.type.file_type" :key="dict.value" :label="dict.label" :value="dict.value"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="上传文件" prop="fileUrl">
          <file-upload v-model="form.fileUrl" :limit="1" @upload-success="handleFileUploadSuccess" ref="fileUpload"/>
        </el-form-item>
        <el-form-item label="资源描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入内容" />
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
import { listResource, getResource, delResource, addResource, updateResource, getPreviewInfo } from "@/api/system/resource";
import { recordResourceDownload } from "@/api/system/lbehavior";
import axios from 'axios';
import { getToken } from '@/utils/auth';

export default {
  name: "Resource",
  dicts: ['file_type'],
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      resourceList: [],
      title: "",
      open: false,
      queryParams: { pageNum: 1, pageSize: 10, courseId: null, name: null },
      form: {},
      rules: {
        courseId: [{ required: true, message: "所属课程ID不能为空", trigger: "blur" }],
        name: [{ required: true, message: "资源名称不能为空", trigger: "blur" }],
        fileType: [{ required: true, message: "文件类型不能为空", trigger: "change" }],
        fileUrl: [{ required: true, message: "文件URL不能为空", trigger: "blur" }]
      },
      // 预览相关
      previewOpen: false,
      previewLoading: false,
      previewTitle: "资源预览",
      previewType: "",
      previewUrl: "",
      previewWidth: "80%",
      currentPreviewResource: null,
      textContent: "",
      officePreviewNote: "",
      officePreviewFailed: false
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询课程资源列表 */
    getList() {
      this.loading = true;
      listResource(this.queryParams).then(response => {
        this.resourceList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    /** 处理下载事件 */
    handleDownload(resource) {
      // 在前端乐观更新下载次数，提供即时反馈
      const res = this.resourceList.find(r => r.id === resource.id);
      if (res) {
        res.downloadCount++;
      }

      // 记录资源下载行为
      this.recordDownloadBehavior(resource);

      // 调用自定义下载方法
      this.downloadResource(resource);
    },

    /** 记录资源下载行为 */
    async recordDownloadBehavior(resource) {
      try {
        if (!resource.courseId || !resource.id) {
          console.log('⚠️ 缺少courseId或resourceId，跳过记录下载行为');
          return;
        }
        await recordResourceDownload(resource.courseId, resource.id);
        console.log('📝 资源下载行为已记录:', { courseId: resource.courseId, resourceId: resource.id });
      } catch (error) {
        console.error('❌ 记录资源下载行为失败:', error);
      }
    },

    // 下载资源文件
    downloadResource(resource) {
      const loading = this.$loading({
        lock: true,
        text: '正在下载文件，请稍候...',
        spinner: 'el-icon-loading',
        background: 'rgba(0, 0, 0, 0.7)'
      });

      // 调用后端下载接口
      const url = process.env.VUE_APP_BASE_API + '/system/resource/download/' + resource.id;

      axios({
        method: 'get',
        url: url,
        responseType: 'blob',
        headers: {
          'Authorization': 'Bearer ' + getToken()
        }
      }).then((response) => {
        // 从响应头获取文件名
        let fileName = resource.name;
        const contentDisposition = response.headers['content-disposition'];
        if (contentDisposition) {
          const fileNameMatch = contentDisposition.match(/filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/);
          if (fileNameMatch && fileNameMatch[1]) {
            fileName = decodeURIComponent(fileNameMatch[1].replace(/['"]/g, ''));
          }
        }

        // 创建blob对象
        const blob = new Blob([response.data]);

        // 创建下载链接
        const downloadUrl = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = downloadUrl;
        link.download = fileName;
        document.body.appendChild(link);
        link.click();

        // 清理
        document.body.removeChild(link);
        window.URL.revokeObjectURL(downloadUrl);

        loading.close();
        this.$message.success('下载成功');
      }).catch((error) => {
        console.error('下载失败:', error);
        loading.close();
        this.$message.error('下载失败，请稍后重试');

        // 回滚下载次数
        const res = this.resourceList.find(r => r.id === resource.id);
        if (res && res.downloadCount > 0) {
          res.downloadCount = res.downloadCount - 1;
        }
      });
    },
    // 文件上传成功后，自动提取文件名、大小和类型
    handleFileUploadSuccess(fileList) {
      if (fileList && fileList.length > 0) {
        const uploadedFile = fileList[fileList.length - 1]; // 获取最后上传的文件

        // 设置文件URL
        this.form.fileUrl = uploadedFile.url;

        // 设置文件大小
        if (uploadedFile.size) {
          this.form.fileSize = uploadedFile.size;
        }

        // 从文件名提取信息
        if (uploadedFile.raw && uploadedFile.raw.name) {
          const fileName = uploadedFile.raw.name;

          // 如果资源名称为空，自动填充（去掉扩展名）
          if (!this.form.name) {
            const dotIndex = fileName.lastIndexOf('.');
            this.form.name = dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
          }

          // 提取文件扩展名
          const dotIndex = fileName.lastIndexOf('.');
          if (dotIndex > 0) {
            const fileExtension = fileName.substring(dotIndex + 1).toLowerCase();

            console.log('文件扩展名:', fileExtension);
            console.log('字典数据:', this.dict.type.file_type);

            // 直接使用扩展名作为文件类型
            this.form.fileType = fileExtension;

            console.log('设置的文件类型:', this.form.fileType);
          }
        }
      }
    },
    // ... 其他方法保持不变，此处为精简省略 ...
    cancel() { this.open = false; this.reset(); },
    reset() {
      this.form = {
        id: null, courseId: null, name: null, fileType: null,
        fileSize: null, fileUrl: null, description: null, downloadCount: 0
      };
      this.resetForm("form");
    },
    handleQuery() { this.queryParams.pageNum = 1; this.getList(); },
    resetQuery() { this.resetForm("queryForm"); this.handleQuery(); },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id);
      this.single = selection.length!==1;
      this.multiple = !selection.length;
    },
    handleAdd() { this.reset(); this.open = true; this.title = "添加课程资源"; },
    handleUpdate(row) {
      this.reset();
      const id = row.id || this.ids[0];
      getResource(id).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改课程资源";
      });
    },
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateResource(this.form).then(() => {
              this.$modal.msgSuccess("修改成功"); this.open = false; this.getList();
            });
          } else {
            addResource(this.form).then(() => {
              this.$modal.msgSuccess("新增成功"); this.open = false; this.getList();
            });
          }
        }
      });
    },
    handleDelete(row) {
      const ids = row.id ? [row.id] : this.ids;
      this.$modal.confirm('是否确认删除课程资源编号为"' + ids.join(',') + '"的数据项？').then(() => {
        return delResource(ids);
      }).then(() => {
        this.getList(); this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    handleExport() { this.download('system/resource/export', { ...this.queryParams }, `resource_${new Date().getTime()}.xlsx`); },
    formatFileSize(bytes) {
      if (!bytes && bytes !== 0) return '';
      if (bytes === 0) return '0 Bytes';
      const k = 1024;
      const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    },
    getFileIcon(fileType) {
      const type = fileType ? fileType.toLowerCase() : '';
      if (['pdf'].includes(type)) return { icon: 'el-icon-document', color: '#e53935' };
      if (['doc', 'docx'].includes(type)) return { icon: 'el-icon-document', color: '#1E88E5' };
      if (['ppt', 'pptx'].includes(type)) return { icon: 'el-icon-monitor', color: '#d84a1b' };
      if (['xls', 'xlsx'].includes(type)) return { icon: 'el-icon-document', color: '#43A047' };
      if (['zip', 'rar', '7z'].includes(type)) return { icon: 'el-icon-folder', color: '#FDD835' };
      if (['jpg', 'jpeg', 'png', 'gif'].includes(type)) return { icon: 'el-icon-picture-outline', color: '#7E57C2' };
      if (['mp4', 'avi', 'mov'].includes(type)) return { icon: 'el-icon-video-camera', color: '#00ACC1' };
      return { icon: 'el-icon-document', color: '#546E7A' };
    },
    /** 判断是否可以预览 */
    canPreview(fileType) {
      const type = fileType ? fileType.toLowerCase() : '';
      const previewableTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'mp4', 'webm', 'mp3', 'wav', 'txt', 'md', 'json'];
      return previewableTypes.includes(type);
    },
    /** 处理预览事件 */
    handlePreview(resource) {
      this.currentPreviewResource = resource;
      this.previewLoading = true;
      this.previewOpen = true;
      this.previewTitle = "预览: " + resource.name;
      this.textContent = "";
      this.officePreviewNote = "";

      getPreviewInfo(resource.id).then(response => {
        this.previewType = response.previewType;
        this.previewUrl = response.previewUrl;
        this.officePreviewNote = response.officePreviewNote || "";

        // 根据预览类型调整对话框宽度
        if (this.previewType === 'image') {
          this.previewWidth = '60%';
        } else if (this.previewType === 'audio') {
          this.previewWidth = '50%';
        } else if (this.previewType === 'text') {
          this.previewWidth = '70%';
          // 加载文本内容
          this.loadTextContent(response.previewUrl);
        } else {
          this.previewWidth = '90%';
        }

        this.previewLoading = false;
      }).catch(error => {
        console.error('获取预览信息失败:', error);
        this.$message.error('获取预览信息失败: ' + (error.message || '未知错误'));
        this.previewLoading = false;
        this.previewType = 'unsupported';
      });
    },
    /** 加载文本内容 */
    loadTextContent(url) {
      fetch(url)
        .then(response => {
          if (!response.ok) {
            throw new Error('文件加载失败');
          }
          return response.text();
        })
        .then(text => {
          this.textContent = text;
        })
        .catch(error => {
          console.error('加载文本内容失败:', error);
          this.textContent = '文本内容加载失败，请下载查看';
        });
    },
    /** 关闭预览 */
    closePreview() {
      this.previewOpen = false;
      this.previewUrl = "";
      this.previewType = "";
      this.currentPreviewResource = null;
      this.textContent = "";
      this.officePreviewNote = "";
    }
  }
};
</script>

<style lang="scss" scoped>
/* 样式与上个版本基本一致，无需修改 */
.course-resource-page {
  .resource-card-col { margin-bottom: 20px; }
  .resource-card {
    display: flex; flex-direction: column; height: 100%;
    ::v-deep .el-card__body { display: flex; flex-direction: column; flex-grow: 1; padding: 15px; }
  }
  .card-content { display: flex; align-items: center; flex-grow: 1; min-height: 60px; }
  .file-icon { font-size: 48px; margin-right: 15px; flex-shrink: 0; }
  .file-info { display: flex; flex-direction: column; justify-content: center; overflow: hidden; width: 100%; }
  .file-name { font-size: 16px; font-weight: 600; color: #303133; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .file-meta { font-size: 12px; color: #909399; margin-top: 5px; .divider { margin: 0 8px; } }
  .card-actions { margin-top: 15px; padding-top: 10px; border-top: 1px solid #EBEEF5; display: flex; justify-content: space-between; align-items: center; }
  .admin-actions .el-button { margin-left: 5px; padding: 7px; }
}

/* 预览对话框样式 */
.preview-dialog {
  ::v-deep .el-dialog__body {
    padding: 10px 20px;
  }
}

.preview-container {
  min-height: 200px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.image-preview, .pdf-preview, .office-preview, .video-preview, .audio-preview, .text-preview {
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.text-preview {
  .text-content {
    width: 100%;
    max-height: 600px;
    overflow: auto;
    background-color: #f5f7fa;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
    padding: 15px;

    pre {
      margin: 0;
      white-space: pre-wrap;
      word-wrap: break-word;
      font-family: 'Courier New', Courier, monospace;
      font-size: 14px;
      line-height: 1.6;
      color: #303133;
    }
  }

  .text-loading {
    text-align: center;
    padding: 40px;
    color: #909399;

    i {
      font-size: 32px;
      margin-bottom: 10px;
    }
  }
}

.unsupported-preview {
  text-align: center;
  padding: 40px;
  color: #909399;

  p {
    margin: 20px 0;
    font-size: 16px;
  }
}

.image-error {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #909399;
  font-size: 14px;

  i {
    font-size: 48px;
    margin-bottom: 10px;
  }
}

.preview-error-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(255, 255, 255, 0.95);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 10;
}
</style>
