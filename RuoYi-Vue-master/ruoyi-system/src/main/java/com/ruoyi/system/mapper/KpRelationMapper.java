package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.KpRelation;

/**
 * 知识点关系Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-22
 */
public interface KpRelationMapper
{
    public KpRelation selectKpRelationById(Long id);

    public List<KpRelation> selectKpRelationList(KpRelation kpRelation);

    public int insertKpRelation(KpRelation kpRelation);

    public int updateKpRelation(KpRelation kpRelation);

    public int deleteKpRelationById(Long id);

    public int deleteKpRelationByIds(Long[] ids);
}
