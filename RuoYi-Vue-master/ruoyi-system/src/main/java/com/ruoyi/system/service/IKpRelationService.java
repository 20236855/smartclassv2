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
}
