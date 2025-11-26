package com.ruoyi.system.domain.vo;

import com.ruoyi.system.domain.AssignmentSubmission;
import com.ruoyi.system.domain.StudentAnswer;
import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

/**
 * 作业答题统计VO（中间数据）
 *
 * @author ruoyi
 * @date 2025-11-23
 */
@Data
public class AssignmentAnswerVO implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * 作业提交记录
     */
    private AssignmentSubmission submission;

    /**
     * 单题答题记录列表
     */
    private List<StudentAnswer> answerList;

    /**
     * 答题总时长（毫秒）
     */
    private Long totalAnswerTime;

    /**
     * 答题正确率（%）
     */
    private BigDecimal correctRate;
}
