package com.ruoyi.system.service;

import com.ruoyi.system.domain.Assignment;

import java.util.List;
import java.util.Map;

/**
 * 作业或考试Service接口
 *
 * @author ruoyi
 * @date 2025-11-18
 */
public interface IAssignmentService
{
    /**
     * 查询作业或考试
     *
     * @param id 作业或考试主键
     * @return 作业或考试
     */
    public Assignment selectAssignmentById(Long id);

    /**
     * 查询作业或考试列表
     *
     * @param assignment 作业或考试
     * @return 作业或考试集合
     */
    public List<Assignment> selectAssignmentList(Assignment assignment);

    /**
     * 新增作业或考试
     *
     * @param assignment 作业或考试
     * @return 结果
     */
    public int insertAssignment(Assignment assignment);

    /**
     * 修改作业或考试
     *
     * @param assignment 作业或考试
     * @return 结果
     */
    public int updateAssignment(Assignment assignment);

    /**
     * 批量删除作业或考试
     *
     * @param ids 需要删除的作业或考试主键集合
     * @return 结果
     */
    public int deleteAssignmentByIds(Long[] ids);

    /**
     * 删除作业或考试信息
     *
     * @param id 作业或考试主键
     * @return 结果
     */
    public int deleteAssignmentById(Long id);

    /**
     * 获取作业的题目列表（包含题目详情和选项）
     *
     * @param assignmentId 作业ID
     * @return 题目列表
     */
    public List<Map<String, Object>> getAssignmentQuestions(Long assignmentId);
}
