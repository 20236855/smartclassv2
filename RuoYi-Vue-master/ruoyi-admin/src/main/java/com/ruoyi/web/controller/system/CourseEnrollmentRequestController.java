package com.ruoyi.web.controller.system;

import java.util.Date;
import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
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
import com.ruoyi.system.service.ICourseEnrollmentRequestService;
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

    /**
     * 查询选课申请列表
     */
    // CourseEnrollmentRequestController.java

    @PreAuthorize("@ss.hasPermi('system:request:list')")
    @GetMapping("/list")
    public TableDataInfo list(CourseEnrollmentRequest courseEnrollmentRequest)
    {
        // ⭐ 关键安全修改：无论前端传来什么，都强制设置为当前登录学生的ID
        courseEnrollmentRequest.setStudentUserId(getUserId());

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
     * 仅需要 courseId，学生信息从当前登录用户获取，状态默认为待审核(0)
     */
    @PreAuthorize("@ss.hasPermi('system:request:add')")
    @PostMapping("/apply/{courseId}")
    public AjaxResult apply(@PathVariable("courseId") Long courseId, @RequestBody(required = false) CourseEnrollmentRequest body)
    {
        CourseEnrollmentRequest req = new CourseEnrollmentRequest();
        req.setStudentUserId(getUserId());
        req.setCourseId(courseId);
        req.setStatus(0L);
        req.setSubmitTime(new Date());
        if (body != null)
        {
            req.setReason(body.getReason());
        }
        return toAjax(courseEnrollmentRequestService.insertCourseEnrollmentRequest(req));
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
