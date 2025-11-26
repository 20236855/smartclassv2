package com.ruoyi.web.controller.system;

import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.system.domain.vo.DigitalTwinResultVO;
import com.ruoyi.system.service.IDigitalTwinService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 数字分身Controller
 * 提供前端调用的接口入口（若依框架规范）
 *
 * @author ruoyi
 * @date 2025-11-24
 */
@RestController
@RequestMapping("/system/digitalTwin") // 接口根路径（与前端API请求地址一致）
@Api(tags = "数字分身接口", description = "学生数字分身计算相关操作")
public class DigitalTwinController extends BaseController {

    private static final Logger log = LoggerFactory.getLogger(DigitalTwinController.class);

    @Autowired
    private IDigitalTwinService digitalTwinService; // 注入Service层

    /**
     * 计算学生数字分身（核心接口）
     * 前端请求地址：/system/digitalTwin/calculate
     * 请求方式：GET
     */
    @GetMapping("/calculate")
    @ApiOperation("计算学生数字分身")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "userId", value = "学生ID", required = true, dataType = "Long", example = "24"),
            @ApiImplicitParam(name = "courseId", value = "课程ID", required = true, dataType = "Long", example = "123")
            // 去掉作业ID参数
    })
    public AjaxResult calculateDigitalTwin(Long userId, Long courseId) { // 去掉 assignmentId 参数
        try {
            log.info("接收数字分身计算请求：userId={}, courseId={}", userId, courseId);
            DigitalTwinResultVO resultVO = digitalTwinService.calculateDigitalTwin(userId, courseId); // 调整参数
            log.info("数字分身计算接口响应：userId={}, result={}", userId, resultVO);
            return AjaxResult.success("计算成功", resultVO);
        } catch (RuntimeException e) {
            log.error("数字分身计算接口异常：userId={}, 错误信息={}", userId, e.getMessage(), e);
            return AjaxResult.error(e.getMessage());
        } catch (Exception e) {
            log.error("数字分身计算接口系统异常：userId={}", userId, e);
            return AjaxResult.error("系统异常，请联系管理员");
        }
    }
}
