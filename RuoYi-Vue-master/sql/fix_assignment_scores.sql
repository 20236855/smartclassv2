-- =============================================
-- 修正作业分数，确保总分为100分
-- =============================================

USE smartclassv2;

-- 修正作业3005的分数（当前90分，需要增加10分）
UPDATE assignment_question SET score = 6 WHERE assignment_id = 3005 AND sequence IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
UPDATE assignment_question SET score = 10 WHERE assignment_id = 3005 AND sequence IN (11, 12, 13);
UPDATE assignment_question SET score = 6 WHERE assignment_id = 3005 AND sequence IN (14, 15);

-- 修正作业3007的分数（当前79分，需要增加21分）
UPDATE assignment_question SET score = 8 WHERE assignment_id = 3007 AND sequence IN (1, 2, 3, 4, 5, 6, 7);
UPDATE assignment_question SET score = 9 WHERE assignment_id = 3007 AND sequence = 8;
UPDATE assignment_question SET score = 12 WHERE assignment_id = 3007 AND sequence IN (9, 10);
UPDATE assignment_question SET score = 6 WHERE assignment_id = 3007 AND sequence IN (11, 12);

-- 修正作业3009的分数（当前85分，需要增加15分）
UPDATE assignment_question SET score = 6 WHERE assignment_id = 3009 AND sequence IN (1, 2, 3, 4, 5, 6, 7, 8);
UPDATE assignment_question SET score = 11 WHERE assignment_id = 3009 AND sequence IN (9, 10, 11);
UPDATE assignment_question SET score = 5 WHERE assignment_id = 3009 AND sequence IN (12, 13, 14);

-- 修正作业3011的分数（当前95分，需要增加5分）
UPDATE assignment_question SET score = 5 WHERE assignment_id = 3011 AND sequence IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
UPDATE assignment_question SET score = 11 WHERE assignment_id = 3011 AND sequence IN (11, 12, 13);
UPDATE assignment_question SET score = 6 WHERE assignment_id = 3011 AND sequence IN (14, 15);
UPDATE assignment_question SET score = 5 WHERE assignment_id = 3011 AND sequence = 16;

-- 修正作业3013的分数（当前80分，需要增加20分）
UPDATE assignment_question SET score = 4 WHERE assignment_id = 3013 AND sequence IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12);
UPDATE assignment_question SET score = 5 WHERE assignment_id = 3013 AND sequence IN (13, 14, 15);
UPDATE assignment_question SET score = 9 WHERE assignment_id = 3013 AND sequence IN (16, 17, 18);
UPDATE assignment_question SET score = 5 WHERE assignment_id = 3013 AND sequence IN (19, 20);

-- 修正作业3015的分数（当前90分，需要增加10分）
UPDATE assignment_question SET score = 7 WHERE assignment_id = 3015 AND sequence IN (1, 2, 3, 4, 5, 6, 7, 8);
UPDATE assignment_question SET score = 11 WHERE assignment_id = 3015 AND sequence IN (9, 10, 11);
UPDATE assignment_question SET score = 5 WHERE assignment_id = 3015 AND sequence IN (12, 13);

-- 修正作业3017的分数（当前86分，需要增加14分）
UPDATE assignment_question SET score = 5 WHERE assignment_id = 3017 AND sequence IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12);
UPDATE assignment_question SET score = 10 WHERE assignment_id = 3017 AND sequence IN (13, 14, 15);
UPDATE assignment_question SET score = 5 WHERE assignment_id = 3017 AND sequence IN (16, 17);

-- 为作业2003添加题目（10道题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(2003, 3001, 10, 1),
(2003, 3002, 10, 2),
(2003, 3003, 10, 3),
(2003, 3004, 10, 4),
(2003, 3005, 10, 5),
(2003, 3006, 10, 6),
(2003, 3009, 10, 7),
(2003, 3010, 10, 8),
(2003, 3017, 10, 9),
(2003, 3018, 10, 10);

-- 验证修正结果
SELECT
    a.id AS '作业ID',
    a.title AS '作业标题',
    a.total_score AS '总分',
    COUNT(aq.id) AS '题目数量',
    SUM(aq.score) AS '实际总分',
    CASE 
        WHEN SUM(aq.score) = a.total_score THEN '✓ 正确'
        ELSE '✗ 错误'
    END AS '状态'
FROM assignment a
LEFT JOIN assignment_question aq ON a.id = aq.assignment_id AND aq.is_deleted = 0
WHERE a.mode = 'question' AND a.is_deleted = 0
GROUP BY a.id
ORDER BY a.id;

