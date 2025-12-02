package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.StudentLearningBehavior;

/**
 * 学生学习行为记录（视频/资源/互动行为）Mapper接口
 * 
 * @author ruoyi
 * @date 2025-12-01
 */
public interface StudentLearningBehaviorMapper 
{
    /**
     * 查询学生学习行为记录（视频/资源/互动行为）
     * 
     * @param id 学生学习行为记录（视频/资源/互动行为）主键
     * @return 学生学习行为记录（视频/资源/互动行为）
     */
    public StudentLearningBehavior selectStudentLearningBehaviorById(Long id);

    /**
     * 查询学生学习行为记录（视频/资源/互动行为）列表
     * 
     * @param studentLearningBehavior 学生学习行为记录（视频/资源/互动行为）
     * @return 学生学习行为记录（视频/资源/互动行为）集合
     */
    public List<StudentLearningBehavior> selectStudentLearningBehaviorList(StudentLearningBehavior studentLearningBehavior);

    /**
     * 新增学生学习行为记录（视频/资源/互动行为）
     * 
     * @param studentLearningBehavior 学生学习行为记录（视频/资源/互动行为）
     * @return 结果
     */
    public int insertStudentLearningBehavior(StudentLearningBehavior studentLearningBehavior);

    /**
     * 修改学生学习行为记录（视频/资源/互动行为）
     * 
     * @param studentLearningBehavior 学生学习行为记录（视频/资源/互动行为）
     * @return 结果
     */
    public int updateStudentLearningBehavior(StudentLearningBehavior studentLearningBehavior);

    /**
     * 删除学生学习行为记录（视频/资源/互动行为）
     * 
     * @param id 学生学习行为记录（视频/资源/互动行为）主键
     * @return 结果
     */
    public int deleteStudentLearningBehaviorById(Long id);

    /**
     * 批量删除学生学习行为记录（视频/资源/互动行为）
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteStudentLearningBehaviorByIds(Long[] ids);
}
