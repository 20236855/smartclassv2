-- Seed script: 为 course_id=33, chapter_id=1 插入 10 道高数极限题
-- 请在执行前确认数据库备份。若需修改 created_by，请更新 @created_by 变量。

SET @course_id = 33;
SET @chapter_id = 1;
SET @created_by = 1; -- 请按需替换为实际用户 id

-- 1) 如果 chapter id=1 且 course_id=33 不存在，则创建该章节（尝试显式插入 id）
INSERT INTO chapter (id, course_id, title, description, sort_order, create_time, is_deleted)
SELECT @chapter_id, @course_id, '第1章 第1小节（极限）', '自动创建用于题目测试', 1, NOW(), 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM chapter WHERE id = @chapter_id AND course_id = @course_id);

-- 2) 插入题目（使用 question_type='short'）
INSERT INTO `question` (`title`,`question_type`,`difficulty`,`correct_answer`,`explanation`,`knowledge_point`,`course_id`,`chapter_id`,`created_by`,`create_time`,`is_deleted`)
VALUES
('求极限 lim_{x→0} (sin x) / x','short',2,'1','基本极限，可用 sin x ≈ x 或夹逼定理得到。',NULL,@course_id,@chapter_id,@created_by,NOW(),0),
('求极限 lim_{x→0} (1 + x)^{1/x}','short',2,'e','令 y=(1+x)^{1/x}, 对数化并用 ln(1+x)≈x 得 e。',NULL,@course_id,@chapter_id,@created_by,NOW(),0),
('求极限 lim_{x→0} (cos x - 1) / x^2','short',2,'-1/2','用 cos x = 1 - x^2/2 + o(x^2)，因此极限为 -1/2。',NULL,@course_id,@chapter_id,@created_by,NOW(),0),
('求极限 lim_{x→0} (e^{x} - 1 - x) / x^2','short',2,'1/2','e^x 展开：1 + x + x^2/2 + …，分子主项为 x^2/2。',NULL,@course_id,@chapter_id,@created_by,NOW(),0),
('求极限 lim_{x→∞} (1 + 1/x)^x','short',2,'e','经典极限，极限为 e。',NULL,@course_id,@chapter_id,@created_by,NOW(),0),
('求极限 lim_{x→0} (tan x - x) / x^3','short',2,'1/3','tan x = x + x^3/3 + …，因此极限为 1/3。',NULL,@course_id,@chapter_id,@created_by,NOW(),0),
('求极限 lim_{x→0} ( (1 + sin x)^{1/x} )','short',2,'e','ln 值为 (1/x) ln(1+sin x) ≈ (1/x) sin x ≈ 1，所以极限为 e。',NULL,@course_id,@chapter_id,@created_by,NOW(),0),
('求极限 lim_{x→0^+} x^x','short',2,'1','写作 e^{x ln x}, x ln x → 0，极限为 1。',NULL,@course_id,@chapter_id,@created_by,NOW(),0),
('求极限 lim_{x→0} ( (1 + ax)^{1/x} )（a 为常数）','short',2,'e^{a}','ln → a，故极限 e^{a}。',NULL,@course_id,@chapter_id,@created_by,NOW(),0),
('求极限 lim_{x→0} (sin 3x) / (sin 2x)','short',2,'3/2','用 sin kx ≈ kx，得 3/2。',NULL,@course_id,@chapter_id,@created_by,NOW(),0);

-- 3) 检查插入结果（如需在脚本内查看）
SELECT id, title, question_type, course_id, chapter_id, created_by, create_time
FROM question
WHERE course_id = @course_id AND chapter_id = @chapter_id
ORDER BY create_time DESC
LIMIT 20;

-- 说明：
-- 1) 若数据库有触发器或其他约束，会影响插入，请在执行前确认约束。
-- 2) 若你使用的 MySQL 用户没有直接插入指定 id 的权限或 id 冲突，手动创建章节或先查询再替换 @chapter_id。
-- 3) 若要在 PowerShell 下运行此脚本：
--    mysql -u 用户名 -p smartclassv2 < path\to\seed_limit_questions_course33_chapter1.sql
