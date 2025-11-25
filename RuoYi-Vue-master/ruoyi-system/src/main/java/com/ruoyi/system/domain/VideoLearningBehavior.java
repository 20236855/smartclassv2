package com.ruoyi.system.domain;

import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;

/**
 * 视频学习行为对象 video_learning_behavior
 *
 * @author ruoyi
 * @date 2025-11-18
 */
@Data
@TableName("video_learning_behavior")
public class VideoLearningBehavior extends BaseEntity {
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

    /** 创建时间 */
    private Date createdAt;

    /** 更新时间 */
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

    /** 是否删除（0-未删除，1-已删除） */
    private Integer isDeleted;

    /** 删除时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date deleteTime;
}
