package com.ruoyi.system.domain.vo;

import lombok.Data;
import java.io.Serializable;
import java.util.List;

/**
 * 数字分身分数明细VO
 *
 * @author ruoyi
 * @date 2025-11-23
 */
@Data
public class TwinScoreDetailVO implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * 分身类型
     */
    private String twinType;

    /**
     * 匹配分数
     */
    private Integer score;

    /**
     * 规则匹配情况（如："薄弱知识点≤2个：符合（+5分）"）
     */
    private List<String> ruleMatches;

}
