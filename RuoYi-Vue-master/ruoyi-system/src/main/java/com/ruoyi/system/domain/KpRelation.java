package com.ruoyi.system.domain;

import java.util.Date;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 知识点关系对象 kp_relation
 *
 * 前置/相似/进阶/推导/反例
 *
 * @author ruoyi
 * @date 2025-11-22
 */
public class KpRelation extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long id;

    @Excel(name = "源知识点 id")
    private Long fromKpId;

    @Excel(name = "目标知识点 id")
    private Long toKpId;

    @Excel(name = "关系类型")
    private String relationType;

    @Excel(name = "AI 生成")
    private Integer aiGenerated;

    private Date createTime;

    public void setId(Long id)
    {
        this.id = id;
    }

    public Long getId()
    {
        return id;
    }

    public void setFromKpId(Long fromKpId)
    {
        this.fromKpId = fromKpId;
    }

    public Long getFromKpId()
    {
        return fromKpId;
    }

    public void setToKpId(Long toKpId)
    {
        this.toKpId = toKpId;
    }

    public Long getToKpId()
    {
        return toKpId;
    }

    public void setRelationType(String relationType)
    {
        this.relationType = relationType;
    }

    public String getRelationType()
    {
        return relationType;
    }

    public void setAiGenerated(Integer aiGenerated)
    {
        this.aiGenerated = aiGenerated;
    }

    public Integer getAiGenerated()
    {
        return aiGenerated;
    }

    public void setCreateTime(Date createTime)
    {
        this.createTime = createTime;
    }

    public Date getCreateTime()
    {
        return createTime;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("id", getId())
            .append("fromKpId", getFromKpId())
            .append("toKpId", getToKpId())
            .append("relationType", getRelationType())
            .append("aiGenerated", getAiGenerated())
            .append("createTime", getCreateTime())
            .toString();
    }
}
