package com.ruoyi.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.VideoLearningBehaviorMapper;
import com.ruoyi.system.domain.VideoLearningBehavior;
import com.ruoyi.system.service.IVideoLearningBehaviorService;

/**
 * 视频学习行为Service业务层处理
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
@Service
public class VideoLearningBehaviorServiceImpl implements IVideoLearningBehaviorService 
{
    @Autowired
    private VideoLearningBehaviorMapper videoLearningBehaviorMapper;

    /**
     * 查询视频学习行为
     * 
     * @param id 视频学习行为主键
     * @return 视频学习行为
     */
    @Override
    public VideoLearningBehavior selectVideoLearningBehaviorById(Long id)
    {
        return videoLearningBehaviorMapper.selectVideoLearningBehaviorById(id);
    }

    /**
     * 查询视频学习行为列表
     * 
     * @param videoLearningBehavior 视频学习行为
     * @return 视频学习行为
     */
    @Override
    public List<VideoLearningBehavior> selectVideoLearningBehaviorList(VideoLearningBehavior videoLearningBehavior)
    {
        return videoLearningBehaviorMapper.selectVideoLearningBehaviorList(videoLearningBehavior);
    }

    /**
     * 新增视频学习行为
     * 
     * @param videoLearningBehavior 视频学习行为
     * @return 结果
     */
    @Override
    public int insertVideoLearningBehavior(VideoLearningBehavior videoLearningBehavior)
    {
        return videoLearningBehaviorMapper.insertVideoLearningBehavior(videoLearningBehavior);
    }

    /**
     * 修改视频学习行为
     *
     * @param videoLearningBehavior 视频学习行为
     * @return 结果
     */
    @Override
    public int updateVideoLearningBehavior(VideoLearningBehavior videoLearningBehavior)
    {
        return videoLearningBehaviorMapper.updateVideoLearningBehavior(videoLearningBehavior);
    }

    /**
     * 插入或更新视频学习行为（UPSERT操作）
     *
     * @param videoLearningBehavior 视频学习行为
     * @return 结果
     */
    @Override
    public int upsertVideoLearningBehavior(VideoLearningBehavior videoLearningBehavior)
    {
        return videoLearningBehaviorMapper.upsertVideoLearningBehavior(videoLearningBehavior);
    }

    /**
     * 批量删除视频学习行为
     * 
     * @param ids 需要删除的视频学习行为主键
     * @return 结果
     */
    @Override
    public int deleteVideoLearningBehaviorByIds(Long[] ids)
    {
        return videoLearningBehaviorMapper.deleteVideoLearningBehaviorByIds(ids);
    }

    /**
     * 删除视频学习行为信息
     * 
     * @param id 视频学习行为主键
     * @return 结果
     */
    @Override
    public int deleteVideoLearningBehaviorById(Long id)
    {
        return videoLearningBehaviorMapper.deleteVideoLearningBehaviorById(id);
    }
}
