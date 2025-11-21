package com.ruoyi.system.domain;

import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;

import java.util.Date;
import java.util.List;

/**
 * 题目对象 question
 *
 * @author ruoyi
 * @date 2025-11-18
 */
public class Question extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** $column.columnComment */
    private Long id;

    /** 题干内容 */
    @Excel(name = "题干内容")
    private String title;

    /** 题型 */
    @Excel(name = "题型")
    private String questionType;

    /** 难度等级，1~5整数 */
    @Excel(name = "难度等级，1~5整数")
    private Long difficulty;

    /** 标准答案 */
    @Excel(name = "标准答案")
    private String correctAnswer;

    /** 答案解析 */
    @Excel(name = "答案解析")
    private String explanation;

    /** 知识点 */
    @Excel(name = "知识点")
    private String knowledgePoint;

    /** $column.columnComment */
    @Excel(name = "${comment}", readConverterExp = "$column.readConverterExp()")
    private Long courseId;

    /** $column.columnComment */
    @Excel(name = "${comment}", readConverterExp = "$column.readConverterExp()")
    private Long chapterId;

    /** 出题教师ID */
    @Excel(name = "出题教师ID")
    private Long createdBy;

    /** $column.columnComment */
    @Excel(name = "${comment}", readConverterExp = "$column.readConverterExp()")
    private Integer isDeleted;

    /** $column.columnComment */
    @Excel(name = "${comment}", readConverterExp = "$column.readConverterExp()")
    private Date deleteTime;

    /** 选项列表（非数据库字段，用于前端展示） */
    private String options;

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

    public void setQuestionType(String questionType)
    {
        this.questionType = questionType;
    }

    public String getQuestionType()
    {
        return questionType;
    }

    public void setDifficulty(Long difficulty)
    {
        this.difficulty = difficulty;
    }

    public Long getDifficulty()
    {
        return difficulty;
    }

    public void setCorrectAnswer(String correctAnswer)
    {
        this.correctAnswer = correctAnswer;
    }

    public String getCorrectAnswer()
    {
        return correctAnswer;
    }

    public void setExplanation(String explanation)
    {
        this.explanation = explanation;
    }

    public String getExplanation()
    {
        return explanation;
    }

    public void setKnowledgePoint(String knowledgePoint)
    {
        this.knowledgePoint = knowledgePoint;
    }

    public String getKnowledgePoint()
    {
        return knowledgePoint;
    }

    public void setCourseId(Long courseId)
    {
        this.courseId = courseId;
    }

    public Long getCourseId()
    {
        return courseId;
    }

    public void setChapterId(Long chapterId)
    {
        this.chapterId = chapterId;
    }

    public Long getChapterId()
    {
        return chapterId;
    }

    public void setCreatedBy(Long createdBy)
    {
        this.createdBy = createdBy;
    }

    public Long getCreatedBy()
    {
        return createdBy;
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

    public void setOptions(String options)
    {
        this.options = options;
    }

    public String getOptions()
    {
        return options;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
                .append("id", getId())
                .append("title", getTitle())
                .append("questionType", getQuestionType())
                .append("difficulty", getDifficulty())
                .append("correctAnswer", getCorrectAnswer())
                .append("explanation", getExplanation())
                .append("knowledgePoint", getKnowledgePoint())
                .append("courseId", getCourseId())
                .append("chapterId", getChapterId())
                .append("createdBy", getCreatedBy())
                .append("createTime", getCreateTime())
                .append("updateTime", getUpdateTime())
                .append("isDeleted", getIsDeleted())
                .append("deleteTime", getDeleteTime())
                .toString();
    }
}
