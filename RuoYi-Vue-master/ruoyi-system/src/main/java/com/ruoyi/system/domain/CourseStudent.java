package com.ruoyi.system.domain;

import java.util.Date;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 学生选课对象 course_student
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public class CourseStudent extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** $column.columnComment */
    private Long id;

    /** $column.columnComment */
    @Excel(name = "${comment}", readConverterExp = "$column.readConverterExp()")
    private Long courseId;

    /** 学生 user.id */
    private Long studentUserId;

    /** $column.columnComment */
    @Excel(name = "${comment}", readConverterExp = "$column.readConverterExp()")
    private Date enrollTime;

    /** 课程是否被该学生收藏，1为被收藏，0为未被收藏 */
    @Excel(name = "课程是否被该学生收藏，1为被收藏，0为未被收藏")
    private Long collected;

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

    public void setStudentUserId(Long studentUserId) 
    {
        this.studentUserId = studentUserId;
    }

    public Long getStudentUserId() 
    {
        return studentUserId;
    }

    public void setEnrollTime(Date enrollTime) 
    {
        this.enrollTime = enrollTime;
    }

    public Date getEnrollTime() 
    {
        return enrollTime;
    }

    public void setCollected(Long collected) 
    {
        this.collected = collected;
    }

    public Long getCollected() 
    {
        return collected;
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
            .append("studentUserId", getStudentUserId())
            .append("enrollTime", getEnrollTime())
            .append("collected", getCollected())
            .append("isDeleted", getIsDeleted())
            .append("deleteTime", getDeleteTime())
            .toString();
    }
}
