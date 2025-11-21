package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.SectionComment;
import org.apache.ibatis.annotations.Param;

/**
 * 小节评论(讨论区)Mapper接口
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public interface SectionCommentMapper 
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
     * 删除小节评论(讨论区)
     * 
     * @param id 小节评论(讨论区)主键
     * @return 结果
     */
    public int deleteSectionCommentById(Long id);

    /**
     * 批量删除小节评论(讨论区)
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteSectionCommentByIds(Long[] ids);

    public List<SectionComment> selectCommentsBySectionIdWithUserInfo(@Param("sectionId") Long sectionId);
}
