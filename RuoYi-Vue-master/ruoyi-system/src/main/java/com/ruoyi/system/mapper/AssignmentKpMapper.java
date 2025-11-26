package com.ruoyi.system.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 作业-知识点关联Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-24
 */
@Mapper
public interface AssignmentKpMapper {

    /**
     * 根据知识点ID集合查询关联的题目ID
     */
    List<Long> selectQuestionIdsByKpIds(@Param("kpIds") List<Long> kpIds);
}
