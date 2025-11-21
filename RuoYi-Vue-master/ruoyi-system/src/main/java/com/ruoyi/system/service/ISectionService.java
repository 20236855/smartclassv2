package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.Section;

/**
 * 课程小节Service接口
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public interface ISectionService 
{
    /**
     * 查询课程小节
     * 
     * @param id 课程小节主键
     * @return 课程小节
     */
    public Section selectSectionById(Long id);

    /**
     * 查询课程小节列表
     * 
     * @param section 课程小节
     * @return 课程小节集合
     */
    public List<Section> selectSectionList(Section section);

    /**
     * 新增课程小节
     * 
     * @param section 课程小节
     * @return 结果
     */
    public int insertSection(Section section);

    /**
     * 修改课程小节
     * 
     * @param section 课程小节
     * @return 结果
     */
    public int updateSection(Section section);

    /**
     * 批量删除课程小节
     * 
     * @param ids 需要删除的课程小节主键集合
     * @return 结果
     */
    public int deleteSectionByIds(Long[] ids);

    /**
     * 删除课程小节信息
     * 
     * @param id 课程小节主键
     * @return 结果
     */
    public int deleteSectionById(Long id);
}
