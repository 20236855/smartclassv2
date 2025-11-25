package com.ruoyi.system.domain.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class PersonalizedRecommendItemVo {
    private Long id;
    private String batchId;
    private String recommendType;
    private Long targetId;
    private String recommendReason;
    private String relatedKpIds;
    private String status;
    private LocalDateTime createTime;
    private String relatedKpNames;
}
