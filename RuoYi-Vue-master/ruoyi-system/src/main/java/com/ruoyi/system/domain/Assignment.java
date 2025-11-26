package com.ruoyi.system.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;
import lombok.Data;

import java.util.Date;

/**
 * 作业或考试对象 assignment
 *
 * @author ruoyi
 * @date 2025-11-18
 */
@Data
public class Assignment extends BaseEntity {
    private static final long serialVersionUID = 1L;

    /** 作业编号 */
    private Long id;

    /** 作业或考试标题 */
    @Excel(name = "作业或考试标题")
    private String title;

    /** 课程编号 */
    @Excel(name = "课程编号")
    private Long courseId;

    /** 发布者 user.id */
    @Excel(name = "发布者 user.id")
    private Long publisherUserId;

    /** 任务类型 */
    @Excel(name = "任务类型")
    private String type;

    /** 作业内容 */
    @Excel(name = "作业内容")
    private String description;

    /** 开始时间 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "开始时间", width = 30, dateFormat = "yyyy-MM-dd")
    private Date startTime;

    /** 结束时间 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "结束时间", width = 30, dateFormat = "yyyy-MM-dd")
    private Date endTime;

    /** 发布状态：0未发布，1已发布 */
    @Excel(name = "发布状态：0未发布，1已发布")
    private Long status;

    /** 作业模式：question-答题型，file-上传型 */
    @Excel(name = "作业模式：question-答题型，file-上传型")
    private String mode;

    /** 时间限制（分钟） */
    @Excel(name = "时间限制", readConverterExp = "分=钟")
    private Long timeLimit;

    /** 总分 */
    @Excel(name = "总分")
    private Long totalScore;

    /** 任务时长（分钟） */
    @Excel(name = "任务时长", readConverterExp = "分=钟")
    private Long duration;

    /** 允许的文件类型（JSON格式） */
    @Excel(name = "允许的文件类型", readConverterExp = "J=SON格式")
    private String allowedFileTypes;

    /** 任务附件列表，支持多文件，格式：[{"name":"文件名.pdf","url":"https://xxx.com/file.pdf"}] */
    @Excel(name = "任务附件列表，支持多文件，格式：[{\"name\":\"文件名.pdf\",\"url\":\"https://xxx.com/file.pdf\"}]")
    private String attachments;

    /** 是否删除 */
    @Excel(name = "是否删除")
    private Integer isDeleted;

    /** 删除时间 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "删除时间", width = 30, dateFormat = "yyyy-MM-dd")
    private Date deleteTime;
}
