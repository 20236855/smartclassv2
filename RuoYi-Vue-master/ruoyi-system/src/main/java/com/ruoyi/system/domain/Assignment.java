package com.ruoyi.system.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;

import java.util.Date;

/**
 * 作业或考试对象 assignment
 *
 * @author ruoyi
 * @date 2025-11-18
 */
public class Assignment extends BaseEntity
{
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


    public void setId(Long id)
    {
        this.id = id;
    }

    public Long getId()
    {
        return id;
    }

    public void setTitle(String title)
    {
        this.title = title;
    }

    public String getTitle()
    {
        return title;
    }

    public void setCourseId(Long courseId)
    {
        this.courseId = courseId;
    }

    public Long getCourseId()
    {
        return courseId;
    }

    public void setPublisherUserId(Long publisherUserId)
    {
        this.publisherUserId = publisherUserId;
    }

    public Long getPublisherUserId()
    {
        return publisherUserId;
    }

    public void setType(String type)
    {
        this.type = type;
    }

    public String getType()
    {
        return type;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }

    public String getDescription()
    {
        return description;
    }

    public void setStartTime(Date startTime)
    {
        this.startTime = startTime;
    }

    public Date getStartTime()
    {
        return startTime;
    }

    public void setEndTime(Date endTime)
    {
        this.endTime = endTime;
    }

    public Date getEndTime()
    {
        return endTime;
    }

    public void setStatus(Long status)
    {
        this.status = status;
    }

    public Long getStatus()
    {
        return status;
    }

    public void setMode(String mode)
    {
        this.mode = mode;
    }

    public String getMode()
    {
        return mode;
    }

    public void setTimeLimit(Long timeLimit)
    {
        this.timeLimit = timeLimit;
    }

    public Long getTimeLimit()
    {
        return timeLimit;
    }

    public void setTotalScore(Long totalScore)
    {
        this.totalScore = totalScore;
    }

    public Long getTotalScore()
    {
        return totalScore;
    }

    public void setDuration(Long duration)
    {
        this.duration = duration;
    }

    public Long getDuration()
    {
        return duration;
    }

    public void setAllowedFileTypes(String allowedFileTypes)
    {
        this.allowedFileTypes = allowedFileTypes;
    }

    public String getAllowedFileTypes()
    {
        return allowedFileTypes;
    }

    public void setAttachments(String attachments)
    {
        this.attachments = attachments;
    }

    public String getAttachments()
    {
        return attachments;
    }

    public void setIsDeleted(Integer isDeleted)
    {
        this.isDeleted = isDeleted;
    }

    public Integer getIsDeleted()
    {
        return isDeleted;
    }

    public void setDeleteTime(Date deleteTime)
    {
        this.deleteTime = deleteTime;
    }

    public Date getDeleteTime()
    {
        return deleteTime;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
                .append("id", getId())
                .append("title", getTitle())
                .append("courseId", getCourseId())
                .append("publisherUserId", getPublisherUserId())
                .append("type", getType())
                .append("description", getDescription())
                .append("startTime", getStartTime())
                .append("endTime", getEndTime())
                .append("createTime", getCreateTime())
                .append("status", getStatus())
                .append("updateTime", getUpdateTime())
                .append("mode", getMode())
                .append("timeLimit", getTimeLimit())
                .append("totalScore", getTotalScore())
                .append("duration", getDuration())
                .append("allowedFileTypes", getAllowedFileTypes())
                .append("attachments", getAttachments())
                .append("isDeleted", getIsDeleted())
                .append("deleteTime", getDeleteTime())
                .toString();
    }
}
