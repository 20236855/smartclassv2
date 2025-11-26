package com.ruoyi.system.domain.vo;

import lombok.Data;
import java.util.List;

@Data
public class QuestionKpRelationVo {
    private Long questionId;
    private Long assignmentId; // 作业ID（必须，来自assignment_question.assignment_id）
    private String assignmentName;
    private Integer questionSequence; // 题目序号（必须，来自assignment_question.sequence）
    private String questionTitle; // 题目名称（可选，增强可读性）
    private List<Long> kpIdList; // 知识点ID列表（集合）
    private List<String> kpTitleList; // 知识点名称列表（集合）
    private String kpIds; // 如 "1002,4001"
    private String kpTitles; // 如 "空间复杂度优化,日志分析技巧"
}
