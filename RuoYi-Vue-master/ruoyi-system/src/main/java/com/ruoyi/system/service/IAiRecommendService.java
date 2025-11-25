package com.ruoyi.system.service;

import com.ruoyi.system.domain.vo.AiRecommendResultVo;

public interface IAiRecommendService {
    /**
     * 生成大模型输入字符串（拼接学生数据、资源数据、规则）
     */
    String generateModelInput(Long studentUserId, Long courseId);

    /**
     * 获取AI个性化推荐结果（含存入数据库）
     */
    AiRecommendResultVo getRecommendResult(Long studentUserId, Long courseId);
}
