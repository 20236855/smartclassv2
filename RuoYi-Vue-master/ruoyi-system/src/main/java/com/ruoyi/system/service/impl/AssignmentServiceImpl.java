package com.ruoyi.system.service.impl;

import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.system.domain.Assignment;
import com.ruoyi.system.mapper.AssignmentMapper;
import com.ruoyi.system.service.IAssignmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * 作业或考试Service业务层处理
 *
 * @author ruoyi
 * @date 2025-11-18
 */
@Service
public class AssignmentServiceImpl implements IAssignmentService
{
    @Autowired
    private AssignmentMapper assignmentMapper;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 查询作业或考试
     *
     * @param id 作业或考试主键
     * @return 作业或考试
     */
    @Override
    public Assignment selectAssignmentById(Long id)
    {
        return assignmentMapper.selectAssignmentById(id);
    }

    /**
     * 查询作业或考试列表
     *
     * @param assignment 作业或考试
     * @return 作业或考试
     */
    @Override
    public List<Assignment> selectAssignmentList(Assignment assignment)
    {
        return assignmentMapper.selectAssignmentList(assignment);
    }

    /**
     * 新增作业或考试
     *
     * @param assignment 作业或考试
     * @return 结果
     */
    @Override
    public int insertAssignment(Assignment assignment)
    {
        assignment.setCreateTime(DateUtils.getNowDate());
        return assignmentMapper.insertAssignment(assignment);
    }

    /**
     * 修改作业或考试
     *
     * @param assignment 作业或考试
     * @return 结果
     */
    @Override
    public int updateAssignment(Assignment assignment)
    {
        assignment.setUpdateTime(DateUtils.getNowDate());
        return assignmentMapper.updateAssignment(assignment);
    }

    /**
     * 批量删除作业或考试
     *
     * @param ids 需要删除的作业或考试主键
     * @return 结果
     */
    @Override
    public int deleteAssignmentByIds(Long[] ids)
    {
        return assignmentMapper.deleteAssignmentByIds(ids);
    }

    /**
     * 删除作业或考试信息
     *
     * @param id 作业或考试主键
     * @return 结果
     */
    @Override
    public int deleteAssignmentById(Long id)
    {
        return assignmentMapper.deleteAssignmentById(id);
    }

    /**
     * 获取作业的题目列表（包含题目详情和选项）
     *
     * @param assignmentId 作业ID
     * @return 题目列表
     */
    @Override
    public List<Map<String, Object>> getAssignmentQuestions(Long assignmentId)
    {
        String sql = "SELECT " +
                "aq.id AS assignment_question_id, " +
                "aq.question_id, " +
                "aq.score, " +
                "aq.sequence, " +
                "q.title AS question_title, " +
                "q.question_type, " +
                "q.difficulty, " +
                "q.correct_answer, " +
                "q.explanation, " +
                "q.knowledge_point, " +
                "GROUP_CONCAT(CONCAT(qo.option_label, ':', qo.option_text) ORDER BY qo.option_label SEPARATOR '||') AS options " +
                "FROM assignment_question aq " +
                "JOIN question q ON aq.question_id = q.id " +
                "LEFT JOIN question_option qo ON q.id = qo.question_id " +
                "WHERE aq.assignment_id = ? AND aq.is_deleted = 0 AND q.is_deleted = 0 " +
                "GROUP BY aq.id, aq.question_id, aq.score, aq.sequence, q.title, q.question_type, q.difficulty, q.correct_answer, q.explanation, q.knowledge_point " +
                "ORDER BY aq.sequence";

        return jdbcTemplate.queryForList(sql, assignmentId);
    }
}
