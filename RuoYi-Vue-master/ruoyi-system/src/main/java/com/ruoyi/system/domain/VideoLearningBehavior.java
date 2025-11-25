package com.ruoyi.system.domain;

import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.core.domain.BaseEntity;
import lombok.Data;

import java.util.Date;

/**
 * 视频学习行为实体类
 *
 * @author ruoyi
 * @date 2025-11-24
 */
@Data
@TableName("video_learning_behavior")
public class VideoLearningBehavior extends BaseEntity {
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;

    /** 学生ID */
    private Long studentUserId;

    /** 课程ID */
    private Long courseId;

    /** 视频ID */
    private Long videoId;

    /** 观看时长（秒） */
    private Long watchDuration;

    /** 视频总时长（秒） */
    private Long videoDuration;

    /** 快进次数 */
    private Integer fastForwardCount;

    /** 是否删除（0-未删除，1-已删除） */
    private Integer isDeleted;

    /** 删除时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date deleteTime;
}
