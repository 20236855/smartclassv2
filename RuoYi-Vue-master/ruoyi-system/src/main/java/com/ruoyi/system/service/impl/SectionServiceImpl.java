package com.ruoyi.system.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.SectionMapper;
import com.ruoyi.system.domain.Section;
import com.ruoyi.system.service.ISectionService;

/**
 * 课程小节Service业务层处理
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
@Service
public class SectionServiceImpl implements ISectionService 
{
    @Autowired
    private SectionMapper sectionMapper;

    /**
     * 查询课程小节
     * 
     * @param id 课程小节主键
     * @return 课程小节
     */
    @Override
    public Section selectSectionById(Long id)
    {
        return sectionMapper.selectSectionById(id);
    }

    /**
     * 查询课程小节列表
     * 
     * @param section 课程小节
     * @return 课程小节
     */
    @Override
    public List<Section> selectSectionList(Section section)
    {
        return sectionMapper.selectSectionList(section);
    }

    /**
     * 新增课程小节
     * 
     * @param section 课程小节
     * @return 结果
     */
    @Override
    public int insertSection(Section section)
    {
        section.setCreateTime(DateUtils.getNowDate());
        return sectionMapper.insertSection(section);
    }

    /**
     * 修改课程小节
     * 
     * @param section 课程小节
     * @return 结果
     */
    @Override
    public int updateSection(Section section)
    {
        section.setUpdateTime(DateUtils.getNowDate());
        return sectionMapper.updateSection(section);
    }

    /**
     * 批量删除课程小节
     * 
     * @param ids 需要删除的课程小节主键
     * @return 结果
     */
    @Override
    public int deleteSectionByIds(Long[] ids)
    {
        return sectionMapper.deleteSectionByIds(ids);
    }

    /**
     * 删除课程小节信息
     * 
     * @param id 课程小节主键
     * @return 结果
     */
    @Override
    public int deleteSectionById(Long id)
    {
        return sectionMapper.deleteSectionById(id);
    }
}
