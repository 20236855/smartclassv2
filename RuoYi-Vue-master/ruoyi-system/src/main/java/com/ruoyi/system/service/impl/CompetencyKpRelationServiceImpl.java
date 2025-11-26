package com.ruoyi.system.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.system.domain.CompetencyKpRelation;
import com.ruoyi.system.domain.vo.CompetencyRadarVo;
import com.ruoyi.system.mapper.CompetencyKpRelationMapper;
import com.ruoyi.system.service.ICompetencyKpRelationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 能力点-知识点关联（支撑能力模型与知识点的映射）Service业务层处理
 *
 * @author ruoyi
 * @date 2025-11-20
 */
@Service
public class CompetencyKpRelationServiceImpl implements ICompetencyKpRelationService
{
    @Autowired
    private CompetencyKpRelationMapper competencyKpRelationMapper;

    /**
     * 查询能力点-知识点关联（支撑能力模型与知识点的映射）
     *
     * @param id 能力点-知识点关联（支撑能力模型与知识点的映射）主键
     * @return 能力点-知识点关联（支撑能力模型与知识点的映射）
     */
    @Override
    public CompetencyKpRelation selectCompetencyKpRelationById(Long id)
    {
        return competencyKpRelationMapper.selectCompetencyKpRelationById(id);
    }

    /**
     * 查询能力点-知识点关联（支撑能力模型与知识点的映射）列表
     *
     * @param competencyKpRelation 能力点-知识点关联（支撑能力模型与知识点的映射）
     * @return 能力点-知识点关联（支撑能力模型与知识点的映射）
     */
    @Override
    public List<CompetencyKpRelation> selectCompetencyKpRelationList(CompetencyKpRelation competencyKpRelation)
    {
        return competencyKpRelationMapper.selectCompetencyKpRelationList(competencyKpRelation);
    }

    /**
     * 新增能力点-知识点关联（支撑能力模型与知识点的映射）
     *
     * @param competencyKpRelation 能力点-知识点关联（支撑能力模型与知识点的映射）
     * @return 结果
     */
    @Override
    public int insertCompetencyKpRelation(CompetencyKpRelation competencyKpRelation)
    {
        competencyKpRelation.setCreateTime(DateUtils.getNowDate());
        return competencyKpRelationMapper.insertCompetencyKpRelation(competencyKpRelation);
    }

    /**
     * 修改能力点-知识点关联（支撑能力模型与知识点的映射）
     *
     * @param competencyKpRelation 能力点-知识点关联（支撑能力模型与知识点的映射）
     * @return 结果
     */
    @Override
    public int updateCompetencyKpRelation(CompetencyKpRelation competencyKpRelation)
    {
        return competencyKpRelationMapper.updateCompetencyKpRelation(competencyKpRelation);
    }

    /**
     * 批量删除能力点-知识点关联（支撑能力模型与知识点的映射）
     *
     * @param ids 需要删除的能力点-知识点关联（支撑能力模型与知识点的映射）主键
     * @return 结果
     */
    @Override
    public int deleteCompetencyKpRelationByIds(Long[] ids)
    {
        return competencyKpRelationMapper.deleteCompetencyKpRelationByIds(ids);
    }

    /**
     * 删除能力点-知识点关联（支撑能力模型与知识点的映射）信息
     *
     * @param id 能力点-知识点关联（支撑能力模型与知识点的映射）主键
     * @return 结果
     */
    @Override
    public int deleteCompetencyKpRelationById(Long id)
    {
        return competencyKpRelationMapper.deleteCompetencyKpRelationById(id);
    }
    @Override
    public List<CompetencyRadarVo> getCompetencyRadarData(Long studentId, Long courseId) {
        return competencyKpRelationMapper.getCompetencyRadarData(studentId, courseId);
    }
}

