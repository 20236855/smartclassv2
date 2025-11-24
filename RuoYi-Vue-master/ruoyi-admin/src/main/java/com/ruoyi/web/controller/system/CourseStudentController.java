package com.ruoyi.web.controller.system;

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
import com.ruoyi.system.domain.CourseStudent;
import com.ruoyi.system.service.ICourseStudentService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 学生选课Controller
 *
 * @author ruoyi
 * @date 2025-11-18
 */
@RestController
@RequestMapping("/system/student")
public class CourseStudentController extends BaseController
{
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
     * ⭐【关键修改】将/my-courses接口调整到/{id}接口之前，解决路由冲突
     * 查询当前登录学生已选上的所有课程
     */
    @GetMapping("/my-courses")
    public AjaxResult getMyCourses()
    {
        // 获取当前登录用户的 sys_user.user_id
        Long sysUserId = getUserId();

        // 查询对应的 user.id
        Long studentUserId = getUserIdBySysUserId(sysUserId);

        if (studentUserId == null) {
            logger.warn("用户 sys_user_id={} 在 user 表中不存在", sysUserId);
            return AjaxResult.success(new java.util.ArrayList<>());  // 返回空列表
        }

        List<com.ruoyi.system.domain.Course> list = courseStudentService.selectMyCoursesByStudentId(studentUserId);
        return AjaxResult.success(list);
    }

    /**
     * 查询学生选课列表
     */
    @PreAuthorize("@ss.hasPermi('system:student:list')")
    @GetMapping("/list")
    public TableDataInfo list(CourseStudent courseStudent)
    {
        startPage();
        List<CourseStudent> list = courseStudentService.selectCourseStudentList(courseStudent);
        return getDataTable(list);
    }

    /**
     * 导出学生选课列表
     */
    @PreAuthorize("@ss.hasPermi('system:student:export')")
    @Log(title = "学生选课", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, CourseStudent courseStudent)
    {
        List<CourseStudent> list = courseStudentService.selectCourseStudentList(courseStudent);
        ExcelUtil<CourseStudent> util = new ExcelUtil<CourseStudent>(CourseStudent.class);
        util.exportExcel(response, list, "学生选课数据");
    }

    /**
     * 获取学生选课详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:student:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(courseStudentService.selectCourseStudentById(id));
    }

    /**
     * 新增学生选课
     */
    @PreAuthorize("@ss.hasPermi('system:student:add')")
    @Log(title = "学生选课", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody CourseStudent courseStudent)
    {
        return toAjax(courseStudentService.insertCourseStudent(courseStudent));
    }

    /**
     * 修改学生选课
     */
    @PreAuthorize("@ss.hasPermi('system:student:edit')")
    @Log(title = "学生选课", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody CourseStudent courseStudent)
    {
        return toAjax(courseStudentService.updateCourseStudent(courseStudent));
    }

    /**
     * 删除学生选课
     */
    @PreAuthorize("@ss.hasPermi('system:student:remove')")
    @Log(title = "学生选课", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(courseStudentService.deleteCourseStudentByIds(ids));
    }

    /**
     * 学生退课接口
     * 根据课程ID退出课程（删除 course_student 表中的记录）
     */
    @Log(title = "学生退课", businessType = BusinessType.DELETE)
    @DeleteMapping("/withdraw/{courseId}")
    public AjaxResult withdrawCourse(@PathVariable("courseId") Long courseId)
    {
        // 获取当前登录用户的 sys_user.user_id
        Long sysUserId = getUserId();

        // 查询对应的 user.id
        Long studentUserId = getUserIdBySysUserId(sysUserId);

        if (studentUserId == null) {
            return error("用户信息不存在，请联系管理员");
        }

        // 1. 查询该学生是否选了这门课
        CourseStudent query = new CourseStudent();
        query.setCourseId(courseId);
        query.setStudentUserId(studentUserId);
        List<CourseStudent> enrollments = courseStudentService.selectCourseStudentList(query);

        if (enrollments == null || enrollments.isEmpty()) {
            return error("您还未选择该课程，无法退课");
        }

        // 2. 删除选课记录
        CourseStudent enrollment = enrollments.get(0);
        int result = courseStudentService.deleteCourseStudentById(enrollment.getId());

        if (result > 0) {
            return success("退课成功");
        } else {
            return error("退课失败");
        }
    }
}
