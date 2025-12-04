<template>
  <div class="homework-wrapper">
    <el-dialog :visible="visible" @close="onClose" :title="editData ? '修改作业' : '添加作业'" append-to-body :width="dialogWidth" :close-on-click-modal="false" custom-class="homework-dialog">
      <el-form ref="elForm" :model="formData" :rules="rules" size="medium" label-width="120px" class="homework-form">
        <el-form-item label="作业标题" prop="field103">
          <el-input v-model="formData.field103" placeholder="请输入作业标题" clearable :style="{width: '100%'}">
          </el-input>
        </el-form-item>
        <el-form-item label="作业描述" prop="field104">
          <el-input v-model="formData.field104" placeholder="请输入作业描述" clearable :style="{width: '100%'}">
          </el-input>
        </el-form-item>
        <el-form-item v-if="!hideCourseSelect" label="课程选择" prop="field105">
          <el-select ref="courseSelect" v-model="formData.field105" placeholder="请选择课程选择" :style="{width: '100%'}" @click="handleCourseSelectClick">
            <el-option v-for="(item, index) in field105Options" :key="index" :label="item.label"
              :value="item.value" :disabled="item.disabled"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="作业类型" prop="field106">
          <el-radio-group v-model="formData.field106" size="medium">
            <el-radio v-for="(item, index) in field106Options" :key="index" :label="item.value"
              :disabled="item.disabled">{{item.label}}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="日期范围" prop="field107">
          <el-date-picker type="datetimerange" v-model="formData.field107" format="yyyy-MM-dd HH:mm:ss" 
            value-format="yyyy-MM-dd HH:mm:ss" :style="{width: '100%'}" start-placeholder="开始日期时间" end-placeholder="结束日期时间"
            range-separator="至" clearable></el-date-picker>
        </el-form-item>
        <el-form-item label="总分" prop="field109">
          <el-input-number v-model="formData.field109" placeholder="总分"></el-input-number>
        </el-form-item>
        <el-form-item v-if="!hideKnowledgePoints" label="关联知识点" prop="knowledgePoints">
          <knowledge-point-selector
            v-model="selectedKpIds"
            :available-kps="availableKps"
            :assignment-data="getCurrentAssignmentData()"
            @change="handleKpChange"
          />
        </el-form-item>
        <el-divider content-position="left">作业附件</el-divider>
        <div class="attachments-container">
          <el-empty v-if="!hasAttachments" description="暂无附件"></el-empty>
          <div v-else class="attachments-list">
            <el-row :gutter="10">
              <el-col :span="24" v-for="(file, idx) in assignmentAttachments" :key="idx" class="attachment-item">
                <el-card shadow="never" class="attachment-card">
                  <div class="attachment-content">
                    <a class="attachment-link" :href="buildAttachmentUrl(file.url)" target="_blank" rel="noopener" @click="downloadAttachment(file)">{{ file.name }}</a>
                    <el-button type="text" icon="el-icon-download" @click="downloadAttachment(file)">下载</el-button>
                  </div>
                </el-card>
              </el-col>
            </el-row>
          </div>
        </div>
        <el-form-item label="上传" prop="field108">
          <el-upload ref="field108" :file-list="field108fileList" :action="field108Action" :data="field108ExtraData"
            :before-upload="field108BeforeUpload" :on-success="field108OnSuccess" :on-error="field108OnError" 
            :on-remove="field108OnRemove" :on-preview="field108OnPreview" :headers="headers">
            <el-button size="small" type="primary" icon="el-icon-upload">点击上传</el-button>
          </el-upload>
        </el-form-item>
        <el-form-item v-if="formData.field106 === 1" label="开始组卷" prop="field110">
          <el-button type="primary" icon="el-icon-search" size="medium"> 主要按钮 </el-button>
        </el-form-item>
      </el-form>
      <div slot="footer">
        <el-button @click="close">取消</el-button>
        <el-button type="primary" @click="submitForm">提交</el-button>
      </div>
    </el-dialog>
  </div>
</template>
<script>
import { listCourse } from "@/api/course/course"
import { listKnowledgePointByCourse } from "@/api/course/knowledgePoint"
import { listAssignmentKp, setAssignmentKnowledgePoints } from "@/api/system/assignmentKp"
import { mapState } from "vuex"
import { getToken } from "@/utils/auth"
import KnowledgePointSelector from '@/components/KnowledgePointSelector/index.vue'

export default {
  inheritAttrs: false,
  components: {
    KnowledgePointSelector
  },
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    editData: {
      type: Object,
      default: null
    },
    hideCourseSelect: {
      type: Boolean,
      default: false
    },
    courseId: {
      type: [Number, String],
      default: null
    },
    hideKnowledgePoints: {
      type: Boolean,
      default: false
    },
    dialogWidth: {
      type: String,
      default: '50%'
    }
  },
  data() {
    return {
      formData: {
        field103: undefined,
        field104: undefined,
        field105: undefined,
        field106: undefined,
        field107: null,
        field109: undefined,
        field108: null,
        field110: undefined,
      },
      rules: {
        field103: [{
          required: true,
          message: '请输入作业标题',
          trigger: 'blur'
        }],
        field104: [],
        field105: [{
          required: true,
          message: '请选择课程选择',
          trigger: 'change'
        }],
        field106: [{
          required: true,
          message: '作业类型不能为空',
          trigger: 'change'
        }],
        field107: [{
          required: true,
          message: '日期范围不能为空',
          trigger: 'change'
        }],
        field109: [{
          required: true,
          message: '总分',
          trigger: 'blur'
        }],
      },
      field108Action: '',
      field108ExtraData: {},
      field108fileList: [],
      uploadedFiles: [], // 存储上传成功的文件信息
      field105Options: [], // 课程选项将动态加载
      // 上传文件的请求头，包含认证信息
      headers: {
        Authorization: "Bearer " + getToken()
      },
      // 知识点相关数据
      availableKps: [], // 可选知识点列表
      selectedKpIds: [], // 已选择的知识点ID数组
      field106Options: [{
        "label": "答题型作业",
        "value": 1
      }, {
        "label": "上传型作业",
        "value": 2
      }],
      assignmentAttachments: [],
      smartCourseApiBase: (process.env.VUE_APP_SMARTCOURSE_API || 'http://localhost:8083')
    }
  },
  computed: {
    ...mapState({
      userId: state => state.user.id
    }),
    hasAttachments() {
      return (this.assignmentAttachments && this.assignmentAttachments.length > 0) || (this.uploadedFiles && this.uploadedFiles.length > 0)
    }
  },
  watch: {
    visible: {
      handler(newVal) {
        if (newVal) {
          this.field108Action = this.getApiBase() + '/files/upload-to-courses'
          this.field108ExtraData = { courseId: this.formData.field105, uploaderUserId: this.getSmartUserId() }
          // 加载课程列表（无论是否编辑模式都需要）
          this.loadCourses()
          
          // 如果隐藏课程选择且传入了courseId，自动设置
          if (this.hideCourseSelect && this.courseId) {
            this.formData.field105 = this.courseId
          }
          
          if (this.editData) {
            this.loadEditData();
            if (this.editData.id) {
              this.fetchAssignmentAttachments(this.editData.id)
            }
          } else {
            // 清空已上传的文件列表
            this.field108fileList = []
            this.uploadedFiles = []
            // 清空知识点选择
            this.availableKps = []
            this.selectedKpIds = []
            this.resetForm();
            this.assignmentAttachments = []
          }
        }
      },
      immediate: true
    },
    // 监听 editData 变化
    editData: {
      handler(newVal) {
        if (newVal && this.visible) {
          console.log('editData变化，重新加载数据:', newVal);
          this.loadEditData();
          if (newVal.id) {
            this.fetchAssignmentAttachments(newVal.id)
          }
        }
      },
      deep: true
    },
    // 监听课程选择变化，加载对应的知识点列表
    'formData.field105': {
      handler(newCourseId) {
        if (newCourseId) {
          this.field108ExtraData = { courseId: newCourseId, uploaderUserId: this.getSmartUserId() }
          this.loadKnowledgePoints(newCourseId)
        } else {
          this.availableKps = []
          this.selectedKpIds = []
        }
      }
    }
  },
  created() {},
  mounted() {},
  methods: {
    getSmartUserId() {
      const envId = Number(process.env.VUE_APP_SMARTCOURSE_USER_ID)
      return envId && !isNaN(envId) ? envId : this.userId
    },
    onOpen() {
      // 清空已上传的文件列表
      this.field108fileList = []
      this.uploadedFiles = []
    },
    handleCourseSelectClick() {
      // 点击选择框时强制显示下拉选项
      this.$nextTick(() => {
        this.$refs.courseSelect && this.$refs.courseSelect.showPicker()
      })
    },
    onClose() {
      // 关闭对话框时立即清空文件列表，避免再次打开时出现文件消失动画
      this.field108fileList = []
      this.uploadedFiles = []
      this.$refs['elForm'].resetFields()
      this.editData = null
      this.$emit('close')
      this.assignmentAttachments = []
    },
    close() {
      this.$emit('close')
    },
    submitForm() {
      this.$refs['elForm'].validate(valid => {
        if (!valid) {
          console.log('表单验证失败')
          return
        }
        
        console.log('表单验证通过，开始构建作业数据')
        console.log('当前表单数据:', this.formData)
        
        // 准备提交数据
        const homeworkData = {
          type: 'homework',  // 作业类型
          title: this.formData.field103,  // 作业标题
          courseId: this.formData.field105,  // 课程ID
          description: this.formData.field104,  // 作业描述
          totalScore: this.formData.field109,  // 总分
          status: 0,  // 0未发布
          isDeleted: 0,  // 0未删除
          mode: this.formData.field106 === 1 ? 'question' : 'file',  // 1=答题型，2=上传型
          attachments: JSON.stringify(this.uploadedFiles)  // 上传的文件信息，转换为JSON字符串
        }
        
        // 处理日期范围，确保格式为YYYY-MM-DD HH:mm:ss
        if (this.formData.field107 && this.formData.field107.length === 2) {
          console.log('日期范围数据:', this.formData.field107)
          // 直接使用日期时间字符串，确保格式为YYYY-MM-DD HH:mm:ss
          homeworkData.startTime = this.formData.field107[0]
          homeworkData.endTime = this.formData.field107[1]
          console.log('处理后的时间数据:', { startTime: homeworkData.startTime, endTime: homeworkData.endTime })
        } else {
          console.log('日期范围数据不完整:', this.formData.field107)
        }
        
        // 如果是编辑模式，添加id字段
        if (this.editData && this.editData.id) {
          homeworkData.id = this.editData.id;
        }
        
        console.log('最终提交的作业数据:', JSON.stringify(homeworkData, null, 2))
        
        // 检查必要字段是否存在
        const requiredFields = ['type', 'title', 'courseId', 'totalScore', 'status', 'isDeleted', 'mode', 'startTime', 'endTime']
        const missingFields = requiredFields.filter(field => homeworkData[field] === undefined || homeworkData[field] === null)
        if (missingFields.length > 0) {
          console.error('缺少必要字段:', missingFields)
          this.$message.error('数据不完整，请检查所有必填项')
          return
        }
        
        // 调用API提交数据
        console.log('开始提交数据...')
        this.$emit('submit', homeworkData, this.selectedKpIds)
        this.close()
      })
    },
    resetForm() {
      this.$refs['elForm'].resetFields()
    },
    // 加载编辑数据到表单
    loadEditData() {
      console.log('homework.vue - editData:', JSON.stringify(this.editData, null, 2))
      if (!this.editData) return
      
      // 填充基本信息
      this.formData.field103 = this.editData.title || this.editData.field103 || '' // 作业标题
      this.formData.field104 = this.editData.description || this.editData.field104 || '' // 作业描述
      this.formData.field105 = this.editData.courseId || this.editData.course_id || this.editData.field105 || '' // 课程ID
      this.formData.field109 = this.editData.totalScore || this.editData.total_score || this.editData.field109 || '' // 总分
      
      // 转换作业模式：将字符串转换为对应的数字值
      const mode = this.editData.mode || ''
      this.formData.field106 = mode === 'question' ? 1 : (mode === 'file' ? 2 : '') // 作业模式
      
      // 处理日期范围
      if (this.editData.startTime && this.editData.endTime) {
        this.formData.field107 = [this.editData.startTime, this.editData.endTime]
      }
      
      // 处理附件信息
      if (this.editData.attachments) {
        try {
          this.uploadedFiles = JSON.parse(this.editData.attachments)
          // 转换为el-upload需要的fileList格式
          this.field108fileList = this.uploadedFiles.map(file => ({
            name: file.name,
            url: file.url,
            status: 'success'
          }))
          this.assignmentAttachments = this.uploadedFiles.slice()
        } catch (e) {
          console.error('解析附件信息失败:', e)
          this.uploadedFiles = []
          this.field108fileList = []
          this.assignmentAttachments = []
        }
      } else {
        this.uploadedFiles = []
        this.field108fileList = []
        this.assignmentAttachments = []
      }
      
      // 加载已关联的知识点
      if (this.editData.id && this.formData.field105) {
        this.loadAssignmentKps(this.editData.id)
      }

    },
    async fetchAssignmentAttachments(assignmentId) {
      try {
        const resp = await fetch(`${this.getApiBase()}/assignments/${assignmentId}`)
        const json = await resp.json()
        const data = json && (json.data || json.result || json)
        const attachmentsStr = data && data.attachments
        if (!attachmentsStr) {
          this.assignmentAttachments = []
          return
        }
        let arr = []
        try {
          arr = JSON.parse(attachmentsStr)
        } catch (e) {
          arr = []
        }
        this.assignmentAttachments = Array.isArray(arr) ? arr.map(it => ({
          name: it.name,
          url: it.url
        })) : []
      } catch (e) {
        this.assignmentAttachments = []
      }
    },
    buildAttachmentUrl(url) {
      if (!url) return ''
      if (/^https?:\/\//i.test(url)) return url
      const u = url.startsWith('/') ? url : `/${url}`
      let result = ''
      if (/^\/(courses|uploads)\//.test(u)) {
        const host = (this.smartCourseApiBase || '').replace(/\/?$/,'')
        result = `${host}${u}`
      } else if (/^\/api\//.test(u)) {
        const host = (this.smartCourseApiBase || '').replace(/\/?$/,'')
        result = `${host}${u}`
      } else {
        const base = this.getApiBase()
        result = `${base}${u}`
      }
      try { console.log('[homework.vue] buildAttachmentUrl input=', url, 'output=', result) } catch (e) {}
      return result
    },
    getApiBase() {
      const base = (this.smartCourseApiBase || '').replace(/\/?$/,'')
      return base.endsWith('/api') ? base : `${base}/api`
    },
    async downloadAttachment(file) {
      const url = this.buildAttachmentUrl(file && file.url)
      if (!url) return
      try {
        console.log('[homework.vue] start download:', { file, url })
        const resp = await fetch(url, { headers: { Authorization: 'Bearer ' + getToken(), Accept: 'application/octet-stream' }})
        const ct = resp.headers.get('content-type') || ''
        const ctLower = ct.toLowerCase()
        console.log('[homework.vue] primary resp:', { status: resp.status, contentType: ct, ok: resp.ok })
        if (resp.ok && !/text\/html/i.test(ctLower) && !/application\/json/i.test(ctLower)) {
          const blob = await resp.blob()
          const a = document.createElement('a')
          const objectUrl = URL.createObjectURL(blob)
          a.href = objectUrl
          a.download = (file && file.name) ? file.name : 'download'
          document.body.appendChild(a)
          a.click()
          document.body.removeChild(a)
          URL.revokeObjectURL(objectUrl)
          console.log('[homework.vue] primary download success')
          return
        }
        if (/application\/json/i.test(ctLower)) {
          try {
            const j = await resp.json()
            console.log('[homework.vue] primary returned JSON:', j)
          } catch (e) {
            console.log('[homework.vue] primary JSON parse failed')
          }
        }
        let raw = (file && file.url) || ''
        let rel = ''
        if (/^https?:\/\//i.test(raw)) {
          try { rel = new URL(raw).pathname } catch (e) { rel = '' }
        } else {
          rel = raw.startsWith('/') ? raw : (raw ? '/' + raw : '')
        }
        if (!/^\/(courses|uploads)\//.test(rel)) {
          console.log('[homework.vue] fallback skipped, unexpected rel path:', rel)
          rel = ''
        }
        if (rel) {
          const fallbackApi = `${this.getApiBase()}/files/download-from-courses?fileUrl=${encodeURIComponent(rel)}`
          console.log('[homework.vue] try fallback api:', fallbackApi)
          const r2 = await fetch(fallbackApi, { headers: { Authorization: 'Bearer ' + getToken(), Accept: 'application/octet-stream' }})
          const ct2 = r2.headers.get('content-type') || ''
          console.log('[homework.vue] fallback resp:', { status: r2.status, contentType: ct2, ok: r2.ok })
          if (r2.ok) {
            const b2 = await r2.blob()
            const a2 = document.createElement('a')
            const obj2 = URL.createObjectURL(b2)
            a2.href = obj2
            a2.download = (file && file.name) ? file.name : 'download'
            document.body.appendChild(a2)
            a2.click()
            document.body.removeChild(a2)
            URL.revokeObjectURL(obj2)
            console.log('[homework.vue] fallback download success')
            return
          }
        }
      } catch (e) {}
      const win = window.open(url, '_blank')
      if (!win || win.closed || typeof win.closed === 'undefined') {
        window.location.href = url
      }
    },
    field108BeforeUpload(file) {
      let isRightSize = file.size / 1024 / 1024 < 2
      if (!isRightSize) {
        this.$message.error('文件大小超过 2MB')
      }
      if (!this.formData.field105) {
        this.$message.warning('请先选择课程')
        return false
      }
      return isRightSize
    },
    field108OnSuccess(response, file, fileList) {
      console.log('上传成功返回的数据:', response)
      let ok = false
      let name = ''
      let url = ''
      if (response && response.code === 200 && response.originalFilename && response.url) {
        ok = true
        name = response.originalFilename
        url = response.url
      } else if (response && response.code === 200 && response.data && (response.data.fileUrl || response.data.fileName)) {
        ok = true
        name = response.data.fileName || file.name
        url = response.data.fileUrl
      }
      if (ok) {
        this.uploadedFiles.push({ name, url })
        this.assignmentAttachments.push({ name, url })
        file.name = name
        file.url = url
        this.field108fileList = fileList
        console.log('uploadedFiles数组:', this.uploadedFiles)
        this.$message.success('文件上传成功')
      } else {
        this.$message.error('文件上传失败')
      }
    },
    field108OnError(error, file, fileList) {
      console.error('文件上传错误:', error)
      this.$message.error('文件上传失败，请检查网络或文件大小')
    },
    field108OnRemove(file, fileList) {
      console.log('移除文件:', file)
      console.log('当前fileList:', fileList)
      
      // 从uploadedFiles数组中移除对应的文件
      // 根据文件名或URL匹配
      const fileName = file.response ? file.response.originalFilename : file.name
      const fileUrl = file.response ? file.response.url : file.url
      
      this.uploadedFiles = this.uploadedFiles.filter(f => {
        return f.name !== fileName && f.url !== fileUrl
      })
      this.assignmentAttachments = this.assignmentAttachments.filter(f => {
        return f.name !== fileName && f.url !== fileUrl
      })
      
      // 更新fileList
      this.field108fileList = fileList
      
      console.log('移除后的uploadedFiles:', this.uploadedFiles)
      this.$message.success('文件已移除')
    },
    field108OnPreview(file) {
      const fileName = file.response ? file.response.originalFilename : file.name
      const fileUrl = file.response ? file.response.url : file.url
      if (!fileUrl) {
        this.$message.warning('无有效下载链接')
        return
      }
      this.downloadAttachment({ name: fileName, url: fileUrl })
    },
    // 加载课程列表
    loadCourses() {
      console.log('当前用户ID:', this.userId); // 调试信息
      listCourse({
        teacherUserId: this.userId
      }).then(response => {
        console.log('课程列表响应:', response); // 调试信息
        this.field105Options = response.rows.map(course => ({
          label: course.title, // 课程名称字段应该是title而不是name
          value: course.id
        }))
      }).catch(error => {
        console.error('加载课程失败:', error); // 调试信息
        this.$message.error('加载课程失败：' + (error.msg || '未知错误'))
      })
    },
    // 加载指定课程的知识点列表
    loadKnowledgePoints(courseId) {
      console.log('加载课程知识点，课程ID:', courseId)
      listKnowledgePointByCourse(courseId).then(response => {
        console.log('知识点列表响应:', response)
        this.availableKps = response.data || []
      }).catch(error => {
        console.error('加载知识点失败:', error)
        this.$message.error('加载知识点失败：' + (error.msg || '未知错误'))
        this.availableKps = []
      })
    },
    // 加载作业已关联的知识点
    loadAssignmentKps(assignmentId) {
      console.log('加载作业关联的知识点，作业ID:', assignmentId)
      listAssignmentKp(assignmentId).then(response => {
        console.log('作业知识点关联响应:', response)
        // 提取知识点ID列表
        this.selectedKpIds = (response.data || []).map(item => item.kpId)
        console.log('已选择的知识点ID:', this.selectedKpIds)
      }).catch(error => {
        console.error('加载作业知识点关联失败:', error)
        this.selectedKpIds = []
      })
    },
    // 知识点选择变化处理
    handleKpChange(value, direction, movedKeys) {
      console.log('知识点选择变化:', { value, direction, movedKeys })
    },
    // 获取当前作业数据(用于AI匹配)
    getCurrentAssignmentData() {
      return {
        title: this.formData.field103 || '',
        description: this.formData.field104 || '',
        attachments: this.uploadedFiles || []
      }
    }
  }
}

</script>
<style scoped>
.homework-dialog {
  padding-bottom: 10px;
}
.homework-form {
  padding: 10px 20px;
}
.attachments-container {
  padding: 0 20px 10px 20px;
}
.attachments-list {
  margin-top: 8px;
}
.attachment-item {
  margin-bottom: 8px;
}
.attachment-card {
  border: 1px solid #ebeef5;
}
.attachment-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
/* 完全禁用文件上传列表的所有动画效果 */
.el-upload-list__item {
  transition: none !important;
  -webkit-transition: none !important;
  animation: none !important;
  -webkit-animation: none !important;
}

/* 禁用文件移除时的动画 */
.el-upload-list__item.is-removed {
  animation: none !important;
  -webkit-animation: none !important;
  opacity: 0;
  transform: none !important;
  -webkit-transform: none !important;
}

/* 禁用所有过渡效果 */
.el-upload-list {
  transition: none !important;
  -webkit-transition: none !important;
}
</style>
<style>
.el-upload__tip {
  line-height: 1.2;
}

</style>
