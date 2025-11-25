package com.ruoyi.system.mapper;

import com.ruoyi.system.domain.AssignmentQuestion;
import com.ruoyi.system.domain.vo.QuestionKpRelationVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

/**
 * 作业-题目关联Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-21
 */
@Mapper
public interface AssignmentQuestionMapper {
    /**
     * 查询作业-题目关联
     *
     * @param id 作业-题目关联主键
     * @return 作业-题目关联
     */
    public AssignmentQuestion selectAssignmentQuestionById(Long id);

    /**
     * 查询作业-题目关联列表
     *
     * @param assignmentQuestion 作业-题目关联
     * @return 作业-题目关联集合
     */
    public List<AssignmentQuestion> selectAssignmentQuestionList(AssignmentQuestion assignmentQuestion);

    /**
     * 新增作业-题目关联
     *
     * @param assignmentQuestion 作业-题目关联
     * @return 结果
     */
    public int insertAssignmentQuestion(AssignmentQuestion assignmentQuestion);

    /**
     * 修改作业-题目关联
     *
     * @param assignmentQuestion 作业-题目关联
     * @return 结果
     */
    public int updateAssignmentQuestion(AssignmentQuestion assignmentQuestion);

    /**
     * 删除作业-题目关联
     *
     * @param id 作业-题目关联主键
     * @return 结果
     */
    public int deleteAssignmentQuestionById(Long id);

    /**
     * 批量删除作业-题目关联
     *
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteAssignmentQuestionByIds(Long[] ids);

    List<QuestionKpRelationVo> selectQuestionKpRelation(Map<String, Object> params);
}
