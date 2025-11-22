-- =============================================
-- 测试数据生成脚本
-- 包含题目和作业的测试数据
-- 数据库：smartclassv2
-- =============================================

-- 设置字符集
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 使用数据库
USE smartclassv2;

-- 清空现有测试数据（可选）
-- DELETE FROM question WHERE id >= 1000;
-- DELETE FROM assignment WHERE id >= 1000;

-- =============================================
-- 创建测试课程和章节（如果不存在）
-- =============================================

-- 插入测试课程（如果不存在）
-- 注意：使用现有的用户ID（29）
INSERT IGNORE INTO course (id, title, description, teacher_user_id, status, create_time, update_time, is_deleted)
VALUES (1, '前端开发基础', '学习HTML、CSS、JavaScript等前端开发技术', 29, '进行中', NOW(), NOW(), 0);

-- 插入测试章节（如果不存在）
INSERT IGNORE INTO chapter (id, course_id, title, description, create_time, update_time, is_deleted)
VALUES
(1, 1, 'HTML基础', 'HTML标签和语法', NOW(), NOW(), 0),
(2, 1, 'CSS样式', 'CSS选择器和布局', NOW(), NOW(), 0),
(3, 1, 'JavaScript编程', 'JavaScript语法和DOM操作', NOW(), NOW(), 0),
(4, 1, 'Vue.js框架', 'Vue.js组件和路由', NOW(), NOW(), 0),
(5, 1, '网络与API', 'HTTP协议和RESTful API', NOW(), NOW(), 0),
(6, 1, '前端工程化', '性能优化和工程化工具', NOW(), NOW(), 0);

-- =============================================
-- 插入题目数据（20道题目，涵盖不同难度和类型）
-- =============================================

-- 简单题目（难度1-2）
INSERT INTO question (id, title, question_type, difficulty, correct_answer, explanation, knowledge_point, course_id, chapter_id, created_by, create_time, update_time, is_deleted) VALUES
(1001, '什么是HTML？', 'short', 1, 'HTML是超文本标记语言（HyperText Markup Language）的缩写，是用于创建网页的标准标记语言。', 'HTML是网页开发的基础，用于定义网页的结构和内容。', 'HTML基础', 1, 1, 29, NOW(), NOW(), 0),
(1002, '请列举三种常见的HTML标签。', 'short', 1, '常见的HTML标签包括：<div>、<p>、<span>、<a>、<img>等。', '这些是最基础的HTML标签，用于构建网页结构。', 'HTML标签', 1, 1, 29, NOW(), NOW(), 0),
(1003, 'CSS的全称是什么？', 'short', 1, 'CSS的全称是层叠样式表（Cascading Style Sheets）。', 'CSS用于控制网页的样式和布局。', 'CSS基础', 1, 2, 29, NOW(), NOW(), 0),
(1004, '什么是JavaScript？', 'short', 2, 'JavaScript是一种高级的、解释型的编程语言，主要用于网页开发，可以实现网页的动态交互效果。', 'JavaScript是前端开发的核心技术之一。', 'JavaScript基础', 1, 3, 29, NOW(), NOW(), 0),
(1005, '请解释什么是DOM？', 'short', 2, 'DOM（Document Object Model，文档对象模型）是HTML和XML文档的编程接口，它将文档表示为节点树，允许程序动态访问和更新文档的内容、结构和样式。', 'DOM是JavaScript操作网页的基础。', 'DOM操作', 1, 3, 29, NOW(), NOW(), 0),

-- 中等难度题目（难度3）
(1006, '请解释CSS盒模型的组成部分。', 'short', 3, 'CSS盒模型由四个部分组成：内容（content）、内边距（padding）、边框（border）和外边距（margin）。从内到外依次是：content → padding → border → margin。', '盒模型是CSS布局的基础概念。', 'CSS盒模型', 1, 2, 29, NOW(), NOW(), 0),
(1007, '什么是响应式设计？请简要说明其实现方法。', 'short', 3, '响应式设计是指网页能够根据不同设备的屏幕尺寸自动调整布局和样式。实现方法包括：使用媒体查询（@media）、弹性布局（flexbox）、网格布局（grid）、相对单位（%、em、rem、vw、vh）等。', '响应式设计是现代网页开发的重要技能。', '响应式设计', 1, 2, 29, NOW(), NOW(), 0),
(1008, '请解释JavaScript中的闭包概念。', 'short', 3, '闭包是指函数能够访问其外部作用域中的变量，即使外部函数已经执行完毕。闭包由函数和其词法环境组成，可以用来创建私有变量、实现数据封装等。', '闭包是JavaScript的重要特性。', 'JavaScript闭包', 1, 3, 29, NOW(), NOW(), 0),
(1009, '什么是事件冒泡和事件捕获？', 'short', 3, '事件冒泡是指事件从最具体的元素（目标元素）开始触发，然后向上传播到较不具体的元素。事件捕获则相反，从最不具体的元素开始，向下传播到目标元素。DOM事件流包括三个阶段：捕获阶段、目标阶段和冒泡阶段。', '理解事件流对于处理DOM事件很重要。', 'DOM事件', 1, 3, 29, NOW(), NOW(), 0),
(1010, '请说明Vue.js中的数据双向绑定原理。', 'short', 3, 'Vue.js通过数据劫持结合发布-订阅模式实现双向绑定。Vue 2.x使用Object.defineProperty()劫持数据的getter和setter，当数据变化时通知订阅者更新视图；当视图变化时（如input输入）更新数据。Vue 3.x使用Proxy实现。', 'Vue的核心特性之一。', 'Vue数据绑定', 1, 4, 29, NOW(), NOW(), 0),

-- 较难题目（难度4）
(1011, '请解释JavaScript中的原型链和继承机制。', 'short', 4, 'JavaScript使用原型链实现继承。每个对象都有一个__proto__属性指向其原型对象，原型对象也有自己的原型，形成原型链。当访问对象的属性时，如果对象本身没有，会沿着原型链向上查找。继承方式包括：原型链继承、构造函数继承、组合继承、寄生组合继承、ES6的class继承等。', '原型链是JavaScript面向对象编程的基础。', 'JavaScript原型', 1, 3, 29, NOW(), NOW(), 0),
(1012, '请说明HTTP和HTTPS的区别，以及HTTPS的工作原理。', 'short', 4, 'HTTP是明文传输，不安全；HTTPS在HTTP基础上加入SSL/TLS加密层，保证数据传输安全。HTTPS工作原理：1)客户端发起请求；2)服务器返回证书；3)客户端验证证书；4)协商加密算法和密钥；5)使用对称加密传输数据。HTTPS使用443端口，HTTP使用80端口。', '网络安全的重要知识点。', '网络协议', 1, 5, 29, NOW(), NOW(), 0),
(1013, '请解释RESTful API的设计原则和最佳实践。', 'short', 4, 'RESTful API设计原则：1)使用HTTP方法（GET查询、POST创建、PUT更新、DELETE删除）；2)资源用名词表示，使用复数形式；3)使用HTTP状态码表示结果；4)版本控制；5)过滤、排序、分页；6)使用HTTPS；7)返回统一的数据格式（JSON）；8)提供清晰的错误信息。', 'API设计的标准规范。', 'API设计', 1, 5, 29, NOW(), NOW(), 0),
(1014, '请说明浏览器的渲染流程和性能优化方法。', 'short', 4, '渲染流程：1)解析HTML生成DOM树；2)解析CSS生成CSSOM树；3)合并生成渲染树；4)布局计算元素位置；5)绘制像素到屏幕。优化方法：减少重排重绘、使用CSS3动画、图片懒加载、代码压缩、CDN加速、缓存策略、减少HTTP请求、异步加载JS等。', '前端性能优化的核心知识。', '性能优化', 1, 6, 29, NOW(), NOW(), 0),
(1015, '请解释Vue组件间通信的几种方式。', 'short', 4, 'Vue组件通信方式：1)props/$emit（父子组件）；2)$parent/$children（父子组件）；3)provide/inject（跨级组件）；4)EventBus（兄弟组件）；5)Vuex（全局状态管理）；6)$attrs/$listeners（跨级组件）；7)ref（父组件访问子组件）。', 'Vue开发中的重要技能。', 'Vue组件通信', 1, 4, 29, NOW(), NOW(), 0),

-- 困难题目（难度5）
(1016, '请设计一个前端路由系统，说明Hash模式和History模式的实现原理及优缺点。', 'short', 5, 'Hash模式：通过监听hashchange事件，URL中#后的内容变化不会向服务器发送请求。优点：兼容性好，无需服务器配置。缺点：URL不美观，SEO不友好。History模式：使用HTML5 History API（pushState、replaceState），监听popstate事件。优点：URL美观，SEO友好。缺点：需要服务器配置，刷新可能404。实现：维护路由表，匹配路径渲染对应组件。', '前端路由是SPA应用的核心。', '前端路由', 1, 4, 29, NOW(), NOW(), 0),
(1017, '请设计一个虚拟DOM的Diff算法，说明其优化策略。', 'short', 5, 'Diff算法策略：1)同层比较，不跨层级；2)不同类型节点直接替换；3)使用key标识节点，优化列表渲染。具体步骤：1)树级别比较；2)组件级别比较；3)元素级别比较。优化：双端比较算法、最长递增子序列。时间复杂度从O(n³)优化到O(n)。', '虚拟DOM是现代框架的核心技术。', '虚拟DOM', 1, 4, 29, NOW(), NOW(), 0),
(1018, '请设计一个前端状态管理系统，说明Vuex/Redux的核心原理。', 'short', 5, '核心概念：单一数据源、状态只读、纯函数修改。Vuex：State（状态）、Getter（计算属性）、Mutation（同步修改）、Action（异步操作）、Module（模块化）。原理：通过Vue的响应式系统实现状态变化自动更新视图。Redux：Store、Action、Reducer。原理：发起Action → Reducer处理 → 更新Store → 触发订阅者。', '大型应用的状态管理方案。', '状态管理', 1, 4, 29, NOW(), NOW(), 0),
(1019, '请设计一个前端微服务架构方案，说明微前端的实现方式。', 'short', 5, '微前端方案：1)iframe隔离；2)Web Components；3)模块联邦（Module Federation）；4)single-spa框架；5)qiankun框架。核心问题：应用隔离（JS、CSS）、通信机制、路由管理、公共依赖。实现要点：主应用负责路由和生命周期，子应用独立开发部署，通过约定的协议通信。', '大型前端项目的架构方案。', '微前端', 1, 6, 29, NOW(), NOW(), 0),
(1020, '请设计一个前端性能监控系统，说明关键指标和实现方案。', 'short', 5, '关键指标：FCP（首次内容绘制）、LCP（最大内容绘制）、FID（首次输入延迟）、CLS（累积布局偏移）、TTFB（首字节时间）。实现方案：1)使用Performance API收集数据；2)使用PerformanceObserver监听；3)上报到服务器；4)数据分析和可视化；5)告警机制。监控内容：页面加载、资源加载、接口请求、错误监控、用户行为。', '前端工程化的重要环节。', '性能监控', 1, 6, 29, NOW(), NOW(), 0);

-- =============================================
-- 插入作业数据（10个作业，包含不同状态和类型）
-- =============================================

INSERT INTO assignment (id, title, course_id, publisher_user_id, type, description, start_time, end_time, create_time, status, update_time, mode, time_limit, total_score, duration, allowed_file_types, attachments, is_deleted) VALUES
-- 进行中的作业
(2001, 'HTML基础练习', 1, 29, 'homework', '请完成HTML基础知识的练习题，包括常用标签的使用、页面结构的搭建等内容。要求：\n1. 掌握HTML5的新特性\n2. 理解语义化标签的使用\n3. 能够独立完成简单页面的搭建', '2025-11-15', '2025-11-25', NOW(), 1, NOW(), 'file', 120, 100, 60, '["pdf","doc","docx","zip"]', '[]', 0),

(2002, 'CSS布局实战', 1, 29, 'homework', '使用CSS完成响应式布局设计，要求：\n1. 使用Flexbox或Grid布局\n2. 实现移动端适配\n3. 注意浏览器兼容性\n\n提交内容：HTML文件、CSS文件、效果截图', '2025-11-18', '2025-11-28', NOW(), 1, NOW(), 'file', 180, 100, 90, '["html","css","zip","png","jpg"]', '[{"name":"布局参考.pdf","url":"https://example.com/layout-ref.pdf"}]', 0),

(2003, 'JavaScript基础测试', 1, 29, 'exam', '本次考试涵盖JavaScript基础知识，包括：\n- 变量和数据类型\n- 函数和作用域\n- 对象和数组\n- DOM操作\n\n考试时长：90分钟\n注意：考试期间不得查阅资料', '2025-11-19', '2025-11-22', NOW(), 1, NOW(), 'question', 90, 100, 90, NULL, '[]', 0),

(2004, 'Vue组件开发', 1, 29, 'homework', '开发一个Vue组件库，要求：\n1. 至少包含3个常用组件（如按钮、输入框、对话框）\n2. 组件支持自定义配置\n3. 提供完整的文档和示例\n4. 代码规范，注释清晰', '2025-11-17', '2025-11-30', NOW(), 1, NOW(), 'file', 240, 100, 120, '["zip","rar"]', '[{"name":"组件设计规范.pdf","url":"https://example.com/component-spec.pdf"}]', 0),

-- 未开始的作业
(2005, '前端性能优化实践', 1, 29, 'homework', '针对给定的项目进行性能优化，要求：\n1. 分析性能瓶颈\n2. 提出优化方案\n3. 实施优化并对比效果\n4. 撰写优化报告', '2025-11-25', '2025-12-05', NOW(), 1, NOW(), 'file', 300, 100, 150, '["pdf","doc","docx","zip"]', '[{"name":"待优化项目.zip","url":"https://example.com/project.zip"}]', 0),

(2006, 'React Hooks深入学习', 1, 29, 'homework', '学习并实践React Hooks，完成以下任务：\n1. 使用useState、useEffect实现计数器\n2. 使用useContext实现主题切换\n3. 自定义Hook实现数据请求\n4. 总结Hooks的使用心得', '2025-11-26', '2025-12-06', NOW(), 1, NOW(), 'file', 180, 100, 90, '["zip","md","pdf"]', '[]', 0),

-- 已截止的作业
(2007, 'HTML5新特性探索', 1, 29, 'homework', '研究HTML5的新特性并完成实践项目，包括：\n- Canvas绘图\n- 本地存储\n- 地理定位\n- 拖放API\n\n提交：项目代码和学习报告', '2025-11-01', '2025-11-10', NOW(), 1, NOW(), 'file', 120, 100, 60, '["zip","pdf"]', '[]', 0),

(2008, 'CSS3动画设计', 1, 29, 'homework', '使用CSS3实现各种动画效果：\n1. 过渡动画（transition）\n2. 关键帧动画（@keyframes）\n3. 3D变换\n4. 创意动画作品', '2025-10-20', '2025-11-05', NOW(), 1, NOW(), 'file', 150, 100, 75, '["html","css","zip"]', '[]', 0),

-- 即将截止的作业
(2009, 'TypeScript入门实践', 1, 29, 'homework', 'TypeScript基础学习和实践：\n1. 理解类型系统\n2. 接口和类的使用\n3. 泛型编程\n4. 将JavaScript项目迁移到TypeScript', '2025-11-18', '2025-11-21', NOW(), 1, NOW(), 'file', 180, 100, 90, '["ts","zip"]', '[{"name":"TypeScript教程.pdf","url":"https://example.com/ts-tutorial.pdf"}]', 0),

(2010, 'Webpack配置与优化', 1, 29, 'exam', '学习Webpack的配置和优化技巧：\n1. 搭建基础配置\n2. 配置loader和plugin\n3. 代码分割和懒加载\n4. 打包优化\n\n提交配置文件和说明文档', '2025-11-19', '2025-11-23', NOW(), 1, NOW(), 'file', 200, 100, 100, '["js","json","md","zip"]', '[]', 0);

-- =============================================
-- 完成提示
-- =============================================
SELECT '测试数据插入完成！' AS message;
SELECT COUNT(*) AS question_count FROM question WHERE id >= 1000;
SELECT COUNT(*) AS assignment_count FROM assignment WHERE id >= 1000;

