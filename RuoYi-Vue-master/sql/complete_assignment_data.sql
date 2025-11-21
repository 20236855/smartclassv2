-- =============================================
-- 完善作业考试数据
-- 为所有课程创建答题型作业/考试
-- =============================================

USE smartclassv2;

-- =============================================
-- 第一部分：为其他课程创建答题型作业
-- =============================================

-- 课程2：后端开发基础 (Java)
INSERT INTO assignment (id, title, course_id, publisher_user_id, type, description, start_time, end_time, create_time, status, update_time, mode, time_limit, total_score, duration, allowed_file_types, attachments, is_deleted) VALUES
(3004, 'Java基础知识测试', 2, 29, 'homework', '本次作业测试Java基础知识，包括数据类型、运算符、控制流程等。\n\n要求：\n1. 独立完成\n2. 认真审题\n3. 建议用时：30分钟', '2025-11-18', '2025-11-28', NOW(), 1, NOW(), 'question', 45, 100, 30, NULL, '[]', 0),
(3005, 'Java面向对象编程考试', 2, 29, 'exam', '本次考试全面考察Java面向对象编程知识。\n\n要求：\n1. 独立完成，严禁作弊\n2. 建议用时：50分钟\n3. 总分：100分', '2025-11-19', '2025-11-29', NOW(), 1, NOW(), 'question', 75, 100, 50, NULL, '[]', 0);

-- 课程3：数据库原理
INSERT INTO assignment (id, title, course_id, publisher_user_id, type, description, start_time, end_time, create_time, status, update_time, mode, time_limit, total_score, duration, allowed_file_types, attachments, is_deleted) VALUES
(3006, 'SQL基础查询练习', 3, 29, 'homework', '本次作业练习SQL基础查询语句。\n\n要求：\n1. 掌握SELECT、WHERE、ORDER BY等基础语法\n2. 建议用时：25分钟', '2025-11-18', '2025-11-28', NOW(), 1, NOW(), 'question', 40, 100, 25, NULL, '[]', 0),
(3007, '数据库设计与优化考试', 3, 29, 'exam', '本次考试考察数据库设计、索引、事务等知识。\n\n要求：\n1. 独立完成\n2. 建议用时：45分钟', '2025-11-19', '2025-11-29', NOW(), 1, NOW(), 'question', 70, 100, 45, NULL, '[]', 0);

-- 课程4：计算机网络
INSERT INTO assignment (id, title, course_id, publisher_user_id, type, description, start_time, end_time, create_time, status, update_time, mode, time_limit, total_score, duration, allowed_file_types, attachments, is_deleted) VALUES
(3008, '网络协议基础测试', 4, 29, 'homework', '本次作业测试TCP/IP、HTTP等网络协议基础知识。\n\n要求：\n1. 理解各层协议的作用\n2. 建议用时：30分钟', '2025-11-18', '2025-11-28', NOW(), 1, NOW(), 'question', 45, 100, 30, NULL, '[]', 0),
(3009, '网络安全综合考试', 4, 29, 'exam', '本次考试全面考察网络安全知识。\n\n要求：\n1. 独立完成\n2. 建议用时：40分钟', '2025-11-19', '2025-11-29', NOW(), 1, NOW(), 'question', 60, 100, 40, NULL, '[]', 0);

-- 课程5：操作系统
INSERT INTO assignment (id, title, course_id, publisher_user_id, type, description, start_time, end_time, create_time, status, update_time, mode, time_limit, total_score, duration, allowed_file_types, attachments, is_deleted) VALUES
(3010, '进程与线程基础练习', 5, 29, 'homework', '本次作业练习进程、线程相关知识。\n\n要求：\n1. 理解进程和线程的区别\n2. 建议用时：25分钟', '2025-11-18', '2025-11-28', NOW(), 1, NOW(), 'question', 40, 100, 25, NULL, '[]', 0),
(3011, '操作系统原理综合考试', 5, 29, 'exam', '本次考试考察操作系统核心原理。\n\n要求：\n1. 独立完成\n2. 建议用时：50分钟', '2025-11-19', '2025-11-29', NOW(), 1, NOW(), 'question', 75, 100, 50, NULL, '[]', 0);

-- 课程6：数据结构与算法
INSERT INTO assignment (id, title, course_id, publisher_user_id, type, description, start_time, end_time, create_time, status, update_time, mode, time_limit, total_score, duration, allowed_file_types, attachments, is_deleted) VALUES
(3012, '线性表与链表练习', 6, 29, 'homework', '本次作业练习线性表、链表相关知识。\n\n要求：\n1. 理解各种数据结构的特点\n2. 建议用时：30分钟', '2025-11-18', '2025-11-28', NOW(), 1, NOW(), 'question', 45, 100, 30, NULL, '[]', 0),
(3013, '算法设计与分析考试', 6, 29, 'exam', '本次考试考察算法设计与时间复杂度分析。\n\n要求：\n1. 独立完成\n2. 建议用时：60分钟', '2025-11-19', '2025-11-29', NOW(), 1, NOW(), 'question', 90, 100, 60, NULL, '[]', 0);

-- 课程7：软件工程
INSERT INTO assignment (id, title, course_id, publisher_user_id, type, description, start_time, end_time, create_time, status, update_time, mode, time_limit, total_score, duration, allowed_file_types, attachments, is_deleted) VALUES
(3014, '软件开发流程测试', 7, 29, 'homework', '本次作业测试软件开发流程相关知识。\n\n要求：\n1. 理解敏捷开发、瀑布模型等\n2. 建议用时：25分钟', '2025-11-18', '2025-11-28', NOW(), 1, NOW(), 'question', 40, 100, 25, NULL, '[]', 0),
(3015, '软件设计模式考试', 7, 29, 'exam', '本次考试考察常用设计模式。\n\n要求：\n1. 独立完成\n2. 建议用时：45分钟', '2025-11-19', '2025-11-29', NOW(), 1, NOW(), 'question', 70, 100, 45, NULL, '[]', 0);

-- 课程8：人工智能基础
INSERT INTO assignment (id, title, course_id, publisher_user_id, type, description, start_time, end_time, create_time, status, update_time, mode, time_limit, total_score, duration, allowed_file_types, attachments, is_deleted) VALUES
(3016, '机器学习基础测试', 8, 29, 'homework', '本次作业测试机器学习基础概念。\n\n要求：\n1. 理解监督学习、非监督学习\n2. 建议用时：30分钟', '2025-11-18', '2025-11-28', NOW(), 1, NOW(), 'question', 45, 100, 30, NULL, '[]', 0),
(3017, '深度学习综合考试', 8, 29, 'exam', '本次考试考察深度学习相关知识。\n\n要求：\n1. 独立完成\n2. 建议用时：50分钟', '2025-11-19', '2025-11-29', NOW(), 1, NOW(), 'question', 75, 100, 50, NULL, '[]', 0);

-- =============================================
-- 第二部分：为新作业关联题目
-- 注意：这里使用课程1的题目作为示例
-- 实际应该为每个课程创建专门的题目
-- =============================================

-- 作业3004：Java基础知识测试（10道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3004, 3001, 10, 1),
(3004, 3002, 10, 2),
(3004, 3003, 10, 3),
(3004, 3004, 10, 4),
(3004, 3005, 10, 5),
(3004, 3006, 10, 6),
(3004, 3009, 10, 7),
(3004, 3010, 10, 8),
(3004, 3017, 10, 9),
(3004, 3018, 10, 10);

-- 作业3005：Java面向对象编程考试（15道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3005, 3001, 5, 1),
(3005, 3003, 5, 2),
(3005, 3005, 5, 3),
(3005, 3007, 5, 4),
(3005, 3009, 5, 5),
(3005, 3011, 5, 6),
(3005, 3013, 5, 7),
(3005, 3015, 5, 8),
(3005, 3017, 5, 9),
(3005, 3019, 5, 10),
(3005, 3021, 10, 11),
(3005, 3022, 10, 12),
(3005, 3023, 10, 13),
(3005, 3026, 5, 14),
(3005, 3027, 5, 15);

-- 作业3006：SQL基础查询练习（8道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3006, 3001, 12, 1),
(3006, 3002, 12, 2),
(3006, 3003, 12, 3),
(3006, 3004, 12, 4),
(3006, 3005, 13, 5),
(3006, 3006, 13, 6),
(3006, 3009, 13, 7),
(3006, 3010, 13, 8);

-- 作业3007：数据库设计与优化考试（12道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3007, 3001, 6, 1),
(3007, 3003, 6, 2),
(3007, 3005, 6, 3),
(3007, 3007, 6, 4),
(3007, 3009, 6, 5),
(3007, 3011, 6, 6),
(3007, 3013, 6, 7),
(3007, 3015, 7, 8),
(3007, 3021, 10, 9),
(3007, 3022, 10, 10),
(3007, 3026, 5, 11),
(3007, 3027, 5, 12);

-- 作业3008：网络协议基础测试（10道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3008, 3001, 10, 1),
(3008, 3002, 10, 2),
(3008, 3003, 10, 3),
(3008, 3004, 10, 4),
(3008, 3005, 10, 5),
(3008, 3006, 10, 6),
(3008, 3009, 10, 7),
(3008, 3010, 10, 8),
(3008, 3017, 10, 9),
(3008, 3018, 10, 10);

-- 作业3009：网络安全综合考试（14道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3009, 3001, 5, 1),
(3009, 3003, 5, 2),
(3009, 3005, 5, 3),
(3009, 3007, 5, 4),
(3009, 3009, 5, 5),
(3009, 3011, 5, 6),
(3009, 3013, 5, 7),
(3009, 3015, 5, 8),
(3009, 3021, 10, 9),
(3009, 3022, 10, 10),
(3009, 3023, 10, 11),
(3009, 3026, 5, 12),
(3009, 3027, 5, 13),
(3009, 3028, 5, 14);

-- 作业3010：进程与线程基础练习（8道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3010, 3001, 12, 1),
(3010, 3002, 12, 2),
(3010, 3003, 12, 3),
(3010, 3004, 13, 4),
(3010, 3005, 13, 5),
(3010, 3006, 13, 6),
(3010, 3009, 12, 7),
(3010, 3010, 13, 8);

-- 作业3011：操作系统原理综合考试（16道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3011, 3001, 5, 1),
(3011, 3002, 5, 2),
(3011, 3003, 5, 3),
(3011, 3005, 5, 4),
(3011, 3007, 5, 5),
(3011, 3009, 5, 6),
(3011, 3011, 5, 7),
(3011, 3013, 5, 8),
(3011, 3015, 5, 9),
(3011, 3017, 5, 10),
(3011, 3021, 10, 11),
(3011, 3022, 10, 12),
(3011, 3023, 10, 13),
(3011, 3026, 5, 14),
(3011, 3027, 5, 15),
(3011, 3028, 5, 16);

-- 作业3012：线性表与链表练习（10道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3012, 3001, 10, 1),
(3012, 3002, 10, 2),
(3012, 3003, 10, 3),
(3012, 3004, 10, 4),
(3012, 3005, 10, 5),
(3012, 3006, 10, 6),
(3012, 3009, 10, 7),
(3012, 3010, 10, 8),
(3012, 3017, 10, 9),
(3012, 3018, 10, 10);

-- 作业3013：算法设计与分析考试（20道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3013, 3001, 3, 1),
(3013, 3002, 3, 2),
(3013, 3003, 3, 3),
(3013, 3005, 3, 4),
(3013, 3006, 3, 5),
(3013, 3007, 3, 6),
(3013, 3009, 3, 7),
(3013, 3011, 3, 8),
(3013, 3012, 3, 9),
(3013, 3013, 3, 10),
(3013, 3014, 3, 11),
(3013, 3015, 3, 12),
(3013, 3017, 4, 13),
(3013, 3019, 4, 14),
(3013, 3020, 4, 15),
(3013, 3021, 8, 16),
(3013, 3022, 8, 17),
(3013, 3023, 8, 18),
(3013, 3026, 4, 19),
(3013, 3027, 4, 20);

-- 作业3014：软件开发流程测试（8道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3014, 3001, 12, 1),
(3014, 3002, 12, 2),
(3014, 3003, 12, 3),
(3014, 3004, 13, 4),
(3014, 3005, 13, 5),
(3014, 3006, 13, 6),
(3014, 3009, 12, 7),
(3014, 3010, 13, 8);

-- 作业3015：软件设计模式考试（13道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3015, 3001, 6, 1),
(3015, 3003, 6, 2),
(3015, 3005, 6, 3),
(3015, 3007, 6, 4),
(3015, 3009, 6, 5),
(3015, 3011, 6, 6),
(3015, 3013, 6, 7),
(3015, 3015, 6, 8),
(3015, 3021, 10, 9),
(3015, 3022, 10, 10),
(3015, 3023, 10, 11),
(3015, 3026, 6, 12),
(3015, 3027, 6, 13);

-- 作业3016：机器学习基础测试（10道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3016, 3001, 10, 1),
(3016, 3002, 10, 2),
(3016, 3003, 10, 3),
(3016, 3004, 10, 4),
(3016, 3005, 10, 5),
(3016, 3006, 10, 6),
(3016, 3009, 10, 7),
(3016, 3010, 10, 8),
(3016, 3017, 10, 9),
(3016, 3018, 10, 10);

-- 作业3017：深度学习综合考试（17道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3017, 3001, 4, 1),
(3017, 3002, 4, 2),
(3017, 3003, 4, 3),
(3017, 3005, 4, 4),
(3017, 3006, 4, 5),
(3017, 3007, 4, 6),
(3017, 3009, 4, 7),
(3017, 3011, 4, 8),
(3017, 3013, 4, 9),
(3017, 3015, 4, 10),
(3017, 3017, 4, 11),
(3017, 3019, 4, 12),
(3017, 3021, 10, 13),
(3017, 3022, 10, 14),
(3017, 3023, 10, 15),
(3017, 3026, 4, 16),
(3017, 3027, 4, 17);

-- =============================================
-- 第三部分：验证数据
-- =============================================

-- 查看所有答题型作业
SELECT
    a.id AS '作业ID',
    a.title AS '作业标题',
    c.title AS '课程名称',
    a.type AS '类型',
    a.mode AS '模式',
    a.total_score AS '总分',
    COUNT(aq.id) AS '题目数量',
    SUM(aq.score) AS '实际总分'
FROM assignment a
LEFT JOIN course c ON a.course_id = c.id
LEFT JOIN assignment_question aq ON a.id = aq.assignment_id AND aq.is_deleted = 0
WHERE a.mode = 'question' AND a.is_deleted = 0
GROUP BY a.id
ORDER BY a.id;

