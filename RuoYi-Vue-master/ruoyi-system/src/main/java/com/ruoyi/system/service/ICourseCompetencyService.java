package com.ruoyi.system.service;

import com.ruoyi.system.domain.CourseCompetency;

import java.util.List;

/**
 * 课程能力点（定义能力模型维度）Service接口
 *
 * @author ruoyi
 * @date 2025-11-20
 */
public interface ICourseCompetencyService
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
     * 批量删除课程能力点（定义能力模型维度）
     *
     * @param ids 需要删除的课程能力点（定义能力模型维度）主键集合
     * @return 结果
     */
    public int deleteCourseCompetencyByIds(Long[] ids);

    /**
     * 删除课程能力点（定义能力模型维度）信息
     *
     * @param id 课程能力点（定义能力模型维度）主键
     * @return 结果
     */
    public int deleteCourseCompetencyById(Long id);
}

