-- 知识图谱测试数据
-- 用于测试知识点抽取和可视化功能

-- 1. 插入测试课程（如果不存在）
INSERT INTO course (id, title, description, status, create_time) 
VALUES (33, '高等数学', '高等数学基础课程', 'published', NOW())
ON DUPLICATE KEY UPDATE title = '高等数学';

-- 2. 插入测试章节（如果不存在）
INSERT INTO chapter (id, course_id, title, description, order_num, create_time)
VALUES (1, 33, '第1章 极限', '极限的概念与计算', 1, NOW())
ON DUPLICATE KEY UPDATE title = '第1章 极限';

-- 3. 插入测试题目（包含丰富的知识点）

-- 题目1：洛必塔法则
INSERT INTO question (course_id, chapter_id, title, explanation, options, difficulty, create_time)
VALUES (
    33, 1,
    '求极限 lim(x→0) (sin x - x) / x³',
    '本题考查洛必塔法则的应用。由于分子分母在 x→0 时都趋于 0，属于 0/0 型未定式，可以使用洛必塔法则。
    连续求导三次：
    第一次：lim(x→0) (cos x - 1) / (3x²)
    第二次：lim(x→0) (-sin x) / (6x)
    第三次：lim(x→0) (-cos x) / 6 = -1/6
    因此原极限为 -1/6。
    本题涉及的知识点：洛必塔法则、三角函数求导、极限的计算。',
    'A. -1/6|B. 1/6|C. 0|D. 不存在',
    'medium',
    NOW()
);

-- 题目2：等价无穷小替换
INSERT INTO question (course_id, chapter_id, title, explanation, options, difficulty, create_time)
VALUES (
    33, 1,
    '求极限 lim(x→0) (1 - cos x) / x²',
    '本题可以使用等价无穷小替换。当 x→0 时，1 - cos x ~ x²/2，因此：
    lim(x→0) (1 - cos x) / x² = lim(x→0) (x²/2) / x² = 1/2
    也可以使用洛必塔法则求解。
    涉及知识点：等价无穷小替换、三角函数的等价无穷小、极限计算。',
    'A. 1/2|B. 1|C. 0|D. 2',
    'easy',
    NOW()
);

-- 题目3：泰勒展开
INSERT INTO question (course_id, chapter_id, title, explanation, options, difficulty, create_time)
VALUES (
    33, 1,
    '求极限 lim(x→0) (e^x - 1 - x - x²/2) / x³',
    '本题使用泰勒展开求解。e^x 在 x=0 处的泰勒展开为：
    e^x = 1 + x + x²/2 + x³/6 + o(x³)
    因此：
    e^x - 1 - x - x²/2 = x³/6 + o(x³)
    原极限 = lim(x→0) (x³/6 + o(x³)) / x³ = 1/6
    涉及知识点：泰勒展开、麦克劳林级数、高阶无穷小。',
    'A. 1/6|B. 1/3|C. 1/2|D. 1',
    'hard',
    NOW()
);

-- 题目4：夹逼定理
INSERT INTO question (course_id, chapter_id, title, explanation, options, difficulty, create_time)
VALUES (
    33, 1,
    '求极限 lim(n→∞) (1/n² + 2/n² + ... + n/n²)',
    '本题使用夹逼定理。原式可以写为：
    S = (1 + 2 + ... + n) / n² = n(n+1)/(2n²) = (n² + n)/(2n²) = (1 + 1/n)/2
    当 n→∞ 时，1/n → 0，因此极限为 1/2。
    也可以用定积分定义求解：lim(n→∞) Σ(k/n²) = ∫₀¹ x dx = 1/2
    涉及知识点：夹逼定理、数列求和、定积分定义。',
    'A. 1/2|B. 1|C. 0|D. ∞',
    'medium',
    NOW()
);

-- 题目5：小角度近似
INSERT INTO question (course_id, chapter_id, title, explanation, options, difficulty, create_time)
VALUES (
    33, 1,
    '当 x 很小时，sin(3x) 约等于多少？',
    '本题考查小角度近似。当 x→0 时，sin x ≈ x（弧度制）。
    因此 sin(3x) ≈ 3x。
    这是等价无穷小的一个特例，在物理学和工程学中经常使用。
    涉及知识点：小角度近似、等价无穷小、三角函数性质。',
    'A. 3x|B. x|C. x/3|D. 9x',
    'easy',
    NOW()
);

-- 题目6：无穷小的比较
INSERT INTO question (course_id, chapter_id, title, explanation, options, difficulty, create_time)
VALUES (
    33, 1,
    '当 x→0 时，x² 和 sin x 哪个是高阶无穷小？',
    'x² 是 sin x 的高阶无穷小。因为：
    lim(x→0) x² / sin x = lim(x→0) x² / x = lim(x→0) x = 0
    这说明 x² 趋于 0 的速度比 sin x 更快。
    涉及知识点：无穷小的比较、高阶无穷小、等价无穷小。',
    'A. x²|B. sin x|C. 同阶|D. 无法比较',
    'medium',
    NOW()
);

-- 题目7：连续性与极限
INSERT INTO question (course_id, chapter_id, title, explanation, options, difficulty, create_time)
VALUES (
    33, 1,
    '函数 f(x) = (x² - 1)/(x - 1) 在 x=1 处是否连续？',
    '函数在 x=1 处无定义，因此不连续。但极限存在：
    lim(x→1) (x² - 1)/(x - 1) = lim(x→1) (x+1)(x-1)/(x-1) = lim(x→1) (x+1) = 2
    如果定义 f(1) = 2，则可以使函数在 x=1 处连续（可去间断点）。
    涉及知识点：函数的连续性、可去间断点、极限的计算。',
    'A. 连续|B. 不连续|C. 可去间断点|D. 跳跃间断点',
    'medium',
    NOW()
);

-- 题目8：中值定理
INSERT INTO question (course_id, chapter_id, title, explanation, options, difficulty, create_time)
VALUES (
    33, 1,
    '罗尔定理的三个条件是什么？',
    '罗尔定理的三个条件：
    1. 函数 f(x) 在闭区间 [a,b] 上连续
    2. 函数 f(x) 在开区间 (a,b) 内可导
    3. f(a) = f(b)
    结论：至少存在一点 ξ ∈ (a,b)，使得 f''(ξ) = 0
    罗尔定理是拉格朗日中值定理的特殊情况。
    涉及知识点：罗尔定理、中值定理、函数的连续性和可导性。',
    'A. 连续、可导、端点相等|B. 连续、可微、单调|C. 可导、可积、有界|D. 连续、有界、周期',
    'hard',
    NOW()
);

-- 4. 查看插入的数据
SELECT '=== 插入的课程 ===' AS info;
SELECT * FROM course WHERE id = 33;

SELECT '=== 插入的章节 ===' AS info;
SELECT * FROM chapter WHERE course_id = 33;

SELECT '=== 插入的题目 ===' AS info;
SELECT id, title, difficulty FROM question WHERE course_id = 33 AND chapter_id = 1;

-- 5. 使用说明
SELECT '
测试数据已插入完成！

下一步操作：
1. 启动后端服务
2. 调用 API 生成知识图谱：
   POST http://localhost:8080/system/graph/extract/chapter/33/1

3. 或在前端页面操作：
   - 进入"知识图谱管理"
   - 点击"知识图谱可视化"
   - 选择课程 ID: 33
   - 选择章节 ID: 1
   - 点击"生成知识图谱"
   - 等待 3-5 秒后点击"加载知识图谱"

预期生成的知识点：
- 洛必塔法则
- 等价无穷小
- 泰勒展开
- 夹逼定理
- 小角度近似
- 罗尔定理
- 连续性
- 可导性

预期生成的关系：
- 连续性 -> 可导性 (prerequisite)
- 等价无穷小 -> 洛必塔法则 (related_method)
- 泰勒展开 -> 等价无穷小 (uses)
' AS usage_guide;

