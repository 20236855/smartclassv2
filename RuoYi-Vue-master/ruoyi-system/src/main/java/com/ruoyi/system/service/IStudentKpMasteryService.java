package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.StudentKpMastery;

/**
 * 学生知识点掌握情况（支撑知识图谱状态标识）Service接口
 *
 * @author ruoyi
 * @date 2025-11-20
 */
public interface IStudentKpMasteryService
{
    /**
     * 查询学生知识点掌握情况（支撑知识图谱状态标识）
     *
     * @param id 学生知识点掌握情况（支撑知识图谱状态标识）主键
     * @return 学生知识点掌握情况（支撑知识图谱状态标识）
     */
    public StudentKpMastery selectStudentKpMasteryById(Long id);

    /**
     * 查询学生知识点掌握情况（支撑知识图谱状态标识）列表
     *
     * @param studentKpMastery 学生知识点掌握情况（支撑知识图谱状态标识）
     * @return 学生知识点掌握情况（支撑知识图谱状态标识）集合
     */
    public List<StudentKpMastery> selectStudentKpMasteryList(StudentKpMastery studentKpMastery);

    /**
     * 新增学生知识点掌握情况（支撑知识图谱状态标识）
     *
     * @param studentKpMastery 学生知识点掌握情况（支撑知识图谱状态标识）
     * @return 结果
     */
    public int insertStudentKpMastery(StudentKpMastery studentKpMastery);

    /**
     * 修改学生知识点掌握情况（支撑知识图谱状态标识）
     *
     * @param studentKpMastery 学生知识点掌握情况（支撑知识图谱状态标识）
     * @return 结果
     */
    public int updateStudentKpMastery(StudentKpMastery studentKpMastery);

    /**
     * 批量删除学生知识点掌握情况（支撑知识图谱状态标识）
     *
     * @param ids 需要删除的学生知识点掌握情况（支撑知识图谱状态标识）主键集合
     * @return 结果
     */
    public int deleteStudentKpMasteryByIds(Long[] ids);

    /**
     * 删除学生知识点掌握情况（支撑知识图谱状态标识）信息
     *
     * @param id 学生知识点掌握情况（支撑知识图谱状态标识）主键
     * @return 结果
     */
    public int deleteStudentKpMasteryById(Long id);
}
