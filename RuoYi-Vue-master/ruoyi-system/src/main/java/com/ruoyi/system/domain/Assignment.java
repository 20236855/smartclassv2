package com.ruoyi.system.domain;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Assignment {
    private Long id; // 作业ID（主键）
    private String title; // 作业名称（核心字段）
    private Long courseId; // 课程ID
    private Long publisherUserId; // 发布人ID
    private String type; // 类型：homework=作业、exam=考试
    private String description; // 作业描述
    private LocalDateTime startTime; // 开始时间
    private LocalDateTime endTime; // 结束时间
    private LocalDateTime createTime; // 创建时间
    private Integer status; // 状态（0=默认）
    private LocalDateTime updateTime; // 更新时间
    private String mode; // 模式：question=题库模式、file=文件模式
    private Integer timeLimit; // 时间限制（分钟）
    private Integer totalScore; // 总分（默认100）
    private Integer duration; // 时长
    private String allowedFileTypes; // 允许上传的文件类型
    private String attachments; // 附件（JSON格式）
    private Integer isDeleted; // 软删除（0=未删除）
    private LocalDateTime deleteTime; // 删除时间
}
