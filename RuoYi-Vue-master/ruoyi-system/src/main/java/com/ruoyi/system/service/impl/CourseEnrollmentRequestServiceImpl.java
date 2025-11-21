package com.ruoyi.system.service.impl;

import java.util.Date;
import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.CourseEnrollmentRequestMapper;
import com.ruoyi.system.mapper.CourseStudentMapper; // ⭐ 1. 确保导入 CourseStudentMapper
import com.ruoyi.system.domain.CourseEnrollmentRequest;
import com.ruoyi.system.domain.CourseStudent; // ⭐ 2. 确保导入 CourseStudent 实体
import com.ruoyi.system.service.ICourseEnrollmentRequestService;
import org.springframework.transaction.annotation.Transactional; // ⭐ 3. 建议为此方法加上事务

/**
 * 选课申请Service业务层处理
 *
 * @author ruoyi
 * @date 2025-11-18
 */
@Service
public class CourseEnrollmentRequestServiceImpl implements ICourseEnrollmentRequestService
{
    @Autowired
    private CourseEnrollmentRequestMapper courseEnrollmentRequestMapper;

    // ⭐ 4. 注入 CourseStudentMapper，用于操作 course_student 表
    @Autowired
    private CourseStudentMapper courseStudentMapper;

    @Override
    public CourseEnrollmentRequest selectCourseEnrollmentRequestById(Long id)
    {
        return courseEnrollmentRequestMapper.selectCourseEnrollmentRequestById(id);
    }

    @Override
    public List<CourseEnrollmentRequest> selectCourseEnrollmentRequestList(CourseEnrollmentRequest courseEnrollmentRequest)
    {
        return courseEnrollmentRequestMapper.selectCourseEnrollmentRequestList(courseEnrollmentRequest);
    }

    @Override
    public int insertCourseEnrollmentRequest(CourseEnrollmentRequest courseEnrollmentRequest)
    {
        return courseEnrollmentRequestMapper.insertCourseEnrollmentRequest(courseEnrollmentRequest);
    }

    /**
     * 修改选课申请
     * ⭐【核心修改】在这里添加了自动写入 course_student 表的逻辑
     * @param courseEnrollmentRequest 选课申请
     * @return 结果
     */
    @Override
    @Transactional // 建议加上事务，保证两个表的操作要么都成功，要么都失败
    public int updateCourseEnrollmentRequest(CourseEnrollmentRequest courseEnrollmentRequest)
    {
        // ⭐ 5. 先查询出这条申请的旧数据，用来判断状态是否是从“未通过”变为“已通过”
        CourseEnrollmentRequest oldRequest = courseEnrollmentRequestMapper.selectCourseEnrollmentRequestById(courseEnrollmentRequest.getId());
        if (oldRequest == null) {
            // 如果找不到旧记录，直接返回失败，避免空指针
            return 0;
        }

        // ⭐ 6. 执行更新操作，更新 course_enrollment_request 表
        int rows = courseEnrollmentRequestMapper.updateCourseEnrollmentRequest(courseEnrollmentRequest);

        // ⭐ 7. 判断是否需要向 course_student 表插入数据
        // 条件：更新成功 && 新状态是“已通过”(1) && 旧状态不是“已通过”
        boolean isNowApproved = courseEnrollmentRequest.getStatus() != null && courseEnrollmentRequest.getStatus() == 1;
        boolean wasAlreadyApproved = oldRequest.getStatus() != null && oldRequest.getStatus() == 1;

        if (rows > 0 && isNowApproved && !wasAlreadyApproved)
        {
            // ⭐ 8. 在插入前，再次检查 course_student 表是否已存在该记录，防止因重复操作导致数据库唯一索引冲突
            CourseStudent query = new CourseStudent();
            query.setCourseId(oldRequest.getCourseId());
            query.setStudentUserId(oldRequest.getStudentUserId());
            List<CourseStudent> exists = courseStudentMapper.selectCourseStudentList(query);

            if (exists == null || exists.isEmpty())
            {
                // ⭐ 9. 构造要插入到 course_student 表的新记录
                CourseStudent newEnrollment = new CourseStudent();
                newEnrollment.setCourseId(oldRequest.getCourseId());
                newEnrollment.setStudentUserId(oldRequest.getStudentUserId());
                newEnrollment.setEnrollTime(new Date()); // 设置报名时间为当前时间
                newEnrollment.setCollected(0L); // 根据您的表设计，collected是int，但用Long 0L更安全
                newEnrollment.setIsDeleted(0); // is_deleted 默认为0

                // ⭐ 10. 执行插入操作
                courseStudentMapper.insertCourseStudent(newEnrollment);
            }
        }
        return rows;
    }

    @Override
    public int deleteCourseEnrollmentRequestByIds(Long[] ids)
    {
        return courseEnrollmentRequestMapper.deleteCourseEnrollmentRequestByIds(ids);
    }

    @Override
    public int deleteCourseEnrollmentRequestById(Long id)
    {
        return courseEnrollmentRequestMapper.deleteCourseEnrollmentRequestById(id);
    }
}