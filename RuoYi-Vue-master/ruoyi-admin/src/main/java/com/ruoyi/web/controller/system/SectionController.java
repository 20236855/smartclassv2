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
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.Section;
import com.ruoyi.system.service.ISectionService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 课程小节Controller
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
@RestController
@RequestMapping("/system/section")
public class SectionController extends BaseController
{
    @Autowired
    private ISectionService sectionService;

    /**
     * 查询课程小节列表
     */
    @PreAuthorize("@ss.hasPermi('system:section:list')")
    @GetMapping("/list")
    public TableDataInfo list(Section section)
    {
        startPage();
        List<Section> list = sectionService.selectSectionList(section);
        return getDataTable(list);
    }

    /**
     * 导出课程小节列表
     */
    @PreAuthorize("@ss.hasPermi('system:section:export')")
    @Log(title = "课程小节", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, Section section)
    {
        List<Section> list = sectionService.selectSectionList(section);
        ExcelUtil<Section> util = new ExcelUtil<Section>(Section.class);
        util.exportExcel(response, list, "课程小节数据");
    }

    /**
     * 获取课程小节详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:section:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(sectionService.selectSectionById(id));
    }

    /**
     * 新增课程小节
     */
    @PreAuthorize("@ss.hasPermi('system:section:add')")
    @Log(title = "课程小节", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Section section)
    {
        return toAjax(sectionService.insertSection(section));
    }

    /**
     * 修改课程小节
     */
    @PreAuthorize("@ss.hasPermi('system:section:edit')")
    @Log(title = "课程小节", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody Section section)
    {
        return toAjax(sectionService.updateSection(section));
    }

    /**
     * 删除课程小节
     */
    @PreAuthorize("@ss.hasPermi('system:section:remove')")
    @Log(title = "课程小节", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(sectionService.deleteSectionByIds(ids));
    }
}
