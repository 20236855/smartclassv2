package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.KpRelation;

/**
 * 知识点关系Service接口
 *
 * @author ruoyi
 * @date 2025-11-22
 */
public interface IKpRelationService
{
    public KpRelation selectKpRelationById(Long id);

    public List<KpRelation> selectKpRelationList(KpRelation kpRelation);

    public int insertKpRelation(KpRelation kpRelation);

    public int updateKpRelation(KpRelation kpRelation);

    public int deleteKpRelationByIds(Long[] ids);

    public int deleteKpRelationById(Long id);

    /**
     * 检查知识点关系是否已存在
     * 
     * @param sourceId 源知识点ID
     * @param targetId 目标知识点ID
     * @param relationType 关系类型
     * @return 是否存在
     */
    public boolean relationExists(Long sourceId, Long targetId, String relationType);
}
