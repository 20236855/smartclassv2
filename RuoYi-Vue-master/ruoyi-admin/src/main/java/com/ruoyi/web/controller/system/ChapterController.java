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
import com.ruoyi.system.domain.Chapter;
import com.ruoyi.system.service.IChapterService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 课程章节Controller
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
@RestController
@RequestMapping("/system/chapter")
public class ChapterController extends BaseController
{
    @Autowired
    private IChapterService chapterService;

    /**
     * 查询课程章节列表
     */
    @PreAuthorize("@ss.hasPermi('system:chapter:list')")
    @GetMapping("/list")
    public TableDataInfo list(Chapter chapter)
    {
        startPage();
        List<Chapter> list = chapterService.selectChapterList(chapter);
        return getDataTable(list);
    }

    /**
     * 导出课程章节列表
     */
    @PreAuthorize("@ss.hasPermi('system:chapter:export')")
    @Log(title = "课程章节", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, Chapter chapter)
    {
        List<Chapter> list = chapterService.selectChapterList(chapter);
        ExcelUtil<Chapter> util = new ExcelUtil<Chapter>(Chapter.class);
        util.exportExcel(response, list, "课程章节数据");
    }

    /**
     * 获取课程章节详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:chapter:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(chapterService.selectChapterById(id));
    }

    /**
     * 新增课程章节
     */
    @PreAuthorize("@ss.hasPermi('system:chapter:add')")
    @Log(title = "课程章节", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Chapter chapter)
    {
        return toAjax(chapterService.insertChapter(chapter));
    }

    /**
     * 修改课程章节
     */
    @PreAuthorize("@ss.hasPermi('system:chapter:edit')")
    @Log(title = "课程章节", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody Chapter chapter)
    {
        return toAjax(chapterService.updateChapter(chapter));
    }

    /**
     * 删除课程章节
     */
    @PreAuthorize("@ss.hasPermi('system:chapter:remove')")
    @Log(title = "课程章节", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(chapterService.deleteChapterByIds(ids));
    }
}
