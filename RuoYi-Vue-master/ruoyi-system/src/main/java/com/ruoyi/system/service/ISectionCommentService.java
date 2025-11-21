package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SectionComment;

/**
 * 小节评论(讨论区)Service接口
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public interface ISectionCommentService 
{
    /**
     * 查询小节评论(讨论区)
     * 
     * @param id 小节评论(讨论区)主键
     * @return 小节评论(讨论区)
     */
    public SectionComment selectSectionCommentById(Long id);

    /**
     * 查询小节评论(讨论区)列表
     * 
     * @param sectionComment 小节评论(讨论区)
     * @return 小节评论(讨论区)集合
     */
    public List<SectionComment> selectSectionCommentList(SectionComment sectionComment);

    /**
     * 新增小节评论(讨论区)
     * 
     * @param sectionComment 小节评论(讨论区)
     * @return 结果
     */
    public int insertSectionComment(SectionComment sectionComment);

    /**
     * 修改小节评论(讨论区)
     * 
     * @param sectionComment 小节评论(讨论区)
     * @return 结果
     */
    public int updateSectionComment(SectionComment sectionComment);

    /**
     * 批量删除小节评论(讨论区)
     * 
     * @param ids 需要删除的小节评论(讨论区)主键集合
     * @return 结果
     */
    public int deleteSectionCommentByIds(Long[] ids);

    /**
     * 删除小节评论(讨论区)信息
     * 
     * @param id 小节评论(讨论区)主键
     * @return 结果
     */
    public int deleteSectionCommentById(Long id);
    public List<SectionComment> selectCommentTreeBySectionId(Long sectionId);
}
