-- =============================================
-- 完善题目相关表数据
-- =============================================
-- 作者：AI Assistant
-- 日期：2025-11-20
-- 说明：为 question_stats、question_option、question_image 表补充数据
-- =============================================

USE smartclassv2;

-- =============================================
-- 1. 完善 question_stats 表（题目统计数据）
-- =============================================
-- 为所有现有题目添加统计数据（模拟真实的答题统计）

-- 简答题统计（ID: 1001-1020）
INSERT INTO question_stats (question_id, answer_count, correct_count, accuracy) VALUES
(1001, 150, 135, 90.00),
(1002, 145, 120, 82.76),
(1003, 160, 152, 95.00),
(1004, 155, 140, 90.32),
(1005, 142, 115, 80.99),
(1006, 138, 110, 79.71),
(1007, 125, 95, 76.00),
(1008, 118, 85, 72.03),
(1009, 130, 98, 75.38),
(1010, 122, 88, 72.13),
(1011, 95, 65, 68.42),
(1012, 88, 60, 68.18),
(1013, 82, 55, 67.07),
(1014, 78, 50, 64.10),
(1015, 92, 68, 73.91),
(1016, 65, 40, 61.54),
(1017, 58, 35, 60.34),
(1018, 70, 45, 64.29),
(1019, 52, 30, 57.69),
(1020, 48, 25, 52.08);

-- 单选题统计（ID: 3001-3020）
INSERT INTO question_stats (question_id, answer_count, correct_count, accuracy) VALUES
(3001, 200, 185, 92.50),
(3002, 198, 175, 88.38),
(3003, 195, 165, 84.62),
(3004, 192, 180, 93.75),
(3005, 205, 195, 95.12),
(3006, 210, 189, 90.00),
(3007, 188, 150, 79.79),
(3008, 185, 140, 75.68),
(3009, 195, 175, 89.74),
(3010, 200, 185, 92.50),
(3011, 178, 145, 81.46),
(3012, 190, 170, 89.47),
(3013, 165, 140, 84.85),
(3014, 172, 155, 90.12),
(3015, 180, 165, 91.67),
(3016, 158, 125, 79.11),
(3017, 195, 180, 92.31),
(3018, 200, 190, 95.00),
(3019, 185, 165, 89.19),
(3020, 175, 140, 80.00);

-- 多选题统计（ID: 3021-3025）
INSERT INTO question_stats (question_id, answer_count, correct_count, accuracy) VALUES
(3021, 150, 105, 70.00),
(3022, 145, 95, 65.52),
(3023, 155, 120, 77.42),
(3024, 148, 110, 74.32),
(3025, 142, 100, 70.42);

-- 判断题统计（ID: 3026-3030）
INSERT INTO question_stats (question_id, answer_count, correct_count, accuracy) VALUES
(3026, 220, 198, 90.00),
(3027, 215, 205, 95.35),
(3028, 210, 189, 90.00),
(3029, 205, 185, 90.24),
(3030, 218, 200, 91.74);

-- =============================================
-- 2. 完善 question_image 表（题目配图）
-- =============================================
-- 为需要图示的题目添加示例图片URL
-- 注意：这里使用占位符URL，实际使用时需要替换为真实的图片URL

-- HTML相关题目配图
INSERT INTO question_image (question_id, image_url, description, sequence) VALUES
(3003, '/upload/questions/html5-semantic-tags.png', 'HTML5语义化标签示意图', 1),
(3004, '/upload/questions/html-table-structure.png', 'HTML表格结构示例', 1);

-- CSS相关题目配图
INSERT INTO question_image (question_id, image_url, description, sequence) VALUES
(3007, '/upload/questions/css-box-model.png', 'CSS盒模型示意图', 1),
(3022, '/upload/questions/css-centering-methods.png', 'CSS居中方法示例', 1),
(1006, '/upload/questions/css-box-model-detail.png', 'CSS盒模型详细说明', 1);

-- JavaScript相关题目配图
INSERT INTO question_image (question_id, image_url, description, sequence) VALUES
(1008, '/upload/questions/js-closure-example.png', 'JavaScript闭包示例代码', 1),
(1009, '/upload/questions/js-event-bubbling.png', '事件冒泡和捕获流程图', 1),
(1011, '/upload/questions/js-prototype-chain.png', 'JavaScript原型链示意图', 1);

-- Vue相关题目配图
INSERT INTO question_image (question_id, image_url, description, sequence) VALUES
(1010, '/upload/questions/vue-data-binding.png', 'Vue数据双向绑定原理图', 1),
(1015, '/upload/questions/vue-component-communication.png', 'Vue组件通信方式', 1),
(3024, '/upload/questions/vue-lifecycle.png', 'Vue生命周期钩子图', 1);

-- 前端架构相关题目配图
INSERT INTO question_image (question_id, image_url, description, sequence) VALUES
(1016, '/upload/questions/router-hash-history.png', '前端路由模式对比', 1),
(1017, '/upload/questions/virtual-dom-diff.png', '虚拟DOM Diff算法流程', 1),
(1018, '/upload/questions/vuex-flow.png', 'Vuex状态管理流程图', 1),
(1019, '/upload/questions/micro-frontend-architecture.png', '微前端架构示意图', 1),
(1020, '/upload/questions/performance-monitoring.png', '前端性能监控指标', 1);

-- HTTP相关题目配图
INSERT INTO question_image (question_id, image_url, description, sequence) VALUES
(1012, '/upload/questions/https-workflow.png', 'HTTPS工作原理示意图', 1),
(1013, '/upload/questions/restful-api-design.png', 'RESTful API设计规范', 1);

-- 浏览器渲染相关题目配图
INSERT INTO question_image (question_id, image_url, description, sequence) VALUES
(1014, '/upload/questions/browser-rendering-process.png', '浏览器渲染流程图', 1);

-- =============================================
-- 数据验证查询
-- =============================================
-- 取消注释以下语句来验证数据是否正确插入

-- SELECT '=== question_stats 统计 ===' AS info;
-- SELECT COUNT(*) AS total_stats, 
--        SUM(answer_count) AS total_answers,
--        AVG(accuracy) AS avg_accuracy
-- FROM question_stats;

-- SELECT '=== question_image 统计 ===' AS info;
-- SELECT COUNT(*) AS total_images FROM question_image;

-- SELECT '=== 按题型统计答题数据 ===' AS info;
-- SELECT q.question_type, 
--        COUNT(*) AS question_count,
--        AVG(qs.accuracy) AS avg_accuracy,
--        SUM(qs.answer_count) AS total_answers
-- FROM question q
-- LEFT JOIN question_stats qs ON q.id = qs.question_id
-- GROUP BY q.question_type;

