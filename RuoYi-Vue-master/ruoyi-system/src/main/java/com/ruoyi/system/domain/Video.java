package com.ruoyi.system.domain;

import java.util.Date;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 视频对象 video
 * 
 * @author ruoyi
 * @date 2025-11-20
 */
public class Video extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 视频ID */
    @Excel(name = "视频ID")
    private Long id;

    /** 课程ID */
    @Excel(name = "课程ID")
    private Long courseId;

    /** 视频标题 */
    @Excel(name = "视频标题")
    private String title;

    /** 视频描述 */
    @Excel(name = "视频描述")
    private String description;

    /** 视频文件路径 */
    @Excel(name = "视频文件路径")
    private String filePath;

    /** 文件大小（字节） */
    @Excel(name = "文件大小", readConverterExp = "字=节")
    private Long fileSize;

    /** 时长（秒） */
    @Excel(name = "时长", readConverterExp = "秒=")
    private Long duration;

    /** 封面图片路径 */
    @Excel(name = "封面图片路径")
    private String coverImage;

    /** 分辨率（如：1080p） */
    @Excel(name = "分辨率", readConverterExp = "如=：1080p")
    private String resolution;

    /** 关联的知识点ID列表 */
    @Excel(name = "关联的知识点ID列表")
    private String knowledgePointIds;

    /** 状态 */
    private String status;

    /** 观看次数 */
    @Excel(name = "观看次数")
    private Long viewCount;

    /** 上传者ID */
    private Long uploadedBy;

    /**  */
    private Date createdAt;

    /**  */
    private Date updatedAt;

    public void setId(Long id) 
    {
        this.id = id;
    }

    public Long getId() 
    {
        return id;
    }

    public void setCourseId(Long courseId) 
    {
        this.courseId = courseId;
    }

    public Long getCourseId()
    {
        return courseId;
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

    public void setFilePath(String filePath) 
    {
        this.filePath = filePath;
    }

    public String getFilePath() 
    {
        return filePath;
    }

    public void setFileSize(Long fileSize) 
    {
        this.fileSize = fileSize;
    }

    public Long getFileSize() 
    {
        return fileSize;
    }

    public void setDuration(Long duration) 
    {
        this.duration = duration;
    }

    public Long getDuration() 
    {
        return duration;
    }

    public void setCoverImage(String coverImage) 
    {
        this.coverImage = coverImage;
    }

    public String getCoverImage() 
    {
        return coverImage;
    }

    public void setResolution(String resolution) 
    {
        this.resolution = resolution;
    }

    public String getResolution() 
    {
        return resolution;
    }

    public void setKnowledgePointIds(String knowledgePointIds) 
    {
        this.knowledgePointIds = knowledgePointIds;
    }

    public String getKnowledgePointIds() 
    {
        return knowledgePointIds;
    }

    public void setStatus(String status) 
    {
        this.status = status;
    }

    public String getStatus() 
    {
        return status;
    }

    public void setViewCount(Long viewCount) 
    {
        this.viewCount = viewCount;
    }

    public Long getViewCount() 
    {
        return viewCount;
    }

    public void setUploadedBy(Long uploadedBy) 
    {
        this.uploadedBy = uploadedBy;
    }

    public Long getUploadedBy() 
    {
        return uploadedBy;
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

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("id", getId())
            .append("courseId", getCourseId())
            .append("title", getTitle())
            .append("description", getDescription())
            .append("filePath", getFilePath())
            .append("fileSize", getFileSize())
            .append("duration", getDuration())
            .append("coverImage", getCoverImage())
            .append("resolution", getResolution())
            .append("knowledgePointIds", getKnowledgePointIds())
            .append("status", getStatus())
            .append("viewCount", getViewCount())
            .append("uploadedBy", getUploadedBy())
            .append("createdAt", getCreatedAt())
            .append("updatedAt", getUpdatedAt())
            .toString();
    }
}
