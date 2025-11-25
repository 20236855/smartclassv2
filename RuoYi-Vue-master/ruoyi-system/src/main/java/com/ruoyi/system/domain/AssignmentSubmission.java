package com.ruoyi.system.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.TableName;

import java.util.Date;

/**
 * 作业提交对象 assignment_submission
 *
 * @author ruoyi
 * @date 2025-11-24
 */
@TableName("assignment_submission")
public class AssignmentSubmission extends BaseEntity {
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;

    /** 作业ID（关联assignment表） */
    @Excel(name = "作业ID")
    private Long assignmentId;

    /** 学生ID（关联user表id） */
    @Excel(name = "学生ID")
    private Long studentUserId;

    /** 提交状态（0-未提交，1-已提交，2-已批改，3-退回） */
    @Excel(name = "提交状态", readConverterExp = "0=未提交,1=已提交,2=已批改,3=退回")
    private Integer status;

    /** 作业得分 */
    @Excel(name = "作业得分")
    private Integer score;

    /** 批改反馈 */
    @Excel(name = "批改反馈")
    private String feedback;

    /** 提交时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "提交时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date submitTime;

    /** 批改时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "批改时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date gradeTime;

    /** 批改人ID（关联user表） */
    @Excel(name = "批改人ID")
    private Long gradedBy;

    /** 提交内容（文本/富文本） */
    @Excel(name = "提交内容")
    private String content;

    /** 提交文件名 */
    @Excel(name = "提交文件名")
    private String fileName;

    /** 提交文件路径 */
    @Excel(name = "提交文件路径")
    private String filePath;

    /** 是否删除（0-未删除，1-已删除） */
    private Integer isDeleted;

    /** 删除时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date deleteTime;

    // ------------------------------ getter/setter ------------------------------
    public void setId(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }

    public void setAssignmentId(Long assignmentId) {
        this.assignmentId = assignmentId;
    }

    public Long getAssignmentId() {
        return assignmentId;
    }

    public void setStudentUserId(Long studentUserId) {
        this.studentUserId = studentUserId;
    }

    public Long getStudentUserId() {
        return studentUserId;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Integer getStatus() {
        return status;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    public Integer getScore() {
        return score;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setSubmitTime(Date submitTime) {
        this.submitTime = submitTime;
    }

    public Date getSubmitTime() {
        return submitTime;
    }

    public void setGradeTime(Date gradeTime) {
        this.gradeTime = gradeTime;
    }

    public Date getGradeTime() {
        return gradeTime;
    }

    public void setGradedBy(Long gradedBy) {
        this.gradedBy = gradedBy;
    }

    public Long getGradedBy() {
        return gradedBy;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getContent() {
        return content;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setIsDeleted(Integer isDeleted) {
        this.isDeleted = isDeleted;
    }

    public Integer getIsDeleted() {
        return isDeleted;
    }

    public void setDeleteTime(Date deleteTime) {
        this.deleteTime = deleteTime;
    }

    public Date getDeleteTime() {
        return deleteTime;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("id", getId())
                .append("assignmentId", getAssignmentId())
                .append("studentUserId", getStudentUserId())
                .append("status", getStatus())
                .append("score", getScore())
                .append("feedback", getFeedback())
                .append("submitTime", getSubmitTime())
                .append("gradeTime", getGradeTime())
                .append("gradedBy", getGradedBy())
                .append("content", getContent())
                .append("fileName", getFileName())
                .append("filePath", getFilePath())
                .append("isDeleted", getIsDeleted())
                .append("deleteTime", getDeleteTime())
                .append("createTime", getCreateTime())
                .append("updateTime", getUpdateTime())
                .toString();
    }
}
