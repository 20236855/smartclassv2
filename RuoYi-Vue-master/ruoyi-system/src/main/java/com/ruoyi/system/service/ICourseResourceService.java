package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.CourseResource;

/**
 * 课程资源Service接口
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public interface ICourseResourceService 
{
    /**
     * 查询课程资源
     * 
     * @param id 课程资源主键
     * @return 课程资源
     */
    public CourseResource selectCourseResourceById(Long id);

    /**
     * 查询课程资源列表
     * 
     * @param courseResource 课程资源
     * @return 课程资源集合
     */
    public List<CourseResource> selectCourseResourceList(CourseResource courseResource);

    /**
     * 新增课程资源
     * 
     * @param courseResource 课程资源
     * @return 结果
     */
    public int insertCourseResource(CourseResource courseResource);

    /**
     * 修改课程资源
     * 
     * @param courseResource 课程资源
     * @return 结果
     */
    public int updateCourseResource(CourseResource courseResource);

    /**
     * 批量删除课程资源
     * 
     * @param ids 需要删除的课程资源主键集合
     * @return 结果
     */
    public int deleteCourseResourceByIds(Long[] ids);

    /**
     * 删除课程资源信息
     * 
     * @param id 课程资源主键
     * @return 结果
     */
    public int deleteCourseResourceById(Long id);

    public int incrementDownloadCount(Long id);
}
