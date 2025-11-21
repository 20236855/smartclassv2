package com.ruoyi.system.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.CourseResourceMapper;
import com.ruoyi.system.domain.CourseResource;
import com.ruoyi.system.service.ICourseResourceService;

/**
 * 课程资源Service业务层处理
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
@Service
public class CourseResourceServiceImpl implements ICourseResourceService 
{
    @Autowired
    private CourseResourceMapper courseResourceMapper;

    /**
     * 查询课程资源
     * 
     * @param id 课程资源主键
     * @return 课程资源
     */
    @Override
    public CourseResource selectCourseResourceById(Long id)
    {
        return courseResourceMapper.selectCourseResourceById(id);
    }

    /**
     * 查询课程资源列表
     * 
     * @param courseResource 课程资源
     * @return 课程资源
     */
    @Override
    public List<CourseResource> selectCourseResourceList(CourseResource courseResource)
    {
        return courseResourceMapper.selectCourseResourceList(courseResource);
    }

    /**
     * 新增课程资源
     * 
     * @param courseResource 课程资源
     * @return 结果
     */
    @Override
    public int insertCourseResource(CourseResource courseResource)
    {
        courseResource.setCreateTime(DateUtils.getNowDate());
        return courseResourceMapper.insertCourseResource(courseResource);
    }

    /**
     * 修改课程资源
     * 
     * @param courseResource 课程资源
     * @return 结果
     */
    @Override
    public int updateCourseResource(CourseResource courseResource)
    {
        courseResource.setUpdateTime(DateUtils.getNowDate());
        return courseResourceMapper.updateCourseResource(courseResource);
    }

    /**
     * 批量删除课程资源
     * 
     * @param ids 需要删除的课程资源主键
     * @return 结果
     */
    @Override
    public int deleteCourseResourceByIds(Long[] ids)
    {
        return courseResourceMapper.deleteCourseResourceByIds(ids);
    }

    /**
     * 删除课程资源信息
     * 
     * @param id 课程资源主键
     * @return 结果
     */
    @Override
    public int deleteCourseResourceById(Long id)
    {
        return courseResourceMapper.deleteCourseResourceById(id);
    }

    /**
     * ⭐ 【核心新增】增加指定资源的下载次数
     */
    @Override
    public int incrementDownloadCount(Long id)
    {
        return courseResourceMapper.incrementDownloadCount(id);
    }
}
