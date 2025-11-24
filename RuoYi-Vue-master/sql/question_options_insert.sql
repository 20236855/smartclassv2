-- =====================================================
-- 题目选项数据插入
-- 为题目ID 4001-4050 添加选项
-- =====================================================

-- 第一章 极限 - 题目 4001-4025 的选项

-- 题目 4001: 下列关于数列极限的说法，正确的是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4001, 'A', '数列收敛则其任意子数列也收敛', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4001, 'B', '数列有界则必收敛', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4001, 'C', '数列收敛则必有界', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4001, 'D', '数列无界则必发散', 0, NULL);

-- 题目 4002: 极限 lim(x→0) (sin x)/x 的值是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4002, 'A', '0', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4002, 'B', '1', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4002, 'C', '∞', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4002, 'D', '不存在', 0, NULL);

-- 题目 4003: 极限 lim(x→∞) (1 + 1/x)^x 的值是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4003, 'A', '1', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4003, 'B', 'e', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4003, 'C', '∞', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4003, 'D', '0', 0, NULL);

-- 题目 4004: 函数 f(x) 在 x=a 处连续的充要条件是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4004, 'A', 'lim(x→a) f(x) 存在', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4004, 'B', 'f(a) 存在', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4004, 'C', 'lim(x→a) f(x) = f(a)', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4004, 'D', 'f(x) 在 x=a 处有定义', 0, NULL);

-- 题目 4005: 无穷小量与无穷大量的关系是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4005, 'A', '互为倒数', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4005, 'B', '互为相反数', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4005, 'C', '没有关系', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4005, 'D', '互为负倒数', 0, NULL);

-- 题目 4006: 极限 lim(x→0) (e^x - 1)/x 的值是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4006, 'A', '0', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4006, 'B', '1', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4006, 'C', 'e', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4006, 'D', '∞', 0, NULL);

-- 题目 4007: 下列函数中，在 x=0 处不连续的是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4007, 'A', 'f(x) = x^2', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4007, 'B', 'f(x) = |x|', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4007, 'C', 'f(x) = 1/x', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4007, 'D', 'f(x) = sin x', 0, NULL);

-- 题目 4008: 极限 lim(x→0) (1 - cos x)/x^2 的值是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4008, 'A', '0', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4008, 'B', '1/2', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4008, 'C', '1', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4008, 'D', '2', 0, NULL);

-- 题目 4009: 数列 {(-1)^n} 的极限是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4009, 'A', '1', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4009, 'B', '-1', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4009, 'C', '0', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4009, 'D', '不存在', 0, NULL);

-- 题目 4010: 极限 lim(x→∞) (3x^2 + 2x + 1)/(x^2 - x + 5) 的值是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4010, 'A', '0', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4010, 'B', '1', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4010, 'C', '3', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4010, 'D', '∞', 0, NULL);

-- 题目 4011-4015: 多选题选项
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4011, 'A', '极限存在', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4011, 'B', '左右极限相等', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4011, 'C', '函数有定义', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4011, 'D', '极限值等于函数值', 0, NULL);

INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4012, 'A', '有界性', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4012, 'B', '保号性', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4012, 'C', '唯一性', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4012, 'D', '周期性', 0, NULL);

INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4013, 'A', '等价无穷小替换', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4013, 'B', '洛必达法则', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4013, 'C', '泰勒展开', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4013, 'D', '夹逼准则', 0, NULL);

INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4014, 'A', '第一类间断点', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4014, 'B', '第二类间断点', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4014, 'C', '可去间断点', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4014, 'D', '跳跃间断点', 0, NULL);

INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4015, 'A', '单调有界数列必收敛', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4015, 'B', '柯西收敛准则', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4015, 'C', '夹逼准则', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4015, 'D', '海涅定理', 0, NULL);

-- 题目 4016-4020: 判断题（无需选项）

-- 题目 4021-4025: 简答题（无需选项）

-- =====================================================
-- 第二章 函数 - 题目 4026-4050 的选项
-- =====================================================

-- 题目 4026: 函数 y = √(1-x²) 的定义域是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4026, 'A', '[-1, 1]', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4026, 'B', '(-1, 1)', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4026, 'C', '(-∞, +∞)', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4026, 'D', '[0, 1]', 0, NULL);

-- 题目 4027: 下列函数中，是奇函数的是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4027, 'A', 'f(x) = x²', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4027, 'B', 'f(x) = x³', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4027, 'C', 'f(x) = |x|', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4027, 'D', 'f(x) = 2^x', 0, NULL);

-- 题目 4028: 函数 f(x) = ln x 的值域是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4028, 'A', '(0, +∞)', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4028, 'B', '(-∞, +∞)', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4028, 'C', '[0, +∞)', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4028, 'D', '(-∞, 0)', 0, NULL);

-- 题目 4029: 下列函数中，是周期函数的是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4029, 'A', 'f(x) = x²', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4029, 'B', 'f(x) = sin x', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4029, 'C', 'f(x) = e^x', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4029, 'D', 'f(x) = ln x', 0, NULL);

-- 题目 4030: 反函数 y = arcsin x 的定义域是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4030, 'A', '[-1, 1]', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4030, 'B', '(-1, 1)', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4030, 'C', '[-π/2, π/2]', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4030, 'D', '(-∞, +∞)', 0, NULL);

-- 题目 4031: 复合函数 f(g(x)) 中，若 f(u) = u², g(x) = sin x，则 f(g(x)) = ?
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4031, 'A', 'sin² x', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4031, 'B', 'sin x²', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4031, 'C', '(sin x)²', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4031, 'D', 'x² sin x', 0, NULL);

-- 题目 4032: 函数 y = |x| 在 x = 0 处？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4032, 'A', '连续但不可导', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4032, 'B', '可导', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4032, 'C', '不连续', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4032, 'D', '既不连续也不可导', 0, NULL);

-- 题目 4033: 下列函数中，是有界函数的是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4033, 'A', 'f(x) = x²', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4033, 'B', 'f(x) = sin x', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4033, 'C', 'f(x) = e^x', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4033, 'D', 'f(x) = ln x', 0, NULL);

-- 题目 4034: 函数 f(x) = 1/x 的间断点是？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4034, 'A', 'x = 0', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4034, 'B', 'x = 1', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4034, 'C', 'x = -1', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4034, 'D', '无间断点', 0, NULL);

-- 题目 4035: 初等函数在其定义域内？
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4035, 'A', '一定连续', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4035, 'B', '不一定连续', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4035, 'C', '一定可导', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4035, 'D', '一定有界', 0, NULL);

-- 题目 4036-4040: 多选题选项
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4036, 'A', '奇偶性', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4036, 'B', '周期性', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4036, 'C', '单调性', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4036, 'D', '有界性', 0, NULL);

INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4037, 'A', '幂函数', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4037, 'B', '指数函数', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4037, 'C', '对数函数', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4037, 'D', '三角函数', 0, NULL);

INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4038, 'A', '定义域关于原点对称', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4038, 'B', 'f(-x) = -f(x)', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4038, 'C', '图像关于原点对称', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4038, 'D', 'f(0) = 0', 0, NULL);

INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4039, 'A', '反函数存在', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4039, 'B', '函数单调', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4039, 'C', '函数连续', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4039, 'D', '定义域与值域互换', 0, NULL);

INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4040, 'A', '有界性', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4040, 'B', '最值定理', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4040, 'C', '介值定理', 0, NULL);
INSERT INTO `question_option` (question_id, option_label, option_text, is_deleted, delete_time) VALUES (4040, 'D', '零点定理', 0, NULL);

-- 题目 4041-4045: 判断题（无需选项）

-- 题目 4046-4050: 简答题（无需选项）

-- =====================================================
-- 插入完成
-- =====================================================

