package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.CourseEnrollmentRequest;

/**
 * 选课申请Mapper接口
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
public interface CourseEnrollmentRequestMapper 
{
    /**
     * 查询选课申请
     * 
     * @param id 选课申请主键
     * @return 选课申请
     */
    public CourseEnrollmentRequest selectCourseEnrollmentRequestById(Long id);

    /**
     * 查询选课申请列表
     * 
     * @param courseEnrollmentRequest 选课申请
     * @return 选课申请集合
     */
    public List<CourseEnrollmentRequest> selectCourseEnrollmentRequestList(CourseEnrollmentRequest courseEnrollmentRequest);

    /**
     * 新增选课申请
     * 
     * @param courseEnrollmentRequest 选课申请
     * @return 结果
     */
    public int insertCourseEnrollmentRequest(CourseEnrollmentRequest courseEnrollmentRequest);

    /**
     * 修改选课申请
     * 
     * @param courseEnrollmentRequest 选课申请
     * @return 结果
     */
    public int updateCourseEnrollmentRequest(CourseEnrollmentRequest courseEnrollmentRequest);

    /**
     * 删除选课申请
     * 
     * @param id 选课申请主键
     * @return 结果
     */
    public int deleteCourseEnrollmentRequestById(Long id);

    /**
     * 批量删除选课申请
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteCourseEnrollmentRequestByIds(Long[] ids);
}
