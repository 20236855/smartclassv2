package com.ruoyi.system.mapper;

import com.ruoyi.system.domain.AssignmentSubmission;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 作业提交Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-24
 */
@Mapper
public interface AssignmentSubmissionMapper {
    /**
     * 根据学生ID和作业ID查询提交记录
     */
    AssignmentSubmission selectByUserIdAndAssignmentId(
            @Param("studentUserId") Long studentUserId,
            @Param("assignmentId") Long assignmentId);
}
