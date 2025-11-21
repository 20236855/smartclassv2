package com.ruoyi.web.controller.system;

import java.util.List;
import javax.servlet.http.HttpServletResponse;

import com.ruoyi.common.utils.SecurityUtils;
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
import com.ruoyi.system.domain.SectionComment;
import com.ruoyi.system.service.ISectionCommentService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 小节评论(讨论区)Controller
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
@RestController
@RequestMapping("/system/comment")
public class SectionCommentController extends BaseController
{
    @Autowired
    private ISectionCommentService sectionCommentService;


    /**
     * 导出小节评论(讨论区)列表
     */
    @PreAuthorize("@ss.hasPermi('system:comment:export')")
    @Log(title = "小节评论(讨论区)", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, SectionComment sectionComment)
    {
        List<SectionComment> list = sectionCommentService.selectSectionCommentList(sectionComment);
        ExcelUtil<SectionComment> util = new ExcelUtil<SectionComment>(SectionComment.class);
        util.exportExcel(response, list, "小节评论(讨论区)数据");
    }

    /**
     * 获取小节评论(讨论区)详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:comment:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(sectionCommentService.selectSectionCommentById(id));
    }


    /**
     * 删除小节评论(讨论区)
     */
    @PreAuthorize("@ss.hasPermi('system:comment:remove')")
    @Log(title = "小节评论(讨论区)", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(sectionCommentService.deleteSectionCommentByIds(ids));
    }

    /**
     * 查询小节评论(讨论区)列表
     */
    @PreAuthorize("@ss.hasPermi('system:comment:list')")
    @GetMapping("/list")
    public TableDataInfo list(SectionComment sectionComment)
    {
        startPage();
        List<SectionComment> list = sectionCommentService.selectSectionCommentList(sectionComment);
        return getDataTable(list);
    }

    /**
     * 新增小节评论(讨论区)
     */
    @PreAuthorize("@ss.hasPermi('system:comment:add')")
    @Log(title = "小节评论(讨论区)", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SectionComment sectionComment)
    {
        // ⭐ 【核心修复】2. 在保存前，从安全上下文中获取当前用户ID并设置
        sectionComment.setUserId(SecurityUtils.getUserId());

        return toAjax(sectionCommentService.insertSectionComment(sectionComment));
    }

    /**
     * 修改小节评论(讨论区)
     */
    @PreAuthorize("@ss.hasPermi('system:comment:edit')")
    @Log(title = "小节评论(讨论区)", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SectionComment sectionComment)
    {
        return toAjax(sectionCommentService.updateSectionComment(sectionComment));
    }

    /**
     * 获取指定小节的树形评论列表
     */
    @GetMapping("/tree/{sectionId}")
    public AjaxResult getCommentTree(@PathVariable("sectionId") Long sectionId)
    {
        List<SectionComment> list = sectionCommentService.selectCommentTreeBySectionId(sectionId);
        return success(list);
    }

}
