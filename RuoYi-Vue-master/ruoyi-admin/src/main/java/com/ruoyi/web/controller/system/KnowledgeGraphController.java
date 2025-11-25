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
import com.ruoyi.system.domain.KnowledgeGraph;
import com.ruoyi.system.service.IKnowledgeGraphService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 知识图谱Controller
 * 
 * @author ruoyi
 * @date 2025-11-21
 */
@RestController
@RequestMapping("/system/graph")
public class KnowledgeGraphController extends BaseController
{
    @Autowired
    private IKnowledgeGraphService knowledgeGraphService;

    /**
     * 为指定课程生成知识图谱（触发抽取任务）
     */
    @PreAuthorize("@ss.hasPermi('system:graph:generate')")
    @PostMapping("/extract/course/{courseId}")
    public AjaxResult extractCourseGraph(@PathVariable("courseId") Long courseId)
    {
        // 触发服务层生成（可异步）
        knowledgeGraphService.generateCourseGraph(courseId);
        return AjaxResult.success("已提交知识图谱生成任务");
    }

    /**
     * 同步触发为指定课程生成知识图谱并返回新创建的图谱（仅用于本地调试/测试）
     */
    @PreAuthorize("@ss.hasPermi('system:graph:generate')")
    @PostMapping("/extract/course/{courseId}/sync")
    public AjaxResult extractCourseGraphSync(@PathVariable("courseId") Long courseId)
    {
        // 直接调用生成（同步），执行完毕后查询最近的课程图谱并返回
        knowledgeGraphService.generateCourseGraph(courseId);
        KnowledgeGraph filter = new KnowledgeGraph();
        filter.setCourseId(courseId);
        filter.setGraphType("COURSE");
        java.util.List<KnowledgeGraph> list = knowledgeGraphService.selectKnowledgeGraphList(filter);
        if (list != null && !list.isEmpty()) {
            // 返回最新一条（按 createTime 排序由 mapper 控制，这里取最后一条作为近似）
            KnowledgeGraph kg = list.get(list.size() - 1);
            return success(kg);
        }
        return AjaxResult.error("未生成任何知识图谱");
    }

    /**
     * 为指定章节生成知识图谱（从题库抽取知识点和关系）
     */
    @PreAuthorize("@ss.hasPermi('system:graph:generate')")
    @PostMapping("/extract/chapter/{courseId}/{chapterId}")
    public AjaxResult extractChapterGraph(@PathVariable("courseId") Long courseId,
                                          @PathVariable("chapterId") Long chapterId)
    {
        // 触发服务层生成章节知识图谱（异步）
        knowledgeGraphService.generateChapterGraph(courseId, chapterId);
        return AjaxResult.success("已提交章节知识图谱生成任务");
    }



    /**
     * 查询知识图谱列表
     */
    @PreAuthorize("@ss.hasPermi('system:graph:list')")
    @GetMapping("/list")
    public TableDataInfo list(KnowledgeGraph knowledgeGraph)
    {
        startPage();
        List<KnowledgeGraph> list = knowledgeGraphService.selectKnowledgeGraphList(knowledgeGraph);
        return getDataTable(list);
    }

    /**
     * 导出知识图谱列表
     */
    @PreAuthorize("@ss.hasPermi('system:graph:export')")
    @Log(title = "知识图谱", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, KnowledgeGraph knowledgeGraph)
    {
        List<KnowledgeGraph> list = knowledgeGraphService.selectKnowledgeGraphList(knowledgeGraph);
        ExcelUtil<KnowledgeGraph> util = new ExcelUtil<KnowledgeGraph>(KnowledgeGraph.class);
        util.exportExcel(response, list, "知识图谱数据");
    }

    /**
     * 获取知识图谱详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:graph:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(knowledgeGraphService.selectKnowledgeGraphById(id));
    }

    /**
     * 新增知识图谱
     */
    @PreAuthorize("@ss.hasPermi('system:graph:add')")
    @Log(title = "知识图谱", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody KnowledgeGraph knowledgeGraph)
    {
        return toAjax(knowledgeGraphService.insertKnowledgeGraph(knowledgeGraph));
    }

    /**
     * 修改知识图谱
     */
    @PreAuthorize("@ss.hasPermi('system:graph:edit')")
    @Log(title = "知识图谱", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody KnowledgeGraph knowledgeGraph)
    {
        return toAjax(knowledgeGraphService.updateKnowledgeGraph(knowledgeGraph));
    }

    /**
     * 删除知识图谱
     */
    @PreAuthorize("@ss.hasPermi('system:graph:remove')")
    @Log(title = "知识图谱", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(knowledgeGraphService.deleteKnowledgeGraphByIds(ids));
    }
}
