<template>
  <div class="upload-video">
    <el-upload
      :action="uploadVideoUrl"
      :before-upload="handleBeforeUpload"
      :on-progress="handleProgress"
      :on-error="handleUploadError"
      :on-success="handleUploadSuccess"
      :show-file-list="false"
      :headers="headers"
      :data="data"
      :disabled="uploading"
      class="video-uploader"
      ref="videoUpload"
      v-if="!disabled"
    >
      <!-- 上传按钮 -->
      <el-button size="small" type="primary" :loading="uploading" :disabled="uploading">
        <i class="el-icon-upload" v-if="!uploading"></i>
        {{ uploading ? '上传中...' : '选择视频文件' }}
      </el-button>
      
      <!-- 上传提示 -->
      <div class="el-upload__tip" slot="tip" v-if="showTip">
        请上传
        <template v-if="fileSize"> 大小不超过 <b style="color: #f56c6c">{{ fileSize }}MB</b> </template>
        <template v-if="fileType"> 格式为 <b style="color: #f56c6c">{{ fileType.join("/") }}</b> </template>
        的视频文件
      </div>
    </el-upload>

    <!-- 上传进度条 -->
    <el-progress
      v-if="uploading"
      :percentage="uploadProgress"
      :status="uploadProgress === 100 ? 'success' : null"
      style="margin-top: 10px;"
    ></el-progress>

    <!-- 视频预览 -->
    <div class="video-preview" v-if="videoUrl && !uploading">
      <video 
        :src="`${baseUrl}${videoUrl}`" 
        controls 
        style="max-width: 100%; max-height: 300px;"
      ></video>
      <div class="video-info">
        <span class="video-name">{{ videoName }}</span>
        <el-button 
          type="text" 
          icon="el-icon-delete" 
          @click="handleDelete"
          v-if="!disabled"
          style="color: #f56c6c; margin-left: 10px;"
        >删除</el-button>
      </div>
    </div>
  </div>
</template>

<script>
import { getToken } from "@/utils/auth"

export default {
  name: "VideoUpload",
  props: {
    // 值
    value: [String],
    // 上传接口地址
    action: {
      type: String,
      default: "/common/upload"
    },
    // 上传携带的参数
    data: {
      type: Object
    },
    // 大小限制(MB)
    fileSize: {
      type: Number,
      default: 500  // 默认500MB
    },
    // 文件类型
    fileType: {
      type: Array,
      default: () => ["mp4", "avi", "mov", "wmv", "flv", "mkv"]
    },
    // 是否显示提示
    isShowTip: {
      type: Boolean,
      default: true
    },
    // 禁用组件
    disabled: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      baseUrl: process.env.VUE_APP_BASE_API,
      uploadVideoUrl: process.env.VUE_APP_BASE_API + this.action,
      headers: {
        Authorization: "Bearer " + getToken(),
      },
      videoUrl: "",
      videoName: "",
      uploading: false,
      uploadProgress: 0
    }
  },
  watch: {
    value: {
      handler(val) {
        if (val) {
          this.videoUrl = val
          this.videoName = this.getFileName(val)
        } else {
          this.videoUrl = ""
          this.videoName = ""
        }
      },
      immediate: true
    }
  },
  computed: {
    showTip() {
      return this.isShowTip && (this.fileType || this.fileSize)
    }
  },
  methods: {
    // 上传前校验
    handleBeforeUpload(file) {
      // 校验文件类型
      if (this.fileType && this.fileType.length > 0) {
        const fileName = file.name.split('.')
        const fileExt = fileName[fileName.length - 1].toLowerCase()
        const isTypeOk = this.fileType.indexOf(fileExt) >= 0
        if (!isTypeOk) {
          this.$modal.msgError(`文件格式不正确，请上传${this.fileType.join("/")}格式的视频文件!`)
          return false
        }
      }
      
      // 校验文件大小
      if (this.fileSize) {
        const isLt = file.size / 1024 / 1024 < this.fileSize
        if (!isLt) {
          this.$modal.msgError(`上传视频大小不能超过 ${this.fileSize} MB!`)
          return false
        }
      }
      
      this.uploading = true
      this.uploadProgress = 0
      return true
    },

    // 上传进度
    handleProgress(event, file, fileList) {
      // 确保进度值在 0-100 之间，并且是整数
      this.uploadProgress = Math.min(Math.floor(event.percent || 0), 99)
    },

    // 上传成功
    handleUploadSuccess(res, file) {
      this.uploadProgress = 100
      if (res.code === 200) {
        this.videoUrl = res.fileName
        this.videoName = res.originalFilename || file.name
        this.$emit("input", res.fileName)
        this.$emit("upload-success", {
          url: res.fileName,
          name: this.videoName,
          size: file.size
        })
        this.$modal.msgSuccess("视频上传成功")
        // 延迟关闭上传状态，让用户看到100%的进度
        setTimeout(() => {
          this.uploading = false
          this.uploadProgress = 0
        }, 500)
      } else {
        this.$modal.msgError(res.msg || "视频上传失败")
        this.uploading = false
        this.uploadProgress = 0
      }
    },

    // 上传失败
    handleUploadError(err) {
      this.$modal.msgError("视频上传失败，请重试")
      this.uploading = false
      this.uploadProgress = 0
    },

    // 删除视频
    handleDelete() {
      this.videoUrl = ""
      this.videoName = ""
      this.$emit("input", "")
    },

    // 获取文件名
    getFileName(url) {
      if (url.lastIndexOf("/") > -1) {
        return url.slice(url.lastIndexOf("/") + 1)
      } else {
        return url
      }
    }
  }
}
</script>

<style scoped lang="scss">
.upload-video {
  .video-uploader {
    margin-bottom: 10px;
  }

  .video-preview {
    margin-top: 10px;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
    padding: 10px;

    video {
      display: block;
      margin: 0 auto 10px;
      border-radius: 4px;
    }

    .video-info {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 5px 0;

      .video-name {
        color: #606266;
        font-size: 14px;
        flex: 1;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
    }
  }
}
</style>

