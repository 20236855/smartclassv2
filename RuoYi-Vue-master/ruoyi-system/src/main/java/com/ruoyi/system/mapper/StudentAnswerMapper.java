package com.ruoyi.system.mapper;

import com.ruoyi.system.domain.StudentAnswer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

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

    /**
     * 查询学生在某课程下实际答题的所有作业ID（去重）
     */
    List<Long> selectDistinctAssignmentIdsByStudentAndCourse(
            @Param("studentUserId") Long studentUserId,
            @Param("courseId") Long courseId);
    List<Map<String, Object>> selectStudentWrongQuestions(@Param("studentUserId") Long studentUserId);
    /**
     * 查询学生在某课程下的最新答题提交时间
     */
    LocalDateTime selectLatestSubmitTimeByStudentAndCourse(@Param("studentUserId") Long studentUserId, @Param("courseId") Long courseId);
}