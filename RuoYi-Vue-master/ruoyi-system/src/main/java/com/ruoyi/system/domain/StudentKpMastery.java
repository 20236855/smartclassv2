package com.ruoyi.system.domain;

import java.math.BigDecimal;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 学生知识点掌握情况（支撑知识图谱状态标识）对象 student_kp_mastery
 *
 * @author ruoyi
 * @date 2025-11-20
 */
public class StudentKpMastery extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 记录ID */
    private Long id;

    /** 学生user.id（关联user表） */
    @Excel(name = "学生user.id", readConverterExp = "关=联user表")
    private Long studentUserId;

    /** 所属课程ID（关联course表） */
    @Excel(name = "所属课程ID", readConverterExp = "关=联course表")
    private Long courseId;

    /** 知识点ID（关联knowledge_point表） */
    @Excel(name = "知识点ID", readConverterExp = "关=联knowledge_point表")
    private Long kpId;

    /** 答对次数 */
    @Excel(name = "答对次数")
    private Long correctCount;

    /** 总答题次数 */
    @Excel(name = "总答题次数")
    private Long totalCount;

    /** 正确率（自动计算） */
    @Excel(name = "正确率", readConverterExp = "自=动计算")
    private BigDecimal accuracy;

    /** 最近一次测试得分 */
    @Excel(name = "最近一次测试得分")
    private BigDecimal lastTestScore;

    /** 最近测试时间 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "最近测试时间", width = 30, dateFormat = "yyyy-MM-dd")
    private Date lastTestTime;

    /** 趋势 */
    @Excel(name = "趋势")
    private String trend;

    /** 掌握指标（0-100分）：按权重计算的综合得分 */
    @Excel(name = "掌握指标", readConverterExp = "0=-100分")
    private BigDecimal masteryScore;

    /** 掌握状态：未学习/学习中/已掌握/薄弱点 */
    @Excel(name = "掌握状态：未学习/学习中/已掌握/薄弱点")
    private String masteryStatus;

    /** 权重因子明细：{"exam_score":0.4,"video_behavior":0.3,"resource_behavior":0.2,"homework_score":0.1}（可配置） */
    @Excel(name = "权重因子明细：{\"exam_score\":0.4,\"video_behavior\":0.3,\"resource_behavior\":0.2,\"homework_score\":0.1}", readConverterExp = "可=配置")
    private String weightFactors;

    /** 最后更新来源：system/ai/job */
    @Excel(name = "最后更新来源：system/ai/job")
    private String lastUpdatedBy;

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

    public void setKpId(Long kpId)
    {
        this.kpId = kpId;
    }

    public Long getKpId()
    {
        return kpId;
    }

    public void setCorrectCount(Long correctCount)
    {
        this.correctCount = correctCount;
    }

    public Long getCorrectCount()
    {
        return correctCount;
    }

    public void setTotalCount(Long totalCount)
    {
        this.totalCount = totalCount;
    }

    public Long getTotalCount()
    {
        return totalCount;
    }

    public void setAccuracy(BigDecimal accuracy)
    {
        this.accuracy = accuracy;
    }

    public BigDecimal getAccuracy()
    {
        return accuracy;
    }

    public void setLastTestScore(BigDecimal lastTestScore)
    {
        this.lastTestScore = lastTestScore;
    }

    public BigDecimal getLastTestScore()
    {
        return lastTestScore;
    }

    public void setLastTestTime(Date lastTestTime)
    {
        this.lastTestTime = lastTestTime;
    }

    public Date getLastTestTime()
    {
        return lastTestTime;
    }

    public void setTrend(String trend)
    {
        this.trend = trend;
    }

    public String getTrend()
    {
        return trend;
    }

    public void setMasteryScore(BigDecimal masteryScore)
    {
        this.masteryScore = masteryScore;
    }

    public BigDecimal getMasteryScore()
    {
        return masteryScore;
    }

    public void setMasteryStatus(String masteryStatus)
    {
        this.masteryStatus = masteryStatus;
    }

    public String getMasteryStatus()
    {
        return masteryStatus;
    }

    public void setWeightFactors(String weightFactors)
    {
        this.weightFactors = weightFactors;
    }

    public String getWeightFactors()
    {
        return weightFactors;
    }

    public void setLastUpdatedBy(String lastUpdatedBy)
    {
        this.lastUpdatedBy = lastUpdatedBy;
    }

    public String getLastUpdatedBy()
    {
        return lastUpdatedBy;
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
                .append("studentUserId", getStudentUserId())
                .append("courseId", getCourseId())
                .append("kpId", getKpId())
                .append("correctCount", getCorrectCount())
                .append("totalCount", getTotalCount())
                .append("accuracy", getAccuracy())
                .append("lastTestScore", getLastTestScore())
                .append("lastTestTime", getLastTestTime())
                .append("trend", getTrend())
                .append("masteryScore", getMasteryScore())
                .append("masteryStatus", getMasteryStatus())
                .append("weightFactors", getWeightFactors())
                .append("lastUpdatedBy", getLastUpdatedBy())
                .append("createTime", getCreateTime())
                .append("updateTime", getUpdateTime())
                .append("isDeleted", getIsDeleted())
                .toString();
    }
}
