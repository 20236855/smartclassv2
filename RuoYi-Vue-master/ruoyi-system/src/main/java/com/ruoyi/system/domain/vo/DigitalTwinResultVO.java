package com.ruoyi.system.domain.vo;


import lombok.Data;
import java.io.Serializable;
import java.util.List;

/**
 * 数字分身计算结果VO
 *
 * @author ruoyi
 * @date 2025-11-23
 */
@Data
public class DigitalTwinResultVO implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * 数字分身类型（稳步积累型/逻辑攻坚型/高效突击型/查漏补缺型）
     */
    private String twinType;

    /**
     * 匹配分数（0-25分）
     */
    private Integer score;

    /**
     * 特征说明（如：薄弱知识点2个、推荐完成率37.5%）
     */
    private List<String> features;

    /**
     * 所有分身的分数明细（用于调试/展示）
     */
    private List<TwinScoreDetailVO> scoreDetails;
}
