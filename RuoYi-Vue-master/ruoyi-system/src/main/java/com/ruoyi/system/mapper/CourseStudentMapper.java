package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.CourseStudent;

/**
 * 学生选课Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-18
 */
public interface CourseStudentMapper
{
    public CourseStudent selectCourseStudentById(Long id);

    public List<CourseStudent> selectCourseStudentList(CourseStudent courseStudent);

    public int insertCourseStudent(CourseStudent courseStudent);

    public int updateCourseStudent(CourseStudent courseStudent);



    public int deleteCourseStudentById(Long id);

    public int deleteCourseStudentByIds(Long[] ids);

    /**
     * ⭐【关键新增】根据学生ID查询其已选的所有课程详情
     * @param studentUserId 学生用户ID
     * @return 课程列表
     */
    public List<com.ruoyi.system.domain.Course> selectMyCoursesByStudentId(Long studentUserId);
}