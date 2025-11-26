package com.ruoyi.system.domain;

import java.math.BigDecimal;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 课程能力点（定义能力模型维度）对象 course_competency
 *
 * @author ruoyi
 * @date 2025-11-20
 */
public class CourseCompetency extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 能力点ID */
    private Long id;

    /** 所属课程ID（关联course表） */
    @Excel(name = "所属课程ID", readConverterExp = "关=联course表")
    private Long courseId;

    /** 能力点名称（如“数据结构理解能力”“算法优化能力”） */
    @Excel(name = "能力点名称", readConverterExp = "如=“数据结构理解能力”“算法优化能力”")
    private String competencyName;

    /** 能力点描述 */
    @Excel(name = "能力点描述")
    private String competencyDesc;

    /** 展示顺序（雷达图维度排序） */
    @Excel(name = "展示顺序", readConverterExp = "雷=达图维度排序")
    private Long sortOrder;

    /** 能力点权重（用于综合能力计算） */
    @Excel(name = "能力点权重", readConverterExp = "用=于综合能力计算")
    private BigDecimal weight;

    /** 软删除标记 */
    @Excel(name = "软删除标记")
    private Integer isDeleted;

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

    public void setCompetencyName(String competencyName)
    {
        this.competencyName = competencyName;
    }

    public String getCompetencyName()
    {
        return competencyName;
    }

    public void setCompetencyDesc(String competencyDesc)
    {
        this.competencyDesc = competencyDesc;
    }

    public String getCompetencyDesc()
    {
        return competencyDesc;
    }

    public void setSortOrder(Long sortOrder)
    {
        this.sortOrder = sortOrder;
    }

    public Long getSortOrder()
    {
        return sortOrder;
    }

    public void setWeight(BigDecimal weight)
    {
        this.weight = weight;
    }

    public BigDecimal getWeight()
    {
        return weight;
    }

    public void setIsDeleted(Integer isDeleted)
    {
        this.isDeleted = isDeleted;
    }

    public Integer getIsDeleted()
    {
        return isDeleted;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
                .append("id", getId())
                .append("courseId", getCourseId())
                .append("competencyName", getCompetencyName())
                .append("competencyDesc", getCompetencyDesc())
                .append("sortOrder", getSortOrder())
                .append("weight", getWeight())
                .append("createTime", getCreateTime())
                .append("updateTime", getUpdateTime())
                .append("isDeleted", getIsDeleted())
                .toString();
    }
}

