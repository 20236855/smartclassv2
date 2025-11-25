package com.ruoyi.system.mapper;

import com.ruoyi.system.domain.VideoLearningBehavior;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 视频学习行为Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-24
 */
@Mapper
public interface VideoLearningBehaviorMapper {

    /**
     * 根据学生ID和课程ID查询视频学习记录
     */
    List<VideoLearningBehavior> selectByUserIdAndCourseId(
            @Param("studentUserId") Long studentUserId,
            @Param("courseId") Long courseId);
}
