package com.ruoyi.system.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.StudentLearningBehaviorMapper;
import com.ruoyi.system.domain.StudentLearningBehavior;
import com.ruoyi.system.service.IStudentLearningBehaviorService;

/**
 * 学生学习行为记录（视频/资源/互动行为）Service业务层处理
 * 
 * @author ruoyi
 * @date 2025-12-01
 */
@Service
public class StudentLearningBehaviorServiceImpl implements IStudentLearningBehaviorService 
{
    @Autowired
    private StudentLearningBehaviorMapper studentLearningBehaviorMapper;

    /**
     * 查询学生学习行为记录（视频/资源/互动行为）
     * 
     * @param id 学生学习行为记录（视频/资源/互动行为）主键
     * @return 学生学习行为记录（视频/资源/互动行为）
     */
    @Override
    public StudentLearningBehavior selectStudentLearningBehaviorById(Long id)
    {
        return studentLearningBehaviorMapper.selectStudentLearningBehaviorById(id);
    }

    /**
     * 查询学生学习行为记录（视频/资源/互动行为）列表
     * 
     * @param studentLearningBehavior 学生学习行为记录（视频/资源/互动行为）
     * @return 学生学习行为记录（视频/资源/互动行为）
     */
    @Override
    public List<StudentLearningBehavior> selectStudentLearningBehaviorList(StudentLearningBehavior studentLearningBehavior)
    {
        return studentLearningBehaviorMapper.selectStudentLearningBehaviorList(studentLearningBehavior);
    }

    /**
     * 新增学生学习行为记录（视频/资源/互动行为）
     * 
     * @param studentLearningBehavior 学生学习行为记录（视频/资源/互动行为）
     * @return 结果
     */
    @Override
    public int insertStudentLearningBehavior(StudentLearningBehavior studentLearningBehavior)
    {
        studentLearningBehavior.setCreateTime(DateUtils.getNowDate());
        return studentLearningBehaviorMapper.insertStudentLearningBehavior(studentLearningBehavior);
    }

    /**
     * 修改学生学习行为记录（视频/资源/互动行为）
     * 
     * @param studentLearningBehavior 学生学习行为记录（视频/资源/互动行为）
     * @return 结果
     */
    @Override
    public int updateStudentLearningBehavior(StudentLearningBehavior studentLearningBehavior)
    {
        studentLearningBehavior.setUpdateTime(DateUtils.getNowDate());
        return studentLearningBehaviorMapper.updateStudentLearningBehavior(studentLearningBehavior);
    }

    /**
     * 批量删除学生学习行为记录（视频/资源/互动行为）
     * 
     * @param ids 需要删除的学生学习行为记录（视频/资源/互动行为）主键
     * @return 结果
     */
    @Override
    public int deleteStudentLearningBehaviorByIds(Long[] ids)
    {
        return studentLearningBehaviorMapper.deleteStudentLearningBehaviorByIds(ids);
    }

    /**
     * 删除学生学习行为记录（视频/资源/互动行为）信息
     * 
     * @param id 学生学习行为记录（视频/资源/互动行为）主键
     * @return 结果
     */
    @Override
    public int deleteStudentLearningBehaviorById(Long id)
    {
        return studentLearningBehaviorMapper.deleteStudentLearningBehaviorById(id);
    }
}
