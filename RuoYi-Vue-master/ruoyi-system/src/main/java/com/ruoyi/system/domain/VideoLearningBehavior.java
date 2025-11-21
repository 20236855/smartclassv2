package com.ruoyi.system.domain;

import java.math.BigDecimal;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 视频学习行为对象 video_learning_behavior
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public class VideoLearningBehavior extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 行为ID */
    private Long id;

    /** 学生ID */
    @Excel(name = "学生ID")
    private Long studentId;

    /** 视频ID */
    @Excel(name = "视频ID")
    private Long videoId;

    /** 观看时长（秒） */
    @Excel(name = "观看时长", readConverterExp = "秒=")
    private Long watchDuration;

    /** 视频总时长（秒） */
    @Excel(name = "视频总时长", readConverterExp = "秒=")
    private Long videoDuration;

    /** 完成率（%） */
    @Excel(name = "完成率", readConverterExp = "%=")
    private BigDecimal completionRate;

    /** 观看次数 */
    @Excel(name = "观看次数")
    private Long watchCount;

    /** 热力图数据 */
    @Excel(name = "热力图数据")
    private String heatmapData;

    /** 是否看完：1-是 0-否 */
    @Excel(name = "是否看完：1-是 0-否")
    private Long isCompleted;

    /** 快进次数 */
    @Excel(name = "快进次数")
    private Long fastForwardCount;

    /** 暂停次数 */
    @Excel(name = "暂停次数")
    private Long pauseCount;

    /** 播放倍速 */
    @Excel(name = "播放倍速")
    private BigDecimal playbackSpeed;

    /** 首次观看时间 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "首次观看时间", width = 30, dateFormat = "yyyy-MM-dd")
    private Date firstWatchAt;

    /** 最近观看时间 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "最近观看时间", width = 30, dateFormat = "yyyy-MM-dd")
    private Date lastWatchAt;

    /** $column.columnComment */
    private Date createdAt;

    /** $column.columnComment */
    private Date updatedAt;

    /** 上次观看位置（秒） */
    private Long lastPosition;

    /** 视频标题（关联查询） */
    private String title;

    /** 课程名称（关联查询） */
    private String courseName;

    /** 章节名称（关联查询） */
    private String chapterName;

    /** 课程ID（关联查询） */
    private Long courseId;

    public void setId(Long id)
    {
        this.id = id;
    }

    public Long getId() 
    {
        return id;
    }

    public void setStudentId(Long studentId) 
    {
        this.studentId = studentId;
    }

    public Long getStudentId() 
    {
        return studentId;
    }

    public void setVideoId(Long videoId) 
    {
        this.videoId = videoId;
    }

    public Long getVideoId() 
    {
        return videoId;
    }

    public void setWatchDuration(Long watchDuration) 
    {
        this.watchDuration = watchDuration;
    }

    public Long getWatchDuration() 
    {
        return watchDuration;
    }

    public void setVideoDuration(Long videoDuration) 
    {
        this.videoDuration = videoDuration;
    }

    public Long getVideoDuration() 
    {
        return videoDuration;
    }

    public void setCompletionRate(BigDecimal completionRate) 
    {
        this.completionRate = completionRate;
    }

    public BigDecimal getCompletionRate() 
    {
        return completionRate;
    }

    public void setWatchCount(Long watchCount) 
    {
        this.watchCount = watchCount;
    }

    public Long getWatchCount() 
    {
        return watchCount;
    }

    public void setHeatmapData(String heatmapData) 
    {
        this.heatmapData = heatmapData;
    }

    public String getHeatmapData() 
    {
        return heatmapData;
    }

    public void setIsCompleted(Long isCompleted) 
    {
        this.isCompleted = isCompleted;
    }

    public Long getIsCompleted() 
    {
        return isCompleted;
    }

    public void setFastForwardCount(Long fastForwardCount) 
    {
        this.fastForwardCount = fastForwardCount;
    }

    public Long getFastForwardCount() 
    {
        return fastForwardCount;
    }

    public void setPauseCount(Long pauseCount) 
    {
        this.pauseCount = pauseCount;
    }

    public Long getPauseCount() 
    {
        return pauseCount;
    }

    public void setPlaybackSpeed(BigDecimal playbackSpeed) 
    {
        this.playbackSpeed = playbackSpeed;
    }

    public BigDecimal getPlaybackSpeed() 
    {
        return playbackSpeed;
    }

    public void setFirstWatchAt(Date firstWatchAt) 
    {
        this.firstWatchAt = firstWatchAt;
    }

    public Date getFirstWatchAt() 
    {
        return firstWatchAt;
    }

    public void setLastWatchAt(Date lastWatchAt) 
    {
        this.lastWatchAt = lastWatchAt;
    }

    public Date getLastWatchAt() 
    {
        return lastWatchAt;
    }

    public void setCreatedAt(Date createdAt) 
    {
        this.createdAt = createdAt;
    }

    public Date getCreatedAt() 
    {
        return createdAt;
    }

    public void setUpdatedAt(Date updatedAt) 
    {
        this.updatedAt = updatedAt;
    }

    public Date getUpdatedAt()
    {
        return updatedAt;
    }

    public void setLastPosition(Long lastPosition)
    {
        this.lastPosition = lastPosition;
    }

    public Long getLastPosition()
    {
        return lastPosition;
    }

    public void setTitle(String title)
    {
        this.title = title;
    }

    public String getTitle()
    {
        return title;
    }

    public void setCourseName(String courseName)
    {
        this.courseName = courseName;
    }

    public String getCourseName()
    {
        return courseName;
    }

    public void setChapterName(String chapterName)
    {
        this.chapterName = chapterName;
    }

    public String getChapterName()
    {
        return chapterName;
    }

    public void setCourseId(Long courseId)
    {
        this.courseId = courseId;
    }

    public Long getCourseId()
    {
        return courseId;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("id", getId())
            .append("studentId", getStudentId())
            .append("videoId", getVideoId())
            .append("watchDuration", getWatchDuration())
            .append("videoDuration", getVideoDuration())
            .append("completionRate", getCompletionRate())
            .append("watchCount", getWatchCount())
            .append("heatmapData", getHeatmapData())
            .append("isCompleted", getIsCompleted())
            .append("fastForwardCount", getFastForwardCount())
            .append("pauseCount", getPauseCount())
            .append("playbackSpeed", getPlaybackSpeed())
            .append("firstWatchAt", getFirstWatchAt())
            .append("lastWatchAt", getLastWatchAt())
            .append("createdAt", getCreatedAt())
            .append("updatedAt", getUpdatedAt())
            .append("lastPosition", getLastPosition())
            .append("title", getTitle())
            .append("courseName", getCourseName())
            .append("chapterName", getChapterName())
            .append("courseId", getCourseId())
            .toString();
    }
}
