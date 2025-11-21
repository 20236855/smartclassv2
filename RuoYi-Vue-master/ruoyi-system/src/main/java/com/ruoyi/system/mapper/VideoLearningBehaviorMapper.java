package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.VideoLearningBehavior;

/**
 * 视频学习行为Mapper接口
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public interface VideoLearningBehaviorMapper 
{
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
}
