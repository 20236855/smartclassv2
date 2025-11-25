package com.ruoyi.system.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.TableName;

import java.util.Date;

/**
 * 学生答题记录对象 student_answer
 *
 * @author ruoyi
 * @date 2025-11-24
 */
@TableName("student_answer")
public class StudentAnswer extends BaseEntity {
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;

    /** 学生ID（关联user表id） */
    @Excel(name = "学生ID")
    private Long studentUserId;

    /** 作业ID（关联assignment表） */
    @Excel(name = "作业ID")
    private Long assignmentId;

    /** 题目ID（关联question表） */
    @Excel(name = "题目ID")
    private Long questionId;

    /** 答题内容 */
    @Excel(name = "答题内容")
    private String answerContent;

    /** 是否正确（0-错误，1-正确） */
    @Excel(name = "是否正确", readConverterExp = "0=错误,1=正确")
    private Boolean isCorrect;

    /** 题目得分 */
    @Excel(name = "题目得分")
    private Integer score;

    /** 答题时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "答题时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date answerTime;

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

    public void setStudentUserId(Long studentUserId) {
        this.studentUserId = studentUserId;
    }

    public Long getStudentUserId() {
        return studentUserId;
    }

    public void setAssignmentId(Long assignmentId) {
        this.assignmentId = assignmentId;
    }

    public Long getAssignmentId() {
        return assignmentId;
    }

    public void setQuestionId(Long questionId) {
        this.questionId = questionId;
    }

    public Long getQuestionId() {
        return questionId;
    }

    public void setAnswerContent(String answerContent) {
        this.answerContent = answerContent;
    }

    public String getAnswerContent() {
        return answerContent;
    }

    public void setIsCorrect(Boolean isCorrect) {
        this.isCorrect = isCorrect;
    }

    public Boolean getIsCorrect() {
        return isCorrect;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    public Integer getScore() {
        return score;
    }

    public void setAnswerTime(Date answerTime) {
        this.answerTime = answerTime;
    }

    public Date getAnswerTime() {
        return answerTime;
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
                .append("studentUserId", getStudentUserId())
                .append("assignmentId", getAssignmentId())
                .append("questionId", getQuestionId())
                .append("answerContent", getAnswerContent())
                .append("isCorrect", getIsCorrect())
                .append("score", getScore())
                .append("answerTime", getAnswerTime())
                .append("isDeleted", getIsDeleted())
                .append("deleteTime", getDeleteTime())
                .append("createTime", getCreateTime())
                .append("updateTime", getUpdateTime())
                .toString();
    }
}
