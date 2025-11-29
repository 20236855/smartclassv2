package com.ruoyi.web.controller.system;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.vo.AiRecommendResultVo;
import com.ruoyi.system.service.IAiRecommendService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.constraints.NotNull;

/**
 * AI个性化推荐控制器（已优化：去掉超大modelInput返回，确保前端拿到数据）
 */
@RestController
@RequestMapping("/system/ai/recommend")
@Api(tags = "AI个性化推荐接口")
public class AiRecommendController extends BaseController {

    @Autowired
    private IAiRecommendService aiRecommendService;

    /**
     * 获取AI个性化推荐结果（核心接口，已优化响应体积）
     * 所有登录用户（包括学生）都可以访问
     */
    @Log(title = "AI个性化推荐", businessType = BusinessType.OTHER)
    @GetMapping("/getResult")
    @ApiOperation(value = "获取个性化推荐", notes = "传入学生ID和课程ID，返回含大模型推荐的报告")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "studentUserId", value = "学生ID（关联user表id）", required = true, dataType = "Long", paramType = "query"),
            @ApiImplicitParam(name = "courseId", value = "课程ID（关联course表id）", required = true, dataType = "Long", paramType = "query")
    })
    public AjaxResult getRecommendResult(
            @RequestParam("studentUserId")
            @NotNull(message = "学生ID不能为空")
                    Long studentUserId,

            @RequestParam("courseId")
            @NotNull(message = "课程ID不能为空")
                    Long courseId
    ) {
        try {
            AiRecommendResultVo resultVo = aiRecommendService.getRecommendResult(studentUserId, courseId);
            // 关键优化：去掉超大体积的modelInput（前端无用，占90%响应体积）
            resultVo.setModelInput(null);
            return success(resultVo);
        } catch (Exception e) {
            return error("获取推荐结果失败：" + e.getMessage().substring(0, 50) + "...");
        }
    }

    /**
     * 单独获取大模型输入数据（用于调试）
     */
    @PreAuthorize("@ss.hasPermi('system:ai:recommend')")
    @GetMapping("/getModelInput")
    @ApiOperation(value = "获取大模型输入数据", notes = "返回拼接后的完整Prompt（用于调试）")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "studentUserId", value = "学生ID", required = true, dataType = "Long", paramType = "query"),
            @ApiImplicitParam(name = "courseId", value = "课程ID", required = true, dataType = "Long", paramType = "query")
    })
    public AjaxResult getModelInput(
            @RequestParam("studentUserId")
            @NotNull(message = "学生ID不能为空")
                    Long studentUserId,

            @RequestParam("courseId")
            @NotNull(message = "课程ID不能为空")
                    Long courseId
    ) {
        try {
            String modelInput = aiRecommendService.generateModelInput(studentUserId, courseId);
            return success(modelInput);
        } catch (Exception e) {
            return error("获取大模型输入数据失败：" + e.getMessage());
        }
    }
}
