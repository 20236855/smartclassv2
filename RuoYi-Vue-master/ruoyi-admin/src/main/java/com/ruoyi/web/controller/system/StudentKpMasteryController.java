package com.ruoyi.web.controller.system;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import com.ruoyi.system.domain.StudentKpMastery;
import com.ruoyi.system.service.IStudentKpMasteryService;
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
 * 学生知识点掌握情况（支撑知识图谱状态标识）Controller
 *
 * @author ruoyi
 * @date 2025-11-20
 */
@RestController
@RequestMapping("/learning/mastery")
public class StudentKpMasteryController extends BaseController
{
    @Autowired
    private IStudentKpMasteryService studentKpMasteryService;

    /**
     * 查询学生知识点掌握情况（支撑知识图谱状态标识）列表
     */
    @PreAuthorize("@ss.hasPermi('learning:mastery:list')")
    @GetMapping("/list")
    public TableDataInfo list(StudentKpMastery studentKpMastery)
    {
        startPage();
        List<StudentKpMastery> list = studentKpMasteryService.selectStudentKpMasteryList(studentKpMastery);
        return getDataTable(list);
    }

    /**
     * 导出学生知识点掌握情况（支撑知识图谱状态标识）列表
     */
    @PreAuthorize("@ss.hasPermi('learning:mastery:export')")
    @Log(title = "学生知识点掌握情况（支撑知识图谱状态标识）", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, StudentKpMastery studentKpMastery)
    {
        List<StudentKpMastery> list = studentKpMasteryService.selectStudentKpMasteryList(studentKpMastery);
        ExcelUtil<StudentKpMastery> util = new ExcelUtil<StudentKpMastery>(StudentKpMastery.class);
        util.exportExcel(response, list, "学生知识点掌握情况（支撑知识图谱状态标识）数据");
    }

    /**
     * 获取学生知识点掌握情况（支撑知识图谱状态标识）详细信息
     */
    @PreAuthorize("@ss.hasPermi('learning:mastery:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(studentKpMasteryService.selectStudentKpMasteryById(id));
    }

    /**
     * 新增学生知识点掌握情况（支撑知识图谱状态标识）
     */
    @PreAuthorize("@ss.hasPermi('learning:mastery:add')")
    @Log(title = "学生知识点掌握情况（支撑知识图谱状态标识）", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody StudentKpMastery studentKpMastery)
    {
        return toAjax(studentKpMasteryService.insertStudentKpMastery(studentKpMastery));
    }

    /**
     * 修改学生知识点掌握情况（支撑知识图谱状态标识）
     */
    @PreAuthorize("@ss.hasPermi('learning:mastery:edit')")
    @Log(title = "学生知识点掌握情况（支撑知识图谱状态标识）", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody StudentKpMastery studentKpMastery)
    {
        return toAjax(studentKpMasteryService.updateStudentKpMastery(studentKpMastery));
    }

    /**
     * 删除学生知识点掌握情况（支撑知识图谱状态标识）
     */
    @PreAuthorize("@ss.hasPermi('learning:mastery:remove')")
    @Log(title = "学生知识点掌握情况（支撑知识图谱状态标识）", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(studentKpMasteryService.deleteStudentKpMasteryByIds(ids));
    }
}
