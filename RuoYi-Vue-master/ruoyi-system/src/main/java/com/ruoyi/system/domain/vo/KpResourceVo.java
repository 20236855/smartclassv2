package com.ruoyi.system.domain.vo;

import lombok.Data;

@Data
public class KpResourceVo {
    private Long kpId; // 知识点ID
    private String kpTitle; // 知识点名称
    private Long sectionId; // 小节ID
    private String sectionTitle; // 小节标题
    private String videoUrl; // 视频URL
    private String coreKnowledge; // 核心考点（section.description）
    private Integer sortOrder; // 小节排序
}
