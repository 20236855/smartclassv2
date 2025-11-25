package com.ruoyi.system.domain;

import java.util.Date;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 小节评论(讨论区)对象 section_comment
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public class SectionComment extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 评论ID，主键 */
    private Long id;

    /** 所属小节ID，外键 */
    @Excel(name = "所属小节ID，外键")
    private Long sectionId;

    /** 评论人ID，外键 */
    @Excel(name = "评论人ID，外键")
    private Long userId;

    /** 评论内容 */
    @Excel(name = "评论内容")
    private String content;

    /** 父评论ID，为NULL表示一级评论 */
    @Excel(name = "父评论ID，为NULL表示一级评论")
    private Long parentId;

    /** $column.columnComment */
    private Integer isDeleted;

    /** $column.columnComment */
    private Date deleteTime;

    public void setId(Long id) 
    {
        this.id = id;
    }

    public Long getId() 
    {
        return id;
    }

    public void setSectionId(Long sectionId) 
    {
        this.sectionId = sectionId;
    }

    public Long getSectionId() 
    {
        return sectionId;
    }

    public void setUserId(Long userId) 
    {
        this.userId = userId;
    }

    public Long getUserId() 
    {
        return userId;
    }

    public void setContent(String content) 
    {
        this.content = content;
    }

    public String getContent() 
    {
        return content;
    }

    public void setParentId(Long parentId) 
    {
        this.parentId = parentId;
    }

    public Long getParentId() 
    {
        return parentId;
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

    private String nickName; // 用户昵称
    private String avatar;   // 用户头像
    private java.util.List<SectionComment> children = new java.util.ArrayList<>(); // 子评论列表

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public java.util.List<SectionComment> getChildren() {
        return children;
    }

    public void setChildren(java.util.List<SectionComment> children) {
        this.children = children;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("id", getId())
            .append("sectionId", getSectionId())
            .append("userId", getUserId())
            .append("content", getContent())
            .append("parentId", getParentId())
            .append("createTime", getCreateTime())
            .append("updateTime", getUpdateTime())
            .append("isDeleted", getIsDeleted())
            .append("deleteTime", getDeleteTime())
            .toString();
    }
}
