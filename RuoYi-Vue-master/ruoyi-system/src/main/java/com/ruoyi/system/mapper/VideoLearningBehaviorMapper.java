package com.ruoyi.system.mapper;

import com.ruoyi.system.domain.VideoLearningBehavior;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 视频学习行为Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-18
 */
@Mapper
public interface VideoLearningBehaviorMapper {
    /**
     * 查询视频学习行为
     *
     * @param id 视频学习行为主键
     * @return 视频学习行为
     */
    public VideoLearningBehavior selectVideoLearningBehaviorById(Long id);

    /**
     * 查询视频学习行为列表
     *
     * @param videoLearningBehavior 视频学习行为
     * @return 视频学习行为集合
     */
    public List<VideoLearningBehavior> selectVideoLearningBehaviorList(VideoLearningBehavior videoLearningBehavior);

    /**
     * 新增视频学习行为
     *
     * @param videoLearningBehavior 视频学习行为
     * @return 结果
     */
    public int insertVideoLearningBehavior(VideoLearningBehavior videoLearningBehavior);

    /**
     * 插入或更新视频学习行为（UPSERT操作）
     *
     * @param videoLearningBehavior 视频学习行为
     * @return 结果
     */
    public int upsertVideoLearningBehavior(VideoLearningBehavior videoLearningBehavior);

    /**
     * 修改视频学习行为
     *
     * @param videoLearningBehavior 视频学习行为
     * @return 结果
     */
    public int updateVideoLearningBehavior(VideoLearningBehavior videoLearningBehavior);

    /**
     * 删除视频学习行为
     *
     * @param id 视频学习行为主键
     * @return 结果
     */
    public int deleteVideoLearningBehaviorById(Long id);

    /**
     * 批量删除视频学习行为
     *
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteVideoLearningBehaviorByIds(Long[] ids);

    /**
     * 根据学生ID和课程ID查询视频学习记录
     * （保留本地业务所需的个性化查询方法）
     */
    List<VideoLearningBehavior> selectByUserIdAndCourseId(
            @Param("studentUserId") Long studentUserId,
            @Param("courseId") Long courseId);
}
