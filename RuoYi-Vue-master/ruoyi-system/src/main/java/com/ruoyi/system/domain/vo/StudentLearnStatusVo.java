package com.ruoyi.system.domain.vo;

import lombok.Data;

@Data
public class StudentLearnStatusVo {
    private Long studentUserId;
    private Long courseId;
    private Long kpId;
    private String kpTitle;
    private String masteryStatus;
    // 关键修改：从 Double/Integer 改为 String，接收带%的字符串
    private String accuracy;
    private Long assignmentId;
    private String wrongQuestionNo;
}
