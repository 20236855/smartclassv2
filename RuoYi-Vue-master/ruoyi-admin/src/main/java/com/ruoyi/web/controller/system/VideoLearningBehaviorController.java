package com.ruoyi.web.controller.system;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.VideoLearningBehavior;
import com.ruoyi.system.service.IVideoLearningBehaviorService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.utils.SecurityUtils;

/**
 * 视频学习行为Controller
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
@RestController
@RequestMapping("/system/video-behavior")
public class VideoLearningBehaviorController extends BaseController
{
    @Autowired
    private IVideoLearningBehaviorService videoLearningBehaviorService;

    /**
     * 查询视频学习行为列表
     */
    @PreAuthorize("@ss.hasPermi('system:behavior:list')")
    @GetMapping("/list")
    public TableDataInfo list(VideoLearningBehavior videoLearningBehavior)
    {
        startPage();
        // 如果是学生角色，只查询自己的学习行为
        if (!SecurityUtils.isAdmin(SecurityUtils.getUserId())) {
            videoLearningBehavior.setStudentId(SecurityUtils.getUserId());
        }
        List<VideoLearningBehavior> list = videoLearningBehaviorService.selectVideoLearningBehaviorList(videoLearningBehavior);
        return getDataTable(list);
    }

    /**
     * 导出视频学习行为列表
     */
    @PreAuthorize("@ss.hasPermi('system:behavior:export')")
    @Log(title = "视频学习行为", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, VideoLearningBehavior videoLearningBehavior)
    {
        // 如果是学生角色，只导出自己的学习行为
        if (!SecurityUtils.isAdmin(SecurityUtils.getUserId())) {
            videoLearningBehavior.setStudentId(SecurityUtils.getUserId());
        }
        List<VideoLearningBehavior> list = videoLearningBehaviorService.selectVideoLearningBehaviorList(videoLearningBehavior);
        ExcelUtil<VideoLearningBehavior> util = new ExcelUtil<VideoLearningBehavior>(VideoLearningBehavior.class);
        util.exportExcel(response, list, "视频学习行为数据");
    }

    /**
     * 根据学生ID和视频ID查询学习行为记录
     */
    @GetMapping("/query/byStudentAndVideo")
    public AjaxResult findByStudentAndVideo(@RequestParam("studentId") Long studentId, @RequestParam("videoId") Long videoId)
    {
        // 安全检查：学生只能查询自己的记录
        Long currentUserId = SecurityUtils.getUserId();
        if (!SecurityUtils.isAdmin(currentUserId) && !currentUserId.equals(studentId)) {
            return error("无权限查询其他用户的学习记录");
        }

        VideoLearningBehavior query = new VideoLearningBehavior();
        query.setStudentId(studentId);
        query.setVideoId(videoId);

        List<VideoLearningBehavior> list = videoLearningBehaviorService.selectVideoLearningBehaviorList(query);
        if (list != null && !list.isEmpty()) {
            return success(list.get(0)); // 返回第一条记录
        } else {
            return success(null); // 没有找到记录
        }
    }

    /**
     * 获取视频学习行为详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:behavior:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(videoLearningBehaviorService.selectVideoLearningBehaviorById(id));
    }

    /**
     * 新增视频学习行为
     */
    @PreAuthorize("@ss.hasPermi('system:behavior:add')")
    @Log(title = "视频学习行为", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody VideoLearningBehavior videoLearningBehavior)
    {
        return toAjax(videoLearningBehaviorService.insertVideoLearningBehavior(videoLearningBehavior));
    }

    /**
     * 插入或更新视频学习行为（UPSERT操作）
     */
    @PostMapping("/upsert")
    public AjaxResult upsert(@RequestBody VideoLearningBehavior videoLearningBehavior)
    {
        // 安全检查：学生只能操作自己的记录
        Long currentUserId = SecurityUtils.getUserId();
        if (!SecurityUtils.isAdmin(currentUserId)) {
            videoLearningBehavior.setStudentId(currentUserId);
        }

        return toAjax(videoLearningBehaviorService.upsertVideoLearningBehavior(videoLearningBehavior));
    }

    /**
     * 修改视频学习行为
     */
    @PreAuthorize("@ss.hasPermi('system:behavior:edit')")
    @Log(title = "视频学习行为", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody VideoLearningBehavior videoLearningBehavior)
    {
        return toAjax(videoLearningBehaviorService.updateVideoLearningBehavior(videoLearningBehavior));
    }

    /**
     * 删除视频学习行为
     */
    @PreAuthorize("@ss.hasPermi('system:behavior:remove')")
    @Log(title = "视频学习行为", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(videoLearningBehaviorService.deleteVideoLearningBehaviorByIds(ids));
    }
}
