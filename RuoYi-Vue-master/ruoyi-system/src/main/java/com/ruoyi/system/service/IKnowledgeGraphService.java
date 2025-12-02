package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.KnowledgeGraph;

/**
 * 知识图谱Service接口
 * 
 * @author ruoyi
 * @date 2025-11-21
 */
public interface IKnowledgeGraphService 
{
    /**
     * 查询知识图谱
     * 
     * @param id 知识图谱主键
     * @return 知识图谱
     */
    public KnowledgeGraph selectKnowledgeGraphById(Long id);

    /**
     * 查询知识图谱列表
     * 
     * @param knowledgeGraph 知识图谱
     * @return 知识图谱集合
     */
    public List<KnowledgeGraph> selectKnowledgeGraphList(KnowledgeGraph knowledgeGraph);

    /**
     * 新增知识图谱
     * 
     * @param knowledgeGraph 知识图谱
     * @return 结果
     */
    public int insertKnowledgeGraph(KnowledgeGraph knowledgeGraph);

    /**
     * 修改知识图谱
     * 
     * @param knowledgeGraph 知识图谱
     * @return 结果
     */
    public int updateKnowledgeGraph(KnowledgeGraph knowledgeGraph);

    /**
     * 批量删除知识图谱
     * 
     * @param ids 需要删除的知识图谱主键集合
     * @return 结果
     */
    public int deleteKnowledgeGraphByIds(Long[] ids);

    /**
     * 删除知识图谱信息
     * 
     * @param id 知识图谱主键
     * @return 结果
     */
    public int deleteKnowledgeGraphById(Long id);

    /**
     * 为指定课程生成知识图谱（最小可用实现，调用 AI 抽取服务）
     * @param courseId 课程ID
     */
    public void generateCourseGraph(Long courseId);

    /**
     * 为指定课程生成知识图谱（带创建者ID，用于异步调用）
     * @param courseId 课程ID
     * @param creatorId 创建者用户ID
     */
    public void generateCourseGraph(Long courseId, Long creatorId);

    /**
     * 为指定章节生成知识图谱（异步）
     * @param courseId 课程ID
     * @param chapterId 章节ID
     */
    public void generateChapterGraph(Long courseId, Long chapterId);

    /**
     * 为指定章节生成知识图谱（带创建者ID，用于异步调用）
     * @param courseId 课程ID
     * @param chapterId 章节ID
     * @param creatorId 创建者用户ID
     */
    public void generateChapterGraph(Long courseId, Long chapterId, Long creatorId);
}
