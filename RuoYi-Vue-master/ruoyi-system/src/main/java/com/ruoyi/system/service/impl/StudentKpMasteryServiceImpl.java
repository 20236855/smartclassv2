package com.ruoyi.system.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.system.domain.StudentKpMastery;
import com.ruoyi.system.mapper.StudentKpMasteryMapper;
import com.ruoyi.system.service.IStudentKpMasteryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 学生知识点掌握情况（支撑知识图谱状态标识）Service业务层处理
 *
 * @author ruoyi
 * @date 2025-11-20
 */
@Service
public class StudentKpMasteryServiceImpl implements IStudentKpMasteryService
{
    @Autowired
    private StudentKpMasteryMapper studentKpMasteryMapper;

    /**
     * 查询学生知识点掌握情况（支撑知识图谱状态标识）
     *
     * @param id 学生知识点掌握情况（支撑知识图谱状态标识）主键
     * @return 学生知识点掌握情况（支撑知识图谱状态标识）
     */
    @Override
    public StudentKpMastery selectStudentKpMasteryById(Long id)
    {
        return studentKpMasteryMapper.selectStudentKpMasteryById(id);
    }

    /**
     * 查询学生知识点掌握情况（支撑知识图谱状态标识）列表
     *
     * @param studentKpMastery 学生知识点掌握情况（支撑知识图谱状态标识）
     * @return 学生知识点掌握情况（支撑知识图谱状态标识）
     */
    @Override
    public List<StudentKpMastery> selectStudentKpMasteryList(StudentKpMastery studentKpMastery)
    {
        return studentKpMasteryMapper.selectStudentKpMasteryList(studentKpMastery);
    }

    /**
     * 新增学生知识点掌握情况（支撑知识图谱状态标识）
     *
     * @param studentKpMastery 学生知识点掌握情况（支撑知识图谱状态标识）
     * @return 结果
     */
    @Override
    public int insertStudentKpMastery(StudentKpMastery studentKpMastery)
    {
        studentKpMastery.setCreateTime(DateUtils.getNowDate());
        return studentKpMasteryMapper.insertStudentKpMastery(studentKpMastery);
    }

    /**
     * 修改学生知识点掌握情况（支撑知识图谱状态标识）
     *
     * @param studentKpMastery 学生知识点掌握情况（支撑知识图谱状态标识）
     * @return 结果
     */
    @Override
    public int updateStudentKpMastery(StudentKpMastery studentKpMastery)
    {
        studentKpMastery.setUpdateTime(DateUtils.getNowDate());
        return studentKpMasteryMapper.updateStudentKpMastery(studentKpMastery);
    }

    /**
     * 批量删除学生知识点掌握情况（支撑知识图谱状态标识）
     *
     * @param ids 需要删除的学生知识点掌握情况（支撑知识图谱状态标识）主键
     * @return 结果
     */
    @Override
    public int deleteStudentKpMasteryByIds(Long[] ids)
    {
        return studentKpMasteryMapper.deleteStudentKpMasteryByIds(ids);
    }

    /**
     * 删除学生知识点掌握情况（支撑知识图谱状态标识）信息
     *
     * @param id 学生知识点掌握情况（支撑知识图谱状态标识）主键
     * @return 结果
     */
    @Override
    public int deleteStudentKpMasteryById(Long id)
    {
        return studentKpMasteryMapper.deleteStudentKpMasteryById(id);
    }
}
