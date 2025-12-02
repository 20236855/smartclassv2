package com.ruoyi.web.controller.system;

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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.StudentLearningBehavior;
import com.ruoyi.system.service.IStudentLearningBehaviorService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 学生学习行为记录（视频/资源/互动行为）Controller
 * 
 * @author ruoyi
 * @date 2025-12-01
 */
@RestController
@RequestMapping("/system/lbehavior")
public class StudentLearningBehaviorController extends BaseController
{
    @Autowired
    private IStudentLearningBehaviorService studentLearningBehaviorService;

    /**
     * 查询学生学习行为记录（视频/资源/互动行为）列表
     */
    @PreAuthorize("@ss.hasPermi('system:lbehavior:list')")
    @GetMapping("/list")
    public TableDataInfo list(StudentLearningBehavior studentLearningBehavior)
    {
        startPage();
        List<StudentLearningBehavior> list = studentLearningBehaviorService.selectStudentLearningBehaviorList(studentLearningBehavior);
        return getDataTable(list);
    }

    /**
     * 导出学生学习行为记录（视频/资源/互动行为）列表
     */
    @PreAuthorize("@ss.hasPermi('system:lbehavior:export')")
    @Log(title = "学生学习行为记录（视频/资源/互动行为）", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, StudentLearningBehavior studentLearningBehavior)
    {
        List<StudentLearningBehavior> list = studentLearningBehaviorService.selectStudentLearningBehaviorList(studentLearningBehavior);
        ExcelUtil<StudentLearningBehavior> util = new ExcelUtil<StudentLearningBehavior>(StudentLearningBehavior.class);
        util.exportExcel(response, list, "学生学习行为记录（视频/资源/互动行为）数据");
    }

    /**
     * 获取学生学习行为记录（视频/资源/互动行为）详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:lbehavior:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(studentLearningBehaviorService.selectStudentLearningBehaviorById(id));
    }

    /**
     * 新增学生学习行为记录（视频/资源/互动行为）
     */
    @PreAuthorize("@ss.hasPermi('system:lbehavior:add')")
    @Log(title = "学生学习行为记录（视频/资源/互动行为）", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody StudentLearningBehavior studentLearningBehavior)
    {
        return toAjax(studentLearningBehaviorService.insertStudentLearningBehavior(studentLearningBehavior));
    }

    /**
     * 修改学生学习行为记录（视频/资源/互动行为）
     */
    @PreAuthorize("@ss.hasPermi('system:lbehavior:edit')")
    @Log(title = "学生学习行为记录（视频/资源/互动行为）", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody StudentLearningBehavior studentLearningBehavior)
    {
        return toAjax(studentLearningBehaviorService.updateStudentLearningBehavior(studentLearningBehavior));
    }

    /**
     * 删除学生学习行为记录（视频/资源/互动行为）
     */
    @PreAuthorize("@ss.hasPermi('system:lbehavior:remove')")
    @Log(title = "学生学习行为记录（视频/资源/互动行为）", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(studentLearningBehaviorService.deleteStudentLearningBehaviorByIds(ids));
    }

    /**
     * 自动记录学习行为（无需权限，登录用户即可调用）
     * 如果已存在相同的行为记录，则更新；否则新增
     */
    @PostMapping("/record")
    public AjaxResult recordBehavior(@RequestBody StudentLearningBehavior behavior)
    {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        behavior.setStudentUserId(userId);

        // 查询是否已存在相同的行为记录
        StudentLearningBehavior query = new StudentLearningBehavior();
        query.setStudentUserId(userId);
        query.setCourseId(behavior.getCourseId());
        query.setBehaviorType(behavior.getBehaviorType());
        query.setTargetId(behavior.getTargetId());
        query.setTargetType(behavior.getTargetType());

        List<StudentLearningBehavior> existingList = studentLearningBehaviorService.selectStudentLearningBehaviorList(query);

        if (existingList != null && !existingList.isEmpty()) {
            // 更新现有记录
            StudentLearningBehavior existing = existingList.get(0);
            behavior.setId(existing.getId());
            // 累加次数
            behavior.setCount((existing.getCount() != null ? existing.getCount() : 1) + 1);
            // 累加时长
            if (behavior.getDuration() != null && existing.getDuration() != null) {
                behavior.setDuration(existing.getDuration() + behavior.getDuration());
            }
            studentLearningBehaviorService.updateStudentLearningBehavior(behavior);
            return success("行为记录已更新");
        } else {
            // 新增记录
            if (behavior.getCount() == null) {
                behavior.setCount(1L);
            }
            if (behavior.getDuration() == null) {
                behavior.setDuration(0L);
            }
            studentLearningBehaviorService.insertStudentLearningBehavior(behavior);
            return success("行为记录已添加");
        }
    }

    /**
     * 查询当前用户的学习行为记录
     */
    @GetMapping("/my")
    public TableDataInfo myBehaviors(StudentLearningBehavior behavior)
    {
        Long userId = SecurityUtils.getUserId();
        behavior.setStudentUserId(userId);
        startPage();
        List<StudentLearningBehavior> list = studentLearningBehaviorService.selectStudentLearningBehaviorList(behavior);
        return getDataTable(list);
    }
}
