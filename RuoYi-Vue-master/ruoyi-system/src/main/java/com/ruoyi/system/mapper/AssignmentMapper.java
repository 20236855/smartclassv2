package com.ruoyi.system.mapper;

import com.ruoyi.system.domain.Assignment;

import java.util.List;

/**
 * 作业或考试Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-18
 */
public interface AssignmentMapper
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
     * 删除作业或考试
     *
     * @param id 作业或考试主键
     * @return 结果
     */
    public int deleteAssignmentById(Long id);

    /**
     * 批量删除作业或考试
     *
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteAssignmentByIds(Long[] ids);
}
