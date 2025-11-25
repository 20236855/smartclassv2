package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.Chapter;

/**
 * 课程章节Mapper接口
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public interface ChapterMapper 
{
    /**
     * 查询课程章节
     * 
     * @param id 课程章节主键
     * @return 课程章节
     */
    public Chapter selectChapterById(Long id);

    /**
     * 查询课程章节列表
     * 
     * @param chapter 课程章节
     * @return 课程章节集合
     */
    public List<Chapter> selectChapterList(Chapter chapter);

    /**
     * 新增课程章节
     * 
     * @param chapter 课程章节
     * @return 结果
     */
    public int insertChapter(Chapter chapter);

    /**
     * 修改课程章节
     * 
     * @param chapter 课程章节
     * @return 结果
     */
    public int updateChapter(Chapter chapter);

    /**
     * 删除课程章节
     * 
     * @param id 课程章节主键
     * @return 结果
     */
    public int deleteChapterById(Long id);

    /**
     * 批量删除课程章节
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteChapterByIds(Long[] ids);
}
