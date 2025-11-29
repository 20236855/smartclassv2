<template>
  <div class="learning-analysis-wrapper">
    <!-- Tab切换：雷达图 + AI推荐 + 数字分身 -->
    <el-tabs v-model="activeTab" type="card" class="data-tabs">
      
      <!-- Tab 1: 能力雷达图 -->
      <el-tab-pane label="能力雷达图" name="radar">
        <el-card shadow="hover" class="radar-card" v-loading="radarLoading">
          <h3 class="chart-title">能力掌握情况雷达图</h3>
          
          <!-- 动态提示文本 (仅当有数据被过滤时显示) -->
          <div class="dynamic-tip" v-if="radarData.length > 0 && radarData.length > filteredRadarData.length">
            <i class="el-icon-info"></i> 未学习的能力已自动隐藏，雷达图随学习进度动态更新
          </div>

          <div class="chart-wrapper">
            <div id="radarChart" class="radar-chart-container"></div>
          </div>
          <!-- 无数据提示 -->
          <div class="no-data" v-if="!radarLoading && radarData.length === 0">
            暂无雷达图数据
          </div>
        </el-card>
      </el-tab-pane>

      <!-- Tab 2: AI个性化推荐 -->
      <el-tab-pane label="AI个性化推荐" name="recommend">
        <el-card shadow="never" class="result-card" :body-style="{ padding: '20px' }">
          
          <!-- Loading 动画 -->
          <div v-if="recommendLoading" class="ai-loading-container">
            <div class="ai-spinner">
              <div class="circle inner"></div>
              <div class="circle outer"></div>
            </div>
            <h3 class="loading-title">AI 正在为您定制学习方案</h3>
            <div class="loading-steps">
              <div class="step-item" :class="{ active: loadingStep >= 1, completed: loadingStep > 1 }">
                <i class="el-icon-cpu"></i> 分析知识薄弱点...
              </div>
              <div class="step-item" :class="{ active: loadingStep >= 2, completed: loadingStep > 2 }">
                <i class="el-icon-connection"></i> 检索关联学习资源...
              </div>
              <div class="step-item" :class="{ active: loadingStep >= 3, completed: loadingStep > 3 }">
                <i class="el-icon-magic-stick"></i> 生成个性化推荐策略...
              </div>
            </div>
          </div>

          <!-- 无数据 / 错误状态 -->
          <div v-else-if="!recommendResult && !recommendLoading" class="no-data">
            <img src="https://img.icons8.com/ios/100/cccccc/search--v1.png" alt="search" style="opacity:0.5; width:60px; margin-bottom:10px;">
            <p>暂无AI推荐数据</p>
          </div>

          <div v-else-if="recommendResult && recommendResult.avatarStatus === 'error'" class="error-data">
            <i class="el-icon-warning error-icon"></i>
            <p>{{ recommendResult.recommendContent || '推荐获取失败' }}</p>
          </div>

          <!-- 成功展示 -->
          <div v-else-if="recommendResult && recommendResult.avatarStatus === 'completed'" class="result-content-wrapper">
            
            <!-- 关联知识点标签 -->
            <div class="result-section" v-if="statusTags.length > 0">
              <div class="section-header">
                <i class="el-icon-pie-chart" style="color: #409EFF; margin-right: 5px;"></i>
                <span>关联知识点状态</span>
              </div>
              <div class="status-tags">
                <el-tag 
                  v-for="(tag, index) in statusTags" 
                  :key="index"
                  type="warning"
                  effect="plain"
                  size="small"
                  class="kp-tag"
                >
                  {{ tag.kpName }}
                </el-tag>
              </div>
            </div>

            <!-- 折叠式推荐批次 -->
            <div class="result-section">
              <div class="section-header" style="margin-top: 20px;">
                <i class="el-icon-collection-tag" style="color: #409EFF; margin-right: 5px;"></i>
                <span>历史推荐记录（按批次展示）</span>
              </div>
              
              <div v-if="recommendBatches.length === 0" class="no-data-mini">暂无推荐记录</div>

              <el-collapse v-else accordion v-model="activeBatchName" class="custom-collapse">
                <el-collapse-item 
                  v-for="(batch, batchIndex) in recommendBatches" 
                  :key="batch.batchId"
                  :name="batch.batchId"
                >
                  <template slot="title">
                    <div class="collapse-title">
                      <span class="batch-tag">第 {{ recommendBatches.length - batchIndex }} 批</span>
                      <span class="batch-time">{{ formatTime(batch.createTime) }}</span>
                      <span class="batch-count">共 {{ batch.items.length }} 条建议</span>
                    </div>
                  </template>

                  <div class="batch-content">
                    <el-card 
                      v-for="(item, index) in batch.items" 
                      :key="item.id"
                      class="recommend-card"
                      shadow="hover"
                      :body-style="{ padding: '0' }" 
                    >
                      <div class="card-header">
                        <div class="header-left">
                          <span class="index-badge">{{ index + 1 }}</span>
                          <h4 class="action-title">{{ extractRecommendAction(item.recommendReason, item.recommendType) }}</h4>
                        </div>
                        <el-tag :type="getStatusTagType(item.status)" size="mini" effect="dark" class="status-tag-right">
                          {{ getStatusText(item.status) }}
                        </el-tag>
                      </div>
                      
                      <div class="card-body">
                        <!-- 结构化显示推荐内容 -->
                        <div class="structured-content">
                          <div class="content-row" v-if="parseRecommendField(item.recommendReason, '知识点ID')">
                            <span class="field-label">知识点ID:</span>
                            <span class="field-value" v-html="parseRecommendField(item.recommendReason, '知识点ID')"></span>
                          </div>
                          <div class="content-row" v-if="parseRecommendField(item.recommendReason, '推荐动作')">
                            <span class="field-label">推荐动作:</span>
                            <span class="field-value" v-html="parseRecommendField(item.recommendReason, '推荐动作')"></span>
                          </div>
                          <div class="content-row" v-if="parseRecommendField(item.recommendReason, '视频位置')">
                            <span class="field-label">视频位置:</span>
                            <span class="field-value" v-html="parseRecommendField(item.recommendReason, '视频位置')"></span>
                          </div>
                          <div class="content-row" v-if="parseRecommendField(item.recommendReason, '重点关注内容')">
                            <span class="field-label">重点关注内容:</span>
                            <span class="field-value" v-html="parseRecommendField(item.recommendReason, '重点关注内容')"></span>
                          </div>
                          <div class="content-row" v-if="parseRecommendField(item.recommendReason, '对应错题')">
                            <span class="field-label">对应错题:</span>
                            <span class="field-value" v-html="parseRecommendField(item.recommendReason, '对应错题')"></span>
                          </div>
                          <div class="content-row" v-if="parseRecommendField(item.recommendReason, '执行建议')">
                            <span class="field-label">执行建议:</span>
                            <span class="field-value" v-html="parseRecommendField(item.recommendReason, '执行建议')"></span>
                          </div>
                        </div>

                        <div class="card-footer">
                          <div class="footer-item">
                            <i class="el-icon-price-tag"></i> 关联知识点：{{ formatKpNames(item) }}
                          </div>
                          <div class="footer-item">
                            <i class="el-icon-s-flag"></i> 推荐动作：{{ getRecommendActionText(item.recommendType) }}
                          </div>
                        </div>
                      </div>
                    </el-card>
                  </div>
                </el-collapse-item>
              </el-collapse>
            </div>
          </div>
        </el-card>
      </el-tab-pane>

      <!-- Tab 3: 数字分身 -->
      <el-tab-pane label="数字分身" name="twin">
        <div class="result-container" v-loading="twinLoading">
          <div class="no-data" v-if="!twinLoading && !digitalTwinResult">
            暂无数字分身数据
          </div>

          <div v-if="!twinLoading && digitalTwinResult" class="result-content">

            <!-- 全家福展示栏 -->
            <div class="twins-preview-bar">
              <div class="bar-title">探索学习分身类型</div>
              <div class="twins-row">
                <div
                  v-for="type in ['稳步积累型', '逻辑攻坚型', '高效突击型', '查漏补缺型']"
                  :key="type"
                  class="mini-twin-item"
                  :class="{ 'is-active': digitalTwinResult.twinType === type }"
                >
                  <div v-if="digitalTwinResult.twinType === type" class="current-badge">我的</div>
                  <div class="mini-avatar-circle" :style="{ borderColor: getDebugColor(type) }">
                    <svg class="avatar-mini" viewBox="0 0 200 200">
                      <defs><clipPath :id="'clip-mini-' + type"><circle cx="100" cy="100" r="90" /></clipPath></defs>
                      <g v-if="type === '稳步积累型'">
                        <circle cx="100" cy="100" r="90" fill="#ecf5ff" />
                        <rect x="85" y="110" width="30" height="40" fill="#ffdec7" />
                        <rect x="70" y="60" width="60" height="80" rx="25" ry="25" fill="#ffdec7" />
                        <path d="M50 190 L50 160 Q50 140 100 140 Q150 140 150 160 L150 190 Z" fill="#409EFF" :clip-path="'url(#clip-mini-' + type + ')'"/>
                        <path d="M90 140 L100 190 L110 140 Z" fill="#fff" />
                        <path d="M95 140 L100 170 L105 140 Z" fill="#303133" />
                        <path d="M68 91 Q68 61 100 61 Q132 61 132 91 L132 85 Q132 61 100 61 Q68 61 68 85 Z" fill="#303133" />
                        <circle cx="85" cy="95" r="3" fill="#303133" />
                        <circle cx="115" cy="95" r="3" fill="#303133" />
                        <path d="M95 110 Q100 113 105 110" stroke="#c08e70" stroke-width="2" fill="none" />
                      </g>
                      <g v-else-if="type === '逻辑攻坚型'">
                        <circle cx="100" cy="100" r="90" fill="#f0f9eb" />
                        <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" fill="#67C23A" :clip-path="'url(#clip-mini-' + type + ')'" />
                        <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" />
                        <path d="M68 100 Q68 60 100 60 Q132 60 132 100 L132 80 Q100 60 68 80 Z" fill="#5e4636" />
                        <circle cx="85" cy="95" r="3" fill="#303133" />
                        <circle cx="115" cy="95" r="3" fill="#303133" />
                        <path d="M97 110 L103 110" stroke="#c08e70" stroke-width="2" />
                        <circle cx="125" cy="130" r="12" fill="#ffdec7" stroke="#f0f9eb" stroke-width="2" />
                        <g><path d="M145 60 Q155 40 165 60 Q165 70 155 70 L150 70 Z" fill="#E6A23C" /></g>
                      </g>
                      <g v-else-if="type === '高效突击型'">
                        <circle cx="100" cy="100" r="90" fill="#fdf6ec" />
                        <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" fill="#E6A23C" :clip-path="'url(#clip-mini-' + type + ')'" />
                        <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" />
                        <rect x="68" y="78" width="64" height="12" fill="#F56C6C" rx="3" />
                        <path d="M68 78 Q68 75 100 75 Q132 75 132 78 L135 75 L100 58 L65 75 Z" fill="#303133" />
                        <circle cx="85" cy="98" r="3" fill="#303133" />
                        <circle cx="115" cy="98" r="3" fill="#303133" />
                        <path d="M95 115 Q100 110 105 115" stroke="#c08e70" stroke-width="2" fill="none" />
                      </g>
                      <g v-else>
                        <circle cx="100" cy="100" r="90" fill="#f4f4f5" />
                        <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" fill="#909399" :clip-path="'url(#clip-mini-' + type + ')'" />
                        <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" />
                        <path d="M68 90 Q68 55 100 55 Q132 55 132 90 L132 80 Q100 60 68 80 Z" fill="#303133" />
                        <circle cx="85" cy="95" r="3" fill="#303133" />
                        <circle cx="115" cy="95" r="3" fill="#303133" />
                        <path d="M98 112 Q100 114 102 112" stroke="#c08e70" stroke-width="2" fill="none" />
                        <circle cx="120" cy="110" r="15" fill="none" stroke="#303133" stroke-width="2" />
                        <line x1="120" y1="125" x2="120" y2="135" stroke="#303133" stroke-width="3" />
                      </g>
                    </svg>
                  </div>
                  <div class="mini-label">{{ type.substring(0, 2) }}型</div>
                </div>
              </div>
            </div>

            <!-- 正式展示区域：大头像 + 详细信息 -->
            <div class="twin-character-container">
              <div class="avatar-circle" :style="{ borderColor: twinColor + '40' }">
                <svg class="avatar-base" viewBox="0 0 200 200" :key="'real-svg-' + digitalTwinResult.twinType">
                  <defs><clipPath id="avatar-clip-real"><circle cx="100" cy="100" r="90" /></clipPath></defs>
                  <g v-if="digitalTwinResult.twinType === '稳步积累型'" class="avatar-group steady-type">
                    <circle cx="100" cy="100" r="90" fill="#ecf5ff" />
                    <rect x="85" y="110" width="30" height="40" fill="#ffdec7" />
                    <rect x="70" y="60" width="60" height="80" rx="25" ry="25" fill="#ffdec7" />
                    <path d="M50 190 L50 160 Q50 140 100 140 Q150 140 150 160 L150 190 Z" :fill="twinColor" clip-path="url(#avatar-clip-real)"/>
                    <path d="M90 140 L100 190 L110 140 Z" fill="#fff" />
                    <path d="M95 140 L100 170 L105 140 Z" fill="#303133" />
                    <path d="M68 91 Q68 61 100 61 Q132 61 132 91 L132 85 Q132 61 100 61 Q68 61 68 85 Z" fill="#303133" />
                    <circle cx="85" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <circle cx="115" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <g stroke="#303133" stroke-width="1.5" fill="none" opacity="0.8">
                       <rect x="78" y="88" width="14" height="10" rx="2" />
                       <rect x="108" y="88" width="14" height="10" rx="2" />
                       <line x1="92" y1="93" x2="108" y2="93" />
                    </g>
                    <path d="M95 110 Q100 113 105 110" stroke="#c08e70" stroke-width="2" fill="none" stroke-linecap="round" />
                  </g>
                  <g v-else-if="digitalTwinResult.twinType === '逻辑攻坚型'" class="avatar-group logic-type">
                    <circle cx="100" cy="100" r="90" fill="#f0f9eb" />
                    <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" :fill="twinColor" clip-path="url(#avatar-clip-real)" />
                    <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" />
                    <path d="M68 100 Q68 60 100 60 Q132 60 132 100 L132 80 Q100 60 68 80 Z" fill="#5e4636" />
                    <circle cx="85" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <circle cx="115" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <path d="M97 110 L103 110" stroke="#c08e70" stroke-width="2" stroke-linecap="round" />
                    <circle cx="125" cy="130" r="12" fill="#ffdec7" stroke="#f0f9eb" stroke-width="2" />
                    <g class="idea-bulb">
                      <path d="M145 60 Q155 40 165 60 Q165 70 155 70 L150 70 Z" fill="#E6A23C" />
                      <line x1="140" y1="50" x2="135" y2="45" stroke="#E6A23C" stroke-width="2" />
                      <line x1="170" y1="50" x2="175" y2="45" stroke="#E6A23C" stroke-width="2" />
                      <line x1="155" y1="35" x2="155" y2="30" stroke="#E6A23C" stroke-width="2" />
                    </g>
                  </g>
                  <g v-else-if="digitalTwinResult.twinType === '高效突击型'" class="avatar-group efficient-type">
                    <circle cx="100" cy="100" r="90" fill="#fdf6ec" />
                    <path d="M20 100 L180 100 M40 50 L160 50" stroke="#faecd8" stroke-width="2" class="bg-speed-lines" />
                    <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" :fill="twinColor" clip-path="url(#avatar-clip-real)" />
                    <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" class="face-tilt" />
                    <rect x="68" y="78" width="64" height="12" fill="#F56C6C" rx="3" class="face-tilt" />
                    <path d="M68 78 Q68 75 100 75 Q132 75 132 78 L135 75 L100 58 L65 75 Z" fill="#303133" class="face-tilt" />
                    <g class="face-tilt">
                      <line x1="80" y1="90" x2="90" y2="92" stroke="#303133" stroke-width="2" />
                      <line x1="110" y1="92" x2="120" y2="90" stroke="#303133" stroke-width="2" />
                      <circle cx="85" cy="98" r="3" fill="#303133" />
                      <circle cx="115" cy="98" r="3" fill="#303133" />
                      <path d="M95 115 Q100 110 105 115" stroke="#c08e70" stroke-width="2" fill="none" />
                    </g>
                  </g>
                  <g v-else class="avatar-group gap-type">
                    <circle cx="100" cy="100" r="90" fill="#f4f4f5" />
                    <path d="M40 200 Q40 150 100 150 Q160 150 160 200 Z" :fill="twinColor" clip-path="url(#avatar-clip-real)" />
                    <rect x="70" y="65" width="60" height="75" rx="25" fill="#ffdec7" />
                    <path d="M68 90 Q68 55 100 55 Q132 55 132 90 L132 80 Q100 60 68 80 Z" fill="#303133" />
                    <circle cx="85" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <circle cx="115" cy="95" r="3" fill="#303133" class="blink-eye" />
                    <path d="M98 112 Q100 114 102 112" stroke="#c08e70" stroke-width="2" fill="none" />
                    <g class="magnifier-float">
                      <circle cx="120" cy="110" r="15" fill="rgba(255,255,255,0.3)" stroke="#303133" stroke-width="2" />
                      <line x1="120" y1="125" x2="120" y2="145" stroke="#303133" stroke-width="3" stroke-linecap="round" />
                    </g>
                  </g>
                </svg>
              </div>

              <div class="character-info">
                <div class="info-header">
                   <h2 :style="{ color: twinColor }">{{ digitalTwinResult.twinType }}</h2>
                   <el-tag size="small" effect="plain" :type="twinTypeTagType" class="ai-badge">AI 智能画像</el-tag>
                </div>

                <p class="info-text">
                  <i class="el-icon-chat-dot-round" style="color: #909399; margin-right: 4px;"></i>
                  学习风格如同<strong>{{ getCharacterDesc(digitalTwinResult.twinType) }}</strong>
                </p>
                <div class="advice-box" :style="{ borderLeftColor: twinColor }">
                  <strong>💡 提升建议：</strong>{{ getAdvice(digitalTwinResult.twinType) }}
                </div>
              </div>
            </div>

            <!-- 数字分身概览卡片 -->
            <el-card shadow="hover" class="overview-card">
              <div class="overview-header">
                <h3 class="card-title">数字分身概览</h3>
                <el-tag :type="twinTypeTagType" size="large" class="twin-type-tag">
                  {{ digitalTwinResult.twinType }}
                </el-tag>
              </div>
              <div class="overview-body">
                <div class="score-item">
                  <span class="label">匹配分数：</span>
                  <span class="score" :style="{ color: twinColor }">{{ digitalTwinResult.score }}分</span>
                  <span class="total-score">（满分25分）</span>
                </div>
                <div class="feature-title">核心特征：</div>
                <div class="feature-tags">
                  <el-tag
                    v-for="(feature, index) in digitalTwinResult.features"
                    :key="index"
                    type="info"
                    effect="plain"
                    class="feature-tag"
                  >
                    {{ feature }}
                  </el-tag>
                </div>
              </div>
            </el-card>

            <!-- 得分明细表格 -->
            <el-card shadow="hover" class="detail-card">
              <h3 class="card-title">各分身得分明细</h3>
              <el-table
                :data="digitalTwinResult.scoreDetails"
                border
                stripe
                style="width: 100%;"
                :header-cell-style="{ 'background-color': '#f5f7fa', 'font-weight': 600 }"
              >
                <el-table-column label="分身类型" prop="twinType" width="180" align="center">
                  <template #default="scope">
                    <el-tag :type="getTagType(scope.row.twinType)" size="medium">
                      {{ scope.row.twinType }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="匹配分数" prop="score" width="120" align="center">
                  <template #default="scope">
                    <span class="table-score">{{ scope.row.score }}分</span>
                  </template>
                </el-table-column>
                <el-table-column label="规则匹配情况" prop="ruleMatches">
                  <template #default="scope">
                    <div class="rule-matches">
                      <div v-for="(rule, index) in scope.row.ruleMatches" :key="index" class="rule-item">
                        <i class="el-icon-circle-check" v-if="rule.includes('符合') && !rule.includes('不符合')"></i>
                        <i class="el-icon-circle-close" v-else></i>
                        <span class="rule-text">{{ rule }}</span>
                      </div>
                    </div>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>
          </div>
        </div>
      </el-tab-pane>

    </el-tabs>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import { getRadarData } from '@/api/learning/radar'
import { getRecommendResult } from '@/api/learning/aiRecommend'
import { calculateDigitalTwin } from '@/api/learning/digitalTwin'

export default {
  name: 'LearningAnalysis',
  props: {
    courseId: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      activeTab: 'radar',

      // 雷达图数据
      radarData: [],
      filteredRadarData: [],
      radarChart: null,
      radarLoading: false,

      // AI推荐数据
      recommendResult: null,
      recommendLoading: false,
      loadingStep: 0,
      loadingTimer: null,
      statusTags: [],
      recommendBatches: [],
      activeBatchName: '',

      // 数字分身数据
      digitalTwinResult: null,
      twinLoading: false
    }
  },
  computed: {
    studentId() {
      return this.$store.getters.userId
    },
    twinColor() {
      if (!this.digitalTwinResult) return '#409EFF'
      switch (this.digitalTwinResult.twinType) {
        case '稳步积累型': return '#409EFF'
        case '逻辑攻坚型': return '#67C23A'
        case '高效突击型': return '#E6A23C'
        case '查漏补缺型': return '#909399'
        default: return '#409EFF'
      }
    },
    twinTypeTagType() {
      if (!this.digitalTwinResult) return 'primary'
      switch (this.digitalTwinResult.twinType) {
        case '稳步积累型': return 'primary'
        case '逻辑攻坚型': return 'success'
        case '高效突击型': return 'warning'
        case '查漏补缺型': return 'info'
        default: return 'primary'
      }
    }
  },
  watch: {
    activeTab(newTab) {
      if (newTab === 'radar' && this.radarData.length === 0) {
        this.loadRadarData()
      } else if (newTab === 'recommend' && !this.recommendResult) {
        this.loadRecommendData()
      } else if (newTab === 'twin' && !this.digitalTwinResult) {
        this.loadDigitalTwinData()
      }
    }
  },
  mounted() {
    this.loadRadarData()
  },
  beforeDestroy() {
    this.clearLoadingTimer()
    if (this.radarChart) {
      this.radarChart.dispose()
      this.radarChart = null
    }
  },
  methods: {
    // ========== 雷达图相关方法 ==========
    loadRadarData() {
      this.radarLoading = true
      getRadarData({
        studentId: this.studentId,
        courseId: this.courseId
      }).then(response => {
        this.radarData = response.data || []
        this.$nextTick(() => {
          this.initRadarChart()
          this.updateRadarChart()
        })
      }).catch(error => {
        console.error('加载雷达图数据失败:', error)
      }).finally(() => {
        this.radarLoading = false
      })
    },

    initRadarChart() {
      const chartDom = document.getElementById('radarChart')
      if (!chartDom) return
      this.radarChart = echarts.init(chartDom)
      this.radarChart.setOption({ radar: { indicator: [] }, series: [{ type: 'radar', data: [] }] })
    },

    updateRadarChart() {
      if (!this.radarChart) return
      if (this.radarData.length === 0) {
        this.filteredRadarData = []
        this.radarChart.clear()
        return
      }

      // 过滤掉分数<=0的能力
      this.filteredRadarData = this.radarData.filter(item => item.competencyScore > 0)

      if (this.filteredRadarData.length === 0) {
        this.radarChart.clear()
        return
      }

      const option = {
        radar: {
          indicator: this.filteredRadarData.map(item => ({
            name: item.competencyName,
            max: 100
          })),
          radius: '65%',
          splitNumber: 4,
          name: { textStyle: { color: '#606266', fontSize: 13 } },
          splitLine: { lineStyle: { color: '#E4E7ED' } },
          splitArea: { show: true, areaStyle: { color: ['rgba(64, 158, 255, 0.05)', 'rgba(64, 158, 255, 0.1)'] } },
          axisLine: { lineStyle: { color: '#DCDFE6' } }
        },
        series: [{
          type: 'radar',
          data: [{
            value: this.filteredRadarData.map(item => item.competencyScore),
            name: `学生${this.studentId}能力评分`
          }],
          symbol: 'circle',
          symbolSize: 8,
          areaStyle: {
            opacity: 0.3,
            color: '#409EFF'
          },
          lineStyle: { width: 2, color: '#409EFF' },
          itemStyle: { color: '#409EFF' },
          label: { show: true, fontSize: 12, color: '#409EFF' }
        }],
        tooltip: { trigger: 'item' }
      }
      this.radarChart.setOption(option)
    },

    // ========== AI推荐相关方法 ==========
    loadRecommendData() {
      this.startLoadingProcess()
      this.statusTags = []
      this.recommendBatches = []
      this.recommendResult = null

      getRecommendResult({
        studentUserId: this.studentId,
        courseId: this.courseId
      }).then(response => {
        setTimeout(() => {
          if (response && response.data) {
            this.recommendResult = response.data
            this.handleRecommendItemList(response.data.recommendItemList || [])
            this.extractTagsFromRecommendations(response.data.recommendItemList || [])

            if (this.recommendBatches.length > 0) {
              this.activeBatchName = this.recommendBatches[0].batchId
            }
          } else {
            this.recommendResult = { avatarStatus: 'error', recommendContent: '后端返回数据格式异常' }
          }
          this.stopLoadingProcess()
        }, 1000)
      }).catch(error => {
        this.recommendResult = { avatarStatus: 'error', recommendContent: '加载失败：' + (error.msg || error.message || '网络异常') }
        this.stopLoadingProcess()
      })
    },

    startLoadingProcess() {
      this.recommendLoading = true
      this.loadingStep = 1
      this.clearLoadingTimer()
      this.loadingTimer = setInterval(() => {
        if (this.loadingStep < 3) {
          this.loadingStep++
        }
      }, 800)
    },

    stopLoadingProcess() {
      this.loadingStep = 3
      this.clearLoadingTimer()
      this.recommendLoading = false
    },

    clearLoadingTimer() {
      if (this.loadingTimer) {
        clearInterval(this.loadingTimer)
        this.loadingTimer = null
      }
    },

    handleRecommendItemList(itemList) {
      const batchMap = new Map()
      itemList.forEach(item => {
        const batchId = item.batchId || 'default'
        if (!batchMap.has(batchId)) {
          batchMap.set(batchId, {
            batchId: batchId,
            createTime: item.createTime,
            items: []
          })
        }
        batchMap.get(batchId).items.push(item)
      })
      this.recommendBatches = Array.from(batchMap.values()).sort((a, b) => {
        return new Date(b.createTime) - new Date(a.createTime)
      })
    },

    extractTagsFromRecommendations(itemList) {
      const kpNameSet = new Set()
      itemList.forEach(item => {
        // 优先使用relatedKpNames
        if (item.relatedKpNames) {
          const names = item.relatedKpNames.split(',').map(name => name.trim())
          names.forEach(name => kpNameSet.add(name))
        } else if (item.relatedKpIds) {
          // 如果没有relatedKpNames，则使用relatedKpIds
          const ids = item.relatedKpIds.split(',').map(id => id.trim())
          ids.forEach(id => kpNameSet.add(`知识点${id}`))
        }
      })
      this.statusTags = Array.from(kpNameSet).map(kpName => ({ kpName }))
    },

    formatTime(timeStr) {
      if (!timeStr) return ''
      return timeStr.substring(0, 16).replace('T', ' ')
    },

    extractRecommendAction(reason, type) {
      if (!reason) return this.getRecommendActionText(type)
      const match = reason.match(/^(.{0,20}?)[:：]/)
      return match ? match[1] : this.getRecommendActionText(type)
    },

    cleanAndFormatContent(content) {
      if (!content) return ''
      return content.replace(/^[^:：]+[:：]\s*/, '').replace(/\n/g, '<br>')
    },

    // 解析推荐理由中的特定字段
    parseRecommendField(content, fieldName) {
      if (!content) return ''

      // 匹配格式：字段名：内容
      const regex = new RegExp(`${fieldName}[:：]\\s*([^\\n]+)`, 'i')
      const match = content.match(regex)

      if (match && match[1]) {
        let value = match[1].trim()

        // 特殊处理：将【1.极限】格式的内容转换为蓝色链接样式
        value = value.replace(/【(\d+\.\S+?)】/g, '<span class="highlight-link">【$1】</span>')

        // 特殊处理：将作业《xxx》格式的内容转换为蓝色链接样式
        value = value.replace(/《([^》]+)》/g, '<span class="highlight-link">《$1》</span>')

        // 特殊处理：将（ID: xxx）格式的内容转换为灰色
        value = value.replace(/（ID[:：]\s*(\d+)）/g, '<span class="id-text">（ID: $1）</span>')

        return value
      }

      return ''
    },

    // 格式化知识点名称（优先使用relatedKpNames）
    formatKpNames(item) {
      if (item && item.relatedKpNames) {
        const names = item.relatedKpNames.split(',').map(n => n.trim())
        if (names.length > 3) {
          return names.slice(0, 3).join('、') + '...'
        }
        return names.join('、')
      }
      if (item && item.relatedKpIds) {
        const ids = item.relatedKpIds.split(',').map(id => id.trim())
        if (ids.length > 3) {
          return ids.slice(0, 3).map(id => `知识点${id}`).join('、') + '...'
        }
        return ids.map(id => `知识点${id}`).join('、')
      }
      return '暂无关联'
    },

    // 获取推荐动作文本
    getRecommendActionText(type) {
      const actionMap = {
        'video': '观看视频学习',
        'exercise': '习题训练',
        'resource': '资料补充学习',
        'kp_review': '知识点复盘巩固'
      }
      return actionMap[type] || '个性化提升'
    },

    getStatusText(status) {
      const statusMap = {
        'pending': '待学习',
        'in_progress': '学习中',
        'completed': '已完成',
        'skipped': '已跳过'
      }
      return statusMap[status] || status
    },

    getStatusTagType(status) {
      const typeMap = {
        'pending': 'warning',
        'in_progress': 'primary',
        'completed': 'success',
        'skipped': 'info'
      }
      return typeMap[status] || 'info'
    },

    // ========== 数字分身相关方法 ==========
    loadDigitalTwinData() {
      this.twinLoading = true
      calculateDigitalTwin({
        studentId: this.studentId,  // 后端接收参数名是 studentId
        courseId: this.courseId
      }).then(response => {
        console.log('数字分身数据:', response)
        this.digitalTwinResult = response.data
      }).catch(error => {
        console.error('加载数字分身数据失败:', error)
        this.$message.error('加载数字分身数据失败: ' + (error.msg || error.message || '网络异常'))
      }).finally(() => {
        this.twinLoading = false
      })
    },

    getDebugColor(type) {
      switch (type) {
        case '稳步积累型': return '#409EFF'
        case '逻辑攻坚型': return '#67C23A'
        case '高效突击型': return '#E6A23C'
        case '查漏补缺型': return '#909399'
        default: return '#409EFF'
      }
    },

    getCharacterDesc(type) {
      const map = {
        '稳步积累型': '一位登山者，一步一个脚印踏实前行',
        '逻辑攻坚型': '一位侦探，善于抽丝剥茧发现逻辑真相',
        '高效突击型': '一位短跑健将，在短时间内爆发力极强',
        '查漏补缺型': '一位质检员，细致入微不放过任何知识瑕疵'
      }
      return map[type] || '一位知识探索者'
    },

    getAdvice(type) {
      const map = {
        '稳步积累型': '保持当前节奏，尝试挑战更高难度的综合题，突破舒适区。',
        '逻辑攻坚型': '继续发挥逻辑优势，同时注意提升解题速度，平衡深思与效率。',
        '高效突击型': '注意基础知识的沉淀，避免粗心丢分，欲速则不达。',
        '查漏补缺型': '建立错题本，定期回顾盲点知识，将短板转化为潜力板。'
      }
      return map[type] || '继续保持学习热情，稳步提升。'
    },

    getTagType(twinType) {
      switch (twinType) {
        case '稳步积累型': return 'primary'
        case '逻辑攻坚型': return 'success'
        case '高效突击型': return 'warning'
        case '查漏补缺型': return 'info'
        default: return 'default'
      }
    }
  }
}
</script>

<style scoped>
.learning-analysis-wrapper {
  padding: 0;
}

/* Tab样式 */
.data-tabs {
  margin-top: 0;
}

/* 雷达图样式 */
.radar-card {
  border-radius: 8px;
  border: none;
}

.chart-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 20px;
  text-align: center;
}

.dynamic-tip {
  background: #ecf5ff;
  color: #409EFF;
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 13px;
  margin-bottom: 15px;
  text-align: center;
}

.chart-wrapper {
  width: 100%;
  display: flex;
  justify-content: center;
}

.radar-chart-container {
  width: 100%;
  height: 500px;
}

.no-data {
  text-align: center;
  padding: 60px 0;
  color: #909399;
}

/* AI推荐样式 */
.result-card {
  border-radius: 8px;
  border: none;
  min-height: 400px;
}

/* Loading 动画 */
.ai-loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
}

.ai-spinner {
  position: relative;
  width: 80px;
  height: 80px;
  margin-bottom: 25px;
}

.circle {
  position: absolute;
  border-radius: 50%;
  border: 3px solid transparent;
}

.circle.outer {
  width: 100%;
  height: 100%;
  border-top-color: #409EFF;
  border-bottom-color: #409EFF;
  animation: spin 1.5s linear infinite;
}

.circle.inner {
  width: 60%;
  height: 60%;
  top: 20%;
  left: 20%;
  border-left-color: #67C23A;
  border-right-color: #67C23A;
  animation: spin-reverse 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@keyframes spin-reverse {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(-360deg); }
}

.loading-title {
  font-size: 18px;
  color: #303133;
  margin-bottom: 20px;
  font-weight: 600;
}

.loading-steps {
  text-align: left;
  width: 240px;
}

.step-item {
  margin-bottom: 12px;
  color: #C0C4CC;
  font-size: 14px;
  transition: all 0.3s;
  display: flex;
  align-items: center;
}

.step-item i {
  margin-right: 8px;
}

.step-item.active {
  color: #409EFF;
  font-weight: 600;
  transform: translateX(5px);
}

.step-item.completed {
  color: #67C23A;
}

.error-data {
  text-align: center;
  padding: 60px 0;
  color: #F56C6C;
}

.error-icon {
  font-size: 48px;
  margin-bottom: 15px;
}

/* 推荐内容样式 */
.result-content-wrapper {
  padding: 0;
}

.result-section {
  margin-bottom: 20px;
}

.section-header {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
}

.status-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.kp-tag {
  margin: 0;
}

.no-data-mini {
  text-align: center;
  color: #c0c4cc;
  padding: 20px;
}

/* Collapse 样式 */
.custom-collapse {
  border: none;
}

::v-deep .el-collapse-item__header {
  background-color: #f9fafc;
  border-radius: 6px;
  margin-bottom: 10px;
  border: 1px solid #ebeef5;
  padding: 0 15px;
  height: 50px;
  line-height: 50px;
  font-size: 14px;
}

::v-deep .el-collapse-item__header.is-active {
  border-bottom-left-radius: 0;
  border-bottom-right-radius: 0;
  border-bottom: 1px solid #ebeef5;
}

::v-deep .el-collapse-item__wrap {
  border-bottom: none;
  background-color: transparent;
}

::v-deep .el-collapse-item__content {
  padding: 15px 5px 5px 5px;
}

.collapse-title {
  width: 100%;
  display: flex;
  align-items: center;
}

.batch-tag {
  background: #e6a23c;
  color: #fff;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  margin-right: 10px;
}

.batch-time {
  font-weight: 600;
  margin-right: 15px;
}

.batch-count {
  color: #909399;
  font-size: 12px;
}

/* 推荐卡片样式 */
.batch-content {
  padding: 0;
}

.recommend-card {
  border: 1px solid #e4e7ed;
  margin-bottom: 15px;
  overflow: visible;
}

.card-header {
  background: linear-gradient(to right, #fdf6ec, #fff);
  padding: 12px 15px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #faecd8;
}

.header-left {
  display: flex;
  align-items: center;
}

.index-badge {
  background: #e6a23c;
  color: #fff;
  width: 22px;
  height: 22px;
  line-height: 22px;
  text-align: center;
  border-radius: 50%;
  font-size: 12px;
  margin-right: 8px;
  font-weight: bold;
}

.action-title {
  margin: 0;
  font-size: 15px;
  color: #303133;
  font-weight: 600;
}

.status-tag-right {
  flex-shrink: 0;
}

.card-body {
  padding: 18px 20px;
}

.content-text {
  font-size: 14px;
  color: #555;
  line-height: 1.8;
}

/* 结构化内容样式 */
.structured-content {
  font-size: 14px;
  line-height: 1.8;
}

.content-row {
  margin-bottom: 10px;
  display: flex;
  align-items: flex-start;
}

.content-row:last-child {
  margin-bottom: 0;
}

.field-label {
  font-weight: 600;
  color: #303133;
  min-width: 100px;
  flex-shrink: 0;
  margin-right: 8px;
}

.field-value {
  color: #606266;
  flex: 1;
  word-break: break-word;
}

/* 高亮链接样式（蓝色） */
::v-deep .highlight-link {
  color: #409EFF;
  font-weight: 500;
}

/* ID文本样式（灰色） */
::v-deep .id-text {
  color: #909399;
  font-size: 13px;
}

.card-footer {
  margin-top: 15px;
  padding-top: 12px;
  border-top: 1px dashed #ebeef5;
  display: flex;
  gap: 20px;
  font-size: 13px;
  color: #909399;
}

.footer-item {
  display: flex;
  align-items: center;
}

.footer-item i {
  margin-right: 4px;
}

/* 数字分身样式 */
.result-container {
  padding: 0;
}

.result-content {
  padding: 0;
}

/* 大头像展示区域 */
.twin-character-container {
  display: flex;
  align-items: center;
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 12px;
  padding: 32px;
  margin-bottom: 20px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.04);
  transition: all 0.3s ease;
}

.twin-character-container:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.06);
}

.avatar-circle {
  width: 140px;
  height: 140px;
  border-radius: 50%;
  border: 4px solid;
  padding: 5px;
  margin-right: 35px;
  flex-shrink: 0;
  background: #fff;
}

.avatar-base {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  overflow: hidden;
}

.character-info {
  flex: 1;
  text-align: left;
}

.info-header {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  gap: 12px;
}

.character-info h2 {
  margin: 0;
  font-size: 26px;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.ai-badge {
  font-weight: normal;
  border-radius: 4px;
}

.info-text {
  font-size: 15px;
  color: #505255;
  margin: 0 0 16px 0;
  line-height: 1.5;
  display: flex;
  align-items: center;
}

.info-text strong {
  color: #303133;
  font-weight: 600;
  margin-left: 4px;
}

.advice-box {
  background: #f9f9fa;
  padding: 12px 16px;
  border-radius: 6px;
  border-left: 4px solid #ccc;
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
}

/* 全家福展示栏 */
.twins-preview-bar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 25px;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.bar-title {
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  text-align: center;
  margin-bottom: 15px;
}

.twins-row {
  display: flex;
  justify-content: space-around;
  align-items: center;
  gap: 15px;
}

.mini-twin-item {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  transition: all 0.3s;
  cursor: pointer;
}

.mini-twin-item:hover {
  transform: translateY(-5px);
}

.mini-twin-item.is-active {
  transform: scale(1.1);
}

.current-badge {
  position: absolute;
  top: -8px;
  right: -8px;
  background: #F56C6C;
  color: #fff;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 10px;
  font-weight: 600;
  z-index: 10;
  box-shadow: 0 2px 4px rgba(245, 108, 108, 0.4);
}

.mini-avatar-circle {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  border: 3px solid transparent;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  transition: all 0.3s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.mini-twin-item.is-active .mini-avatar-circle {
  box-shadow: 0 4px 16px rgba(255, 255, 255, 0.5);
}

.avatar-mini {
  width: 100%;
  height: 100%;
}

.mini-label {
  margin-top: 8px;
  color: #fff;
  font-size: 12px;
  font-weight: 600;
}

/* 概览卡片 */
.overview-card {
  background: #fff;
  margin-top: 20px;
}

.overview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.card-title {
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0;
  padding-bottom: 8px;
  border-bottom: 2px solid #e4e7ed;
}

.twin-type-tag {
  flex-shrink: 0;
}

.overview-body {
  padding: 0;
}

.score-item {
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.score-item .label {
  font-size: 14px;
  color: #606266;
}

.score-item .score {
  font-size: 28px;
  font-weight: 700;
}

.score-item .total-score {
  font-size: 14px;
  color: #909399;
}

.feature-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
}

.feature-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.feature-tag {
  margin: 0;
}

/* 得分明细表格 */
.detail-card {
  background: #fff;
  margin-top: 20px;
}

.table-score {
  font-size: 16px;
  font-weight: 600;
  color: #67C23A;
}

.rule-matches {
  padding: 0;
}

.rule-item {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  font-size: 13px;
  margin-bottom: 4px;
}

.rule-item .el-icon-circle-check {
  color: #67C23A;
  margin-top: 2px;
  flex-shrink: 0;
}

.rule-item .el-icon-circle-close {
  color: #F56C6C;
  margin-top: 2px;
  flex-shrink: 0;
}

.rule-text {
  flex: 1;
  line-height: 1.5;
}

/* 动画效果 */
.blink-eye {
  animation: blink 4s infinite;
  transform-origin: center;
}

@keyframes blink {
  0%, 48%, 52%, 100% { transform: scaleY(1); }
  50% { transform: scaleY(0.1); }
}

.idea-bulb {
  animation: flash 2s infinite alternate;
  transform-origin: center;
}

@keyframes flash {
  from { opacity: 0.4; transform: scale(0.9); }
  to { opacity: 1; transform: scale(1.1); }
}

.face-tilt {
  animation: tiltHead 2s infinite ease-in-out;
  transform-origin: 100px 200px;
}

@keyframes tiltHead {
  0%, 100% { transform: rotate(0deg); }
  50% { transform: rotate(3deg); }
}

.bg-speed-lines {
  animation: speedMove 1s linear infinite;
  stroke-dasharray: 10;
}

@keyframes speedMove {
  from { stroke-dashoffset: 20; }
  to { stroke-dashoffset: 0; }
}

.magnifier-float {
  animation: floatMag 3s ease-in-out infinite;
}

@keyframes floatMag {
  0%, 100% { transform: translateY(0) rotate(0); }
  50% { transform: translateY(-5px) rotate(-5deg); }
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-3px); }
}

/* 响应式适配 */
@media (max-width: 768px) {
  .twins-row {
    overflow-x: auto;
    justify-content: flex-start;
    gap: 15px;
    padding-bottom: 10px;
  }

  .radar-chart-container {
    height: 400px;
  }

  .dynamic-tip {
    font-size: 12px;
    padding: 6px;
  }
}
</style>

