package com.ruoyi.system.domain.vo;

import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 视频学习统计VO（中间数据）
 *
 * @author ruoyi
 * @date 2025-11-23
 */
@Data
public class VideoLearningStatVO implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * 平均视频完成率（%）
     */
    private BigDecimal averageCompletionRate;

    /**
     * 总快进次数
     */
    private Integer totalFastForwardCount;

    /**
     * 视频总条数
     */
    private Integer totalVideoCount;
}
