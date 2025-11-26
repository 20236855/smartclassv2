package com.ruoyi.system.service;

import com.ruoyi.system.domain.vo.DigitalTwinResultVO;

/**
 * 数字分身服务接口
 *
 * @author ruoyi
 * @date 2025-11-23
 */
public interface IDigitalTwinService {

    /**
     * 计算学生的数字分身（匹配4种类型，返回最高分结果）
     *
     * @param studentId    用户ID（对应user表的id，如24、37）
     * @param courseId  课程ID（如123）
     * @return 数字分身结果（包含类型、分数、特征说明）
     */
    DigitalTwinResultVO calculateDigitalTwin(Long studentId, Long courseId);
}
