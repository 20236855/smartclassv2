-- =============================================
-- 选择题题库和演示作业
-- 数据库：smartclassv2
-- =============================================

-- 设置字符集
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 使用数据库
USE smartclassv2;

-- =============================================
-- 第一部分：创建选择题题库（单选题）
-- =============================================

-- 清空可能存在的旧数据（可选）
-- DELETE FROM question_option WHERE question_id >= 3001 AND question_id <= 3020;
-- DELETE FROM question WHERE id >= 3001 AND id <= 3020;

-- 插入20道单选题（ID: 3001-3020）
INSERT INTO question (id, title, question_type, difficulty, correct_answer, explanation, knowledge_point, course_id, chapter_id, created_by, create_time, update_time, is_deleted) VALUES
-- HTML基础单选题（难度1-2）
(3001, 'HTML的全称是什么？', 'single', 1, 'A', 'HTML是HyperText Markup Language的缩写，是网页开发的基础标记语言。', 'HTML基础', 1, 1, 29, NOW(), NOW(), 0),
(3002, '以下哪个标签用于创建超链接？', 'single', 1, 'B', '<a>标签用于创建超链接，href属性指定链接地址。', 'HTML标签', 1, 1, 29, NOW(), NOW(), 0),
(3003, 'HTML5中新增的语义化标签是？', 'single', 2, 'C', '<header>、<footer>、<nav>、<article>等都是HTML5新增的语义化标签。', 'HTML5新特性', 1, 1, 29, NOW(), NOW(), 0),
(3004, '以下哪个标签用于定义表格？', 'single', 1, 'D', '<table>标签用于定义HTML表格。', 'HTML表格', 1, 1, 29, NOW(), NOW(), 0),

-- CSS基础单选题（难度2-3）
(3005, 'CSS的全称是什么？', 'single', 1, 'A', 'CSS是Cascading Style Sheets的缩写，用于控制网页样式。', 'CSS基础', 1, 2, 29, NOW(), NOW(), 0),
(3006, '以下哪个CSS属性用于设置文字颜色？', 'single', 2, 'B', 'color属性用于设置文字颜色。', 'CSS属性', 1, 2, 29, NOW(), NOW(), 0),
(3007, 'CSS中的盒模型包括哪些部分？', 'single', 3, 'C', 'CSS盒模型包括内容(content)、内边距(padding)、边框(border)和外边距(margin)。', 'CSS盒模型', 1, 2, 29, NOW(), NOW(), 0),
(3008, '以下哪个选择器的优先级最高？', 'single', 3, 'D', 'ID选择器的优先级高于类选择器和标签选择器。', 'CSS选择器', 1, 2, 29, NOW(), NOW(), 0),

-- JavaScript基础单选题（难度2-4）
(3009, 'JavaScript是一种什么类型的语言？', 'single', 2, 'A', 'JavaScript是一种解释型、动态类型的脚本语言。', 'JavaScript基础', 1, 3, 29, NOW(), NOW(), 0),
(3010, '以下哪个关键字用于声明变量？', 'single', 2, 'B', 'var、let、const都可以用于声明变量，其中let和const是ES6新增的。', 'JavaScript变量', 1, 3, 29, NOW(), NOW(), 0),
(3011, 'JavaScript中的数据类型不包括？', 'single', 3, 'C', 'JavaScript的基本数据类型包括：Number、String、Boolean、Undefined、Null、Symbol、BigInt。', 'JavaScript数据类型', 1, 3, 29, NOW(), NOW(), 0),
(3012, '以下哪个方法用于向数组末尾添加元素？', 'single', 2, 'D', 'push()方法用于向数组末尾添加一个或多个元素。', 'JavaScript数组', 1, 3, 29, NOW(), NOW(), 0),

-- 前端框架单选题（难度3-4）
(3013, 'Vue.js是由谁创建的？', 'single', 2, 'A', 'Vue.js是由尤雨溪（Evan You）创建的渐进式JavaScript框架。', 'Vue.js基础', 1, 4, 29, NOW(), NOW(), 0),
(3014, 'React中用于管理组件状态的Hook是？', 'single', 3, 'B', 'useState是React中用于在函数组件中添加状态的Hook。', 'React Hooks', 1, 4, 29, NOW(), NOW(), 0),
(3015, 'Vue中用于双向数据绑定的指令是？', 'single', 3, 'C', 'v-model指令用于在表单元素上创建双向数据绑定。', 'Vue指令', 1, 4, 29, NOW(), NOW(), 0),
(3016, '以下哪个不是前端构建工具？', 'single', 3, 'D', 'MySQL是数据库管理系统，不是前端构建工具。Webpack、Vite、Rollup都是前端构建工具。', '前端工具链', 1, 4, 29, NOW(), NOW(), 0),

-- HTTP和网络单选题（难度3-5）
(3017, 'HTTP协议默认使用的端口号是？', 'single', 2, 'A', 'HTTP协议默认使用80端口，HTTPS使用443端口。', 'HTTP协议', 1, 5, 29, NOW(), NOW(), 0),
(3018, '以下哪个HTTP状态码表示"未找到"？', 'single', 2, 'B', '404状态码表示请求的资源未找到。', 'HTTP状态码', 1, 5, 29, NOW(), NOW(), 0),
(3019, 'RESTful API中，用于更新资源的HTTP方法是？', 'single', 3, 'C', 'PUT方法用于更新资源，POST用于创建，GET用于获取，DELETE用于删除。', 'RESTful API', 1, 5, 29, NOW(), NOW(), 0),
(3020, '以下哪个不是跨域解决方案？', 'single', 4, 'D', 'localStorage是浏览器本地存储，不是跨域解决方案。CORS、JSONP、代理服务器都可以解决跨域问题。', '跨域问题', 1, 5, 29, NOW(), NOW(), 0);

-- =============================================
-- 第二部分：为每道单选题添加选项
-- =============================================

-- 题目3001的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3001, 'A', 'HyperText Markup Language'),
(3001, 'B', 'High Tech Modern Language'),
(3001, 'C', 'Home Tool Markup Language'),
(3001, 'D', 'Hyperlinks and Text Markup Language');

-- 题目3002的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3002, 'A', '<link>'),
(3002, 'B', '<a>'),
(3002, 'C', '<href>'),
(3002, 'D', '<url>');

-- 题目3003的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3003, 'A', '<div>'),
(3003, 'B', '<span>'),
(3003, 'C', '<header>'),
(3003, 'D', '<section>');

-- 题目3004的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3004, 'A', '<tr>'),
(3004, 'B', '<td>'),
(3004, 'C', '<th>'),
(3004, 'D', '<table>');

-- 题目3005的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3005, 'A', 'Cascading Style Sheets'),
(3005, 'B', 'Computer Style Sheets'),
(3005, 'C', 'Creative Style Sheets'),
(3005, 'D', 'Colorful Style Sheets');

-- 题目3006的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3006, 'A', 'text-color'),
(3006, 'B', 'color'),
(3006, 'C', 'font-color'),
(3006, 'D', 'text-style');

-- 题目3007的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3007, 'A', '内容、边框'),
(3007, 'B', '内容、内边距、边框'),
(3007, 'C', '内容、内边距、边框、外边距'),
(3007, 'D', '内容、外边距');

-- 题目3008的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3008, 'A', '标签选择器'),
(3008, 'B', '类选择器'),
(3008, 'C', '伪类选择器'),
(3008, 'D', 'ID选择器');

-- 题目3009的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3009, 'A', '解释型语言'),
(3009, 'B', '编译型语言'),
(3009, 'C', '汇编语言'),
(3009, 'D', '机器语言');

-- 题目3010的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3010, 'A', 'var'),
(3010, 'B', 'let'),
(3010, 'C', 'const'),
(3010, 'D', '以上都可以');

-- 题目3011的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3011, 'A', 'Number'),
(3011, 'B', 'String'),
(3011, 'C', 'Float'),
(3011, 'D', 'Boolean');

-- 题目3012的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3012, 'A', 'pop()'),
(3012, 'B', 'shift()'),
(3012, 'C', 'unshift()'),
(3012, 'D', 'push()');

-- 题目3013的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3013, 'A', '尤雨溪（Evan You）'),
(3013, 'B', 'Jordan Walke'),
(3013, 'C', 'Ryan Dahl'),
(3013, 'D', 'Brendan Eich');

-- 题目3014的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3014, 'A', 'useEffect'),
(3014, 'B', 'useState'),
(3014, 'C', 'useContext'),
(3014, 'D', 'useReducer');

-- 题目3015的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3015, 'A', 'v-bind'),
(3015, 'B', 'v-on'),
(3015, 'C', 'v-model'),
(3015, 'D', 'v-if');

-- 题目3016的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3016, 'A', 'Webpack'),
(3016, 'B', 'Vite'),
(3016, 'C', 'Rollup'),
(3016, 'D', 'MySQL');

-- 题目3017的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3017, 'A', '80'),
(3017, 'B', '443'),
(3017, 'C', '8080'),
(3017, 'D', '3306');

-- 题目3018的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3018, 'A', '200'),
(3018, 'B', '404'),
(3018, 'C', '500'),
(3018, 'D', '403');

-- 题目3019的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3019, 'A', 'GET'),
(3019, 'B', 'POST'),
(3019, 'C', 'PUT'),
(3019, 'D', 'DELETE');

-- 题目3020的选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3020, 'A', 'CORS'),
(3020, 'B', 'JSONP'),
(3020, 'C', '代理服务器'),
(3020, 'D', 'localStorage');

-- =============================================
-- 第三部分：创建多选题（ID: 3021-3025）
-- =============================================

INSERT INTO question (id, title, question_type, difficulty, correct_answer, explanation, knowledge_point, course_id, chapter_id, created_by, create_time, update_time, is_deleted) VALUES
(3021, '以下哪些是HTML5新增的语义化标签？（多选）', 'multiple', 2, 'A,B,C', 'HTML5新增了多个语义化标签，包括<header>、<footer>、<nav>、<article>、<section>等。', 'HTML5新特性', 1, 1, 29, NOW(), NOW(), 0),
(3022, 'CSS中可以用来实现居中的方法有哪些？（多选）', 'multiple', 3, 'A,B,C,D', 'CSS实现居中的方法很多，包括flex布局、grid布局、margin: auto、绝对定位+transform等。', 'CSS布局', 1, 2, 29, NOW(), NOW(), 0),
(3023, 'JavaScript中的循环语句包括哪些？（多选）', 'multiple', 2, 'A,B,C', 'JavaScript的循环语句包括for、while、do-while、for...in、for...of等。', 'JavaScript循环', 1, 3, 29, NOW(), NOW(), 0),
(3024, '以下哪些是Vue的生命周期钩子？（多选）', 'multiple', 3, 'A,B,D', 'Vue的生命周期钩子包括created、mounted、updated、destroyed等。render不是生命周期钩子。', 'Vue生命周期', 1, 4, 29, NOW(), NOW(), 0),
(3025, 'HTTP请求方法中，哪些是幂等的？（多选）', 'multiple', 4, 'A,C,D', 'GET、PUT、DELETE是幂等的，POST不是幂等的。幂等是指多次执行相同操作，结果相同。', 'HTTP方法', 1, 5, 29, NOW(), NOW(), 0);

-- 多选题选项
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3021, 'A', '<header>'),
(3021, 'B', '<footer>'),
(3021, 'C', '<nav>'),
(3021, 'D', '<div>');

INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3022, 'A', 'display: flex; justify-content: center;'),
(3022, 'B', 'display: grid; place-items: center;'),
(3022, 'C', 'margin: 0 auto;'),
(3022, 'D', 'position: absolute; left: 50%; transform: translateX(-50%);');

INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3023, 'A', 'for'),
(3023, 'B', 'while'),
(3023, 'C', 'do-while'),
(3023, 'D', 'switch');

INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3024, 'A', 'created'),
(3024, 'B', 'mounted'),
(3024, 'C', 'render'),
(3024, 'D', 'destroyed');

INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3025, 'A', 'GET'),
(3025, 'B', 'POST'),
(3025, 'C', 'PUT'),
(3025, 'D', 'DELETE');

-- =============================================
-- 第四部分：创建判断题（ID: 3026-3030）
-- =============================================

INSERT INTO question (id, title, question_type, difficulty, correct_answer, explanation, knowledge_point, course_id, chapter_id, created_by, create_time, update_time, is_deleted) VALUES
(3026, 'HTML是一种编程语言。', 'true_false', 1, 'B', 'HTML是标记语言，不是编程语言。编程语言具有逻辑控制、变量等特性。', 'HTML基础', 1, 1, 29, NOW(), NOW(), 0),
(3027, 'CSS可以用来控制网页的布局和样式。', 'true_false', 1, 'A', 'CSS（层叠样式表）的主要作用就是控制网页的布局和样式。', 'CSS基础', 1, 2, 29, NOW(), NOW(), 0),
(3028, 'JavaScript是一种静态类型语言。', 'true_false', 2, 'B', 'JavaScript是动态类型语言，变量的类型可以在运行时改变。', 'JavaScript基础', 1, 3, 29, NOW(), NOW(), 0),
(3029, 'Vue.js是由Facebook开发的前端框架。', 'true_false', 2, 'B', 'Vue.js是由尤雨溪开发的，React才是Facebook开发的。', 'Vue.js基础', 1, 4, 29, NOW(), NOW(), 0),
(3030, 'HTTPS使用443端口作为默认端口。', 'true_false', 2, 'A', 'HTTPS协议默认使用443端口，HTTP使用80端口。', 'HTTP协议', 1, 5, 29, NOW(), NOW(), 0);

-- 判断题选项（A=正确，B=错误）
INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3026, 'A', '正确'),
(3026, 'B', '错误');

INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3027, 'A', '正确'),
(3027, 'B', '错误');

INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3028, 'A', '正确'),
(3028, 'B', '错误');

INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3029, 'A', '正确'),
(3029, 'B', '错误');

INSERT INTO question_option (question_id, option_label, option_text) VALUES
(3030, 'A', '正确'),
(3030, 'B', '错误');

-- =============================================
-- 第五部分：创建演示作业（答题型）
-- =============================================

-- 清空可能存在的旧数据（可选）
-- DELETE FROM assignment_question WHERE assignment_id >= 3001 AND assignment_id <= 3003;
-- DELETE FROM assignment WHERE id >= 3001 AND id <= 3003;

-- 作业1：前端基础综合测试（简单）- 包含10道单选题
INSERT INTO assignment (id, title, course_id, publisher_user_id, type, description, start_time, end_time, create_time, status, update_time, mode, time_limit, total_score, duration, allowed_file_types, attachments, is_deleted) VALUES
(3001, '前端基础综合测试（简单）', 1, 29, 'homework', '本次作业包含10道单选题，主要考察HTML、CSS、JavaScript的基础知识。\n\n要求：\n1. 独立完成，不得抄袭\n2. 仔细阅读题目，选择最合适的答案\n3. 建议用时：20分钟\n4. 总分：100分（每题10分）', '2025-11-18', '2025-11-28', NOW(), 1, NOW(), 'question', 30, 100, 20, NULL, '[]', 0);

-- 作业2：前端进阶能力测试（中等）- 包含15道题（单选+多选+判断）
INSERT INTO assignment (id, title, course_id, publisher_user_id, type, description, start_time, end_time, create_time, status, update_time, mode, time_limit, total_score, duration, allowed_file_types, attachments, is_deleted) VALUES
(3002, '前端进阶能力测试（中等）', 1, 29, 'exam', '本次考试包含15道题目，涵盖单选题、多选题和判断题，全面考察前端开发知识。\n\n要求：\n1. 独立完成，严禁作弊\n2. 多选题少选得部分分，多选或错选不得分\n3. 建议用时：40分钟\n4. 总分：100分\n   - 单选题：10题，每题5分，共50分\n   - 多选题：3题，每题10分，共30分\n   - 判断题：5题，每题4分，共20分', '2025-11-19', '2025-11-29', NOW(), 1, NOW(), 'question', 60, 100, 40, NULL, '[]', 0);

-- 作业3：前端高级综合考试（困难）- 包含20道题（全部类型）
INSERT INTO assignment (id, title, course_id, publisher_user_id, type, description, start_time, end_time, create_time, status, update_time, mode, time_limit, total_score, duration, allowed_file_types, attachments, is_deleted) VALUES
(3003, '前端高级综合考试（困难）', 1, 29, 'exam', '本次考试是前端开发的综合性考试，包含所有题型，难度较高。\n\n要求：\n1. 独立完成，考试期间不得查阅资料\n2. 认真审题，仔细作答\n3. 建议用时：60分钟\n4. 总分：100分\n   - 单选题：15题，每题3分，共45分\n   - 多选题：5题，每题7分，共35分\n   - 判断题：5题，每题4分，共20分\n\n注意：本次考试成绩将计入期末总评！', '2025-11-20', '2025-12-05', NOW(), 1, NOW(), 'question', 90, 100, 60, NULL, '[]', 0);

-- =============================================
-- 第六部分：关联作业和题目
-- =============================================

-- 作业1的题目（10道简单单选题：3001-3006, 3009-3010, 3017-3018）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
(3001, 3001, 10, 1),
(3001, 3002, 10, 2),
(3001, 3003, 10, 3),
(3001, 3004, 10, 4),
(3001, 3005, 10, 5),
(3001, 3006, 10, 6),
(3001, 3009, 10, 7),
(3001, 3010, 10, 8),
(3001, 3017, 10, 9),
(3001, 3018, 10, 10);

-- 作业2的题目（10道单选 + 3道多选 + 5道判断 = 18题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
-- 单选题（10题，每题5分）
(3002, 3001, 5, 1),
(3002, 3003, 5, 2),
(3002, 3005, 5, 3),
(3002, 3007, 5, 4),
(3002, 3009, 5, 5),
(3002, 3011, 5, 6),
(3002, 3013, 5, 7),
(3002, 3015, 5, 8),
(3002, 3017, 5, 9),
(3002, 3019, 5, 10),
-- 多选题（3题，每题10分）
(3002, 3021, 10, 11),
(3002, 3022, 10, 12),
(3002, 3023, 10, 13),
-- 判断题（5题，每题4分）
(3002, 3026, 4, 14),
(3002, 3027, 4, 15),
(3002, 3028, 4, 16),
(3002, 3029, 4, 17),
(3002, 3030, 4, 18);

-- 作业3的题目（15道单选 + 5道多选 + 5道判断 = 25题）
INSERT INTO assignment_question (assignment_id, question_id, score, sequence) VALUES
-- 单选题（15题，每题3分）
(3003, 3001, 3, 1),
(3003, 3002, 3, 2),
(3003, 3003, 3, 3),
(3003, 3005, 3, 4),
(3003, 3006, 3, 5),
(3003, 3007, 3, 6),
(3003, 3009, 3, 7),
(3003, 3011, 3, 8),
(3003, 3012, 3, 9),
(3003, 3013, 3, 10),
(3003, 3014, 3, 11),
(3003, 3015, 3, 12),
(3003, 3017, 3, 13),
(3003, 3019, 3, 14),
(3003, 3020, 3, 15),
-- 多选题（5题，每题7分）
(3003, 3021, 7, 16),
(3003, 3022, 7, 17),
(3003, 3023, 7, 18),
(3003, 3024, 7, 19),
(3003, 3025, 7, 20),
-- 判断题（5题，每题4分）
(3003, 3026, 4, 21),
(3003, 3027, 4, 22),
(3003, 3028, 4, 23),
(3003, 3029, 4, 24),
(3003, 3030, 4, 25);

-- =============================================
-- 完成！
-- =============================================

-- 查询验证
SELECT '题目总数：' AS info, COUNT(*) AS count FROM question WHERE id >= 3001 AND id <= 3030;
SELECT '选项总数：' AS info, COUNT(*) AS count FROM question_option WHERE question_id >= 3001 AND question_id <= 3030;
SELECT '作业总数：' AS info, COUNT(*) AS count FROM assignment WHERE id >= 3001 AND id <= 3003;
SELECT '作业-题目关联总数：' AS info, COUNT(*) AS count FROM assignment_question WHERE assignment_id >= 3001 AND assignment_id <= 3003;

-- 查看作业详情
SELECT
    a.id AS '作业ID',
    a.title AS '作业标题',
    a.mode AS '模式',
    a.total_score AS '总分',
    a.duration AS '时长(分钟)',
    COUNT(aq.id) AS '题目数量'
FROM assignment a
LEFT JOIN assignment_question aq ON a.id = aq.assignment_id
WHERE a.id >= 3001 AND a.id <= 3003
GROUP BY a.id;

