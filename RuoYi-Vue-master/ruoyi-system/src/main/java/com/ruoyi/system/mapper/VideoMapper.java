package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.Video;

/**
 * 视频Mapper接口
 * 
 * @author ruoyi
 * @date 2025-11-20
 */
public interface VideoMapper 
{
    /**
     * 查询视频
     * 
     * @param id 视频主键
     * @return 视频
     */
    public Video selectVideoById(Long id);

    /**
     * 查询视频列表
     * 
     * @param video 视频
     * @return 视频集合
     */
    public List<Video> selectVideoList(Video video);

    /**
     * 新增视频
     * 
     * @param video 视频
     * @return 结果
     */
    public int insertVideo(Video video);

    /**
     * 修改视频
     * 
     * @param video 视频
     * @return 结果
     */
    public int updateVideo(Video video);

    /**
     * 删除视频
     * 
     * @param id 视频主键
     * @return 结果
     */
    public int deleteVideoById(Long id);

    /**
     * 批量删除视频
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteVideoByIds(Long[] ids);
}
