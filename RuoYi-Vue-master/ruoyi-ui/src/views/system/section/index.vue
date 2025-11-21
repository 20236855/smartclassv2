<template>
  <div class="app-container section-player-page">
    <!-- 精简的顶部导航栏 -->
    <div class="page-header">
      <div class="header-left">
        <el-button icon="el-icon-back" circle size="small" @click="goBack" class="back-btn"></el-button>
        <div class="breadcrumb">
          <span class="course-name">{{ courseName || '课程' }}</span>
          <i class="el-icon-arrow-right divider"></i>
          <span class="section-title">{{ sectionInfo.title || '加载中...' }}</span>
        </div>
      </div>
      <div class="header-right">
        <el-button
          icon="el-icon-menu"
          size="small"
          @click="catalogVisible = !catalogVisible"
          class="catalog-toggle-btn"
        >
          {{ catalogVisible ? '隐藏目录' : '显示目录' }}
        </el-button>
        <div v-if="totalDuration || sectionInfo.duration" class="duration-info">
          <i class="el-icon-time"></i>
          <span>{{ formatDuration(totalDuration || sectionInfo.duration) }}</span>
        </div>
      </div>
    </div>

    <!-- 主内容区 -->
    <div class="main-content">
      <!-- 上部分：视频和目录 -->
      <div class="top-section" :class="{ 'catalog-hidden': !catalogVisible }">
        <!-- 左侧：视频播放器 -->
        <div class="video-section">
          <div class="video-container" v-loading="loading">
            <div class="video-wrapper">
              <!-- 原生视频播放器 -->
              <div
                class="custom-video-player"
                v-if="playerConfig.url"
                @mousemove="showControls"
                @mouseleave="hideControls"
              >
                <video
                  ref="videoPlayer"
                  :src="playerConfig.url"
                  @loadedmetadata="onVideoLoaded"
                  @timeupdate="onTimeUpdate"
                  @ended="onVideoEnded"
                  @click="togglePlay"
                  class="video-element"
                ></video>

                <!-- 自定义控制栏 -->
                <div
                  class="custom-controls"
                  :class="{ 'controls-visible': controlsVisible }"
                  @mouseenter="showControls"
                  @mouseleave="hideControls"
                >
                  <!-- 进度条 -->
                  <div class="progress-container" @click="seekTo">
                    <div class="progress-bar">
                      <div class="progress-played" :style="{ width: progressPercent + '%' }"></div>
                      <div class="progress-thumb" :style="{ left: progressPercent + '%' }"></div>
                    </div>
                  </div>

                  <!-- 控制按钮 -->
                  <div class="controls-bar">
                    <div class="controls-left">
                      <!-- 播放/暂停 -->
                      <button class="control-btn play-btn" @click="togglePlay">
                        <i :class="isPlaying ? 'el-icon-video-pause' : 'el-icon-video-play'"></i>
                      </button>

                      <!-- 时间显示 -->
                      <span class="time-display">
                        {{ formatTime(currentTime) }} / {{ formatTime(duration) }}
                      </span>

                      <!-- 音量控制 -->
                      <div class="volume-control" @mouseenter="showVolumeSlider = true" @mouseleave="showVolumeSlider = false">
                        <button class="control-btn volume-btn" @click="toggleMute">
                          <i :class="volumeIcon"></i>
                        </button>
                        <div class="volume-slider" v-show="showVolumeSlider">
                          <input
                            type="range"
                            min="0"
                            max="1"
                            step="0.1"
                            v-model="volume"
                            @input="setVolume"
                            class="volume-range"
                          />
                          <span class="volume-text">{{ Math.round(volume * 100) }}%</span>
                        </div>
                      </div>
                    </div>

                    <div class="controls-right">
                      <!-- 倍速控制 -->
                      <div class="playback-rate" @mouseenter="showRateMenu = true" @mouseleave="showRateMenu = false">
                        <button class="control-btn rate-btn">{{ playbackRate }}x</button>
                        <div class="rate-menu" v-show="showRateMenu">
                          <div
                            v-for="rate in playbackRates"
                            :key="rate"
                            class="rate-item"
                            :class="{ active: rate === playbackRate }"
                            @click="setPlaybackRate(rate)"
                          >
                            {{ rate }}x
                          </div>
                        </div>
                      </div>

                      <!-- 全屏 -->
                      <button class="control-btn fullscreen-btn" @click="toggleFullscreen">
                        <i :class="isFullscreen ? 'el-icon-copy-document' : 'el-icon-full-screen'"></i>
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <el-empty
                v-if="!loading && !playerConfig.url"
                description="暂无视频资源"
                :image-size="120"
                class="empty-state"
              >
                <el-button type="primary" size="small" @click="goBack">返回课程</el-button>
              </el-empty>
            </div>
          </div>

          <!-- 上一个/下一个按钮 -->
          <div class="navigation-buttons">
            <el-button
              :disabled="!previousSection"
              @click="navigateToSection(previousSection)"
              icon="el-icon-arrow-left"
              size="medium"
            >
              上一小节
            </el-button>
            <el-checkbox v-model="autoPlayNext" class="auto-play-checkbox">
              自动连播
            </el-checkbox>
            <el-button
              :disabled="!nextSection"
              @click="navigateToSection(nextSection)"
              size="medium"
            >
              下一小节
              <i class="el-icon-arrow-right"></i>
            </el-button>
          </div>
        </div>

        <!-- 右侧：章节目录 -->
        <div class="catalog-section" v-show="catalogVisible">
          <div class="catalog-container">
            <div class="catalog-header">
              <h3>课程目录</h3>
              <el-button
                icon="el-icon-close"
                circle
                size="mini"
                @click="catalogVisible = false"
                class="close-catalog-btn"
              ></el-button>
            </div>
            <div class="catalog-content" v-loading="catalogLoading">
              <el-collapse v-model="activeCatalogChapter" accordion>
                <el-collapse-item
                  v-for="chapter in catalogData"
                  :key="chapter.id"
                  :name="chapter.id"
                  class="chapter-item"
                >
                  <template slot="title">
                    <div class="chapter-title">
                      <i class="el-icon-folder-opened"></i>
                      <span>{{ chapter.title }}</span>
                      <span class="section-count">({{ chapter.sections.length }}节)</span>
                    </div>
                  </template>
                  <div class="section-list">
                    <div
                      v-for="section in chapter.sections"
                      :key="section.id"
                      class="section-item"
                      :class="{ 'active': section.id === sectionId }"
                      @click="navigateToSection(section)"
                    >
                      <div class="section-info">
                        <i class="el-icon-video-play section-icon"></i>
                        <span class="section-name">{{ section.title }}</span>
                      </div>
                      <div class="section-meta">
                        <span v-if="section.duration" class="duration">
                          {{ formatDuration(section.duration) }}
                        </span>
                        <i v-if="section.id === sectionId" class="el-icon-check current-indicator"></i>
                      </div>
                    </div>
                  </div>
                </el-collapse-item>
              </el-collapse>
            </div>
          </div>
        </div>
      </div>

      <!-- 下部分：简介和评论 -->
      <div class="bottom-section">
        <div class="info-panel">
          <el-tabs v-model="activeTab" class="info-tabs">
            <!-- 简介标签 -->
            <el-tab-pane name="intro">
              <span slot="label">
                <i class="el-icon-document"></i>
                简介
              </span>
              <div class="tab-pane-content">
                <div v-if="sectionInfo.description" class="description-text">
                  {{ sectionInfo.description }}
                </div>
                <el-empty v-else description="暂无简介" :image-size="60"></el-empty>
              </div>
            </el-tab-pane>

            <!-- 评论标签 -->
            <el-tab-pane name="comments">
              <span slot="label">
                <i class="el-icon-chat-dot-round"></i>
                评论
                <el-badge
                  :value="commentList.length"
                  :max="99"
                  v-if="commentList.length > 0"
                ></el-badge>
              </span>
              <div class="tab-pane-content">
                <!-- 发表评论 -->
                <div class="comment-editor">
                  <el-input
                    type="textarea"
                    :rows="3"
                    placeholder="分享你的想法..."
                    v-model="newComment"
                    maxlength="500"
                    show-word-limit
                    class="comment-textarea"
                  ></el-input>
                  <div class="editor-footer">
                    <el-button
                      type="primary"
                      size="small"
                      @click="submitTopLevelComment"
                      :disabled="!newComment.trim()"
                    >
                      发布
                    </el-button>
                  </div>
                </div>

                <!-- 评论列表 -->
                <div class="comment-list" v-loading="commentLoading">
                  <div v-if="commentList.length > 0">
                    <div
                      v-for="comment in commentList"
                      :key="comment.id"
                      class="comment-item"
                    >
                      <!-- 父评论 -->
                      <div class="comment-main">
                        <el-avatar
                          :size="40"
                          :src="backendHost + comment.avatar"
                          class="avatar"
                        >
                          {{ comment.nickName ? comment.nickName.charAt(0) : '匿' }}
                        </el-avatar>
                        <div class="comment-content">
                          <div class="comment-meta">
                            <span class="username">{{ comment.nickName || '匿名用户' }}</span>
                            <span class="time">{{ parseTime(comment.createTime, '{y}-{m}-{d} {h}:{i}') }}</span>
                          </div>
                          <div class="comment-text">{{ comment.content }}</div>
                          <div class="comment-actions">
                            <el-button
                              type="text"
                              size="mini"
                              @click="showReplyBox(comment)"
                            >
                              <i class="el-icon-chat-line-round"></i>
                              回复
                            </el-button>
                            <span
                              v-if="comment.children && comment.children.length > 0"
                              class="reply-count"
                            >
                              {{ comment.children.length }} 条回复
                            </span>
                          </div>
                        </div>
                      </div>

                      <!-- 子评论 -->
                      <div
                        v-if="comment.children && comment.children.length > 0"
                        class="reply-list"
                      >
                        <div
                          v-for="child in comment.children"
                          :key="child.id"
                          class="reply-item"
                        >
                          <el-avatar
                            :size="32"
                            :src="backendHost + child.avatar"
                            class="avatar"
                          >
                            {{ child.nickName ? child.nickName.charAt(0) : '匿' }}
                          </el-avatar>
                          <div class="reply-content">
                            <div class="reply-meta">
                              <span class="username">{{ child.nickName || '匿名用户' }}</span>
                              <span class="time">{{ parseTime(child.createTime, '{y}-{m}-{d} {h}:{i}') }}</span>
                            </div>
                            <div class="reply-text">{{ child.content }}</div>
                            <el-button
                              type="text"
                              size="mini"
                              @click="showReplyBox(comment, child)"
                              class="reply-btn"
                            >
                              <i class="el-icon-chat-line-round"></i>
                              回复
                            </el-button>
                          </div>
                        </div>
                      </div>

                      <!-- 回复输入框 -->
                      <div v-if="replyingTo.parentId === comment.id" class="reply-editor">
                        <el-input
                          v-model="replyingTo.content"
                          type="textarea"
                          :rows="2"
                          :placeholder="replyingTo.placeholder"
                          ref="replyInput"
                          maxlength="500"
                          show-word-limit
                        ></el-input>
                        <div class="editor-actions">
                          <el-button size="small" @click="cancelReply">取消</el-button>
                          <el-button
                            type="primary"
                            size="small"
                            @click="submitReply"
                            :disabled="!replyingTo.content.trim()"
                          >
                            发布
                          </el-button>
                        </div>
                      </div>
                    </div>
                  </div>
                  <el-empty
                    v-else
                    description="还没有评论，快来抢沙发吧！"
                    :image-size="80"
                  ></el-empty>
                </div>
              </div>
            </el-tab-pane>
          </el-tabs>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Player from 'xgplayer-vue';
import 'xgplayer/dist/index.min.css';
import { getSection, listSection } from "@/api/system/section";
import { listChapter } from "@/api/system/chapter";
import { getCommentTree, addComment } from "@/api/system/comment";
import { findBehaviorByStudentAndVideo, upsertBehavior } from "@/api/system/behavior";

export default {
  name: "SectionPlayer",
  components: { Player },
  data() {
    return {
      loading: true,
      commentLoading: false,
      sectionId: null,
      courseName: '',
      courseId: null,
      sectionInfo: {},
      activeTab: 'intro',
      // 自定义视频播放器数据
      playerConfig: {
        url: ''
      },
      isPlaying: false,
      currentTime: 0,
      duration: 0,
      volume: 0.6,
      isMuted: false,
      playbackRate: 1,
      playbackRates: [0.5, 0.75, 1, 1.25, 1.5, 2],
      isFullscreen: false,
      controlsVisible: true,
      showVolumeSlider: false,
      showRateMenu: false,
      controlsTimer: null,
      totalDuration: 0,
      newComment: '',
      commentList: [],
      backendHost: process.env.VUE_APP_BASE_API,
      replyingTo: {
        parentId: null,
        content: '',
        placeholder: ''
      },
      // 章节目录相关
      catalogVisible: true, // 默认显示目录
      catalogLoading: false,
      catalogData: [], // 章节和小节数据
      activeCatalogChapter: null,
      allSections: [], // 所有小节的扁平列表
      autoPlayNext: true, // 自动连播
      // 学习行为记录相关数据
      learningBehavior: {
        id: null,
        studentId: null,
        videoId: null,
        watchDuration: 0,
        videoDuration: 0,
        completionRate: 0.0,
        watchCount: 0,
        isCompleted: 0,
        fastForwardCount: 0,
        pauseCount: 0,
        playbackSpeed: 1.0,
        firstWatchAt: null,
        lastWatchAt: null,
        lastPosition: 0
      },
      lastSaveTime: 0,
      saveInterval: 10, // 每10秒保存一次
      hasStartedWatching: false,
      learningBehaviorLoaded: false // 标记学习记录是否已加载
    };
  },
  created() {
    // 初始化学习行为的学生ID
    this.learningBehavior.studentId = this.$store.getters.id;

    const sectionIdFromRoute = this.$route.params && this.$route.params.sectionId;
    if (sectionIdFromRoute) {
      this.sectionId = parseInt(sectionIdFromRoute);
      console.log("🚀 组件创建 - sectionId:", this.sectionId);
      this.courseName = this.$route.query && this.$route.query.courseName;
      this.courseId = this.$route.query && this.$route.query.courseId;
      this.getSectionDetails();
      this.loadComments();
      this.loadCourseCatalog(); // 加载课程目录
      // 注意：不在这里调用 loadExistingLearningBehavior，让 getSectionDetails 调用
    } else {
      this.$modal.msgError("无效的小节ID");
    }
  },

  beforeDestroy() {
    // 页面销毁前保存学习行为
    if (this.learningBehavior.id || this.hasStartedWatching) {
      this.saveLearningBehavior();
    }
  },
  computed: {
    progressPercent() {
      return this.duration > 0 ? (this.currentTime / this.duration) * 100 : 0;
    },
    volumeIcon() {
      if (this.isMuted || this.volume === 0) {
        return 'el-icon-mute';
      } else if (this.volume < 0.5) {
        return 'el-icon-turn-off-microphone';
      } else {
        return 'el-icon-microphone';
      }
    },
    // 当前小节在所有小节中的索引
    currentSectionIndex() {
      return this.allSections.findIndex(s => s.id === this.sectionId);
    },
    // 上一个小节
    previousSection() {
      if (this.currentSectionIndex > 0) {
        return this.allSections[this.currentSectionIndex - 1];
      }
      return null;
    },
    // 下一个小节
    nextSection() {
      if (this.currentSectionIndex >= 0 && this.currentSectionIndex < this.allSections.length - 1) {
        return this.allSections[this.currentSectionIndex + 1];
      }
      return null;
    }
  },
  watch: {
    '$route.params.sectionId': {
      async handler(newSectionId, oldSectionId) {
        if (newSectionId && newSectionId !== oldSectionId) {
          // 保存当前视频的学习进度
          if (this.learningBehavior.id || this.hasStartedWatching) {
            await this.saveLearningBehavior();
          }

          // 路由参数变化时，重新加载数据
          this.sectionId = parseInt(newSectionId);
          this.resetPlayerState();
          this.getSectionDetails();
          this.loadComments();
          this.loadCourseCatalog();
          // 注意：不在这里调用 loadExistingLearningBehavior，让 getSectionDetails 调用
        }
      },
      immediate: false
    }
  },
  beforeDestroy() {
    if (this.controlsTimer) {
      clearTimeout(this.controlsTimer);
    }
  },
  methods: {
    // 重置播放器状态
    resetPlayerState() {
      this.sectionInfo = {};
      this.playerConfig.url = '';
      this.currentTime = 0;
      this.duration = 0;
      this.isPlaying = false;
      this.hasStartedWatching = false;
      this.learningBehaviorLoaded = false; // 重置加载标志

      // 重置学习行为
      this.learningBehavior = {
        id: null,
        studentId: this.$store.getters.id,
        videoId: null,
        watchDuration: 0,
        videoDuration: 0,
        completionRate: 0.0,
        watchCount: 0,
        isCompleted: 0,
        fastForwardCount: 0,
        pauseCount: 0,
        playbackSpeed: 1.0,
        firstWatchAt: null,
        lastWatchAt: null,
        lastPosition: 0
      };
    },
    goBack() {
      this.$router.go(-1);
    },

    formatDuration(seconds) {
      if (!seconds && seconds !== 0) return '未知';
      seconds = Math.floor(seconds);
      const h = Math.floor(seconds / 3600);
      const m = Math.floor((seconds % 3600) / 60);
      const s = seconds % 60;
      if (h > 0) {
        return `${h}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
      }
      return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
    },

    formatTime(seconds) {
      if (!seconds && seconds !== 0) return '00:00';
      seconds = Math.floor(seconds);
      const m = Math.floor(seconds / 60);
      const s = seconds % 60;
      return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
    },

    // 自定义视频播放器方法
    async onVideoLoaded() {
      const video = this.$refs.videoPlayer;
      if (!video) return;
      this.duration = video.duration;
      this.totalDuration = video.duration;
      video.volume = this.volume;
      video.playbackRate = this.playbackRate;

      // 等待学习记录加载完成（最多等待2秒）
      let waitCount = 0;
      while (!this.learningBehaviorLoaded && waitCount < 20) {
        await new Promise(resolve => setTimeout(resolve, 100));
        waitCount++;
      }

      // 处理时间跳转（URL参数或上次观看位置）
      this.handleTimeJump();
    },

    // 处理时间跳转逻辑
    handleTimeJump() {
      const video = this.$refs.videoPlayer;
      if (!video) return;

      // 优先使用URL中的时间参数
      const timeParam = this.$route.query.t;
      if (timeParam && !isNaN(timeParam)) {
        const jumpTime = parseInt(timeParam);
        console.log(`🎯 跳转到URL指定时间: ${jumpTime}秒`);
        video.currentTime = jumpTime;
        this.currentTime = jumpTime;

        // 清除URL参数，避免下次切换视频时再次跳转
        this.$router.replace({
          path: this.$route.path,
          query: {
            courseName: this.$route.query.courseName,
            courseId: this.$route.query.courseId
          }
        });
        return;
      }

      // 其次使用学习记录中的上次观看位置（仅当videoId匹配时）
      if (this.learningBehavior &&
          this.learningBehavior.videoId === this.sectionId &&
          this.learningBehavior.lastPosition > 0) {
        const lastPosition = this.learningBehavior.lastPosition;
        console.log(`🎯 跳转到上次观看位置: ${lastPosition}秒`);
        video.currentTime = lastPosition;
        this.currentTime = lastPosition;

        // 显示提示信息
        this.$message({
          message: `已跳转到上次观看位置: ${this.formatTime(lastPosition)}`,
          type: 'info',
          duration: 3000
        });
      }
    },

    onTimeUpdate() {
      const video = this.$refs.videoPlayer;
      if (!video) return;

      this.currentTime = video.currentTime;

      // 记录学习行为
      this.updateLearningProgress();
    },

    onVideoEnded() {
      this.isPlaying = false;

      // 标记视频为已完成
      this.markVideoCompleted();

      // 自动播放下一个视频
      if (this.autoPlayNext && this.nextSection) {
        this.$message.success('视频播放完成！3秒后自动播放下一小节...');
        setTimeout(() => {
          this.navigateToSection(this.nextSection);
        }, 3000);
      } else {
        this.$message.success('视频播放完成！');
      }
    },

    togglePlay() {
      const video = this.$refs.videoPlayer;
      if (!video) return;
      if (video.paused) {
        video.play();
        this.isPlaying = true;
      } else {
        video.pause();
        this.isPlaying = false;
        // 记录暂停次数
        this.learningBehavior.pauseCount = (this.learningBehavior.pauseCount || 0) + 1;
      }
    },

    seekTo(event) {
      const progressContainer = event.currentTarget;
      const rect = progressContainer.getBoundingClientRect();
      const percent = (event.clientX - rect.left) / rect.width;
      const video = this.$refs.videoPlayer;
      if (!video) return;

      const oldTime = video.currentTime;
      const newTime = percent * this.duration;

      // 如果跳转超过5秒，记录为快进
      if (Math.abs(newTime - oldTime) > 5) {
        this.learningBehavior.fastForwardCount = (this.learningBehavior.fastForwardCount || 0) + 1;
      }

      video.currentTime = newTime;
    },

    setVolume() {
      const video = this.$refs.videoPlayer;
      if (!video) return;
      video.volume = this.volume;
      this.isMuted = this.volume === 0;
    },

    toggleMute() {
      const video = this.$refs.videoPlayer;
      if (!video) return;
      if (this.isMuted) {
        video.volume = this.volume;
        this.isMuted = false;
      } else {
        video.volume = 0;
        this.isMuted = true;
      }
    },

    setPlaybackRate(rate) {
      const video = this.$refs.videoPlayer;
      if (!video) return;
      video.playbackRate = rate;
      this.playbackRate = rate;
      this.showRateMenu = false;

      // 记录播放倍速
      this.learningBehavior.playbackSpeed = rate;
    },

    toggleFullscreen() {
      const video = this.$refs.videoPlayer;
      if (!video) return;
      const container = video.parentElement;
      if (!document.fullscreenElement) {
        container.requestFullscreen();
        this.isFullscreen = true;
      } else {
        document.exitFullscreen();
        this.isFullscreen = false;
      }
    },

    showControls() {
      this.controlsVisible = true;
      if (this.controlsTimer) {
        clearTimeout(this.controlsTimer);
      }
    },

    hideControls() {
      this.controlsTimer = setTimeout(() => {
        this.controlsVisible = false;
      }, 3000);
    },

    onPlayerReady() {
      // 保留原有的xgplayer相关代码以防需要
      console.log('✅ 播放器已准备就绪');
    },

    processVideoUrl(videoUrl) {
      if (!videoUrl) return '';
      if (videoUrl.startsWith('http://') || videoUrl.startsWith('https://')) {
        return videoUrl;
      }
      try {
        videoUrl = decodeURIComponent(videoUrl);
      } catch (e) {
        console.warn('URL解码失败，使用原始URL:', e);
      }
      return this.backendHost + videoUrl;
    },

    async getSectionDetails() {
      this.loading = true;
      try {
        const response = await getSection(this.sectionId);
        this.sectionInfo = response.data;

        // 如果没有courseId，从sectionInfo中获取
        if (!this.courseId && this.sectionInfo.chapterId) {
          // 通过chapterId获取courseId
          await this.getCourseIdFromChapter(this.sectionInfo.chapterId);
        }

        const videoPath = this.sectionInfo.videoUrl || '';
        if (videoPath) {
          this.playerConfig.url = this.processVideoUrl(videoPath);
          // 加载已存在的学习行为记录
          await this.loadExistingLearningBehavior();
        } else {
          console.warn('⚠️ 该小节没有视频URL');
        }
      } catch (error) {
        console.error("❌ 加载小节信息失败:", error);
        this.$modal.msgError("加载小节信息失败");
      } finally {
        this.loading = false;
      }
    },

    async getCourseIdFromChapter(chapterId) {
      try {
        const response = await listChapter({ id: chapterId, pageNum: 1, pageSize: 1 });
        if (response.rows && response.rows.length > 0) {
          this.courseId = response.rows[0].courseId;
        }
      } catch (error) {
        console.error("获取课程ID失败:", error);
      }
    },

    // 加载课程目录
    async loadCourseCatalog() {
      // 如果没有courseId，等待getSectionDetails完成
      if (!this.courseId) {
        setTimeout(() => this.loadCourseCatalog(), 500);
        return;
      }

      this.catalogLoading = true;
      try {
        const [chapterRes, sectionRes] = await Promise.all([
          listChapter({ courseId: this.courseId, pageNum: 1, pageSize: 999 }),
          listSection({ courseId: this.courseId, pageNum: 1, pageSize: 999 })
        ]);

        const chapters = chapterRes.rows || [];
        const sections = sectionRes.rows || [];

        // 构建章节树结构
        this.catalogData = chapters.map(chapter => ({
          ...chapter,
          sections: sections
            .filter(section => String(section.chapterId) === String(chapter.id))
            .sort((a, b) => a.sortOrder - b.sortOrder),
        })).sort((a, b) => a.sortOrder - b.sortOrder);

        // 构建所有小节的扁平列表（用于上一个/下一个导航）
        this.allSections = [];
        this.catalogData.forEach(chapter => {
          this.allSections.push(...chapter.sections);
        });

        // 展开当前小节所在的章节
        const currentSection = sections.find(s => s.id === this.sectionId);
        if (currentSection) {
          this.activeCatalogChapter = currentSection.chapterId;
        }

        console.log('📚 课程目录加载完成:', this.catalogData);
      } catch (error) {
        console.error("加载课程目录失败:", error);
      } finally {
        this.catalogLoading = false;
      }
    },

    // 导航到指定小节
    async navigateToSection(section) {
      if (!section || section.id === this.sectionId) return;

      // 保存当前学习进度
      if (this.learningBehavior.id || this.hasStartedWatching) {
        await this.saveLearningBehavior();
      }

      // 跳转到新小节（路由跳转会触发组件重新创建，自动调用created钩子）
      this.$router.push({
        path: `/course/section/${section.id}`,
        query: {
          courseName: this.courseName,
          courseId: this.courseId
        }
      });
    },

    async loadComments() {
      this.commentLoading = true;
      try {
        const response = await getCommentTree(this.sectionId);
        this.commentList = response.data;
      } catch (error) {
        console.error("加载评论失败:", error);
      } finally {
        this.commentLoading = false;
      }
    },

    async submitTopLevelComment() {
      if (!this.newComment.trim()) {
        this.$modal.msgWarning("评论内容不能为空");
        return;
      }
      try {
        await addComment({
          sectionId: this.sectionId,
          content: this.newComment,
          parentId: null
        });
        this.$modal.msgSuccess("评论成功");
        this.newComment = '';
        this.loadComments();
      } catch (error) {
        console.error("发布评论失败:", error);
      }
    },

    showReplyBox(parentComment, targetUser = null) {
      this.replyingTo.parentId = parentComment.id;
      this.replyingTo.content = '';
      const replyToName = targetUser ? targetUser.nickName : parentComment.nickName;
      this.replyingTo.placeholder = `回复 @${replyToName || '匿名用户'}`;
      this.$nextTick(() => {
        if (this.$refs.replyInput && this.$refs.replyInput[0]) {
          this.$refs.replyInput[0].focus();
        }
      });
    },

    cancelReply() {
      this.replyingTo.parentId = null;
      this.replyingTo.content = '';
      this.replyingTo.placeholder = '';
    },

    async submitReply() {
      if (!this.replyingTo.content.trim()) {
        this.$modal.msgWarning("回复内容不能为空");
        return;
      }
      try {
        await addComment({
          sectionId: this.sectionId,
          content: this.replyingTo.content,
          parentId: this.replyingTo.parentId
        });
        this.$modal.msgSuccess("回复成功");
        this.cancelReply();
        this.loadComments();
      } catch (error) {
        console.error("回复失败:", error);
      }
    },

    // ==================== 学习行为记录相关方法 ====================

    updateLearningProgress() {
      if (!this.hasStartedWatching) {
        this.hasStartedWatching = true;
        this.learningBehavior.firstWatchAt = new Date();
        this.learningBehavior.watchCount = (this.learningBehavior.watchCount || 0) + 1;

        // 确保student_id和video_id被设置
        if (!this.learningBehavior.studentId) {
          this.learningBehavior.studentId = this.$store.getters.id;
        }
        if (!this.learningBehavior.videoId) {
          this.learningBehavior.videoId = this.sectionId;
        }

        console.log("🎬 开始观看视频:", {
          sectionId: this.sectionId,
          videoId: this.learningBehavior.videoId,
          studentId: this.learningBehavior.studentId
        });
      }

      const currentTime = Math.floor(this.currentTime);
      this.learningBehavior.lastPosition = currentTime;
      this.learningBehavior.lastWatchAt = new Date();

      // 计算观看时长和完成率
      if (this.totalDuration > 0) {
        this.learningBehavior.videoDuration = Math.floor(this.totalDuration);
        this.learningBehavior.watchDuration = Math.max(
          this.learningBehavior.watchDuration || 0,
          currentTime
        );
        this.learningBehavior.completionRate = Math.min(
          100,
          (this.learningBehavior.watchDuration / this.learningBehavior.videoDuration) * 100
        );
      }

      // 每10秒保存一次
      if (currentTime - this.lastSaveTime >= this.saveInterval) {
        this.saveLearningBehavior();
        this.lastSaveTime = currentTime;
      }
    },

    async markVideoCompleted() {
      this.learningBehavior.isCompleted = 1;
      this.learningBehavior.completionRate = 100;
      this.learningBehavior.watchDuration = this.learningBehavior.videoDuration;
      await this.saveLearningBehavior();
    },

    // 加载已存在的学习行为记录
    async loadExistingLearningBehavior() {
      try {
        const studentId = this.$store.getters.id;
        const videoId = this.sectionId;

        if (!studentId || !videoId) {
          console.log("⚠️ 用户ID或视频ID无效，跳过加载已存在的学习记录", { studentId, videoId });
          return;
        }

        console.log("🔍 查询已存在的学习记录:", { studentId, videoId, currentSectionId: this.sectionId });

        // 使用专门的API查询该学生对该视频的学习记录
        const response = await findBehaviorByStudentAndVideo(studentId, videoId);

        if (response.data) {
          // 找到已存在的记录，使用它
          const existingRecord = response.data;
          console.log("✅ 找到已存在的学习记录:", existingRecord);
          console.log("📌 记录的videoId:", existingRecord.videoId, "当前sectionId:", this.sectionId);

          this.learningBehavior = {
            id: existingRecord.id,
            studentId: existingRecord.studentId,
            videoId: existingRecord.videoId,
            watchDuration: existingRecord.watchDuration || 0,
            videoDuration: existingRecord.videoDuration || 0,
            completionRate: existingRecord.completionRate || 0.0,
            watchCount: existingRecord.watchCount || 0,
            isCompleted: existingRecord.isCompleted || 0,
            fastForwardCount: existingRecord.fastForwardCount || 0,
            pauseCount: existingRecord.pauseCount || 0,
            playbackSpeed: existingRecord.playbackSpeed || 1.0,
            firstWatchAt: existingRecord.firstWatchAt,
            lastWatchAt: existingRecord.lastWatchAt,
            lastPosition: existingRecord.lastPosition || 0
          };

          // 如果有上次观看位置，可以考虑跳转到该位置
          if (existingRecord.lastPosition > 0) {
            console.log("检测到上次观看位置:", existingRecord.lastPosition);
            // 可以在这里添加询问用户是否要跳转到上次位置的逻辑
          }
        } else {
          console.log("📝 未找到已存在的学习记录，将创建新记录");
          console.log("📌 新记录的videoId将设置为:", videoId, "sectionId:", this.sectionId);
          // 初始化新记录
          this.learningBehavior.studentId = studentId;
          this.learningBehavior.videoId = videoId;
        }
      } catch (error) {
        console.error("加载已存在的学习记录失败:", error);
        // 即使加载失败，也要确保基本字段被设置
        this.learningBehavior.studentId = this.$store.getters.id;
        this.learningBehavior.videoId = this.sectionId;
      } finally {
        // 标记学习记录已加载完成
        this.learningBehaviorLoaded = true;
      }
    },

    async saveLearningBehavior() {
      try {
        // 确保必需字段都有值
        if (!this.learningBehavior.studentId) {
          this.learningBehavior.studentId = this.$store.getters.id;
        }

        if (!this.learningBehavior.videoId) {
          this.learningBehavior.videoId = this.sectionId;
          console.warn("⚠️ videoId 为空，使用 sectionId:", this.sectionId);
        }

        // 验证必需字段
        if (!this.learningBehavior.studentId || !this.learningBehavior.videoId) {
          console.error("❌ 缺少必需字段:", {
            studentId: this.learningBehavior.studentId,
            videoId: this.learningBehavior.videoId,
            sectionId: this.sectionId
          });
          return;
        }

        console.log("💾 准备保存学习行为 - sectionId:", this.sectionId, "videoId:", this.learningBehavior.videoId);

        // 准备保存的数据
        const behaviorData = {
          id: this.learningBehavior.id,
          studentId: this.learningBehavior.studentId,
          videoId: this.learningBehavior.videoId,
          watchDuration: this.learningBehavior.watchDuration || 0,
          videoDuration: this.learningBehavior.videoDuration || 0,
          completionRate: this.learningBehavior.completionRate || 0.0,
          watchCount: this.learningBehavior.watchCount || 1,
          isCompleted: this.learningBehavior.isCompleted || 0,
          fastForwardCount: this.learningBehavior.fastForwardCount || 0,
          pauseCount: this.learningBehavior.pauseCount || 0,
          playbackSpeed: this.learningBehavior.playbackSpeed || 1.0,
          firstWatchAt: this.learningBehavior.firstWatchAt,
          lastWatchAt: this.learningBehavior.lastWatchAt,
          lastPosition: this.learningBehavior.lastPosition || 0
        };

        console.log("保存学习行为数据:", behaviorData);

        // 使用UPSERT操作，自动处理插入或更新
        console.log("使用UPSERT操作保存学习行为");
        const response = await upsertBehavior(behaviorData);

        // 如果是新创建的记录，获取生成的ID
        if (response.data && !this.learningBehavior.id) {
          this.learningBehavior.id = response.data;
          console.log("UPSERT操作完成，记录ID:", response.data);
        } else {
          console.log("UPSERT操作完成，更新了现有记录");
        }
      } catch (error) {
        console.error("保存学习行为失败:", error);
        console.error("失败时的数据:", this.learningBehavior);
      }
    }
  }
};
</script>
<style lang="scss" scoped>
.section-player-page {
  min-height: 100vh;
  background: #f5f6f8;

  /* ==================== 顶部导航栏 ==================== */
  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 24px;
    background: #fff;
    border-bottom: 1px solid #e8eaec;
    position: sticky;
    top: 0;
    z-index: 100;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);

    .header-left {
      display: flex;
      align-items: center;
      gap: 16px;
      flex: 1;
      min-width: 0;

      .back-btn {
        flex-shrink: 0;
        width: 36px;
        height: 36px;
        border: 1px solid #dcdfe6;
        background: #fff;
        color: #606266;
        font-size: 16px;
        transition: all 0.3s;
        cursor: pointer;

        ::v-deep i {
          color: #606266;
          font-size: 16px;
          font-weight: bold;
        }

        &:hover {
          border-color: #409eff;
          color: #409eff;
          background: #ecf5ff;
          transform: translateX(-2px);

          ::v-deep i {
            color: #409eff;
          }
        }

        &:active {
          transform: translateX(-3px);
        }
      }

      .breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        color: #606266;
        overflow: hidden;

        .course-name {
          font-weight: 500;
          color: #909399;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          max-width: 200px;
        }

        .divider {
          font-size: 12px;
          color: #c0c4cc;
          flex-shrink: 0;
        }

        .section-title {
          color: #303133;
          font-weight: 600;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
      }
    }

    .header-right {
      display: flex;
      align-items: center;
      gap: 12px;
      flex-shrink: 0;

      .catalog-toggle-btn {
        background: #409eff;
        color: #fff;
        border: none;

        &:hover {
          background: #66b1ff;
        }
      }

      .duration-info {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        color: #909399;
        padding: 6px 12px;
        background: #f5f7fa;
        border-radius: 4px;

        i {
          font-size: 14px;
          color: #409eff;
        }
      }
    }
  }

  /* ==================== 主内容区 ==================== */
  .main-content {
    max-width: 1600px;
    margin: 0 auto;
    padding: 24px;
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  /* ==================== 上部分：视频和目录 ==================== */
  .top-section {
    display: flex;
    gap: 20px;
    align-items: flex-start;

    &.catalog-hidden {
      .video-section {
        width: 100%;
      }
    }
  }

  /* ==================== 视频区域 ==================== */
  .video-section {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  /* ==================== 下部分：简介和评论 ==================== */
  .bottom-section {
    width: 100%;
  }

  /* ==================== 自定义视频播放器 ==================== */
  .video-container {
    background: #000;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);

    .video-wrapper {
      position: relative;
      width: 100%;
      padding-top: 56.25%;

      .custom-video-player {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: #000;

        .video-element {
          width: 100%;
          height: 100%;
          object-fit: contain;
          background: #000;
        }

        .custom-controls {
          position: absolute;
          bottom: 0;
          left: 0;
          right: 0;
          background: linear-gradient(to top, rgba(0, 0, 0, 0.8) 0%, transparent 100%);
          padding: 12px;
          opacity: 0;
          transition: opacity 0.3s ease;

          &.controls-visible {
            opacity: 1;
          }

          &:hover {
            opacity: 1;
          }
        }

        &:hover .custom-controls {
          opacity: 1;
        }

        &:mousemove {
          .custom-controls {
            opacity: 1;
          }
        }
      }

      .empty-state {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #000;
      }
    }

    /* ========== 自定义控制栏样式 ========== */

    .progress-container {
      margin-bottom: 8px;
      cursor: pointer;

      .progress-bar {
        position: relative;
        height: 4px;
        background: rgba(255, 255, 255, 0.3);
        border-radius: 2px;
        overflow: hidden;

        .progress-played {
          height: 100%;
          background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
          border-radius: 2px;
          transition: width 0.1s ease;
        }

        .progress-thumb {
          position: absolute;
          top: 50%;
          width: 12px;
          height: 12px;
          background: #fff;
          border-radius: 50%;
          transform: translate(-50%, -50%);
          box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
          opacity: 0;
          transition: opacity 0.2s ease;
        }

        &:hover .progress-thumb {
          opacity: 1;
        }
      }
    }

    .controls-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      height: 36px;

      .controls-left,
      .controls-right {
        display: flex;
        align-items: center;
        gap: 12px;
      }

      .control-btn {
        background: none;
        border: none;
        color: #fff;
        cursor: pointer;
        padding: 6px;
        border-radius: 4px;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        min-width: 32px;
        height: 32px;

        &:hover {
          background: rgba(255, 255, 255, 0.2);
          transform: scale(1.1);
        }

        i {
          font-size: 16px;
        }
      }

      .time-display {
        color: #fff;
        font-size: 13px;
        font-family: 'Courier New', monospace;
        white-space: nowrap;
        padding: 0 8px;
      }

      .volume-control {
        position: relative;
        display: flex;
        align-items: center;

        .volume-slider {
          position: absolute;
          left: 100%;
          top: 50%;
          transform: translateY(-50%);
          margin-left: 8px;
          padding: 8px 12px;
          background: rgba(0, 0, 0, 0.9);
          border-radius: 20px;
          display: flex;
          align-items: center;
          gap: 8px;
          white-space: nowrap;
          box-shadow: 0 2px 12px rgba(0, 0, 0, 0.4);

          .volume-range {
            width: 60px;
            height: 4px;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 2px;
            outline: none;
            cursor: pointer;

            &::-webkit-slider-thumb {
              appearance: none;
              width: 12px;
              height: 12px;
              background: #fff;
              border-radius: 50%;
              cursor: pointer;
              box-shadow: 0 1px 4px rgba(0, 0, 0, 0.3);
            }

            &::-moz-range-thumb {
              width: 12px;
              height: 12px;
              background: #fff;
              border-radius: 50%;
              cursor: pointer;
              border: none;
              box-shadow: 0 1px 4px rgba(0, 0, 0, 0.3);
            }
          }

          .volume-text {
            color: #fff;
            font-size: 12px;
            min-width: 30px;
            text-align: center;
          }
        }
      }

      .playback-rate {
        position: relative;

        .rate-btn {
          min-width: 40px;
          font-size: 13px;
          font-weight: 500;
        }

        .rate-menu {
          position: absolute;
          bottom: 100%;
          left: 50%;
          transform: translateX(-50%);
          margin-bottom: 8px;
          background: rgba(0, 0, 0, 0.9);
          border-radius: 8px;
          padding: 4px 0;
          box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4);
          min-width: 60px;

          .rate-item {
            padding: 8px 16px;
            color: #fff;
            font-size: 13px;
            cursor: pointer;
            text-align: center;
            transition: background 0.2s ease;

            &:hover {
              background: rgba(255, 255, 255, 0.1);
            }

            &.active {
              color: #667eea;
              background: rgba(102, 126, 234, 0.2);
              font-weight: 600;
            }
          }
        }
      }
    }
  }

  /* ==================== 导航按钮 ==================== */
  .navigation-buttons {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);

    .auto-play-checkbox {
      ::v-deep .el-checkbox__label {
        font-size: 14px;
        color: #606266;
      }
    }

    .el-button {
      min-width: 120px;
    }
  }

  /* ==================== 章节目录 ==================== */
  .catalog-section {
    width: 320px;
    flex-shrink: 0;
    align-self: stretch;
  }

  .catalog-container {
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    height: 100%;
    display: flex;
    flex-direction: column;
  }

  .catalog-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 20px;
    border-bottom: 1px solid #e8eaec;
    background: #fafafa;

    h3 {
      margin: 0;
      font-size: 16px;
      font-weight: 600;
      color: #303133;
    }

    .close-catalog-btn {
      background: transparent;
      border: 1px solid #dcdfe6;

      &:hover {
        background: #f5f7fa;
        border-color: #409eff;
        color: #409eff;
      }
    }
  }

  .catalog-content {
    flex: 1;
    overflow-y: auto;
    padding: 12px;
    max-height: 600px;

    &::-webkit-scrollbar {
      width: 6px;
    }

    &::-webkit-scrollbar-thumb {
      background: #dcdfe6;
      border-radius: 3px;

      &:hover {
        background: #c0c4cc;
      }
    }

    .el-collapse {
      border: none;
    }

    ::v-deep .el-collapse-item {
      margin-bottom: 8px;
      border: 1px solid #e8eaec;
      border-radius: 6px;
      overflow: hidden;

      &:last-child {
        margin-bottom: 0;
      }

      .el-collapse-item__header {
        background: #fafafa;
        border: none;
        padding: 0 16px;
        height: 48px;
        line-height: 48px;
        font-weight: 500;

        &:hover {
          background: #f0f2f5;
        }

        &.is-active {
          background: #ecf5ff;
          color: #409eff;
        }
      }

      .el-collapse-item__wrap {
        border: none;
        background: #fff;
      }

      .el-collapse-item__content {
        padding: 0;
      }
    }

    .chapter-title {
      display: flex;
      align-items: center;
      gap: 8px;
      width: 100%;

      i {
        font-size: 16px;
        color: #409eff;
      }

      span {
        flex: 1;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .section-count {
        font-size: 12px;
        color: #909399;
        font-weight: normal;
      }
    }

    .section-list {
      .section-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 16px;
        cursor: pointer;
        transition: all 0.2s;
        border-bottom: 1px solid #f0f0f0;

        &:last-child {
          border-bottom: none;
        }

        &:hover {
          background: #f5f7fa;
        }

        &.active {
          background: #ecf5ff;
          border-left: 3px solid #409eff;

          .section-name {
            color: #409eff;
            font-weight: 600;
          }

          .section-icon {
            color: #409eff;
          }
        }

        .section-info {
          display: flex;
          align-items: center;
          gap: 8px;
          flex: 1;
          min-width: 0;

          .section-icon {
            font-size: 14px;
            color: #909399;
            flex-shrink: 0;
          }

          .section-name {
            font-size: 14px;
            color: #606266;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
          }
        }

        .section-meta {
          display: flex;
          align-items: center;
          gap: 8px;
          flex-shrink: 0;

          .duration {
            font-size: 12px;
            color: #909399;
          }

          .current-indicator {
            color: #67c23a;
            font-size: 16px;
          }
        }
      }
    }
  }

  /* ==================== 信息面板 ==================== */
  .info-panel {
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    overflow: hidden;
    width: 100%;
  }

  .info-tabs {
      ::v-deep .el-tabs__header {
        margin: 0;
        padding: 0 24px;
        background: #fafafa;
        border-bottom: 1px solid #e8eaec;
      }

      ::v-deep .el-tabs__nav-wrap::after {
        display: none;
      }

      ::v-deep .el-tabs__item {
        height: 50px;
        line-height: 50px;
        font-size: 14px;
        color: #606266;
        padding: 0 20px;

        i {
          margin-right: 6px;
        }

        .el-badge {
          margin-left: 6px;
        }

        &:hover {
          color: #409eff;
        }

        &.is-active {
          color: #409eff;
          font-weight: 600;
        }
      }

      ::v-deep .el-tabs__active-bar {
        height: 3px;
        background: #409eff;
      }
    }

    .tab-pane-content {
      padding: 24px;
    }

    .description-text {
      font-size: 14px;
      line-height: 1.8;
      color: #606266;
      white-space: pre-wrap;
    }
  }

  /* ==================== 评论编辑器 ==================== */
  .comment-editor {
    margin-bottom: 24px;

    .comment-textarea {
      ::v-deep .el-textarea__inner {
        border-radius: 6px;
        font-size: 14px;
        line-height: 1.6;
        padding: 12px;

        &:focus {
          border-color: #409eff;
          box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.1);
        }
      }
    }

    .editor-footer {
      display: flex;
      justify-content: flex-end;
      margin-top: 12px;
    }
  }

  /* ==================== 评论列表 ==================== */
  .comment-list {
    .comment-item {
      padding: 20px 0;
      border-bottom: 1px solid #f0f0f0;

      &:last-child {
        border-bottom: none;
      }

      .comment-main {
        display: flex;
        gap: 12px;

        .avatar {
          flex-shrink: 0;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: #fff;
          font-weight: 600;
        }

        .comment-content {
          flex: 1;
          min-width: 0;

          .comment-meta {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 8px;

            .username {
              font-size: 14px;
              font-weight: 600;
              color: #303133;
            }

            .time {
              font-size: 12px;
              color: #909399;
            }
          }

          .comment-text {
            font-size: 14px;
            line-height: 1.6;
            color: #606266;
            margin-bottom: 8px;
            word-wrap: break-word;
          }

          .comment-actions {
            display: flex;
            align-items: center;
            gap: 16px;

            .el-button {
              padding: 0;
              font-size: 13px;
              color: #909399;

              &:hover {
                color: #409eff;
              }

              i {
                margin-right: 4px;
              }
            }

            .reply-count {
              font-size: 12px;
              color: #c0c4cc;
            }
          }
        }
      }

      .reply-list {
        margin-top: 16px;
        padding-left: 52px;
        background: #fafafa;
        border-radius: 6px;
        padding: 16px;

        .reply-item {
          display: flex;
          gap: 10px;
          padding: 12px 0;

          &:first-child {
            padding-top: 0;
          }

          &:last-child {
            padding-bottom: 0;
          }

          .avatar {
            flex-shrink: 0;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: #fff;
            font-weight: 600;
          }

          .reply-content {
            flex: 1;
            min-width: 0;

            .reply-meta {
              display: flex;
              align-items: center;
              gap: 8px;
              margin-bottom: 6px;

              .username {
                font-size: 13px;
                font-weight: 600;
                color: #303133;
              }

              .time {
                font-size: 12px;
                color: #909399;
              }
            }

            .reply-text {
              font-size: 13px;
              line-height: 1.5;
              color: #606266;
              margin-bottom: 6px;
              word-wrap: break-word;
            }

            .reply-btn {
              padding: 0;
              font-size: 12px;
              color: #909399;

              &:hover {
                color: #409eff;
              }

              i {
                margin-right: 3px;
              }
            }
          }
        }
      }

      .reply-editor {
        margin-top: 16px;
        padding-left: 52px;

        ::v-deep .el-textarea__inner {
          border-radius: 6px;
          font-size: 13px;
        }

        .editor-actions {
          display: flex;
          justify-content: flex-end;
          gap: 8px;
          margin-top: 8px;
        }
      }
    }
  }

  /* ==================== 响应式设计 ==================== */
  @media (max-width: 1200px) {
    .catalog-section {
      width: 280px;
    }
  }

  @media (max-width: 992px) {
    .top-section {
      flex-direction: column;

      .catalog-section {
        width: 100%;
        max-height: 500px;

        .catalog-content {
          max-height: 400px;
        }
      }
    }
  }

  @media (max-width: 768px) {
    .page-header {
      padding: 12px 16px;

      .header-left {
        .breadcrumb {
          .course-name {
            max-width: 100px;
          }
        }
      }

      .header-right {
        .catalog-toggle-btn {
          span {
            display: none;
          }
        }
      }
    }

    .main-content {
      padding: 16px;
    }

    .navigation-buttons {
      flex-direction: column;
      gap: 12px;

      .el-button {
        width: 100%;
      }
    }

    .info-panel {
      .tab-pane-content {
        padding: 16px;
      }
    }

    .comment-list {
      .comment-item {
        .reply-list {
          padding-left: 42px;
        }

        .reply-editor {
          padding-left: 42px;
        }
      }
    }
  }
</style>
