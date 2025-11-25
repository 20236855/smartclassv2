package com.ruoyi.web.controller.system;

import java.util.List;
import javax.servlet.http.HttpServletResponse;

import com.ruoyi.system.domain.CompetencyKpRelation;
import com.ruoyi.system.service.ICompetencyKpRelationService;
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
 * 能力点-知识点关联（支撑能力模型与知识点的映射）Controller
 *
 * @author ruoyi
 * @date 2025-11-20
 */
@RestController
@RequestMapping("/learning/relation")
public class CompetencyKpRelationController extends BaseController
{
    @Autowired
    private ICompetencyKpRelationService competencyKpRelationService;

    /**
     * 查询能力点-知识点关联（支撑能力模型与知识点的映射）列表
     */
    @PreAuthorize("@ss.hasPermi('learning:relation:list')")
    @GetMapping("/list")
    public TableDataInfo list(CompetencyKpRelation competencyKpRelation)
    {
        startPage();
        List<CompetencyKpRelation> list = competencyKpRelationService.selectCompetencyKpRelationList(competencyKpRelation);
        return getDataTable(list);
    }

    /**
     * 导出能力点-知识点关联（支撑能力模型与知识点的映射）列表
     */
    @PreAuthorize("@ss.hasPermi('learning:relation:export')")
    @Log(title = "能力点-知识点关联（支撑能力模型与知识点的映射）", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, CompetencyKpRelation competencyKpRelation)
    {
        List<CompetencyKpRelation> list = competencyKpRelationService.selectCompetencyKpRelationList(competencyKpRelation);
        ExcelUtil<CompetencyKpRelation> util = new ExcelUtil<CompetencyKpRelation>(CompetencyKpRelation.class);
        util.exportExcel(response, list, "能力点-知识点关联（支撑能力模型与知识点的映射）数据");
    }

    /**
     * 获取能力点-知识点关联（支撑能力模型与知识点的映射）详细信息
     */
    @PreAuthorize("@ss.hasPermi('learning:relation:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(competencyKpRelationService.selectCompetencyKpRelationById(id));
    }

    /**
     * 新增能力点-知识点关联（支撑能力模型与知识点的映射）
     */
    @PreAuthorize("@ss.hasPermi('learning:relation:add')")
    @Log(title = "能力点-知识点关联（支撑能力模型与知识点的映射）", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody CompetencyKpRelation competencyKpRelation)
    {
        return toAjax(competencyKpRelationService.insertCompetencyKpRelation(competencyKpRelation));
    }

    /**
     * 修改能力点-知识点关联（支撑能力模型与知识点的映射）
     */
    @PreAuthorize("@ss.hasPermi('learning:relation:edit')")
    @Log(title = "能力点-知识点关联（支撑能力模型与知识点的映射）", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody CompetencyKpRelation competencyKpRelation)
    {
        return toAjax(competencyKpRelationService.updateCompetencyKpRelation(competencyKpRelation));
    }

    /**
     * 删除能力点-知识点关联（支撑能力模型与知识点的映射）
     */
    @PreAuthorize("@ss.hasPermi('learning:relation:remove')")
    @Log(title = "能力点-知识点关联（支撑能力模型与知识点的映射）", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(competencyKpRelationService.deleteCompetencyKpRelationByIds(ids));
    }
}
