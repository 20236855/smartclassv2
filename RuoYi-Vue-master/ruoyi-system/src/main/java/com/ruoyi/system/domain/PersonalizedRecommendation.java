package com.ruoyi.system.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("personalized_recommendation")
public class PersonalizedRecommendation {

    @TableId(type = IdType.AUTO)
    private Long id; // 主键ID（自增）

    private Long studentUserId; // 学生ID
    private Long courseId; // 课程ID
    private String recommendType; // 推荐类型（video/exercise/resource/kp_review）
    private Long targetId; // 目标ID（小节ID/题目ID/资源ID）
    private String recommendReason; // 推荐理由
    private String relatedKpIds; // 关联知识点ID（逗号分隔）
    private String status; // 状态（pending/viewed/completed/expired）
    private Integer priority; // 优先级（默认3）
    private String aiModelVersion; // AI模型版本
    private LocalDateTime expireTime; // 过期时间（7天）
    private Integer isDeleted; // 是否删除（默认0）
    // 新增：推荐批次ID（对应数据库batch_id）
    @TableField("batch_id") // 明确指定数据库字段名，避免驼峰映射问题
    private String batchId;
    // 自动填充：创建时间（插入时填充）
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    // 自动填充：更新时间（插入和更新时填充）
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
