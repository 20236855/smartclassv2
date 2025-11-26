package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.KnowledgeGraph;
import org.apache.ibatis.annotations.Mapper;

/**
 * 知识图谱Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-21
 */
@Mapper
public interface KnowledgeGraphMapper
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
     * 删除知识图谱
     *
     * @param id 知识图谱主键
     * @return 结果
     */
    public int deleteKnowledgeGraphById(Long id);

    /**
     * 批量删除知识图谱
     *
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteKnowledgeGraphByIds(Long[] ids);
}
