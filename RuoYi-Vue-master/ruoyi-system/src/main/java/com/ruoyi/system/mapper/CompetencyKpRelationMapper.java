package com.ruoyi.system.mapper;


import java.util.List;
import com.ruoyi.system.domain.CompetencyKpRelation;
import com.ruoyi.system.domain.vo.CompetencyRadarVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
@Mapper
/**
 * 能力点-知识点关联（支撑能力模型与知识点的映射）Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-20
 */
public interface CompetencyKpRelationMapper
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
     * 删除能力点-知识点关联（支撑能力模型与知识点的映射）
     *
     * @param id 能力点-知识点关联（支撑能力模型与知识点的映射）主键
     * @return 结果
     */
    public int deleteCompetencyKpRelationById(Long id);

    /**
     * 批量删除能力点-知识点关联（支撑能力模型与知识点的映射）
     *
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteCompetencyKpRelationByIds(Long[] ids);
    // ========== 新增：雷达图数据查询方法（必须在这个接口中，因为SQL在对应的XML里） ==========
    /**
     * 根据学生ID和课程ID查询能力雷达图数据
     * @param studentId 学生ID（对应student_kp_mastery.student_user_id）
     * @param courseId 课程ID（对应course_competency.course_id）
     * @return 能力名称+加权分数
     */
    List<CompetencyRadarVo> getCompetencyRadarData(
            @Param("studentId") Long studentId,
            @Param("courseId") Long courseId
    );
}

