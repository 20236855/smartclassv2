package com.ruoyi.system.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.system.domain.CourseCompetency;
import com.ruoyi.system.mapper.CourseCompetencyMapper;
import com.ruoyi.system.service.ICourseCompetencyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 课程能力点Service业务层处理（若依规范：手动注入Mapper，不继承ServiceImpl）
 */
@Service
public class CourseCompetencyServiceImpl implements ICourseCompetencyService {

    // 手动注入Mapper（若依原生Service的标准写法）
    @Autowired
    private CourseCompetencyMapper courseCompetencyMapper;

    /**
     * 查询课程能力点
     * @return
     */
    @Override
    public CourseCompetency selectCourseCompetencyById(Long id) {
        return courseCompetencyMapper.selectCourseCompetencyById(id);
    }

    /**
     * 查询课程能力点列表
     */
    @Override
    public List<CourseCompetency> selectCourseCompetencyList(CourseCompetency courseCompetency) {
        return courseCompetencyMapper.selectCourseCompetencyList(courseCompetency);
    }

    /**
     * 新增课程能力点
     */
    @Override
    public int insertCourseCompetency(CourseCompetency courseCompetency) {
        courseCompetency.setCreateTime(DateUtils.getNowDate());
        return courseCompetencyMapper.insertCourseCompetency(courseCompetency);
    }

    /**
     * 修改课程能力点
     */
    @Override
    public int updateCourseCompetency(CourseCompetency courseCompetency) {
        courseCompetency.setUpdateTime(DateUtils.getNowDate());
        return courseCompetencyMapper.updateCourseCompetency(courseCompetency);
    }

    /**
     * 批量删除课程能力点
     */
    @Override
    public int deleteCourseCompetencyByIds(Long[] ids) {
        return courseCompetencyMapper.deleteCourseCompetencyByIds(ids);
    }

    /**
     * 删除课程能力点信息
     */
    @Override
    public int deleteCourseCompetencyById(Long id) {
        return courseCompetencyMapper.deleteCourseCompetencyById(id);
    }

}

