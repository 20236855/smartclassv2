package com.ruoyi.web.controller.system;

import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.system.domain.User; // 导入业务用户实体（和推荐功能用的一样）
import com.ruoyi.system.domain.vo.CompetencyRadarVo;
import com.ruoyi.system.mapper.UserMapper; // 导入UserMapper，用于查询业务用户ID
import com.ruoyi.system.service.ICompetencyKpRelationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/learning/radar")
public class CompetencyRadarController extends BaseController {

    @Autowired
    private ICompetencyKpRelationService competencyKpRelationService;

    @Autowired
    private UserMapper userMapper; // 新增：注入UserMapper（关键）

    @GetMapping("/getData")
    public AjaxResult getRadarData(
            // 关键：用 @RequestParam 的 name 属性指定前端传的参数名，required=true 表示必填
            @RequestParam(name = "studentId", required = true) Long sysUserId, // 前端传 studentId=220，后端接收为 sysUserId
            @RequestParam Long courseId
    ) {
        // 后续逻辑不变（映射业务用户ID）
        User businessUser = userMapper.selectUserBySysUserId(sysUserId);
        if (businessUser == null || businessUser.getId() == null) {
            return AjaxResult.error("未查询到学生的业务账号信息");
        }
        Long businessUserId = businessUser.getId();
        List<CompetencyRadarVo> data = competencyKpRelationService.getCompetencyRadarData(businessUserId, courseId);
        return AjaxResult.success(data);
    }
}
