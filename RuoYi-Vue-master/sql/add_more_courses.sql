-- =============================================
-- 添加更多课程数据
-- =============================================
USE smartclassv2;

-- 添加更多课程
INSERT INTO course (id, title, description, cover_image, credit, course_type, start_time, end_time, teacher_user_id, status, term, student_count, average_score, is_deleted) VALUES
(2, 'JavaScript高级编程', 'JavaScript深入学习，包括ES6+新特性、异步编程、设计模式等高级主题', '/upload/courses/javascript-advanced.jpg', 4.0, '必修课', '2025-09-01', '2026-01-15', 29, '进行中', '2025-2026学年第一学期', 85, 82.50, 0),
(3, 'Vue.js框架开发', '学习Vue.js框架的核心概念、组件开发、状态管理和路由系统', '/upload/courses/vue-framework.jpg', 3.5, '必修课', '2025-09-01', '2026-01-15', 29, '进行中', '2025-2026学年第一学期', 78, 85.30, 0),
(4, 'React框架实战', 'React框架从入门到精通，包括Hooks、Redux、React Router等', '/upload/courses/react-framework.jpg', 3.5, '选修课', '2025-09-01', '2026-01-15', 29, '进行中', '2025-2026学年第一学期', 62, 80.20, 0),
(5, '前端工程化实践', '学习Webpack、Vite等构建工具，掌握前端工程化开发流程', '/upload/courses/frontend-engineering.jpg', 3.0, '选修课', '2025-09-01', '2026-01-15', 29, '进行中', '2025-2026学年第一学期', 55, 78.90, 0),
(6, 'Node.js后端开发', '使用Node.js进行后端开发，学习Express、Koa等框架', '/upload/courses/nodejs-backend.jpg', 4.0, '选修课', '2025-09-15', '2026-01-30', 29, '进行中', '2025-2026学年第一学期', 48, 76.50, 0),
(7, '移动端开发', '学习响应式设计、移动端适配、微信小程序开发等', '/upload/courses/mobile-development.jpg', 3.0, '选修课', '2025-10-01', '2026-01-30', 29, '进行中', '2025-2026学年第一学期', 42, 81.20, 0),
(8, '前端性能优化', '深入学习前端性能优化技术，包括加载优化、渲染优化、网络优化等', '/upload/courses/performance-optimization.jpg', 2.5, '选修课', '2025-11-01', '2026-01-30', 29, '进行中', '2025-2026学年第一学期', 35, 74.80, 0);

-- 为新课程分配一些题目（将部分题目关联到不同课程）
-- JavaScript高级编程课程（课程ID: 2）
UPDATE question SET course_id = 2 WHERE id IN (1008, 1009, 1011, 3009, 3010, 3011, 3012, 3023);

-- Vue.js框架开发课程（课程ID: 3）
UPDATE question SET course_id = 3 WHERE id IN (1010, 1015, 3013, 3015, 3024, 3029);

-- React框架实战课程（课程ID: 4）
UPDATE question SET course_id = 4 WHERE id IN (3014);

-- 前端工程化实践课程（课程ID: 5）
UPDATE question SET course_id = 5 WHERE id IN (3016);

-- Node.js后端开发课程（课程ID: 6）
UPDATE question SET course_id = 6 WHERE id IN (1012, 1013, 3017, 3018, 3019, 3020, 3025);

-- 移动端开发课程（课程ID: 7）
UPDATE question SET course_id = 7 WHERE id IN (1007);

-- 前端性能优化课程（课程ID: 8）
UPDATE question SET course_id = 8 WHERE id IN (1014, 1016, 1017, 1018, 1019, 1020);

-- 验证数据
SELECT '=== 课程列表 ===' AS info;
SELECT id, title, course_type, status, student_count FROM course WHERE is_deleted = 0;

SELECT '=== 各课程题目数量 ===' AS info;
SELECT 
    c.id AS course_id,
    c.title AS course_title,
    COUNT(q.id) AS question_count
FROM course c
LEFT JOIN question q ON c.id = q.course_id AND q.is_deleted = 0
WHERE c.is_deleted = 0
GROUP BY c.id, c.title
ORDER BY c.id;

