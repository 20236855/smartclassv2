package com.ruoyi.system.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.KpRelationMapper;
import com.ruoyi.system.domain.KpRelation;
import com.ruoyi.system.service.IKpRelationService;

/**
 * 知识点关系Service业务层处理
 *
 * @author ruoyi
 * @date 2025-11-22
 */
@Service
public class KpRelationServiceImpl implements IKpRelationService
{
    @Autowired
    private KpRelationMapper kpRelationMapper;

    @Override
    public KpRelation selectKpRelationById(Long id)
    {
        return kpRelationMapper.selectKpRelationById(id);
    }

    @Override
    public List<KpRelation> selectKpRelationList(KpRelation kpRelation)
    {
        return kpRelationMapper.selectKpRelationList(kpRelation);
    }

    @Override
    public int insertKpRelation(KpRelation kpRelation)
    {
        kpRelation.setCreateTime(DateUtils.getNowDate());
        return kpRelationMapper.insertKpRelation(kpRelation);
    }

    @Override
    public int updateKpRelation(KpRelation kpRelation)
    {
        return kpRelationMapper.updateKpRelation(kpRelation);
    }

    @Override
    public int deleteKpRelationByIds(Long[] ids)
    {
        return kpRelationMapper.deleteKpRelationByIds(ids);
    }

    @Override
    public int deleteKpRelationById(Long id)
    {
        return kpRelationMapper.deleteKpRelationById(id);
    }
}
