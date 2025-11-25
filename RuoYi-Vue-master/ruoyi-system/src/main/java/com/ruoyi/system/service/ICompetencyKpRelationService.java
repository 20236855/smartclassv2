package com.ruoyi.system.service;

import com.ruoyi.system.domain.CompetencyKpRelation;
import com.ruoyi.system.domain.vo.CompetencyRadarVo;

import java.util.List;

/**
 * 能力点-知识点关联（支撑能力模型与知识点的映射）Service接口
 *
 * @author ruoyi
 * @date 2025-11-20
 */
public interface ICompetencyKpRelationService
{
    /**
     * 查询能力点-知识点关联（支撑能力模型与知识点的映射）
     *
     * @param id 能力点-知识点关联（支撑能力模型与知识点的映射）主键
     * @return 能力点-知识点关联（支撑能力模型与知识点的映射）
     */
    public CompetencyKpRelation selectCompetencyKpRelationById(Long id);

    /**
     * 查询能力点-知识点关联（支撑能力模型与知识点的映射）列表
     *
     * @param competencyKpRelation 能力点-知识点关联（支撑能力模型与知识点的映射）
     * @return 能力点-知识点关联（支撑能力模型与知识点的映射）集合
     */
    public List<CompetencyKpRelation> selectCompetencyKpRelationList(CompetencyKpRelation competencyKpRelation);

    /**
     * 新增能力点-知识点关联（支撑能力模型与知识点的映射）
     *
     * @param competencyKpRelation 能力点-知识点关联（支撑能力模型与知识点的映射）
     * @return 结果
     */
    public int insertCompetencyKpRelation(CompetencyKpRelation competencyKpRelation);

    /**
     * 修改能力点-知识点关联（支撑能力模型与知识点的映射）
     *
     * @param competencyKpRelation 能力点-知识点关联（支撑能力模型与知识点的映射）
     * @return 结果
     */
    public int updateCompetencyKpRelation(CompetencyKpRelation competencyKpRelation);

    /**
     * 批量删除能力点-知识点关联（支撑能力模型与知识点的映射）
     *
     * @param ids 需要删除的能力点-知识点关联（支撑能力模型与知识点的映射）主键集合
     * @return 结果
     */
    public int deleteCompetencyKpRelationByIds(Long[] ids);

    /**
     * 删除能力点-知识点关联（支撑能力模型与知识点的映射）信息
     *
     * @param id 能力点-知识点关联（支撑能力模型与知识点的映射）主键
     * @return 结果
     */
    public int deleteCompetencyKpRelationById(Long id);
    /**
     * 新增：获取能力雷达图数据
     * @param studentId 学生ID
     * @param courseId 课程ID
     * @return 能力点名称+加权分数
     */
    List<CompetencyRadarVo> getCompetencyRadarData(Long studentId, Long courseId);
}

