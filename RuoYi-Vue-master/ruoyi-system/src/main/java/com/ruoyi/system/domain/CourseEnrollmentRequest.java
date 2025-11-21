package com.ruoyi.system.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 选课申请对象 course_enrollment_request
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public class CourseEnrollmentRequest extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 申请ID */
    private Long id;

    /** 学生 user.id */
    @Excel(name = "学生 user.id")
    private Long studentUserId;

    /** 申请加入的课程ID */
    @Excel(name = "申请加入的课程ID")
    private Long courseId;

    /** 申请状态：0=待审核 1=已通过 2=已拒绝 */
    @Excel(name = "申请状态：0=待审核 1=已通过 2=已拒绝")
    private Long status;

    /** 学生申请理由 */
    @Excel(name = "学生申请理由")
    private String reason;

    /** 教师审核意见 */
    @Excel(name = "教师审核意见")
    private String reviewComment;

    /** $column.columnComment */
    @Excel(name = "${comment}", readConverterExp = "$column.readConverterExp()")
    private Date submitTime;

    /** 审核时间 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "审核时间", width = 30, dateFormat = "yyyy-MM-dd")
    private Date reviewTime;

    public void setId(Long id) 
    {
        this.id = id;
    }

    public Long getId() 
    {
        return id;
    }

    public void setStudentUserId(Long studentUserId) 
    {
        this.studentUserId = studentUserId;
    }

    public Long getStudentUserId() 
    {
        return studentUserId;
    }

    public void setCourseId(Long courseId) 
    {
        this.courseId = courseId;
    }

    public Long getCourseId() 
    {
        return courseId;
    }

    public void setStatus(Long status) 
    {
        this.status = status;
    }

    public Long getStatus() 
    {
        return status;
    }

    public void setReason(String reason) 
    {
        this.reason = reason;
    }

    public String getReason() 
    {
        return reason;
    }

    public void setReviewComment(String reviewComment) 
    {
        this.reviewComment = reviewComment;
    }

    public String getReviewComment() 
    {
        return reviewComment;
    }

    public void setSubmitTime(Date submitTime) 
    {
        this.submitTime = submitTime;
    }

    public Date getSubmitTime() 
    {
        return submitTime;
    }

    public void setReviewTime(Date reviewTime) 
    {
        this.reviewTime = reviewTime;
    }

    public Date getReviewTime() 
    {
        return reviewTime;
    }
    private String courseName;

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("id", getId())
            .append("studentUserId", getStudentUserId())
            .append("courseId", getCourseId())
            .append("status", getStatus())
            .append("reason", getReason())
            .append("reviewComment", getReviewComment())
            .append("submitTime", getSubmitTime())
            .append("reviewTime", getReviewTime())
            .toString();
    }
}
