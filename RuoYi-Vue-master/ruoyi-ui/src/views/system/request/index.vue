<template>
  <div class="app-container request-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="title-section">
          <h2 class="page-title">我的申请记录</h2>
          <div class="title-underline"></div>
        </div>
        <el-radio-group v-model="queryParams.status" size="small" @change="handleQuery" class="status-filter">
          <el-radio-button :label="null">全部</el-radio-button>
          <el-radio-button label="0">待审核</el-radio-button>
          <el-radio-button label="1">已通过</el-radio-button>
          <el-radio-button label="2">已拒绝</el-radio-button>
        </el-radio-group>
      </div>
    </div>

    <!-- 申请列表 -->
    <div class="table-container">
      <el-table
        v-loading="loading"
        :data="requestList"
        class="request-table"
      >
        <el-table-column label="申请课程" align="left" prop="courseName" min-width="200">
          <template slot-scope="scope">
            <div class="course-name-wrapper">
              <span class="course-dot"></span>
              <span class="course-name">{{ scope.row.courseName }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="申请状态" align="center" width="100">
          <template slot-scope="scope">
            <span :class="['status-badge', statusClass(scope.row.status)]">
              <dict-tag :options="dict.type.enrollment_status" :value="scope.row.status"/>
            </span>
          </template>
        </el-table-column>

        <el-table-column label="申请时间" align="center" prop="submitTime" width="160">
          <template slot-scope="scope">
            <span class="time-text">{{ parseTime(scope.row.submitTime, '{y}-{m}-{d} {h}:{i}') }}</span>
          </template>
        </el-table-column>

        <el-table-column label="审核时间" align="center" prop="reviewTime" width="160">
          <template slot-scope="scope">
            <span v-if="scope.row.reviewTime" class="time-text">{{ parseTime(scope.row.reviewTime, '{y}-{m}-{d} {h}:{i}') }}</span>
            <span v-else class="empty-text">--</span>
          </template>
        </el-table-column>

        <el-table-column label="审核意见" align="left" prop="reviewComment" min-width="180">
          <template slot-scope="scope">
            <span v-if="scope.row.reviewComment" class="review-text">{{ scope.row.reviewComment }}</span>
            <span v-else class="empty-text">暂无</span>
          </template>
        </el-table-column>

        <el-table-column label="操作" align="center" width="100">
          <template slot-scope="scope">
            <el-button
              v-if="String(scope.row.status) === '0'"
              size="mini"
              type="text"
              class="action-btn"
              @click="handleWithdraw(scope.row)"
            >撤销</el-button>
            <span v-else class="empty-text">--</span>
          </template>
        </el-table-column>
      </el-table>

      <!-- 空状态 -->
      <el-empty
        v-if="!loading && requestList.length === 0"
        description="暂无申请记录"
        :image-size="100"
      />
    </div>

    <!-- 分页 -->
    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />
  </div>
</template>

<script>
import { listRequest, delRequest } from "@/api/system/request";

export default {
  name: "MyCourseRequest",
  dicts: ['enrollment_status'],
  data() {
    return {
      loading: true,
      total: 0,
      requestList: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        status: null,
      },
    };
  },
  created() {
    this.getList();
  },
  methods: {
    getList() {
      this.loading = true;
      listRequest(this.queryParams).then(response => {
        this.requestList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },

    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },

    handleWithdraw(row) {
      this.$modal.confirm('是否确认撤销对课程《' + row.courseName + '》的申请？').then(() => {
        return delRequest(row.id);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("撤销成功");
      }).catch(() => {
        // 用户点击取消，不做任何事
      });
    },

    statusTagType(status) {
      const statusMap = {
        '0': 'warning',
        '1': 'success',
        '2': 'danger'
      };
      return statusMap[String(status)] || 'info';
    },

    statusClass(status) {
      const classMap = {
        '0': 'status-pending',
        '1': 'status-approved',
        '2': 'status-rejected'
      };
      return classMap[String(status)] || '';
    },


  }
};
</script>

<style lang="scss" scoped>
.request-page {
  padding: 24px;
  background: #fafbfc;
  min-height: calc(100vh - 84px);
}

/* 页面头部 */
.page-header {
  margin-bottom: 24px;

  .header-content {
    background: #fff;
    padding: 24px 28px;
    border-radius: 8px;
    border: 1px solid #e8eaed;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.02);
  }

  .title-section {
    position: relative;

    .page-title {
      font-size: 20px;
      font-weight: 500;
      margin: 0;
      color: #2c3e50;
      letter-spacing: 0.3px;
    }

    .title-underline {
      width: 40px;
      height: 3px;
      background: linear-gradient(90deg, #606266 0%, transparent 100%);
      margin-top: 8px;
      border-radius: 2px;
    }
  }

  .status-filter {
    ::v-deep .el-radio-button__inner {
      padding: 8px 18px;
      border-color: #dcdfe6;
      color: #606266;
      background: #fff;
      transition: all 0.2s;
      font-size: 13px;

      &:hover {
        color: #303133;
        border-color: #c0c4cc;
      }
    }

    ::v-deep .el-radio-button__orig-radio:checked + .el-radio-button__inner {
      background: #606266;
      border-color: #606266;
      color: #fff;
      box-shadow: none;
    }

    ::v-deep .el-radio-button:first-child .el-radio-button__inner {
      border-radius: 4px 0 0 4px;
    }

    ::v-deep .el-radio-button:last-child .el-radio-button__inner {
      border-radius: 0 4px 4px 0;
    }
  }
}

/* 表格容器 */
.table-container {
  background: #fff;
  border-radius: 8px;
  border: 1px solid #e8eaed;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.02);
}

/* 申请列表 */
.request-table {
  ::v-deep .el-table__header-wrapper {
    th {
      background: #f7f8fa;
      color: #606266;
      font-weight: 500;
      font-size: 13px;
      border-bottom: 1px solid #e8eaed;
      padding: 14px 0;
    }
  }

  ::v-deep .el-table__body-wrapper {
    .el-table__row {
      transition: background-color 0.2s;

      &:hover {
        background: #f7f8fa;
      }

      td {
        border-bottom: 1px solid #f0f2f5;
        padding: 16px 0;
      }
    }
  }

  ::v-deep .el-table::before {
    display: none;
  }

  .course-name-wrapper {
    display: flex;
    align-items: center;
    gap: 10px;

    .course-dot {
      width: 6px;
      height: 6px;
      background: #909399;
      border-radius: 50%;
      flex-shrink: 0;
    }

    .course-name {
      font-weight: 500;
      color: #303133;
      line-height: 1.5;
    }
  }

  .status-badge {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 500;
    background: #f0f2f5;
    color: #606266;

    &.status-pending {
      background: #fef6ec;
      color: #b88230;
    }

    &.status-approved {
      background: #f0f9f4;
      color: #5a8f6f;
    }

    &.status-rejected {
      background: #fef0f0;
      color: #b85a5a;
    }
  }

  .time-text {
    color: #606266;
    font-size: 13px;
  }

  .review-text {
    color: #303133;
    font-size: 13px;
    line-height: 1.6;
  }

  .empty-text {
    color: #c0c4cc;
    font-size: 13px;
  }

  .action-btn {
    color: #606266;
    font-size: 13px;

    &:hover {
      color: #303133;
    }
  }
}

/* 分页 */
::v-deep .pagination-container {
  background: transparent;
  padding: 16px 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .request-page {
    padding: 16px;
  }

  .page-header {
    .header-content {
      flex-direction: column;
      align-items: flex-start;
      gap: 16px;
      padding: 20px;
    }

    .status-filter {
      width: 100%;

      ::v-deep .el-radio-button {
        flex: 1;

        .el-radio-button__inner {
          width: 100%;
        }
      }
    }
  }

  .table-container {
    overflow-x: auto;
  }
}
</style>
