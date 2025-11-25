package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.CourseCompetency;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
@Mapper
/**
 * 课程能力点（定义能力模型维度）Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-20
 */
public interface CourseCompetencyMapper
{
    /**
     * 查询课程能力点（定义能力模型维度）
     *
     * @param id 课程能力点（定义能力模型维度）主键
     * @return 课程能力点（定义能力模型维度）
     */
    public CourseCompetency selectCourseCompetencyById(Long id);

    /**
     * 查询课程能力点（定义能力模型维度）列表
     *
     * @param courseCompetency 课程能力点（定义能力模型维度）
     * @return 课程能力点（定义能力模型维度）集合
     */
    public List<CourseCompetency> selectCourseCompetencyList(CourseCompetency courseCompetency);

    /**
     * 新增课程能力点（定义能力模型维度）
     *
     * @param courseCompetency 课程能力点（定义能力模型维度）
     * @return 结果
     */
    public int insertCourseCompetency(CourseCompetency courseCompetency);

    /**
     * 修改课程能力点（定义能力模型维度）
     *
     * @param courseCompetency 课程能力点（定义能力模型维度）
     * @return 结果
     */
    public int updateCourseCompetency(CourseCompetency courseCompetency);

    /**
     * 删除课程能力点（定义能力模型维度）
     *
     * @param id 课程能力点（定义能力模型维度）主键
     * @return 结果
     */
    public int deleteCourseCompetencyById(Long id);

    /**
     * 批量删除课程能力点（定义能力模型维度）
     *
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteCourseCompetencyByIds(Long[] ids);
}

