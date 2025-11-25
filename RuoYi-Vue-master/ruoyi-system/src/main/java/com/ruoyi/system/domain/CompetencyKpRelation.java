package com.ruoyi.system.domain;

import java.math.BigDecimal;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 能力点-知识点关联（支撑能力模型与知识点的映射）对象 competency_kp_relation
 *
 * @author ruoyi
 * @date 2025-11-20
 */
public class CompetencyKpRelation extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 关联ID */
    private Long id;

    /** 能力点ID（关联course_competency表） */
    @Excel(name = "能力点ID", readConverterExp = "关=联course_competency表")
    private Long competencyId;

    /** 知识点ID（关联knowledge_point表） */
    @Excel(name = "知识点ID", readConverterExp = "关=联knowledge_point表")
    private Long kpId;

    /** 知识点对能力点的贡献度（0-1，用于加权计算能力得分） */
    @Excel(name = "知识点对能力点的贡献度", readConverterExp = "0=-1，用于加权计算能力得分")
    private BigDecimal contributionRate;

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

    public void setCompetencyId(Long competencyId)
    {
        this.competencyId = competencyId;
    }

    public Long getCompetencyId()
    {
        return competencyId;
    }

    public void setKpId(Long kpId)
    {
        this.kpId = kpId;
    }

    public Long getKpId()
    {
        return kpId;
    }

    public void setContributionRate(BigDecimal contributionRate)
    {
        this.contributionRate = contributionRate;
    }

    public BigDecimal getContributionRate()
    {
        return contributionRate;
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
                .append("competencyId", getCompetencyId())
                .append("kpId", getKpId())
                .append("contributionRate", getContributionRate())
                .append("createTime", getCreateTime())
                .append("isDeleted", getIsDeleted())
                .toString();
    }
}

