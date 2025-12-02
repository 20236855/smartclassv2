package com.ruoyi.system.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 学生学习行为记录（视频/资源/互动行为）对象 student_learning_behavior
 * 
 * @author ruoyi
 * @date 2025-12-01
 */
public class StudentLearningBehavior extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 行为ID */
    private Long id;

    /** 学生user.id（关联user表） */
    @Excel(name = "学生user.id", readConverterExp = "关=联user表")
    private Long studentUserId;

    /** 所属课程ID（关联course表） */
    @Excel(name = "所属课程ID", readConverterExp = "关=联course表")
    private Long courseId;

    /** 行为类型：视频观看/资源查看/资源下载/评论 */
    @Excel(name = "行为类型：视频观看/资源查看/资源下载/评论")
    private String behaviorType;

    /** 行为目标ID：视频→section.id，资源→course_resource.id，评论→section_comment.id */
    @Excel(name = "行为目标ID：视频→section.id，资源→course_resource.id，评论→section_comment.id")
    private Long targetId;

    /** 目标类型（与target_id对应） */
    @Excel(name = "目标类型", readConverterExp = "与=target_id对应")
    private String targetType;

    /** 行为时长（秒）：视频观看/资源查看时长 */
    @Excel(name = "行为时长", readConverterExp = "秒=")
    private Long duration;

    /** 行为次数：视频重复观看次数/资源重复查看次数 */
    @Excel(name = "行为次数：视频重复观看次数/资源重复查看次数")
    private Long count;

    /** 行为详情：视频→{"start_time":120,"end_time":300,"is_replay":1}（开始秒/结束秒/是否重复）；资源→{"view_pages":"1-5","is_bookmark":0}（查看页数/是否收藏） */
    @Excel(name = "行为详情")
    private String detail;

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

    public void setBehaviorType(String behaviorType) 
    {
        this.behaviorType = behaviorType;
    }

    public String getBehaviorType() 
    {
        return behaviorType;
    }

    public void setTargetId(Long targetId) 
    {
        this.targetId = targetId;
    }

    public Long getTargetId() 
    {
        return targetId;
    }

    public void setTargetType(String targetType) 
    {
        this.targetType = targetType;
    }

    public String getTargetType() 
    {
        return targetType;
    }

    public void setDuration(Long duration) 
    {
        this.duration = duration;
    }

    public Long getDuration() 
    {
        return duration;
    }

    public void setCount(Long count) 
    {
        this.count = count;
    }

    public Long getCount() 
    {
        return count;
    }

    public void setDetail(String detail) 
    {
        this.detail = detail;
    }

    public String getDetail() 
    {
        return detail;
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
            .append("behaviorType", getBehaviorType())
            .append("targetId", getTargetId())
            .append("targetType", getTargetType())
            .append("duration", getDuration())
            .append("count", getCount())
            .append("detail", getDetail())
            .append("createTime", getCreateTime())
            .append("updateTime", getUpdateTime())
            .append("isDeleted", getIsDeleted())
            .toString();
    }
}
