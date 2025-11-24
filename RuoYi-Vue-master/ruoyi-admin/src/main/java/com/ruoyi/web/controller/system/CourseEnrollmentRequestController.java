package com.ruoyi.web.controller.system;

import java.util.Date;
import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.CourseEnrollmentRequest;
import com.ruoyi.system.domain.Course;
import com.ruoyi.system.domain.CourseStudent;
import com.ruoyi.system.service.ICourseEnrollmentRequestService;
import com.ruoyi.system.service.ICourseService;
import com.ruoyi.system.service.ICourseStudentService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 选课申请Controller
 *
 * @author ruoyi
 * @date 2025-11-18
 */
@RestController
@RequestMapping("/system/request")
public class CourseEnrollmentRequestController extends BaseController
{
    @Autowired
    private ICourseEnrollmentRequestService courseEnrollmentRequestService;

    @Autowired
    private ICourseService courseService;

    @Autowired
    private ICourseStudentService courseStudentService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 根据 sys_user_id 查询 user 表的 id
     * @param sysUserId sys_user 表的 user_id
     * @return user 表的 id，如果不存在返回 null
     */
    private Long getUserIdBySysUserId(Long sysUserId) {
        try {
            String sql = "SELECT id FROM user WHERE sys_user_id = ?";
            return jdbcTemplate.queryForObject(sql, Long.class, sysUserId);
        } catch (Exception e) {
            logger.error("查询 user.id 失败，sys_user_id: {}", sysUserId, e);
            return null;
        }
    }

    /**
     * 查询选课申请列表
     */
    // CourseEnrollmentRequestController.java

    @PreAuthorize("@ss.hasPermi('system:request:list')")
    @GetMapping("/list")
    public TableDataInfo list(CourseEnrollmentRequest courseEnrollmentRequest)
    {
        // 获取当前登录用户的 sys_user.user_id
        Long sysUserId = getUserId();

        // 查询对应的 user.id
        Long studentUserId = getUserIdBySysUserId(sysUserId);

        // ⭐ 关键安全修改：无论前端传来什么，都强制设置为当前登录学生的ID
        courseEnrollmentRequest.setStudentUserId(studentUserId);

        startPage();
        // Service和Mapper层无需任何改动，继续使用即可
        List<CourseEnrollmentRequest> list = courseEnrollmentRequestService.selectCourseEnrollmentRequestList(courseEnrollmentRequest);
        return getDataTable(list);
    }
    /**
     * 导出选课申请列表
     */
    @PreAuthorize("@ss.hasPermi('system:request:export')")
    @Log(title = "选课申请", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, CourseEnrollmentRequest courseEnrollmentRequest)
    {
        List<CourseEnrollmentRequest> list = courseEnrollmentRequestService.selectCourseEnrollmentRequestList(courseEnrollmentRequest);
        ExcelUtil<CourseEnrollmentRequest> util = new ExcelUtil<CourseEnrollmentRequest>(CourseEnrollmentRequest.class);
        util.exportExcel(response, list, "选课申请数据");
    }

    /**
     * 获取选课申请详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:request:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(courseEnrollmentRequestService.selectCourseEnrollmentRequestById(id));
    }

    /**
     * 新增选课申请
     */
    @PreAuthorize("@ss.hasPermi('system:request:add')")
    @Log(title = "选课申请", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody CourseEnrollmentRequest courseEnrollmentRequest)
    {
        return toAjax(courseEnrollmentRequestService.insertCourseEnrollmentRequest(courseEnrollmentRequest));
    }

    /**
     * 学生在课程页面点击"申请选课"
     *
     * ⭐【核心逻辑】：
     * 1. 如果课程状态为"已结束"，直接将学生加入 course_student 表，无需审核
     * 2. 其他状态的课程，创建待审核的选课申请
     */
    @PreAuthorize("@ss.hasPermi('system:request:add')")
    @PostMapping("/apply/{courseId}")
    public AjaxResult apply(@PathVariable("courseId") Long courseId, @RequestBody(required = false) CourseEnrollmentRequest body)
    {
        // 获取当前登录用户的 sys_user.user_id
        Long sysUserId = getUserId();

        // 查询对应的 user.id
        Long studentUserId = getUserIdBySysUserId(sysUserId);

        if (studentUserId == null) {
            return error("用户信息不存在，请联系管理员");
        }

        // ⭐ 1. 查询课程信息，判断课程状态
        Course course = courseService.selectCourseById(courseId);
        if (course == null) {
            return error("课程不存在");
        }

        // ⭐ 2. 检查是否已经选过这门课
        CourseStudent query = new CourseStudent();
        query.setCourseId(courseId);
        query.setStudentUserId(studentUserId);
        List<CourseStudent> existingEnrollments = courseStudentService.selectCourseStudentList(query);

        if (existingEnrollments != null && !existingEnrollments.isEmpty()) {
            return error("您已经选过这门课程了");
        }

        // ⭐ 3. 如果课程状态为"已结束"（字典值为 "1"），直接加入 course_student 表
        // 注意：数据库中 status 字段存储的是字典值（"0"=进行中, "1"=已结束），而不是中文标签
        if ("1".equals(course.getStatus()) || "已结束".equals(course.getStatus())) {
            CourseStudent newEnrollment = new CourseStudent();
            newEnrollment.setCourseId(courseId);
            newEnrollment.setStudentUserId(studentUserId);
            newEnrollment.setEnrollTime(new Date());
            newEnrollment.setCollected(0L);
            newEnrollment.setIsDeleted(0);

            int result = courseStudentService.insertCourseStudent(newEnrollment);
            if (result > 0) {
                return success("选课成功！已结束的课程无需审核，已直接加入您的课程列表");
            } else {
                return error("选课失败，请稍后重试");
            }
        }

        // ⭐ 4. 检查是否已经提交过申请
        CourseEnrollmentRequest queryRequest = new CourseEnrollmentRequest();
        queryRequest.setStudentUserId(studentUserId);
        queryRequest.setCourseId(courseId);
        List<CourseEnrollmentRequest> existingRequests = courseEnrollmentRequestService.selectCourseEnrollmentRequestList(queryRequest);

        if (existingRequests != null && !existingRequests.isEmpty()) {
            CourseEnrollmentRequest existingRequest = existingRequests.get(0);
            if (existingRequest.getStatus() == 0L) {
                return error("您已提交过选课申请，请等待审核");
            } else if (existingRequest.getStatus() == 1L) {
                return error("您的选课申请已通过，无需重复申请");
            } else if (existingRequest.getStatus() == 2L) {
                // 如果之前被拒绝，允许重新申请，先删除旧记录
                courseEnrollmentRequestService.deleteCourseEnrollmentRequestById(existingRequest.getId());
            }
        }

        // ⭐ 5. 创建待审核的选课申请
        CourseEnrollmentRequest req = new CourseEnrollmentRequest();
        req.setStudentUserId(studentUserId);  // 使用 user.id 而不是 sys_user.user_id
        req.setCourseId(courseId);
        req.setStatus(0L);  // 待审核
        req.setSubmitTime(new Date());
        if (body != null)
        {
            req.setReason(body.getReason());
        }

        try {
            int result = courseEnrollmentRequestService.insertCourseEnrollmentRequest(req);
            if (result > 0) {
                return success("选课申请已提交，请等待教师审核");
            } else {
                return error("选课申请提交失败，请稍后重试");
            }
        } catch (Exception e) {
            // 捕获数据库唯一约束异常
            String errorMsg = e.getMessage();
            if (errorMsg != null && (errorMsg.contains("Duplicate entry") || errorMsg.contains("uk_student_course"))) {
                return error("您已提交过选课申请，请勿重复提交");
            }
            // 不要把详细的异常信息返回给前端
            return error("选课申请提交失败，请稍后重试");
        }
    }

    /**
     * 修改选课申请
     */
    @PreAuthorize("@ss.hasPermi('system:request:edit')")
    @Log(title = "选课申请", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody CourseEnrollmentRequest courseEnrollmentRequest)
    {
        return toAjax(courseEnrollmentRequestService.updateCourseEnrollmentRequest(courseEnrollmentRequest));
    }

    /**
     * 删除选课申请
     */
    @PreAuthorize("@ss.hasPermi('system:request:remove')")
    @Log(title = "选课申请", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(courseEnrollmentRequestService.deleteCourseEnrollmentRequestByIds(ids));
    }
}
