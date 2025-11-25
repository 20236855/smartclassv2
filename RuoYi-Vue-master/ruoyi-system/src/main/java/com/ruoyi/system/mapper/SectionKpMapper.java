package com.ruoyi.system.mapper;

import com.ruoyi.system.domain.SectionKp;
import com.ruoyi.system.domain.vo.KpResourceVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 小节-知识点关联Mapper接口
 *
 * @author ruoyi
 * @date 2025-11-21
 */
@Mapper
public interface SectionKpMapper {
    /**
     * 查询小节-知识点关联
     *
     * @param id 小节-知识点关联主键
     * @return 小节-知识点关联
     */
    public SectionKp selectSectionKpById(Long id);

    /**
     * 查询小节-知识点关联列表
     *
     * @param sectionKp 小节-知识点关联
     * @return 小节-知识点关联集合
     */
    public List<SectionKp> selectSectionKpList(SectionKp sectionKp);

    /**
     * 新增小节-知识点关联
     *
     * @param sectionKp 小节-知识点关联
     * @return 结果
     */
    public int insertSectionKp(SectionKp sectionKp);

    /**
     * 修改小节-知识点关联
     *
     * @param sectionKp 小节-知识点关联
     * @return 结果
     */
    public int updateSectionKp(SectionKp sectionKp);

    /**
     * 删除小节-知识点关联
     *
     * @param id 小节-知识点关联主键
     * @return 结果
     */
    public int deleteSectionKpById(Long id);

    /**
     * 批量删除小节-知识点关联
     *
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteSectionKpByIds(Long[] ids);

    /**
     * 自定义方法：查询课程下知识点对应的资源（小节+视频）
     *
     * @param courseId 课程ID
     * @return 知识点资源VO列表
     */
    List<KpResourceVo> selectKpResourceByCourseId(@Param("courseId") Long courseId);
}
