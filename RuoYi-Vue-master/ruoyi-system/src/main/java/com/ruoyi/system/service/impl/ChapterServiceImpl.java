package com.ruoyi.system.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.ChapterMapper;
import com.ruoyi.system.domain.Chapter;
import com.ruoyi.system.service.IChapterService;

/**
 * 课程章节Service业务层处理
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
@Service
public class ChapterServiceImpl implements IChapterService 
{
    @Autowired
    private ChapterMapper chapterMapper;

    /**
     * 查询课程章节
     * 
     * @param id 课程章节主键
     * @return 课程章节
     */
    @Override
    public Chapter selectChapterById(Long id)
    {
        return chapterMapper.selectChapterById(id);
    }

    /**
     * 查询课程章节列表
     * 
     * @param chapter 课程章节
     * @return 课程章节
     */
    @Override
    public List<Chapter> selectChapterList(Chapter chapter)
    {
        return chapterMapper.selectChapterList(chapter);
    }

    /**
     * 新增课程章节
     * 
     * @param chapter 课程章节
     * @return 结果
     */
    @Override
    public int insertChapter(Chapter chapter)
    {
        chapter.setCreateTime(DateUtils.getNowDate());
        return chapterMapper.insertChapter(chapter);
    }

    /**
     * 修改课程章节
     * 
     * @param chapter 课程章节
     * @return 结果
     */
    @Override
    public int updateChapter(Chapter chapter)
    {
        chapter.setUpdateTime(DateUtils.getNowDate());
        return chapterMapper.updateChapter(chapter);
    }

    /**
     * 批量删除课程章节
     * 
     * @param ids 需要删除的课程章节主键
     * @return 结果
     */
    @Override
    public int deleteChapterByIds(Long[] ids)
    {
        return chapterMapper.deleteChapterByIds(ids);
    }

    /**
     * 删除课程章节信息
     * 
     * @param id 课程章节主键
     * @return 结果
     */
    @Override
    public int deleteChapterById(Long id)
    {
        return chapterMapper.deleteChapterById(id);
    }
}
