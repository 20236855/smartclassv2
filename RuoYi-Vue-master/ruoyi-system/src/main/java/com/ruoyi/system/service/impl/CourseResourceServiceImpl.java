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
        // 验证文件类型：禁止上传视频文件到课程资源表
        // 视频应该通过Section表的video_url字段存储
        String fileType = courseResource.getFileType();
        if (fileType != null) {
            String lowerFileType = fileType.toLowerCase();
            if (lowerFileType.equals("mp4") || lowerFileType.equals("avi") ||
                lowerFileType.equals("mov") || lowerFileType.equals("wmv") ||
                lowerFileType.equals("flv") || lowerFileType.equals("mkv") ||
                lowerFileType.equals("webm") || lowerFileType.equals("video")) {
                throw new RuntimeException("视频文件不应上传到课程资源，请通过课程章节的小节视频功能上传");
            }
        }

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
        // 验证文件类型：禁止修改为视频文件类型
        String fileType = courseResource.getFileType();
        if (fileType != null) {
            String lowerFileType = fileType.toLowerCase();
            if (lowerFileType.equals("mp4") || lowerFileType.equals("avi") ||
                lowerFileType.equals("mov") || lowerFileType.equals("wmv") ||
                lowerFileType.equals("flv") || lowerFileType.equals("mkv") ||
                lowerFileType.equals("webm") || lowerFileType.equals("video")) {
                throw new RuntimeException("视频文件不应上传到课程资源，请通过课程章节的小节视频功能上传");
            }
        }

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
