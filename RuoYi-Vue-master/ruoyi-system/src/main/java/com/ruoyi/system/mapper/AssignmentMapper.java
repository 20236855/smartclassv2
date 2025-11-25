package com.ruoyi.system.mapper;

import com.ruoyi.system.domain.Assignment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 作业表Mapper（用于查询作业名称）
 */
@Mapper
public interface AssignmentMapper {

    /**
     * 根据作业ID查询未删除的作业（仅查核心字段：id、title、course_id）
     * @param id 作业ID
     * @return 作业实体（含名称）
     */
    Assignment selectAssignmentById(@Param("id") Long id);
}
