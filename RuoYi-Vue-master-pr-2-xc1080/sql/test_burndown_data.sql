-- 测试课时燃尽图数据
-- 为userId=37的教师的课程小节添加上课时间
-- 课程信息：
-- 40003: 自然语言处理 (2025-10-30 至 2026-01-10) - 最早开始
-- 40004: 高等数学 (2025-11-05 至 2025-12-06)
-- 40005: 计算机组成原理 (2025-11-19 至 2025-12-05)
-- 40002: python编程技术 (2025-11-20 至 2025-12-31)
-- 40001: 人工智能导论 (2025-11-30 至 2025-12-31)

-- ========== 计算机组成原理课程 (40005) - 进度正常 ==========
-- 第一章 计算机系统概述和系统总线 (章节ID: 72011) - 已完成
UPDATE section SET class_time = '2025-11-20 10:00:00' WHERE id = 503 AND is_deleted = 0; -- 1.1 计算机软硬件概念
UPDATE section SET class_time = '2025-11-21 10:00:00' WHERE id = 504 AND is_deleted = 0; -- 1.2 计算机系统的层次结构
UPDATE section SET class_time = '2025-11-22 10:00:00' WHERE id = 505 AND is_deleted = 0; -- 1.3 计算机的基本组成
UPDATE section SET class_time = '2025-11-22 14:00:00' WHERE id = 506 AND is_deleted = 0; -- 1.4 计算机硬件框图及工作过程
UPDATE section SET class_time = '2025-11-25 10:00:00' WHERE id = 507 AND is_deleted = 0; -- 1.5 计算机硬件主要技术指标
UPDATE section SET class_time = '2025-11-26 10:00:00' WHERE id = 508 AND is_deleted = 0; -- 1.6 计算机发展及应用
UPDATE section SET class_time = '2025-11-26 14:00:00' WHERE id = 509 AND is_deleted = 0; -- 1.7 系统总线分类
UPDATE section SET class_time = '2025-11-27 10:00:00' WHERE id = 510 AND is_deleted = 0; -- 1.8 系统总线性能指标
UPDATE section SET class_time = '2025-11-27 14:00:00' WHERE id = 511 AND is_deleted = 0; -- 1.9 总线控制

-- 第二章 存储器 (章节ID: 72012) - 已完成大部分
UPDATE section SET class_time = '2025-11-28 10:00:00' WHERE id = 512 AND is_deleted = 0; -- 2.1 存储器概述
UPDATE section SET class_time = '2025-11-28 14:00:00' WHERE id = 513 AND is_deleted = 0; -- 2.2 存储器的层次结构
UPDATE section SET class_time = '2025-11-29 10:00:00' WHERE id = 514 AND is_deleted = 0; -- 2.3 主存储器概述
UPDATE section SET class_time = '2025-11-29 14:00:00' WHERE id = 515 AND is_deleted = 0; -- 2.4 半导体存储芯片简介与扩容
UPDATE section SET class_time = '2025-11-30 10:00:00' WHERE id = 516 AND is_deleted = 0; -- 2.5 半导体存储芯片与CPU的连接
UPDATE section SET class_time = '2025-11-30 14:00:00' WHERE id = 517 AND is_deleted = 0; -- 2.6 提高访存速度的措施
UPDATE section SET class_time = '2025-12-01 10:00:00' WHERE id = 518 AND is_deleted = 0; -- 2.7 存储器的校验
UPDATE section SET class_time = '2025-12-01 14:00:00' WHERE id = 519 AND is_deleted = 0; -- 2.8 高速缓存概述
UPDATE section SET class_time = '2025-12-02 10:00:00' WHERE id = 520 AND is_deleted = 0; -- 2.9 Cache-主存地址映射
UPDATE section SET class_time = '2025-12-02 14:00:00' WHERE id = 521 AND is_deleted = 0; -- 2.10 替换策略

-- 第三章 运算器 (章节ID: 72013) - 进行中
UPDATE section SET class_time = '2025-12-03 10:00:00' WHERE id = 524 AND is_deleted = 0; -- 3.1 无符号数和有符号数
UPDATE section SET class_time = '2025-12-03 14:00:00' WHERE id = 525 AND is_deleted = 0; -- 3.2 数的定点表示

-- ========== 高等数学课程 (40004) - 进度较快（早期开始） ==========
-- 需要先查找章节ID 72005-72010的小节ID
-- 这里用通用的方式批量更新前20个小节
UPDATE section s
INNER JOIN chapter ch ON s.chapter_id = ch.id
SET s.class_time = CASE 
    WHEN s.sort_order = 1 THEN '2025-11-06 10:00:00'
    WHEN s.sort_order = 2 THEN '2025-11-07 10:00:00'
    WHEN s.sort_order = 3 THEN '2025-11-08 10:00:00'
    WHEN s.sort_order = 4 THEN '2025-11-11 10:00:00'
    WHEN s.sort_order = 5 THEN '2025-11-12 10:00:00'
    WHEN s.sort_order = 6 THEN '2025-11-13 10:00:00'
    ELSE s.class_time
END
WHERE ch.course_id = 40004 
AND ch.id = 72005 -- 第一章
AND s.is_deleted = 0
AND ch.is_deleted = 0;

UPDATE section s
INNER JOIN chapter ch ON s.chapter_id = ch.id
SET s.class_time = CASE 
    WHEN s.sort_order = 1 THEN '2025-11-14 10:00:00'
    WHEN s.sort_order = 2 THEN '2025-11-15 10:00:00'
    WHEN s.sort_order = 3 THEN '2025-11-18 10:00:00'
    WHEN s.sort_order = 4 THEN '2025-11-19 10:00:00'
    ELSE s.class_time
END
WHERE ch.course_id = 40004 
AND ch.id = 72006 -- 第二章
AND s.is_deleted = 0
AND ch.is_deleted = 0;

-- ========== 人工智能导论课程 (40001) - 刚开始 ==========
-- 第1章 神经网络入门 (章节ID: 72001)
UPDATE section s
INNER JOIN chapter ch ON s.chapter_id = ch.id
SET s.class_time = CASE 
    WHEN s.sort_order = 1 THEN '2025-12-01 16:00:00'
    WHEN s.sort_order = 2 THEN '2025-12-02 16:00:00'
    ELSE s.class_time
END
WHERE ch.id = 72001
AND s.is_deleted = 0
AND ch.is_deleted = 0
LIMIT 2;

-- ========== Python编程技术 (40002) - 中等进度 ==========
-- 为前8个小节设置上课时间（分布在11月下旬到12月初）
UPDATE section s
INNER JOIN chapter ch ON s.chapter_id = ch.id
SET s.class_time = DATE_ADD('2025-11-21 14:00:00', INTERVAL (s.sort_order - 1) * 2 DAY)
WHERE ch.course_id = 40002
AND s.is_deleted = 0
AND ch.is_deleted = 0
AND s.sort_order <= 8;

-- 查询已设置上课时间的小节（按课程分组统计）
SELECT 
    c.id AS course_id,
    c.title AS course_title,
    c.start_time,
    c.end_time,
    COUNT(DISTINCT s.id) AS total_sections,
    COUNT(DISTINCT CASE WHEN s.class_time IS NOT NULL THEN s.id END) AS completed_sections,
    CONCAT(
        ROUND(COUNT(DISTINCT CASE WHEN s.class_time IS NOT NULL THEN s.id END) * 100.0 / NULLIF(COUNT(DISTINCT s.id), 0), 1),
        '%'
    ) AS completion_rate
FROM course c
LEFT JOIN chapter ch ON c.id = ch.course_id AND ch.is_deleted = 0
LEFT JOIN section s ON ch.id = s.chapter_id AND s.is_deleted = 0
WHERE c.teacher_user_id = 37 
AND c.is_deleted = 0
GROUP BY c.id, c.title, c.start_time, c.end_time
ORDER BY c.start_time;

-- 查询详细的已上课小节列表
SELECT 
    s.id,
    c.title AS course_title,
    ch.title AS chapter_title,
    s.title AS section_title,
    s.class_time
FROM section s
INNER JOIN chapter ch ON s.chapter_id = ch.id AND ch.is_deleted = 0
INNER JOIN course c ON ch.course_id = c.id AND c.is_deleted = 0
WHERE s.class_time IS NOT NULL 
AND s.is_deleted = 0
AND c.teacher_user_id = 37
ORDER BY s.class_time;

-- 统计总体进度
SELECT 
    COUNT(DISTINCT s.id) AS total_sections,
    COUNT(DISTINCT CASE WHEN s.class_time IS NOT NULL THEN s.id END) AS completed_sections,
    COUNT(DISTINCT CASE WHEN s.class_time <= NOW() THEN s.id END) AS should_be_completed,
    CONCAT(
        ROUND(COUNT(DISTINCT CASE WHEN s.class_time IS NOT NULL THEN s.id END) * 100.0 / NULLIF(COUNT(DISTINCT s.id), 0), 1),
        '%'
    ) AS overall_completion_rate
FROM course c
LEFT JOIN chapter ch ON c.id = ch.course_id AND ch.is_deleted = 0
LEFT JOIN section s ON ch.id = s.chapter_id AND s.is_deleted = 0
WHERE c.teacher_user_id = 37 
AND c.is_deleted = 0;
