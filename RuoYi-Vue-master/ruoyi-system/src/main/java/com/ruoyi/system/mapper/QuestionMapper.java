package com.ruoyi.system.mapper;

import com.ruoyi.system.domain.Question;

import java.util.List;

/**
 * 题目Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-18
 */
public interface QuestionMapper
{
    /**
     * 查询题目
     *
     * @param id 题目主键
     * @return 题目
     */
    public Question selectQuestionById(Long id);

    /**
     * 查询题目列表
     *
     * @param question 题目
     * @return 题目集合
     */
    public List<Question> selectQuestionList(Question question);

    /**
     * 新增题目
     *
     * @param question 题目
     * @return 结果
     */
    public int insertQuestion(Question question);

    /**
     * 修改题目
     *
     * @param question 题目
     * @return 结果
     */
    public int updateQuestion(Question question);

    /**
     * 删除题目
     *
     * @param id 题目主键
     * @return 结果
     */
    public int deleteQuestionById(Long id);

    /**
     * 批量删除题目
     *
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteQuestionByIds(Long[] ids);
}
