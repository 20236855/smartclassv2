package com.ruoyi.system.mapper;

import com.ruoyi.system.domain.PersonalizedRecommendation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 个性化推荐记录Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-21
 */
@Mapper
public interface PersonalizedRecommendationMapper {
    /**
     * 查询个性化推荐记录
     *
     * @param id 个性化推荐记录主键
     * @return 个性化推荐记录
     */
    public PersonalizedRecommendation selectPersonalizedRecommendationById(Long id);

    /**
     * 查询个性化推荐记录列表
     *
     * @param personalizedRecommendation 个性化推荐记录
     * @return 个性化推荐记录集合
     */
    public List<PersonalizedRecommendation> selectPersonalizedRecommendationList(PersonalizedRecommendation personalizedRecommendation);

    /**
     * 新增个性化推荐记录
     *
     * @param personalizedRecommendation 个性化推荐记录
     * @return 结果
     */
    public int insertPersonalizedRecommendation(PersonalizedRecommendation personalizedRecommendation);

    /**
     * 批量新增个性化推荐记录（新增：适配Service中的批量插入）
     *
     * @param list 个性化推荐记录集合
     * @return 结果
     */
    public int insertPersonalizedRecommendationBatch(List<PersonalizedRecommendation> list);

    /**
     * 修改个性化推荐记录
     *
     * @param personalizedRecommendation 个性化推荐记录
     * @return 结果
     */
    public int updatePersonalizedRecommendation(PersonalizedRecommendation personalizedRecommendation);

    /**
     * 删除个性化推荐记录
     *
     * @param id 个性化推荐记录主键
     * @return 结果
     */
    public int deletePersonalizedRecommendationById(Long id);

    /**
     * 批量删除个性化推荐记录
     *
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deletePersonalizedRecommendationByIds(Long[] ids);

    boolean existsDuplicate(
            @Param("studentUserId") Long studentUserId,
            @Param("courseId") Long courseId,
            @Param("recommendType") String recommendType,
            @Param("relatedKpIds") String relatedKpIds
    );
    //新增：查询学生+课程的有效推荐（未过期、未删除、状态为pending/viewed）
    List<PersonalizedRecommendation> selectValidRecommendations(
            @Param("studentUserId") Long studentUserId,
            @Param("courseId") Long courseId
    );
}
