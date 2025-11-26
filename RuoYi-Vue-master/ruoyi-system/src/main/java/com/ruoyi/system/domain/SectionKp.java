package com.ruoyi.system.domain;

import lombok.Data;
import java.util.Date;

/**
 * 小节-知识点关联实体类
 *
 * @author ruoyi
 * @date 2025-11-21
 */
@Data
public class SectionKp {
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;

    /** 小节ID */
    private Long sectionId;

    /** 知识点ID */
    private Long kpId;

    /** 排序序号（默认1） */
    private Integer sequence;

    /** 创建时间 */
    private Date createTime;
}
