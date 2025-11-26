package com.ruoyi.system.domain.vo;

import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 同课程其他学生基准数据VO（用于对比）
 *
 * @author ruoyi
 * @date 2025-11-23
 */
@Data
public class CourseBenchmarkVO implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * 同课程平均答题时长（毫秒）
     */
    private Long avgAnswerTime;

    /**
     * 同课程平均视频完成率（%）
     */
    private BigDecimal avgVideoCompletionRate;

    /**
     * 同课程平均薄弱知识点数量
     */
    private Integer avgWeakKpCount;
}
