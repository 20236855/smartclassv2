package com.ruoyi.system.mapper;

import com.ruoyi.system.domain.StudentAnswer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 学生答题Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-24
 */
@Mapper
public interface StudentAnswerMapper {
    /**
     * 根据学生ID和作业ID查询答题记录
     */
    List<StudentAnswer> selectByUserIdAndAssignmentId(
            @Param("studentUserId") Long studentUserId,
            @Param("assignmentId") Long assignmentId);
}
