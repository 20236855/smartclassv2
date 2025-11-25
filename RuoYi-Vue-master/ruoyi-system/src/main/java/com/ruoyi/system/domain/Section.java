package com.ruoyi.system.domain;

import java.util.Date;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 课程小节对象 section
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public class Section extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 小节ID，主键 */
    private Long id;

    /** 所属章节ID，外键 */
    @Excel(name = "所属章节ID，外键")
    private Long chapterId;

    /** 小节名称 */
    @Excel(name = "小节名称")
    private String title;

    /** 小节简介 */
    @Excel(name = "小节简介")
    private String description;

    /** 视频播放地址，可对接OSS */
    @Excel(name = "视频播放地址，可对接OSS")
    private String videoUrl;

    /** 视频时长(秒) */
    @Excel(name = "视频时长(秒)")
    private Long duration;

    /** 小节顺序，用于排序 */
    @Excel(name = "小节顺序，用于排序")
    private Long sortOrder;

    /** $column.columnComment */
    private Integer isDeleted;

    /** $column.columnComment */
    private Date deleteTime;

    public void setId(Long id) 
    {
        this.id = id;
    }

    public Long getId() 
    {
        return id;
    }

    public void setChapterId(Long chapterId) 
    {
        this.chapterId = chapterId;
    }

    public Long getChapterId() 
    {
        return chapterId;
    }

    public void setTitle(String title) 
    {
        this.title = title;
    }

    public String getTitle() 
    {
        return title;
    }

    public void setDescription(String description) 
    {
        this.description = description;
    }

    public String getDescription() 
    {
        return description;
    }

    public void setVideoUrl(String videoUrl) 
    {
        this.videoUrl = videoUrl;
    }

    public String getVideoUrl() 
    {
        return videoUrl;
    }

    public void setDuration(Long duration) 
    {
        this.duration = duration;
    }

    public Long getDuration() 
    {
        return duration;
    }

    public void setSortOrder(Long sortOrder) 
    {
        this.sortOrder = sortOrder;
    }

    public Long getSortOrder() 
    {
        return sortOrder;
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

    private Long courseId;

    public Long getCourseId() {
        return courseId;
    }

    public void setCourseId(Long courseId) {
        this.courseId = courseId;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("id", getId())
            .append("chapterId", getChapterId())
            .append("title", getTitle())
            .append("description", getDescription())
            .append("videoUrl", getVideoUrl())
            .append("duration", getDuration())
            .append("sortOrder", getSortOrder())
            .append("createTime", getCreateTime())
            .append("updateTime", getUpdateTime())
            .append("isDeleted", getIsDeleted())
            .append("deleteTime", getDeleteTime())
            .toString();
    }
}
