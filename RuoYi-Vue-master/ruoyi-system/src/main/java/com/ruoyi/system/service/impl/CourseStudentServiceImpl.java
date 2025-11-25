package com.ruoyi.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.CourseStudentMapper;
import com.ruoyi.system.domain.CourseStudent;
import com.ruoyi.system.service.ICourseStudentService;

/**
 * 学生选课Service业务层处理
 *
 * @author ruoyi
 * @date 2025-11-18
 */
@Service
public class CourseStudentServiceImpl implements ICourseStudentService
{
    @Autowired
    private CourseStudentMapper courseStudentMapper;

    @Override
    public CourseStudent selectCourseStudentById(Long id)
    {
        return courseStudentMapper.selectCourseStudentById(id);
    }

    @Override
    public List<CourseStudent> selectCourseStudentList(CourseStudent courseStudent)
    {
        return courseStudentMapper.selectCourseStudentList(courseStudent);
    }

    @Override
    public int insertCourseStudent(CourseStudent courseStudent)
    {
        return courseStudentMapper.insertCourseStudent(courseStudent);
    }

    @Override
    public int updateCourseStudent(CourseStudent courseStudent)
    {
        return courseStudentMapper.updateCourseStudent(courseStudent);
    }

    @Override
    public int deleteCourseStudentByIds(Long[] ids)
    {
        return courseStudentMapper.deleteCourseStudentByIds(ids);
    }

    @Override
    public int deleteCourseStudentById(Long id)
    {
        return courseStudentMapper.deleteCourseStudentById(id);
    }

    /**
     * ⭐【关键新增】根据学生ID查询其已选的所有课程详情
     * @param studentUserId 学生用户ID
     * @return 课程列表
     */
    @Override
    public List<com.ruoyi.system.domain.Course> selectMyCoursesByStudentId(Long studentUserId)
    {
        return courseStudentMapper.selectMyCoursesByStudentId(studentUserId);
    }
}