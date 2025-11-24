package com.ruoyi.system.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 知识点对象 knowledge_point
 * 
 * @author ruoyi
 * @date 2025-11-21
 */
public class KnowledgePoint extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** $column.columnComment */
    private Long id;

    /** 所属课程 */
    @Excel(name = "所属课程")
    private Long courseId;

    /** 知识点名称（如“二分查找”） */
    @Excel(name = "知识点名称", readConverterExp = "如=“二分查找”")
    private String title;

    /** 详细解释（AI生成） */
    @Excel(name = "详细解释", readConverterExp = "A=I生成")
    private String description;

    /** 难度 */
    @Excel(name = "难度")
    private String level;

    /** 创建者 user.id */
    @Excel(name = "创建者 user.id")
    private Long creatorUserId;

    /** $column.columnComment */
    @Excel(name = "${comment}", readConverterExp = "$column.readConverterExp()")
    private Integer isDeleted;

    /** $column.columnComment */
    @Excel(name = "${comment}", readConverterExp = "$column.readConverterExp()")
    private Date deleteTime;

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

    public void setLevel(String level) 
    {
        this.level = level;
    }

    public String getLevel() 
    {
        return level;
    }

    public void setCreatorUserId(Long creatorUserId) 
    {
        this.creatorUserId = creatorUserId;
    }

    public Long getCreatorUserId() 
    {
        return creatorUserId;
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
            .append("courseId", getCourseId())
            .append("title", getTitle())
            .append("description", getDescription())
            .append("level", getLevel())
            .append("creatorUserId", getCreatorUserId())
            .append("createTime", getCreateTime())
            .append("updateTime", getUpdateTime())
            .append("isDeleted", getIsDeleted())
            .append("deleteTime", getDeleteTime())
            .toString();
    }
}
