package com.ruoyi.system.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.SectionCommentMapper;
import com.ruoyi.system.domain.SectionComment;
import com.ruoyi.system.service.ISectionCommentService;

/**
 * 小节评论(讨论区)Service业务层处理
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
@Service
public class SectionCommentServiceImpl implements ISectionCommentService 
{
    @Autowired
    private SectionCommentMapper sectionCommentMapper;

    /**
     * 查询小节评论(讨论区)
     * 
     * @param id 小节评论(讨论区)主键
     * @return 小节评论(讨论区)
     */
    @Override
    public SectionComment selectSectionCommentById(Long id)
    {
        return sectionCommentMapper.selectSectionCommentById(id);
    }

    /**
     * 查询小节评论(讨论区)列表
     * 
     * @param sectionComment 小节评论(讨论区)
     * @return 小节评论(讨论区)
     */
    @Override
    public List<SectionComment> selectSectionCommentList(SectionComment sectionComment)
    {
        return sectionCommentMapper.selectSectionCommentList(sectionComment);
    }

    /**
     * 新增小节评论(讨论区)
     * 
     * @param sectionComment 小节评论(讨论区)
     * @return 结果
     */
    @Override
    public int insertSectionComment(SectionComment sectionComment)
    {
        sectionComment.setCreateTime(DateUtils.getNowDate());
        return sectionCommentMapper.insertSectionComment(sectionComment);
    }

    /**
     * 修改小节评论(讨论区)
     * 
     * @param sectionComment 小节评论(讨论区)
     * @return 结果
     */
    @Override
    public int updateSectionComment(SectionComment sectionComment)
    {
        sectionComment.setUpdateTime(DateUtils.getNowDate());
        return sectionCommentMapper.updateSectionComment(sectionComment);
    }

    /**
     * 批量删除小节评论(讨论区)
     * 
     * @param ids 需要删除的小节评论(讨论区)主键
     * @return 结果
     */
    @Override
    public int deleteSectionCommentByIds(Long[] ids)
    {
        return sectionCommentMapper.deleteSectionCommentByIds(ids);
    }

    /**
     * 删除小节评论(讨论区)信息
     * 
     * @param id 小节评论(讨论区)主键
     * @return 结果
     */
    @Override
    public int deleteSectionCommentById(Long id)
    {
        return sectionCommentMapper.deleteSectionCommentById(id);
    }
    @Override
    public List<SectionComment> selectCommentTreeBySectionId(Long sectionId)
    {
        // 1. 获取所有相关评论（您的XML中已有此方法，非常好！）
        List<SectionComment> allComments = sectionCommentMapper.selectCommentsBySectionIdWithUserInfo(sectionId);

        // 2. 将列表转为Map，便于快速查找父评论
        java.util.Map<Long, SectionComment> map = new java.util.HashMap<>();
        for (SectionComment comment : allComments) {
            map.put(comment.getId(), comment);
        }

        // 3. 构建树形结构
        List<SectionComment> treeList = new java.util.ArrayList<>();
        for (SectionComment comment : allComments) {
            // 如果是顶级评论
            if (comment.getParentId() == null || comment.getParentId() == 0) {
                treeList.add(comment);
            } else {
                // 如果是子评论，找到它的父评论并添加进去
                SectionComment parent = map.get(comment.getParentId());
                if (parent != null) {
                    // 确保父评论的children列表已初始化
                    if (parent.getChildren() == null) {
                        parent.setChildren(new java.util.ArrayList<>());
                    }
                    parent.getChildren().add(comment);
                }
            }
        }
        return treeList;
    }
}
