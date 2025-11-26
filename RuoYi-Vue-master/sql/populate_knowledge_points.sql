-- =====================================================
-- 根据 question 表完善 knowledge_point 表
-- =====================================================

-- 清空现有数据（如果有）
DELETE FROM knowledge_point WHERE is_deleted = 0;

-- 插入知识点数据
-- 根据 question 表中的 knowledge_point 字段和 course_id 分组统计

-- 课程1: 前端开发基础
INSERT INTO knowledge_point (course_id, title, description, level, creator_user_id, create_time, is_deleted) VALUES
(1, 'HTML基础', 'HTML基础知识，包括HTML文档结构、基本标签等', 'BASIC', 1, NOW(), 0),
(1, 'CSS基础', 'CSS基础知识，包括选择器、样式属性等', 'BASIC', 1, NOW(), 0),
(1, 'HTML标签', 'HTML常用标签的使用方法', 'BASIC', 1, NOW(), 0),
(1, 'JavaScript基础', 'JavaScript基础语法和概念', 'BASIC', 1, NOW(), 0),
(1, 'HTML5新特性', 'HTML5的新增特性和API', 'INTERMEDIATE', 1, NOW(), 0),
(1, 'CSS盒模型', 'CSS盒模型的概念和应用', 'INTERMEDIATE', 1, NOW(), 0),
(1, 'DOM操作', 'JavaScript操作DOM元素的方法', 'INTERMEDIATE', 1, NOW(), 0),
(1, 'CSS属性', 'CSS各种样式属性的使用', 'BASIC', 1, NOW(), 0),
(1, 'CSS选择器', 'CSS选择器的类型和使用方法', 'BASIC', 1, NOW(), 0),
(1, 'CSS布局', 'CSS布局技术，包括Flexbox、Grid等', 'INTERMEDIATE', 1, NOW(), 0),
(1, 'HTTP协议', 'HTTP协议基础知识', 'INTERMEDIATE', 1, NOW(), 0),
(1, 'HTML表格', 'HTML表格的创建和使用', 'BASIC', 1, NOW(), 0);

-- 课程2: JavaScript高级编程
INSERT INTO knowledge_point (course_id, title, description, level, creator_user_id, create_time, is_deleted) VALUES
(2, 'JavaScript闭包', 'JavaScript闭包的概念和应用场景', 'ADVANCED', 1, NOW(), 0),
(2, 'DOM事件', 'DOM事件处理机制和事件委托', 'INTERMEDIATE', 1, NOW(), 0),
(2, 'JavaScript原型', 'JavaScript原型链和继承机制', 'ADVANCED', 1, NOW(), 0),
(2, 'JavaScript数据类型', 'JavaScript的基本数据类型和引用类型', 'BASIC', 1, NOW(), 0),
(2, 'JavaScript数组', 'JavaScript数组的操作方法', 'INTERMEDIATE', 1, NOW(), 0),
(2, 'JavaScript基础', 'JavaScript基础语法和概念', 'BASIC', 1, NOW(), 0),
(2, 'JavaScript循环', 'JavaScript循环语句的使用', 'BASIC', 1, NOW(), 0),
(2, 'JavaScript变量', 'JavaScript变量声明和作用域', 'BASIC', 1, NOW(), 0);

-- 课程3: Vue.js框架开发
INSERT INTO knowledge_point (course_id, title, description, level, creator_user_id, create_time, is_deleted) VALUES
(3, 'Vue.js基础', 'Vue.js框架的基础概念和使用', 'BASIC', 1, NOW(), 0),
(3, 'Vue数据绑定', 'Vue的数据绑定机制和响应式原理', 'INTERMEDIATE', 1, NOW(), 0),
(3, 'Vue组件通信', 'Vue组件之间的通信方式', 'INTERMEDIATE', 1, NOW(), 0),
(3, 'Vue指令', 'Vue的内置指令和自定义指令', 'BASIC', 1, NOW(), 0),
(3, 'Vue生命周期', 'Vue组件的生命周期钩子函数', 'INTERMEDIATE', 1, NOW(), 0);

-- 课程4: React框架实战
INSERT INTO knowledge_point (course_id, title, description, level, creator_user_id, create_time, is_deleted) VALUES
(4, 'React Hooks', 'React Hooks的使用方法和最佳实践', 'INTERMEDIATE', 1, NOW(), 0);

-- 课程5: 前端工程化实践
INSERT INTO knowledge_point (course_id, title, description, level, creator_user_id, create_time, is_deleted) VALUES
(5, '前端工具链', '前端开发工具链的配置和使用', 'INTERMEDIATE', 1, NOW(), 0);

-- 课程6: Node.js后端开发
INSERT INTO knowledge_point (course_id, title, description, level, creator_user_id, create_time, is_deleted) VALUES
(6, '网络协议', '计算机网络协议基础知识', 'INTERMEDIATE', 1, NOW(), 0),
(6, 'API设计', 'RESTful API设计原则和最佳实践', 'INTERMEDIATE', 1, NOW(), 0),
(6, 'HTTP协议', 'HTTP协议的工作原理和特性', 'INTERMEDIATE', 1, NOW(), 0),
(6, 'HTTP状态码', 'HTTP状态码的含义和使用场景', 'BASIC', 1, NOW(), 0),
(6, 'RESTful API', 'RESTful API的设计规范', 'INTERMEDIATE', 1, NOW(), 0),
(6, '跨域问题', '浏览器跨域问题的原因和解决方案', 'INTERMEDIATE', 1, NOW(), 0),
(6, 'HTTP方法', 'HTTP请求方法的使用和区别', 'BASIC', 1, NOW(), 0);

-- 课程7: 移动端开发
INSERT INTO knowledge_point (course_id, title, description, level, creator_user_id, create_time, is_deleted) VALUES
(7, '响应式设计', '响应式网页设计的原理和实现', 'INTERMEDIATE', 1, NOW(), 0);

-- 课程8: 前端性能优化
INSERT INTO knowledge_point (course_id, title, description, level, creator_user_id, create_time, is_deleted) VALUES
(8, '性能优化', '前端性能优化的方法和技巧', 'ADVANCED', 1, NOW(), 0),
(8, '前端路由', '前端路由的实现原理', 'INTERMEDIATE', 1, NOW(), 0),
(8, '虚拟DOM', '虚拟DOM的概念和diff算法', 'ADVANCED', 1, NOW(), 0),
(8, '状态管理', '前端状态管理方案（Vuex、Redux等）', 'INTERMEDIATE', 1, NOW(), 0),
(8, '微前端', '微前端架构的设计和实现', 'ADVANCED', 1, NOW(), 0),
(8, '性能监控', '前端性能监控和分析工具', 'ADVANCED', 1, NOW(), 0);

-- 验证插入结果
SELECT '✅ 知识点数据插入完成' AS message;

-- 统计每个课程的知识点数量
SELECT 
    c.id AS course_id,
    c.title AS course_name,
    COUNT(kp.id) AS kp_count,
    GROUP_CONCAT(kp.title ORDER BY kp.id SEPARATOR ', ') AS knowledge_points
FROM course c
LEFT JOIN knowledge_point kp ON c.id = kp.course_id AND kp.is_deleted = 0
WHERE c.is_deleted = 0
GROUP BY c.id
ORDER BY c.id;

-- 验证知识点与题目的对应关系
SELECT 
    '知识点覆盖情况' AS check_type,
    COUNT(DISTINCT q.knowledge_point) AS question_kp_count,
    COUNT(DISTINCT kp.title) AS kp_table_count
FROM question q
LEFT JOIN knowledge_point kp ON q.knowledge_point = kp.title AND q.course_id = kp.course_id
WHERE q.is_deleted = 0;

-- 显示所有知识点及其对应的题目数量
SELECT 
    kp.id,
    kp.course_id,
    c.title AS course_name,
    kp.title AS kp_title,
    kp.level,
    COUNT(q.id) AS question_count
FROM knowledge_point kp
LEFT JOIN course c ON kp.course_id = c.id
LEFT JOIN question q ON kp.title = q.knowledge_point AND kp.course_id = q.course_id AND q.is_deleted = 0
WHERE kp.is_deleted = 0
GROUP BY kp.id
ORDER BY kp.course_id, question_count DESC;

