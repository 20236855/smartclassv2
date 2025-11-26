package com.ruoyi.system.domain.vo;

import lombok.Data;

import java.util.List;

@Data
public class AiRecommendResultVo {
    private String recommendContent; // 大模型推荐内容
    private String modelInput;
    private String thinkingMode; // 思维模式
    private String avatarUrl; // 2D形象URL
    private String modeDesc; // 思维模式说明
    private String avatarStatus; // 状态
    private List<PersonalizedRecommendItemVo> recommendItemList;
}
