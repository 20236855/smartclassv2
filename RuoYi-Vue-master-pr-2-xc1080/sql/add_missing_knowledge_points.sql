-- 为高等数学和计算机组成原理课程添加知识点数据
-- 解决题库标签页知识点下拉框无法正常显示的问题

USE education_platform_v1;

-- ============================================
-- 40004: 高等数学课程知识点
-- ============================================
INSERT INTO `knowledge_point` (`id`, `course_id`, `title`, `description`, `level`, `creator_user_id`, `create_time`, `update_time`, `is_deleted`, `delete_time`) VALUES
(60025, 40004, '函数与极限', '理解函数的概念、性质及极限的定义与运算法则，掌握极限存在准则和两个重要极限', 'BASIC', 37, NOW(), NOW(), 0, NULL),
(60026, 40004, '导数与微分', '掌握导数的定义、几何意义及求导法则，理解微分的概念及其在近似计算中的应用', 'BASIC', 37, NOW(), NOW(), 0, NULL),
(60027, 40004, '中值定理及导数应用', '掌握罗尔定理、拉格朗日中值定理、柯西中值定理，学会用导数判断函数单调性、极值及凹凸性', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL),
(60028, 40004, '不定积分', '理解原函数与不定积分的概念，掌握换元积分法和分部积分法，熟练计算基本积分', 'BASIC', 37, NOW(), NOW(), 0, NULL),
(60029, 40004, '定积分及其应用', '理解定积分的概念与性质，掌握牛顿-莱布尼茨公式，学会用定积分计算面积、体积、弧长等', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL),
(60030, 40004, '多元函数微分学', '理解二元函数极限、连续性，掌握偏导数、全微分的概念及计算方法，学会求多元函数极值', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL),
(60031, 40004, '重积分', '掌握二重积分的概念、性质及计算方法（直角坐标、极坐标），了解三重积分的基本计算', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL),
(60032, 40004, '曲线积分与曲面积分', '理解第一类、第二类曲线积分和曲面积分的概念，掌握格林公式、高斯公式和斯托克斯公式', 'ADVANCED', 37, NOW(), NOW(), 0, NULL),
(60033, 40004, '无穷级数', '掌握常数项级数的收敛性判别法，理解幂级数的收敛域及和函数，学会函数展开成幂级数', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL),
(60034, 40004, '常微分方程', '掌握一阶微分方程（可分离变量、齐次、一阶线性）的解法，理解高阶线性微分方程的通解结构', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL);

-- ============================================
-- 40005: 计算机组成原理课程知识点
-- ============================================
INSERT INTO `knowledge_point` (`id`, `course_id`, `title`, `description`, `level`, `creator_user_id`, `create_time`, `update_time`, `is_deleted`, `delete_time`) VALUES
(60035, 40005, '计算机系统概述', '理解计算机系统的层次结构，掌握冯·诺依曼体系结构的基本思想及计算机的基本组成', 'BASIC', 37, NOW(), NOW(), 0, NULL),
(60036, 40005, '数据的表示与运算', '掌握数值数据（定点数、浮点数）和非数值数据（字符、汉字）的编码表示，理解补码加减运算和浮点数运算方法', 'BASIC', 37, NOW(), NOW(), 0, NULL),
(60037, 40005, '存储器层次结构', '理解存储系统的层次结构（Cache-主存-辅存），掌握主存的组织方式及存储器的扩展技术', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL),
(60038, 40005, 'Cache 工作原理', '掌握Cache的基本原理、地址映射方式（直接映射、全相联映射、组相联映射）及替换算法', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL),
(60039, 40005, '指令系统', '理解指令格式、寻址方式的概念，掌握CISC和RISC指令系统的特点及区别', 'BASIC', 37, NOW(), NOW(), 0, NULL),
(60040, 40005, '中央处理器（CPU）', '理解CPU的基本功能和组成，掌握指令周期、机器周期、时钟周期的概念及指令执行过程', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL),
(60041, 40005, '数据通路与控制器', '掌握单总线数据通路的组织方式，理解硬布线控制器和微程序控制器的工作原理及特点', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL),
(60042, 40005, '流水线技术', '理解流水线的基本概念、分类及性能指标，掌握流水线冒险（数据冒险、控制冒险、结构冒险）的解决方法', 'ADVANCED', 37, NOW(), NOW(), 0, NULL),
(60043, 40005, '总线系统', '理解总线的概念、分类及结构，掌握总线仲裁方法、总线定时（同步、异步）及总线标准', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL),
(60044, 40005, '输入输出系统', '掌握I/O接口的功能和结构，理解程序查询、中断、DMA三种I/O方式的工作原理及特点', 'INTERMEDIATE', 37, NOW(), NOW(), 0, NULL),
(60045, 40005, '中断系统', '深入理解中断的概念、分类及中断处理过程，掌握中断优先级、中断屏蔽及多重中断的处理机制', 'ADVANCED', 37, NOW(), NOW(), 0, NULL);

-- 验证插入结果
SELECT '高等数学课程知识点:' AS '提示';
SELECT id, course_id, title, level FROM knowledge_point WHERE course_id = 40004;

SELECT '计算机组成原理课程知识点:' AS '提示';
SELECT id, course_id, title, level FROM knowledge_point WHERE course_id = 40005;

-- 统计各课程知识点数量
SELECT 
    c.id AS course_id,
    c.title AS course_title,
    COUNT(kp.id) AS knowledge_point_count
FROM course c
LEFT JOIN knowledge_point kp ON c.id = kp.course_id AND kp.is_deleted = 0
WHERE c.teacher_user_id = 37
GROUP BY c.id, c.title
ORDER BY c.id;
