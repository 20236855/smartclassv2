package com.ruoyi.web.controller.system;

import java.util.List;
import javax.servlet.http.HttpServletResponse;

import com.ruoyi.system.domain.CourseCompetency;
import com.ruoyi.system.service.ICourseCompetencyService;
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
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 课程能力点（定义能力模型维度）Controller
 *
 * @author ruoyi
 * @date 2025-11-20
 */
@RestController
@RequestMapping("/learning/competency")
public class CourseCompetencyController extends BaseController
{
    @Autowired
    private ICourseCompetencyService courseCompetencyService;

    /**
     * 查询课程能力点（定义能力模型维度）列表
     */
    @PreAuthorize("@ss.hasPermi('learning:competency:list')")
    @GetMapping("/list")
    public TableDataInfo list(CourseCompetency courseCompetency)
    {
        startPage();
        List<CourseCompetency> list = courseCompetencyService.selectCourseCompetencyList(courseCompetency);
        return getDataTable(list);
    }

    /**
     * 导出课程能力点（定义能力模型维度）列表
     */
    @PreAuthorize("@ss.hasPermi('learning:competency:export')")
    @Log(title = "课程能力点（定义能力模型维度）", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, CourseCompetency courseCompetency)
    {
        List<CourseCompetency> list = courseCompetencyService.selectCourseCompetencyList(courseCompetency);
        ExcelUtil<CourseCompetency> util = new ExcelUtil<CourseCompetency>(CourseCompetency.class);
        util.exportExcel(response, list, "课程能力点（定义能力模型维度）数据");
    }

    /**
     * 获取课程能力点（定义能力模型维度）详细信息
     */
    @PreAuthorize("@ss.hasPermi('learning:competency:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(courseCompetencyService.selectCourseCompetencyById(id));
    }

    /**
     * 新增课程能力点（定义能力模型维度）
     */
    @PreAuthorize("@ss.hasPermi('learning:competency:add')")
    @Log(title = "课程能力点（定义能力模型维度）", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody CourseCompetency courseCompetency)
    {
        return toAjax(courseCompetencyService.insertCourseCompetency(courseCompetency));
    }

    /**
     * 修改课程能力点（定义能力模型维度）
     */
    @PreAuthorize("@ss.hasPermi('learning:competency:edit')")
    @Log(title = "课程能力点（定义能力模型维度）", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody CourseCompetency courseCompetency)
    {
        return toAjax(courseCompetencyService.updateCourseCompetency(courseCompetency));
    }

    /**
     * 删除课程能力点（定义能力模型维度）
     */
    @PreAuthorize("@ss.hasPermi('learning:competency:remove')")
    @Log(title = "课程能力点（定义能力模型维度）", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(courseCompetencyService.deleteCourseCompetencyByIds(ids));
    }
}
