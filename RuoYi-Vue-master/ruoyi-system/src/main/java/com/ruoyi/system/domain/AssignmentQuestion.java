package com.ruoyi.system.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 作业-题目关联对象 assignment_question
 *
 * @author ruoyi
 * @date 2025-11-21
 */
public class AssignmentQuestion extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;

    /** 作业ID（关联assignment表） */
    @Excel(name = "作业ID", readConverterExp = "关=联assignment表")
    private Long assignmentId;

    /** 题目ID（关联question表） */
    @Excel(name = "题目ID", readConverterExp = "关=联question表")
    private Long questionId;

    /** 题目分值（默认5分） */
    @Excel(name = "题目分值")
    private Integer score;

    /** 题目排序序号（默认1） */
    @Excel(name = "题目排序序号")
    private Integer sequence;

    /** 软删除标记（0=未删除，1=已删除） */
    @Excel(name = "软删除标记")
    private Integer isDeleted;

    /** 删除时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "删除时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date deleteTime;

    public void setId(Long id)
    {
        this.id = id;
    }

    public Long getId()
    {
        return id;
    }

    public void setAssignmentId(Long assignmentId)
    {
        this.assignmentId = assignmentId;
    }

    public Long getAssignmentId()
    {
        return assignmentId;
    }

    public void setQuestionId(Long questionId)
    {
        this.questionId = questionId;
    }

    public Long getQuestionId()
    {
        return questionId;
    }

    public void setScore(Integer score)
    {
        this.score = score;
    }

    public Integer getScore()
    {
        return score;
    }

    public void setSequence(Integer sequence)
    {
        this.sequence = sequence;
    }

    public Integer getSequence()
    {
        return sequence;
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
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("id", getId())
                .append("assignmentId", getAssignmentId())
                .append("questionId", getQuestionId())
                .append("score", getScore())
                .append("sequence", getSequence())
                .append("isDeleted", getIsDeleted())
                .append("deleteTime", getDeleteTime())
                .append("createTime", getCreateTime())
                .append("updateTime", getUpdateTime())
                .toString();
    }
}
