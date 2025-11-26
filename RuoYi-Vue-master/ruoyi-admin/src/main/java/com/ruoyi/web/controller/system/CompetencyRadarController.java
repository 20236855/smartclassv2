package com.ruoyi.web.controller.system;

import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.system.domain.vo.CompetencyRadarVo;
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
    private ICompetencyKpRelationService competencyKpRelationService; // 注入新Service

    @GetMapping("/getData")
    public AjaxResult getRadarData(
            @RequestParam Long studentId,
            @RequestParam Long courseId
    ) {
        List<CompetencyRadarVo> data = competencyKpRelationService.getCompetencyRadarData(studentId, courseId);
        return AjaxResult.success(data);
    }
}
