/*
 Navicat Premium Dump SQL

 Source Server         : MySql
 Source Server Type    : MySQL
 Source Server Version : 80041 (8.0.41)
 Source Host           : localhost:3306
 Source Schema         : smartclassv2

 Target Server Type    : MySQL
 Target Server Version : 80041 (8.0.41)
 File Encoding         : 65001

 Date: 22/11/2025 19:29:32
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ai_grading
-- ----------------------------
DROP TABLE IF EXISTS `ai_grading`;
CREATE TABLE `ai_grading`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '批改ID',
  `assignment_submission_id` bigint NOT NULL COMMENT '作业提交表id',
  `content_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '内容相关性得分（0-100）',
  `logic_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '逻辑结构得分（0-100）',
  `knowledge_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '知识点覆盖得分（0-100）',
  `innovation_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '创新性得分（0-100）',
  `total_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '综合得分',
  `ai_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'AI评语',
  `improvement_suggestions` json NULL COMMENT '改进建议',
  `covered_knowledge_points` json NULL COMMENT '覆盖的知识点',
  `missing_knowledge_points` json NULL COMMENT '缺失的知识点',
  `llm_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '使用的LLM模型',
  `llm_tokens` int NULL DEFAULT NULL COMMENT '消耗的token数',
  `processing_time` int NULL DEFAULT NULL COMMENT '处理时长（毫秒）',
  `status` enum('pending','processing','completed','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息（如果失败）',
  `teacher_confirmed` tinyint NULL DEFAULT 0 COMMENT '教师是否确认：1-是 0-否',
  `teacher_modified_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '教师修改后的分数',
  `teacher_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '教师补充评语',
  `confirmed_by` bigint NULL DEFAULT NULL COMMENT '确认教师ID',
  `confirmed_at` timestamp NULL DEFAULT NULL COMMENT '确认时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '智能批改记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ai_grading
-- ----------------------------

-- ----------------------------
-- Table structure for assignment
-- ----------------------------
DROP TABLE IF EXISTS `assignment`;
CREATE TABLE `assignment`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '作业或考试标题',
  `course_id` bigint NOT NULL,
  `publisher_user_id` bigint NOT NULL COMMENT '发布者 user.id',
  `type` enum('homework','exam') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'homework' COMMENT '任务类型',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `start_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '发布状态：0未发布，1已发布',
  `update_time` datetime NULL DEFAULT NULL,
  `mode` enum('question','file') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'question' COMMENT '作业模式：question-答题型，file-上传型',
  `time_limit` int NULL DEFAULT NULL COMMENT '时间限制（分钟）',
  `total_score` int NULL DEFAULT 100 COMMENT '总分',
  `duration` int NULL DEFAULT NULL COMMENT '任务时长（分钟）',
  `allowed_file_types` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '允许的文件类型（JSON格式）',
  `attachments` json NULL COMMENT '任务附件列表，支持多文件，格式：[{\"name\":\"文件名.pdf\",\"url\":\"https://xxx.com/file.pdf\"}]',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  INDEX `fk_assignment_user`(`publisher_user_id` ASC) USING BTREE,
  INDEX `idx_deleted`(`is_deleted` ASC) USING BTREE,
  CONSTRAINT `assignment_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_assignment_user` FOREIGN KEY (`publisher_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3018 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '作业或考试表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of assignment
-- ----------------------------
INSERT INTO `assignment` VALUES (2001, 'HTML基础练习', 1, 29, 'homework', '请完成HTML基础知识的练习题，包括常用标签的使用、页面结构的搭建等内容。要求：\n1. 掌握HTML5的新特性\n2. 理解语义化标签的使用\n3. 能够独立完成简单页面的搭建', '2025-11-15 00:00:00', '2025-11-25 00:00:00', '2025-11-19 20:53:53', 1, '2025-11-19 20:53:53', 'file', 120, 100, 60, '[\"pdf\",\"doc\",\"docx\",\"zip\"]', '[]', 0, NULL);
INSERT INTO `assignment` VALUES (2002, 'CSS布局实战', 1, 29, 'homework', '使用CSS完成响应式布局设计，要求：\n1. 使用Flexbox或Grid布局\n2. 实现移动端适配\n3. 注意浏览器兼容性\n\n提交内容：HTML文件、CSS文件、效果截图', '2025-11-18 00:00:00', '2025-11-28 00:00:00', '2025-11-19 20:53:53', 1, '2025-11-19 20:53:53', 'file', 180, 100, 90, '[\"html\",\"css\",\"zip\",\"png\",\"jpg\"]', '[{\"url\": \"https://example.com/layout-ref.pdf\", \"name\": \"布局参考.pdf\"}]', 0, NULL);
INSERT INTO `assignment` VALUES (2003, 'JavaScript基础测试', 1, 29, 'exam', '本次考试涵盖JavaScript基础知识，包括：\n- 变量和数据类型\n- 函数和作用域\n- 对象和数组\n- DOM操作\n\n考试时长：90分钟\n注意：考试期间不得查阅资料', '2025-11-19 00:00:00', '2025-11-22 00:00:00', '2025-11-19 20:53:53', 1, '2025-11-19 20:53:53', 'question', 90, 100, 90, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (2004, 'Vue组件开发', 1, 29, 'homework', '开发一个Vue组件库，要求：\n1. 至少包含3个常用组件（如按钮、输入框、对话框）\n2. 组件支持自定义配置\n3. 提供完整的文档和示例\n4. 代码规范，注释清晰', '2025-11-17 00:00:00', '2025-11-30 00:00:00', '2025-11-19 20:53:53', 1, '2025-11-19 20:53:53', 'file', 240, 100, 120, '[\"zip\",\"rar\"]', '[{\"url\": \"https://example.com/component-spec.pdf\", \"name\": \"组件设计规范.pdf\"}]', 0, NULL);
INSERT INTO `assignment` VALUES (2005, '前端性能优化实践', 1, 29, 'homework', '针对给定的项目进行性能优化，要求：\n1. 分析性能瓶颈\n2. 提出优化方案\n3. 实施优化并对比效果\n4. 撰写优化报告', '2025-11-25 00:00:00', '2025-12-05 00:00:00', '2025-11-19 20:53:53', 1, '2025-11-19 20:53:53', 'file', 300, 100, 150, '[\"pdf\",\"doc\",\"docx\",\"zip\"]', '[{\"url\": \"https://example.com/project.zip\", \"name\": \"待优化项目.zip\"}]', 0, NULL);
INSERT INTO `assignment` VALUES (2006, 'React Hooks深入学习', 1, 29, 'homework', '学习并实践React Hooks，完成以下任务：\n1. 使用useState、useEffect实现计数器\n2. 使用useContext实现主题切换\n3. 自定义Hook实现数据请求\n4. 总结Hooks的使用心得', '2025-11-26 00:00:00', '2025-12-06 00:00:00', '2025-11-19 20:53:53', 1, '2025-11-19 20:53:53', 'file', 180, 100, 90, '[\"zip\",\"md\",\"pdf\"]', '[]', 0, NULL);
INSERT INTO `assignment` VALUES (2007, 'HTML5新特性探索', 1, 29, 'homework', '研究HTML5的新特性并完成实践项目，包括：\n- Canvas绘图\n- 本地存储\n- 地理定位\n- 拖放API\n\n提交：项目代码和学习报告', '2025-11-01 00:00:00', '2025-11-10 00:00:00', '2025-11-19 20:53:53', 1, '2025-11-19 20:53:53', 'file', 120, 100, 60, '[\"zip\",\"pdf\"]', '[]', 0, NULL);
INSERT INTO `assignment` VALUES (2008, 'CSS3动画设计', 1, 29, 'homework', '使用CSS3实现各种动画效果：\n1. 过渡动画（transition）\n2. 关键帧动画（@keyframes）\n3. 3D变换\n4. 创意动画作品', '2025-10-20 00:00:00', '2025-11-05 00:00:00', '2025-11-19 20:53:53', 1, '2025-11-19 20:53:53', 'file', 150, 100, 75, '[\"html\",\"css\",\"zip\"]', '[]', 0, NULL);
INSERT INTO `assignment` VALUES (2009, 'TypeScript入门实践', 1, 29, 'homework', 'TypeScript基础学习和实践：\n1. 理解类型系统\n2. 接口和类的使用\n3. 泛型编程\n4. 将JavaScript项目迁移到TypeScript', '2025-11-18 00:00:00', '2025-11-21 00:00:00', '2025-11-19 20:53:53', 1, '2025-11-19 20:53:53', 'file', 180, 100, 90, '[\"ts\",\"zip\"]', '[{\"url\": \"https://example.com/ts-tutorial.pdf\", \"name\": \"TypeScript教程.pdf\"}]', 0, NULL);
INSERT INTO `assignment` VALUES (2010, 'Webpack配置与优化', 1, 29, 'exam', '学习Webpack的配置和优化技巧：\n1. 搭建基础配置\n2. 配置loader和plugin\n3. 代码分割和懒加载\n4. 打包优化\n\n提交配置文件和说明文档', '2025-11-19 00:00:00', '2025-11-23 00:00:00', '2025-11-19 20:53:53', 1, '2025-11-19 20:53:53', 'file', 200, 100, 100, '[\"js\",\"json\",\"md\",\"zip\"]', '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3001, '前端基础综合测试（简单）', 1, 29, 'homework', '本次作业包含10道单选题，主要考察HTML、CSS、JavaScript的基础知识。\n\n要求：\n1. 独立完成，不得抄袭\n2. 仔细阅读题目，选择最合适的答案\n3. 建议用时：20分钟\n4. 总分：100分（每题10分）', '2025-11-18 00:00:00', '2025-11-28 00:00:00', '2025-11-20 10:51:27', 1, '2025-11-20 10:51:27', 'question', 30, 100, 20, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3002, '前端进阶能力测试（中等）', 1, 29, 'exam', '本次考试包含15道题目，涵盖单选题、多选题和判断题，全面考察前端开发知识。\n\n要求：\n1. 独立完成，严禁作弊\n2. 多选题少选得部分分，多选或错选不得分\n3. 建议用时：40分钟\n4. 总分：100分\n   - 单选题：10题，每题5分，共50分\n   - 多选题：3题，每题10分，共30分\n   - 判断题：5题，每题4分，共20分', '2025-11-19 00:00:00', '2025-11-29 00:00:00', '2025-11-20 10:51:27', 1, '2025-11-20 10:51:27', 'question', 60, 100, 40, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3003, '前端高级综合考试（困难）', 1, 29, 'exam', '本次考试是前端开发的综合性考试，包含所有题型，难度较高。\n\n要求：\n1. 独立完成，考试期间不得查阅资料\n2. 认真审题，仔细作答\n3. 建议用时：60分钟\n4. 总分：100分\n   - 单选题：15题，每题3分，共45分\n   - 多选题：5题，每题7分，共35分\n   - 判断题：5题，每题4分，共20分\n\n注意：本次考试成绩将计入期末总评！', '2025-11-20 00:00:00', '2025-12-05 00:00:00', '2025-11-20 10:51:27', 1, '2025-11-20 10:51:27', 'question', 90, 100, 60, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3004, 'Java基础知识测试', 2, 29, 'homework', '本次作业测试Java基础知识，包括数据类型、运算符、控制流程等。\n\n要求：\n1. 独立完成\n2. 认真审题\n3. 建议用时：30分钟', '2025-11-18 00:00:00', '2025-11-28 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 45, 100, 30, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3005, 'Java面向对象编程考试', 2, 29, 'exam', '本次考试全面考察Java面向对象编程知识。\n\n要求：\n1. 独立完成，严禁作弊\n2. 建议用时：50分钟\n3. 总分：100分', '2025-11-19 00:00:00', '2025-11-29 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 75, 100, 50, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3006, 'SQL基础查询练习', 3, 29, 'homework', '本次作业练习SQL基础查询语句。\n\n要求：\n1. 掌握SELECT、WHERE、ORDER BY等基础语法\n2. 建议用时：25分钟', '2025-11-18 00:00:00', '2025-11-28 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 40, 100, 25, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3007, '数据库设计与优化考试', 3, 29, 'exam', '本次考试考察数据库设计、索引、事务等知识。\n\n要求：\n1. 独立完成\n2. 建议用时：45分钟', '2025-11-19 00:00:00', '2025-11-29 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 70, 100, 45, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3008, '网络协议基础测试', 4, 29, 'homework', '本次作业测试TCP/IP、HTTP等网络协议基础知识。\n\n要求：\n1. 理解各层协议的作用\n2. 建议用时：30分钟', '2025-11-18 00:00:00', '2025-11-28 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 45, 100, 30, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3009, '网络安全综合考试', 4, 29, 'exam', '本次考试全面考察网络安全知识。\n\n要求：\n1. 独立完成\n2. 建议用时：40分钟', '2025-11-19 00:00:00', '2025-11-29 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 60, 100, 40, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3010, '进程与线程基础练习', 5, 29, 'homework', '本次作业练习进程、线程相关知识。\n\n要求：\n1. 理解进程和线程的区别\n2. 建议用时：25分钟', '2025-11-18 00:00:00', '2025-11-28 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 40, 100, 25, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3011, '操作系统原理综合考试', 5, 29, 'exam', '本次考试考察操作系统核心原理。\n\n要求：\n1. 独立完成\n2. 建议用时：50分钟', '2025-11-19 00:00:00', '2025-11-29 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 75, 100, 50, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3012, '线性表与链表练习', 6, 29, 'homework', '本次作业练习线性表、链表相关知识。\n\n要求：\n1. 理解各种数据结构的特点\n2. 建议用时：30分钟', '2025-11-18 00:00:00', '2025-11-28 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 45, 100, 30, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3013, '算法设计与分析考试', 6, 29, 'exam', '本次考试考察算法设计与时间复杂度分析。\n\n要求：\n1. 独立完成\n2. 建议用时：60分钟', '2025-11-19 00:00:00', '2025-11-29 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 90, 100, 60, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3014, '软件开发流程测试', 7, 29, 'homework', '本次作业测试软件开发流程相关知识。\n\n要求：\n1. 理解敏捷开发、瀑布模型等\n2. 建议用时：25分钟', '2025-11-18 00:00:00', '2025-11-28 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 40, 100, 25, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3015, '软件设计模式考试', 7, 29, 'exam', '本次考试考察常用设计模式。\n\n要求：\n1. 独立完成\n2. 建议用时：45分钟', '2025-11-19 00:00:00', '2025-11-29 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 70, 100, 45, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3016, '机器学习基础测试', 8, 29, 'homework', '本次作业测试机器学习基础概念。\n\n要求：\n1. 理解监督学习、非监督学习\n2. 建议用时：30分钟', '2025-11-18 00:00:00', '2025-11-28 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 45, 100, 30, NULL, '[]', 0, NULL);
INSERT INTO `assignment` VALUES (3017, '深度学习综合考试', 8, 29, 'exam', '本次考试考察深度学习相关知识。\n\n要求：\n1. 独立完成\n2. 建议用时：50分钟', '2025-11-19 00:00:00', '2025-11-29 00:00:00', '2025-11-20 20:48:49', 1, '2025-11-20 20:48:49', 'question', 75, 100, 50, NULL, '[]', 0, NULL);

-- ----------------------------
-- Table structure for assignment_kp
-- ----------------------------
DROP TABLE IF EXISTS `assignment_kp`;
CREATE TABLE `assignment_kp`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `assignment_id` bigint NULL DEFAULT NULL COMMENT '作业/考试ID（允许为空，兼容旧数据）',
  `kp_id` bigint NULL DEFAULT NULL COMMENT '知识点ID',
  `sequence` int NULL DEFAULT 1 COMMENT '在任务中的顺序',
  `is_required` tinyint(1) NULL DEFAULT 1 COMMENT '是否必修知识点',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_assignment_kp`(`assignment_id` ASC, `kp_id` ASC) USING BTREE,
  INDEX `idx_kp`(`kp_id` ASC) USING BTREE,
  INDEX `idx_assignment`(`assignment_id` ASC) USING BTREE,
  CONSTRAINT `fk_ak_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignment` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_ak_kp` FOREIGN KEY (`kp_id`) REFERENCES `knowledge_point` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '任务与知识点关联表（非强制）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of assignment_kp
-- ----------------------------

-- ----------------------------
-- Table structure for assignment_question
-- ----------------------------
DROP TABLE IF EXISTS `assignment_question`;
CREATE TABLE `assignment_question`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `assignment_id` bigint NOT NULL,
  `question_id` bigint NOT NULL,
  `score` int NULL DEFAULT 5 COMMENT '该题满分',
  `sequence` int NULL DEFAULT 1 COMMENT '题目顺序',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `assignment_id`(`assignment_id` ASC) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE,
  CONSTRAINT `assignment_question_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignment` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `assignment_question_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 307 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '作业题目关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of assignment_question
-- ----------------------------
INSERT INTO `assignment_question` VALUES (73, 3001, 3001, 10, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (74, 3001, 3002, 10, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (75, 3001, 3003, 10, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (76, 3001, 3004, 10, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (77, 3001, 3005, 10, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (78, 3001, 3006, 10, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (79, 3001, 3009, 10, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (80, 3001, 3010, 10, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (81, 3001, 3017, 10, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (82, 3001, 3018, 10, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (83, 3002, 3001, 5, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (84, 3002, 3003, 5, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (85, 3002, 3005, 5, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (86, 3002, 3007, 5, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (87, 3002, 3009, 5, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (88, 3002, 3011, 5, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (89, 3002, 3013, 5, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (90, 3002, 3015, 5, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (91, 3002, 3017, 5, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (92, 3002, 3019, 5, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (93, 3002, 3021, 10, 11, 0, NULL);
INSERT INTO `assignment_question` VALUES (94, 3002, 3022, 10, 12, 0, NULL);
INSERT INTO `assignment_question` VALUES (95, 3002, 3023, 10, 13, 0, NULL);
INSERT INTO `assignment_question` VALUES (96, 3002, 3026, 4, 14, 0, NULL);
INSERT INTO `assignment_question` VALUES (97, 3002, 3027, 4, 15, 0, NULL);
INSERT INTO `assignment_question` VALUES (98, 3002, 3028, 4, 16, 0, NULL);
INSERT INTO `assignment_question` VALUES (99, 3002, 3029, 4, 17, 0, NULL);
INSERT INTO `assignment_question` VALUES (100, 3002, 3030, 4, 18, 0, NULL);
INSERT INTO `assignment_question` VALUES (101, 3003, 3001, 3, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (102, 3003, 3002, 3, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (103, 3003, 3003, 3, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (104, 3003, 3005, 3, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (105, 3003, 3006, 3, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (106, 3003, 3007, 3, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (107, 3003, 3009, 3, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (108, 3003, 3011, 3, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (109, 3003, 3012, 3, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (110, 3003, 3013, 3, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (111, 3003, 3014, 3, 11, 0, NULL);
INSERT INTO `assignment_question` VALUES (112, 3003, 3015, 3, 12, 0, NULL);
INSERT INTO `assignment_question` VALUES (113, 3003, 3017, 3, 13, 0, NULL);
INSERT INTO `assignment_question` VALUES (114, 3003, 3019, 3, 14, 0, NULL);
INSERT INTO `assignment_question` VALUES (115, 3003, 3020, 3, 15, 0, NULL);
INSERT INTO `assignment_question` VALUES (116, 3003, 3021, 7, 16, 0, NULL);
INSERT INTO `assignment_question` VALUES (117, 3003, 3022, 7, 17, 0, NULL);
INSERT INTO `assignment_question` VALUES (118, 3003, 3023, 7, 18, 0, NULL);
INSERT INTO `assignment_question` VALUES (119, 3003, 3024, 7, 19, 0, NULL);
INSERT INTO `assignment_question` VALUES (120, 3003, 3025, 7, 20, 0, NULL);
INSERT INTO `assignment_question` VALUES (121, 3003, 3026, 4, 21, 0, NULL);
INSERT INTO `assignment_question` VALUES (122, 3003, 3027, 4, 22, 0, NULL);
INSERT INTO `assignment_question` VALUES (123, 3003, 3028, 4, 23, 0, NULL);
INSERT INTO `assignment_question` VALUES (124, 3003, 3029, 4, 24, 0, NULL);
INSERT INTO `assignment_question` VALUES (125, 3003, 3030, 4, 25, 0, NULL);
INSERT INTO `assignment_question` VALUES (126, 3004, 3001, 10, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (127, 3004, 3002, 10, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (128, 3004, 3003, 10, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (129, 3004, 3004, 10, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (130, 3004, 3005, 10, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (131, 3004, 3006, 10, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (132, 3004, 3009, 10, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (133, 3004, 3010, 10, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (134, 3004, 3017, 10, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (135, 3004, 3018, 10, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (136, 3005, 3001, 5, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (137, 3005, 3003, 5, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (138, 3005, 3005, 5, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (139, 3005, 3007, 5, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (140, 3005, 3009, 5, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (141, 3005, 3011, 5, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (142, 3005, 3013, 5, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (143, 3005, 3015, 5, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (144, 3005, 3017, 5, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (145, 3005, 3019, 5, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (146, 3005, 3021, 10, 11, 0, NULL);
INSERT INTO `assignment_question` VALUES (147, 3005, 3022, 10, 12, 0, NULL);
INSERT INTO `assignment_question` VALUES (148, 3005, 3023, 10, 13, 0, NULL);
INSERT INTO `assignment_question` VALUES (149, 3005, 3026, 10, 14, 0, NULL);
INSERT INTO `assignment_question` VALUES (150, 3005, 3027, 10, 15, 0, NULL);
INSERT INTO `assignment_question` VALUES (151, 3006, 3001, 12, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (152, 3006, 3002, 12, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (153, 3006, 3003, 12, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (154, 3006, 3004, 12, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (155, 3006, 3005, 13, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (156, 3006, 3006, 13, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (157, 3006, 3009, 13, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (158, 3006, 3010, 13, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (159, 3007, 3001, 8, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (160, 3007, 3003, 8, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (161, 3007, 3005, 8, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (162, 3007, 3007, 8, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (163, 3007, 3009, 8, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (164, 3007, 3011, 8, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (165, 3007, 3013, 7, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (166, 3007, 3015, 7, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (167, 3007, 3021, 13, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (168, 3007, 3022, 13, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (169, 3007, 3026, 8, 11, 0, NULL);
INSERT INTO `assignment_question` VALUES (170, 3007, 3027, 8, 12, 0, NULL);
INSERT INTO `assignment_question` VALUES (171, 3008, 3001, 10, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (172, 3008, 3002, 10, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (173, 3008, 3003, 10, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (174, 3008, 3004, 10, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (175, 3008, 3005, 10, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (176, 3008, 3006, 10, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (177, 3008, 3009, 10, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (178, 3008, 3010, 10, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (179, 3008, 3017, 10, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (180, 3008, 3018, 10, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (181, 3009, 3001, 7, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (182, 3009, 3003, 7, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (183, 3009, 3005, 7, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (184, 3009, 3007, 7, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (185, 3009, 3009, 7, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (186, 3009, 3011, 7, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (187, 3009, 3013, 7, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (188, 3009, 3015, 7, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (189, 3009, 3021, 10, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (190, 3009, 3022, 10, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (191, 3009, 3023, 9, 11, 0, NULL);
INSERT INTO `assignment_question` VALUES (192, 3009, 3026, 7, 12, 0, NULL);
INSERT INTO `assignment_question` VALUES (193, 3009, 3027, 7, 13, 0, NULL);
INSERT INTO `assignment_question` VALUES (194, 3009, 3028, 7, 14, 0, NULL);
INSERT INTO `assignment_question` VALUES (195, 3010, 3001, 12, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (196, 3010, 3002, 12, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (197, 3010, 3003, 12, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (198, 3010, 3004, 13, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (199, 3010, 3005, 13, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (200, 3010, 3006, 13, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (201, 3010, 3009, 12, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (202, 3010, 3010, 13, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (203, 3011, 3001, 5, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (204, 3011, 3002, 5, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (205, 3011, 3003, 5, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (206, 3011, 3005, 5, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (207, 3011, 3007, 5, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (208, 3011, 3009, 5, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (209, 3011, 3011, 5, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (210, 3011, 3013, 5, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (211, 3011, 3015, 5, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (212, 3011, 3017, 5, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (213, 3011, 3021, 11, 11, 0, NULL);
INSERT INTO `assignment_question` VALUES (214, 3011, 3022, 11, 12, 0, NULL);
INSERT INTO `assignment_question` VALUES (215, 3011, 3023, 11, 13, 0, NULL);
INSERT INTO `assignment_question` VALUES (216, 3011, 3026, 6, 14, 0, NULL);
INSERT INTO `assignment_question` VALUES (217, 3011, 3027, 6, 15, 0, NULL);
INSERT INTO `assignment_question` VALUES (218, 3011, 3028, 5, 16, 0, NULL);
INSERT INTO `assignment_question` VALUES (219, 3012, 3001, 10, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (220, 3012, 3002, 10, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (221, 3012, 3003, 10, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (222, 3012, 3004, 10, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (223, 3012, 3005, 10, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (224, 3012, 3006, 10, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (225, 3012, 3009, 10, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (226, 3012, 3010, 10, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (227, 3012, 3017, 10, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (228, 3012, 3018, 10, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (229, 3013, 3001, 4, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (230, 3013, 3002, 4, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (231, 3013, 3003, 4, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (232, 3013, 3005, 4, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (233, 3013, 3006, 4, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (234, 3013, 3007, 4, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (235, 3013, 3009, 4, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (236, 3013, 3011, 4, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (237, 3013, 3012, 4, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (238, 3013, 3013, 4, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (239, 3013, 3014, 4, 11, 0, NULL);
INSERT INTO `assignment_question` VALUES (240, 3013, 3015, 4, 12, 0, NULL);
INSERT INTO `assignment_question` VALUES (241, 3013, 3017, 5, 13, 0, NULL);
INSERT INTO `assignment_question` VALUES (242, 3013, 3019, 5, 14, 0, NULL);
INSERT INTO `assignment_question` VALUES (243, 3013, 3020, 5, 15, 0, NULL);
INSERT INTO `assignment_question` VALUES (244, 3013, 3021, 9, 16, 0, NULL);
INSERT INTO `assignment_question` VALUES (245, 3013, 3022, 9, 17, 0, NULL);
INSERT INTO `assignment_question` VALUES (246, 3013, 3023, 9, 18, 0, NULL);
INSERT INTO `assignment_question` VALUES (247, 3013, 3026, 5, 19, 0, NULL);
INSERT INTO `assignment_question` VALUES (248, 3013, 3027, 5, 20, 0, NULL);
INSERT INTO `assignment_question` VALUES (249, 3014, 3001, 12, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (250, 3014, 3002, 12, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (251, 3014, 3003, 12, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (252, 3014, 3004, 13, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (253, 3014, 3005, 13, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (254, 3014, 3006, 13, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (255, 3014, 3009, 12, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (256, 3014, 3010, 13, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (257, 3015, 3001, 7, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (258, 3015, 3003, 7, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (259, 3015, 3005, 7, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (260, 3015, 3007, 7, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (261, 3015, 3009, 7, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (262, 3015, 3011, 7, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (263, 3015, 3013, 7, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (264, 3015, 3015, 7, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (265, 3015, 3021, 10, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (266, 3015, 3022, 10, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (267, 3015, 3023, 10, 11, 0, NULL);
INSERT INTO `assignment_question` VALUES (268, 3015, 3026, 7, 12, 0, NULL);
INSERT INTO `assignment_question` VALUES (269, 3015, 3027, 7, 13, 0, NULL);
INSERT INTO `assignment_question` VALUES (270, 3016, 3001, 10, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (271, 3016, 3002, 10, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (272, 3016, 3003, 10, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (273, 3016, 3004, 10, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (274, 3016, 3005, 10, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (275, 3016, 3006, 10, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (276, 3016, 3009, 10, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (277, 3016, 3010, 10, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (278, 3016, 3017, 10, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (279, 3016, 3018, 10, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (280, 3017, 3001, 5, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (281, 3017, 3002, 5, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (282, 3017, 3003, 5, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (283, 3017, 3005, 5, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (284, 3017, 3006, 5, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (285, 3017, 3007, 5, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (286, 3017, 3009, 5, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (287, 3017, 3011, 5, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (288, 3017, 3013, 5, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (289, 3017, 3015, 5, 10, 0, NULL);
INSERT INTO `assignment_question` VALUES (290, 3017, 3017, 5, 11, 0, NULL);
INSERT INTO `assignment_question` VALUES (291, 3017, 3019, 5, 12, 0, NULL);
INSERT INTO `assignment_question` VALUES (292, 3017, 3021, 10, 13, 0, NULL);
INSERT INTO `assignment_question` VALUES (293, 3017, 3022, 10, 14, 0, NULL);
INSERT INTO `assignment_question` VALUES (294, 3017, 3023, 10, 15, 0, NULL);
INSERT INTO `assignment_question` VALUES (295, 3017, 3026, 5, 16, 0, NULL);
INSERT INTO `assignment_question` VALUES (296, 3017, 3027, 5, 17, 0, NULL);
INSERT INTO `assignment_question` VALUES (297, 2003, 3001, 10, 1, 0, NULL);
INSERT INTO `assignment_question` VALUES (298, 2003, 3002, 10, 2, 0, NULL);
INSERT INTO `assignment_question` VALUES (299, 2003, 3003, 10, 3, 0, NULL);
INSERT INTO `assignment_question` VALUES (300, 2003, 3004, 10, 4, 0, NULL);
INSERT INTO `assignment_question` VALUES (301, 2003, 3005, 10, 5, 0, NULL);
INSERT INTO `assignment_question` VALUES (302, 2003, 3006, 10, 6, 0, NULL);
INSERT INTO `assignment_question` VALUES (303, 2003, 3009, 10, 7, 0, NULL);
INSERT INTO `assignment_question` VALUES (304, 2003, 3010, 10, 8, 0, NULL);
INSERT INTO `assignment_question` VALUES (305, 2003, 3017, 10, 9, 0, NULL);
INSERT INTO `assignment_question` VALUES (306, 2003, 3018, 10, 10, 0, NULL);

-- ----------------------------
-- Table structure for assignment_submission
-- ----------------------------
DROP TABLE IF EXISTS `assignment_submission`;
CREATE TABLE `assignment_submission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `assignment_id` bigint NOT NULL COMMENT '作业ID',
  `student_user_id` bigint NOT NULL COMMENT '学生 user.id',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态：0-未提交，1-已提交未批改，2-已批改',
  `score` int NULL DEFAULT NULL COMMENT '得分',
  `feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '教师反馈',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `grade_time` datetime NULL DEFAULT NULL COMMENT '批改时间',
  `graded_by` bigint NULL DEFAULT NULL COMMENT '批改人ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '提交内容',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件名称',
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件路径',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_assignment_id`(`assignment_id` ASC) USING BTREE,
  INDEX `idx_student_id`(`student_user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_deleted`(`is_deleted` ASC) USING BTREE,
  CONSTRAINT `fk_submission_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignment` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_submission_student` FOREIGN KEY (`student_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 49 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '作业提交记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of assignment_submission
-- ----------------------------

-- ----------------------------
-- Table structure for chapter
-- ----------------------------
DROP TABLE IF EXISTS `chapter`;
CREATE TABLE `chapter`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '章节ID，主键',
  `course_id` bigint NOT NULL COMMENT '所属课程ID，外键',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '章节名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `sort_order` int NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_id`(`course_id` ASC) USING BTREE,
  INDEX `idx_deleted`(`is_deleted` ASC) USING BTREE,
  CONSTRAINT `fk_chapter_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程章节表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of chapter
-- ----------------------------
INSERT INTO `chapter` VALUES (1, 1, 'HTML基础', 'HTML标签和语法', 0, '2025-11-19 20:48:16', '2025-11-19 20:48:16', 0, NULL);
INSERT INTO `chapter` VALUES (2, 1, 'CSS样式', 'CSS选择器和布局', 0, '2025-11-19 20:48:16', '2025-11-19 20:48:16', 0, NULL);
INSERT INTO `chapter` VALUES (3, 1, 'JavaScript编程', 'JavaScript语法和DOM操作', 0, '2025-11-19 20:48:16', '2025-11-19 20:48:16', 0, NULL);
INSERT INTO `chapter` VALUES (4, 1, 'Vue.js框架', 'Vue.js组件和路由', 0, '2025-11-19 20:48:16', '2025-11-19 20:48:16', 0, NULL);
INSERT INTO `chapter` VALUES (5, 1, '网络与API', 'HTTP协议和RESTful API', 0, '2025-11-19 20:48:16', '2025-11-19 20:48:16', 0, NULL);
INSERT INTO `chapter` VALUES (6, 1, '前端工程化', '性能优化和工程化工具', 0, '2025-11-19 20:48:16', '2025-11-19 20:48:16', 0, NULL);
INSERT INTO `chapter` VALUES (10, 33, '1.极限', '什么是极限？', 1, '2025-11-19 20:20:44', '2025-11-19 20:21:17', 0, NULL);
INSERT INTO `chapter` VALUES (11, 33, '2.函数', '函数有哪些特性？', 2, '2025-11-19 20:21:54', '2025-11-19 20:21:54', 0, NULL);

-- ----------------------------
-- Table structure for class_student
-- ----------------------------
DROP TABLE IF EXISTS `class_student`;
CREATE TABLE `class_student`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `class_id` bigint NOT NULL,
  `student_user_id` bigint NOT NULL,
  `join_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_class_student`(`class_id` ASC, `student_user_id` ASC) USING BTREE,
  INDEX `student_id`(`student_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_class_student_user` FOREIGN KEY (`student_user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '班级学生关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of class_student
-- ----------------------------

-- ----------------------------
-- Table structure for competency_kp_relation
-- ----------------------------
DROP TABLE IF EXISTS `competency_kp_relation`;
CREATE TABLE `competency_kp_relation`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `competency_id` bigint NOT NULL COMMENT '能力点ID（关联course_competency表）',
  `kp_id` bigint NOT NULL COMMENT '知识点ID（关联knowledge_point表）',
  `contribution_rate` decimal(3, 2) NULL DEFAULT 1.00 COMMENT '知识点对能力点的贡献度（0-1，用于加权计算能力得分）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '软删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_competency_kp`(`competency_id` ASC, `kp_id` ASC) USING BTREE COMMENT '同一能力点-知识点关联唯一',
  INDEX `idx_kp`(`kp_id` ASC) USING BTREE,
  CONSTRAINT `fk_ckr_competency` FOREIGN KEY (`competency_id`) REFERENCES `course_competency` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_ckr_kp` FOREIGN KEY (`kp_id`) REFERENCES `knowledge_point` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '能力点-知识点关联表（支撑能力模型与知识点的映射）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of competency_kp_relation
-- ----------------------------

-- ----------------------------
-- Table structure for course
-- ----------------------------
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '课程ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '课程名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '课程描述',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '课程封面图片',
  `credit` decimal(3, 1) NULL DEFAULT 3.0 COMMENT '学分',
  `course_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '必修课' COMMENT '课程类型',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `teacher_user_id` bigint NOT NULL COMMENT '任课教师 user.id',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '未开始' COMMENT '课程状态',
  `term` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '学期',
  `student_count` int NULL DEFAULT 0 COMMENT '学生数量',
  `average_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '平均分数',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '软删除标记: 0=未删除, 1=已删除',
  `delete_time` datetime NULL DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_term`(`term` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_teacher_user_id`(`teacher_user_id` ASC) USING BTREE,
  INDEX `idx_deleted`(`is_deleted` ASC) USING BTREE,
  CONSTRAINT `fk_course_teacher_user` FOREIGN KEY (`teacher_user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '课程表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of course
-- ----------------------------
INSERT INTO `course` VALUES (1, '前端开发基础', '学习HTML、CSS、JavaScript等前端开发技术', 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&h=600&fit=crop', 3.0, '必修课', NULL, NULL, 29, '进行中', NULL, 53, NULL, '2025-11-19 20:48:16', '2025-11-21 13:16:03', 0, NULL);
INSERT INTO `course` VALUES (2, 'JavaScript高级编程', 'JavaScript深入学习，包括ES6+新特性、异步编程、设计模式等高级主题', 'https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=800&h=600&fit=crop', 4.0, '必修课', '2025-09-01 00:00:00', '2026-01-15 00:00:00', 29, '进行中', '2025-2026学年第一学期', 85, 82.50, '2025-11-20 12:12:32', '2025-11-20 15:24:06', 0, NULL);
INSERT INTO `course` VALUES (3, 'Vue.js框架开发', '学习Vue.js框架的核心概念、组件开发、状态管理和路由系统', 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=800&h=600&fit=crop', 3.5, '必修课', '2025-09-01 00:00:00', '2026-01-15 00:00:00', 29, '进行中', '2025-2026学年第一学期', 78, 85.30, '2025-11-20 12:12:32', '2025-11-20 15:24:06', 0, NULL);
INSERT INTO `course` VALUES (4, 'React框架实战', 'React框架从入门到精通，包括Hooks、Redux、React Router等', 'https://images.unsplash.com/photo-1633356122102-3fe601e05bd2?w=800&h=600&fit=crop', 3.5, '选修课', '2025-09-01 00:00:00', '2026-01-15 00:00:00', 29, '进行中', '2025-2026学年第一学期', 62, 80.20, '2025-11-20 12:12:32', '2025-11-20 15:24:06', 0, NULL);
INSERT INTO `course` VALUES (5, '前端工程化实践', '学习Webpack、Vite等构建工具，掌握前端工程化开发流程', 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800&h=600&fit=crop', 3.0, '选修课', '2025-09-01 00:00:00', '2026-01-15 00:00:00', 29, '进行中', '2025-2026学年第一学期', 55, 78.90, '2025-11-20 12:12:32', '2025-11-20 15:24:06', 0, NULL);
INSERT INTO `course` VALUES (6, 'Node.js后端开发', '使用Node.js进行后端开发，学习Express、Koa等框架', 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&h=600&fit=crop', 4.0, '选修课', '2025-09-15 00:00:00', '2026-01-30 00:00:00', 29, '进行中', '2025-2026学年第一学期', 48, 76.50, '2025-11-20 12:12:32', '2025-11-20 15:24:06', 0, NULL);
INSERT INTO `course` VALUES (7, '移动端开发', '学习响应式设计、移动端适配、微信小程序开发等', 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800&h=600&fit=crop', 3.0, '选修课', '2025-10-01 00:00:00', '2026-01-30 00:00:00', 29, '进行中', '2025-2026学年第一学期', 42, 81.20, '2025-11-20 12:12:32', '2025-11-20 15:24:06', 0, NULL);
INSERT INTO `course` VALUES (8, '前端性能优化', '深入学习前端性能优化技术，包括加载优化、渲染优化、网络优化等', 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=600&fit=crop', 2.5, '选修课', '2025-11-01 00:00:00', '2026-01-30 00:00:00', 29, '进行中', '2025-2026学年第一学期', 35, 74.80, '2025-11-20 12:12:32', '2025-11-20 15:24:06', 0, NULL);
INSERT INTO `course` VALUES (32, '数据结构', '数据结构', '/profile/upload/2025/11/19/1.jpg', 3.0, '必修课', '2025-09-03 00:00:00', '2025-11-05 00:00:00', 19, '1', '2025年秋季学期', 56, 86.40, '2025-11-19 17:48:23', '2025-11-20 23:27:48', 0, NULL);
INSERT INTO `course` VALUES (33, '高等数学', '高等数学', '/profile/upload/2025/11/19/2.jpg', 5.0, '必修课', '2025-09-01 00:00:00', '2026-01-08 00:00:00', 19, '0', '2025年秋季学期', 132, NULL, '2025-11-19 17:50:54', '2025-11-20 23:27:50', 0, NULL);
INSERT INTO `course` VALUES (34, '大学英语', '大学英语', '/profile/upload/2025/11/19/3.jpg', 5.0, '必修课', '2025-09-01 00:00:00', '2026-01-01 00:00:00', 19, '0', '2025年秋季', 145, NULL, '2025-11-19 17:52:19', '2025-11-20 23:27:53', 0, NULL);
INSERT INTO `course` VALUES (35, '茶艺', '茶艺', '/profile/upload/2025/11/19/4.jpg', 2.0, '选修课', '2025-11-01 00:00:00', '2025-12-25 00:00:00', 19, '0', '2025年秋季', 45, NULL, '2025-11-19 17:53:48', '2025-11-20 23:27:54', 0, NULL);
INSERT INTO `course` VALUES (36, '心理学', '心理学', '/profile/upload/2025/11/19/5.jpg', 2.0, '选修课', '2025-09-10 00:00:00', '2025-10-08 00:00:00', 19, '1', '2025年秋季', 32, 88.00, '2025-11-19 17:57:14', '2025-11-21 13:15:59', 0, NULL);

-- ----------------------------
-- Table structure for course_class
-- ----------------------------
DROP TABLE IF EXISTS `course_class`;
CREATE TABLE `course_class`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '班级ID',
  `course_id` bigint NULL DEFAULT NULL,
  `teacher_user_id` bigint NOT NULL COMMENT '教师 user.id',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `is_default` tinyint(1) NULL DEFAULT 0,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `course_class_ibfk_1`(`course_id` ASC) USING BTREE,
  INDEX `course_class_ibfk_2`(`teacher_user_id` ASC) USING BTREE,
  CONSTRAINT `course_class_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_course_class_teacher_user` FOREIGN KEY (`teacher_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程班级表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of course_class
-- ----------------------------

-- ----------------------------
-- Table structure for course_competency
-- ----------------------------
DROP TABLE IF EXISTS `course_competency`;
CREATE TABLE `course_competency`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '能力点ID',
  `course_id` bigint NOT NULL COMMENT '所属课程ID（关联course表）',
  `competency_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '能力点名称（如“数据结构理解能力”“算法优化能力”）',
  `competency_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '能力点描述',
  `sort_order` int NULL DEFAULT 1 COMMENT '展示顺序（雷达图维度排序）',
  `weight` decimal(3, 2) NULL DEFAULT 1.00 COMMENT '能力点权重（用于综合能力计算）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '软删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_course_competency`(`course_id` ASC, `competency_name` ASC) USING BTREE COMMENT '同一课程能力点名称唯一',
  INDEX `idx_course`(`course_id` ASC) USING BTREE,
  CONSTRAINT `fk_cc_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程能力点表（定义能力模型维度）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of course_competency
-- ----------------------------

-- ----------------------------
-- Table structure for course_enrollment_request
-- ----------------------------
DROP TABLE IF EXISTS `course_enrollment_request`;
CREATE TABLE `course_enrollment_request`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '申请ID',
  `student_user_id` bigint NOT NULL COMMENT '学生 user.id',
  `course_id` bigint NOT NULL COMMENT '申请加入的课程ID',
  `status` tinyint NULL DEFAULT 0 COMMENT '申请状态：0=待审核 1=已通过 2=已拒绝',
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '学生申请理由',
  `review_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '教师审核意见',
  `submit_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `review_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_student_course`(`student_user_id` ASC, `course_id` ASC) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  CONSTRAINT `course_enrollment_request_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_enrollment_student_user` FOREIGN KEY (`student_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学生选课申请表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of course_enrollment_request
-- ----------------------------
INSERT INTO `course_enrollment_request` VALUES (5, 1, 33, 1, '', '同意', '2025-11-19 18:37:59', NULL);
INSERT INTO `course_enrollment_request` VALUES (6, 1, 35, 1, NULL, '好好学习', '2025-11-19 20:17:08', NULL);
INSERT INTO `course_enrollment_request` VALUES (7, 1, 8, 1, NULL, NULL, '2025-11-21 13:00:18', NULL);
INSERT INTO `course_enrollment_request` VALUES (8, 1, 7, 1, NULL, NULL, '2025-11-21 13:00:22', NULL);
INSERT INTO `course_enrollment_request` VALUES (9, 1, 6, 1, NULL, NULL, '2025-11-21 13:00:24', NULL);
INSERT INTO `course_enrollment_request` VALUES (10, 1, 5, 1, NULL, NULL, '2025-11-21 13:00:26', NULL);
INSERT INTO `course_enrollment_request` VALUES (11, 1, 4, 1, NULL, NULL, '2025-11-21 13:00:30', NULL);
INSERT INTO `course_enrollment_request` VALUES (12, 1, 3, 1, NULL, NULL, '2025-11-21 13:00:32', NULL);
INSERT INTO `course_enrollment_request` VALUES (13, 1, 2, 1, NULL, NULL, '2025-11-21 13:00:35', NULL);
INSERT INTO `course_enrollment_request` VALUES (14, 1, 1, 1, NULL, NULL, '2025-11-21 13:00:38', NULL);

-- ----------------------------
-- Table structure for course_resource
-- ----------------------------
DROP TABLE IF EXISTS `course_resource`;
CREATE TABLE `course_resource`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '资源ID',
  `course_id` bigint NOT NULL COMMENT '所属课程ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资源名称',
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件类型，如pdf、doc、ppt等',
  `file_size` bigint NOT NULL COMMENT '文件大小(字节)',
  `file_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件URL',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '资源描述',
  `download_count` int NULL DEFAULT 0 COMMENT '下载次数',
  `upload_user_id` bigint NOT NULL COMMENT '上传用户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_id`(`course_id` ASC) USING BTREE COMMENT '课程ID索引',
  INDEX `idx_upload_user_id`(`upload_user_id` ASC) USING BTREE COMMENT '上传用户ID索引'
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程资源表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of course_resource
-- ----------------------------
INSERT INTO `course_resource` VALUES (8, 33, '第一章', 'pdf', 668281, '/profile/upload/2025/11/20/第一章_20251120111030A001.pdf', '1', 1, 1, '2025-11-20 11:10:37', '2025-11-20 11:10:38');
INSERT INTO `course_resource` VALUES (9, 33, '第二章', 'pdf', 3594236, '/profile/upload/2025/11/20/第二章_20251120111233A002.pdf', '2', 1, 1, '2025-11-20 11:12:38', '2025-11-20 11:12:49');
INSERT INTO `course_resource` VALUES (10, 33, '大作业', 'docx', 23298, '/profile/upload/2025/11/20/大作业_20251120111411A003.docx', '1', 1, 1, '2025-11-20 11:14:17', '2025-11-20 11:14:19');
INSERT INTO `course_resource` VALUES (11, 33, '推荐书目', 'xls', 48762, '/profile/upload/2025/11/20/推荐书目_20251120111545A004.xls', NULL, 1, 1, '2025-11-20 11:15:53', '2025-11-21 15:50:54');

-- ----------------------------
-- Table structure for course_resource_kp
-- ----------------------------
DROP TABLE IF EXISTS `course_resource_kp`;
CREATE TABLE `course_resource_kp`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `resource_id` bigint NULL DEFAULT NULL COMMENT '资源ID（允许为空）',
  `kp_id` bigint NULL DEFAULT NULL COMMENT '知识点ID',
  `is_confirmed` tinyint(1) NULL DEFAULT 0 COMMENT '教师是否确认',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_resource_kp`(`resource_id` ASC, `kp_id` ASC) USING BTREE,
  INDEX `idx_kp`(`kp_id` ASC) USING BTREE,
  INDEX `idx_confirmed`(`is_confirmed` ASC) USING BTREE,
  CONSTRAINT `fk_crk_kp` FOREIGN KEY (`kp_id`) REFERENCES `knowledge_point` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_crk_resource` FOREIGN KEY (`resource_id`) REFERENCES `course_resource` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程资源与知识点智能关联表（非强制）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of course_resource_kp
-- ----------------------------

-- ----------------------------
-- Table structure for course_student
-- ----------------------------
DROP TABLE IF EXISTS `course_student`;
CREATE TABLE `course_student`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `student_user_id` bigint NOT NULL COMMENT '学生 user.id',
  `enroll_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `collected` int NULL DEFAULT 0 COMMENT '课程是否被该学生收藏，1为被收藏，0为未被收藏',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_course_student`(`course_id` ASC, `student_user_id` ASC) USING BTREE,
  INDEX `student_id`(`student_user_id` ASC) USING BTREE,
  CONSTRAINT `course_student_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_course_student_user` FOREIGN KEY (`student_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学生选课表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of course_student
-- ----------------------------
INSERT INTO `course_student` VALUES (1, 33, 1, '2025-11-19 18:39:17', 0, 0, NULL);
INSERT INTO `course_student` VALUES (2, 1, 1, '2025-11-21 13:01:49', 0, 0, NULL);
INSERT INTO `course_student` VALUES (6, 2, 1, '2025-11-21 13:02:01', 0, 0, NULL);
INSERT INTO `course_student` VALUES (7, 3, 1, '2025-11-21 13:02:11', 0, 0, NULL);
INSERT INTO `course_student` VALUES (8, 4, 1, '2025-11-21 13:02:18', 0, 0, NULL);
INSERT INTO `course_student` VALUES (9, 5, 1, '2025-11-21 13:02:24', 0, 0, NULL);
INSERT INTO `course_student` VALUES (10, 6, 1, '2025-11-21 13:02:31', 0, 0, NULL);
INSERT INTO `course_student` VALUES (11, 7, 1, '2025-11-21 13:02:38', 0, 0, NULL);
INSERT INTO `course_student` VALUES (12, 8, 1, '2025-11-21 13:02:43', 0, 0, NULL);

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '生成功能作者',
  `gen_type` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '代码生成业务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of gen_table
-- ----------------------------
INSERT INTO `gen_table` VALUES (1, 'chapter', '课程章节表', NULL, NULL, 'Chapter', 'crud', 'element-ui', 'com.ruoyi.system', 'system', 'chapter', '课程章节', 'ruoyi', '0', '/', '{\"parentMenuId\":2030}', 'admin', '2025-11-18 10:19:14', '', '2025-11-18 13:54:49', NULL);
INSERT INTO `gen_table` VALUES (2, 'course', '课程表', NULL, NULL, 'Course', 'crud', 'element-ui', 'com.ruoyi.system', 'system', 'course', '课程', 'ruoyi', '0', '/', '{\"parentMenuId\":1}', 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23', NULL);
INSERT INTO `gen_table` VALUES (3, 'section_comment', '小节评论表(讨论区)', NULL, NULL, 'SectionComment', 'crud', 'element-ui', 'com.ruoyi.system', 'system', 'comment', '小节评论(讨论区)', 'ruoyi', '0', '/', '{\"parentMenuId\":2042}', 'admin', '2025-11-18 10:19:15', '', '2025-11-18 14:03:26', NULL);
INSERT INTO `gen_table` VALUES (5, 'section', '课程小节表', NULL, NULL, 'Section', 'crud', 'element-ui', 'com.ruoyi.system', 'system', 'section', '课程小节', 'ruoyi', '0', '/', '{\"parentMenuId\":2036}', 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09', NULL);
INSERT INTO `gen_table` VALUES (6, 'course_resource', '课程资源表', NULL, NULL, 'CourseResource', 'crud', 'element-ui', 'com.ruoyi.system', 'system', 'resource', '课程资源', 'ruoyi', '0', '/', '{\"parentMenuId\":1}', 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26', NULL);
INSERT INTO `gen_table` VALUES (7, 'course_enrollment_request', '学生选课申请表', NULL, NULL, 'CourseEnrollmentRequest', 'crud', 'element-ui', 'com.ruoyi.system', 'system', 'request', '选课申请', 'ruoyi', '0', '/', '{\"parentMenuId\":1}', 'admin', '2025-11-18 10:20:59', '', '2025-11-18 13:07:49', NULL);
INSERT INTO `gen_table` VALUES (9, 'course_student', '学生选课表', NULL, NULL, 'CourseStudent', 'crud', 'element-ui', 'com.ruoyi.system', 'system', 'student', '学生选课', 'ruoyi', '0', '/', '{\"parentMenuId\":1}', 'admin', '2025-11-18 10:21:00', '', '2025-11-18 13:44:53', NULL);
INSERT INTO `gen_table` VALUES (10, 'video_learning_behavior', '视频学习行为表', NULL, NULL, 'VideoLearningBehavior', 'crud', 'element-ui', 'com.ruoyi.system', 'system', 'behavior', '视频学习行为', 'ruoyi', '0', '/', '{\"parentMenuId\":2054}', 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06', NULL);
INSERT INTO `gen_table` VALUES (12, 'knowledge_graph', '知识图谱表', NULL, NULL, 'KnowledgeGraph', 'crud', 'element-ui', 'com.ruoyi.system', 'system', 'graph', '知识图谱', 'ruoyi', '0', '/', '{}', 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06', NULL);
INSERT INTO `gen_table` VALUES (13, 'student_kp_mastery', '学生知识点掌握情况表（支撑知识图谱状态标识）', NULL, NULL, 'StudentKpMastery', 'crud', 'element-ui', 'com.ruoyi.system', 'system', 'mastery', '学生知识点掌握情况（支撑知识图谱状态标识）', 'ruoyi', '0', '/', '{}', 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30', NULL);
INSERT INTO `gen_table` VALUES (14, 'question', '题目表', NULL, NULL, 'Question', 'crud', '', 'com.ruoyi.system', 'system', 'question', '题目', 'ruoyi', '0', '/', NULL, 'admin', '2025-11-21 21:07:56', '', NULL, NULL);
INSERT INTO `gen_table` VALUES (15, 'knowledge_point', '知识点表', NULL, NULL, 'KnowledgePoint', 'crud', 'element-ui', 'com.ruoyi.system', 'system', 'point', '知识点', 'ruoyi', '0', '/', '{}', 'admin', '2025-11-21 21:12:10', '', '2025-11-21 21:13:20', NULL);

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint NULL DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `sort` int NULL DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 171 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '代码生成业务表字段' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------
INSERT INTO `gen_table_column` VALUES (1, 1, 'id', '章节ID，主键', 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-18 10:19:14', '', '2025-11-18 13:54:49');
INSERT INTO `gen_table_column` VALUES (2, 1, 'course_id', '所属课程ID，外键', 'bigint', 'Long', 'courseId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-18 10:19:14', '', '2025-11-18 13:54:49');
INSERT INTO `gen_table_column` VALUES (3, 1, 'title', '章节名称', 'varchar(255)', 'String', 'title', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 3, 'admin', '2025-11-18 10:19:14', '', '2025-11-18 13:54:49');
INSERT INTO `gen_table_column` VALUES (4, 1, 'description', NULL, 'text', 'String', 'description', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'textarea', '', 4, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 13:54:49');
INSERT INTO `gen_table_column` VALUES (5, 1, 'sort_order', NULL, 'int', 'Long', 'sortOrder', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 5, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 13:54:49');
INSERT INTO `gen_table_column` VALUES (6, 1, 'create_time', '创建时间', 'datetime', 'Date', 'createTime', '0', '0', '0', '1', NULL, NULL, NULL, 'EQ', 'datetime', '', 6, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 13:54:49');
INSERT INTO `gen_table_column` VALUES (7, 1, 'update_time', '更新时间', 'datetime', 'Date', 'updateTime', '0', '0', '0', '1', '1', NULL, NULL, 'EQ', 'datetime', '', 7, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 13:54:49');
INSERT INTO `gen_table_column` VALUES (8, 1, 'is_deleted', NULL, 'tinyint(1)', 'Integer', 'isDeleted', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 8, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 13:54:49');
INSERT INTO `gen_table_column` VALUES (9, 1, 'delete_time', NULL, 'datetime', 'Date', 'deleteTime', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'datetime', '', 9, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 13:54:49');
INSERT INTO `gen_table_column` VALUES (10, 2, 'id', '课程ID', 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (11, 2, 'title', '课程名称', 'varchar(100)', 'String', 'title', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (12, 2, 'description', '课程描述', 'text', 'String', 'description', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'textarea', '', 3, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (13, 2, 'cover_image', '课程封面图片', 'varchar(500)', 'String', 'coverImage', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'imageUpload', '', 4, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (14, 2, 'credit', '学分', 'decimal(3,1)', 'BigDecimal', 'credit', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 5, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (15, 2, 'course_type', '课程类型', 'varchar(20)', 'String', 'courseType', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'select', 'course_type', 6, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (16, 2, 'start_time', '开始时间', 'datetime', 'Date', 'startTime', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'datetime', '', 7, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (17, 2, 'end_time', '结束时间', 'datetime', 'Date', 'endTime', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'datetime', '', 8, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (18, 2, 'teacher_user_id', '任课教师 user.id', 'bigint', 'Long', 'teacherUserId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 9, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (19, 2, 'status', '课程状态', 'varchar(20)', 'String', 'status', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'radio', 'course_status', 10, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (20, 2, 'term', '学期', 'varchar(20)', 'String', 'term', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 11, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (21, 2, 'student_count', '学生数量', 'int', 'Long', 'studentCount', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 12, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (22, 2, 'average_score', '平均分数', 'decimal(5,2)', 'BigDecimal', 'averageScore', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 13, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (23, 2, 'create_time', '创建时间', 'datetime', 'Date', 'createTime', '0', '0', '0', '1', NULL, NULL, NULL, 'EQ', 'datetime', '', 14, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (24, 2, 'update_time', '更新时间', 'datetime', 'Date', 'updateTime', '0', '0', '0', '1', '1', NULL, NULL, 'EQ', 'datetime', '', 15, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (25, 2, 'is_deleted', '软删除标记: 0=未删除, 1=已删除', 'tinyint(1)', 'Integer', 'isDeleted', '0', '0', '0', '0', '0', '0', '0', 'EQ', 'input', '', 16, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (26, 2, 'delete_time', '删除时间', 'datetime', 'Date', 'deleteTime', '0', '0', '0', '0', '0', '0', '0', 'EQ', 'datetime', '', 17, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 11:57:23');
INSERT INTO `gen_table_column` VALUES (27, 3, 'id', '评论ID，主键', 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 14:03:26');
INSERT INTO `gen_table_column` VALUES (28, 3, 'section_id', '所属小节ID，外键', 'bigint', 'Long', 'sectionId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 14:03:26');
INSERT INTO `gen_table_column` VALUES (29, 3, 'user_id', '评论人ID，外键', 'bigint', 'Long', 'userId', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'input', '', 3, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 14:03:26');
INSERT INTO `gen_table_column` VALUES (30, 3, 'content', '评论内容', 'text', 'String', 'content', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'editor', '', 4, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 14:03:26');
INSERT INTO `gen_table_column` VALUES (31, 3, 'parent_id', '父评论ID，为NULL表示一级评论', 'bigint', 'Long', 'parentId', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 5, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 14:03:26');
INSERT INTO `gen_table_column` VALUES (32, 3, 'create_time', '创建时间', 'datetime', 'Date', 'createTime', '0', '0', '0', '1', NULL, NULL, NULL, 'EQ', 'datetime', '', 6, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 14:03:26');
INSERT INTO `gen_table_column` VALUES (33, 3, 'update_time', '更新时间', 'datetime', 'Date', 'updateTime', '0', '0', '0', '1', '1', NULL, NULL, 'EQ', 'datetime', '', 7, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 14:03:26');
INSERT INTO `gen_table_column` VALUES (34, 3, 'is_deleted', NULL, 'tinyint(1)', 'Integer', 'isDeleted', '0', '0', '0', '1', '1', '0', '0', 'EQ', 'input', '', 8, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 14:03:26');
INSERT INTO `gen_table_column` VALUES (35, 3, 'delete_time', NULL, 'datetime', 'Date', 'deleteTime', '0', '0', '0', '1', '1', '0', '0', 'EQ', 'datetime', '', 9, 'admin', '2025-11-18 10:19:15', '', '2025-11-18 14:03:26');
INSERT INTO `gen_table_column` VALUES (45, 5, 'id', '小节ID，主键', 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09');
INSERT INTO `gen_table_column` VALUES (46, 5, 'chapter_id', '所属章节ID，外键', 'bigint', 'Long', 'chapterId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09');
INSERT INTO `gen_table_column` VALUES (47, 5, 'title', '小节名称', 'varchar(255)', 'String', 'title', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 3, 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09');
INSERT INTO `gen_table_column` VALUES (48, 5, 'description', '小节简介', 'text', 'String', 'description', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'textarea', '', 4, 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09');
INSERT INTO `gen_table_column` VALUES (49, 5, 'video_url', '视频播放地址，可对接OSS', 'varchar(1024)', 'String', 'videoUrl', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'textarea', '', 5, 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09');
INSERT INTO `gen_table_column` VALUES (50, 5, 'duration', '视频时长(秒)', 'int', 'Long', 'duration', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'input', '', 6, 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09');
INSERT INTO `gen_table_column` VALUES (51, 5, 'sort_order', '小节顺序，用于排序', 'int', 'Long', 'sortOrder', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 7, 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09');
INSERT INTO `gen_table_column` VALUES (52, 5, 'create_time', '创建时间', 'datetime', 'Date', 'createTime', '0', '0', '0', '1', NULL, NULL, NULL, 'EQ', 'datetime', '', 8, 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09');
INSERT INTO `gen_table_column` VALUES (53, 5, 'update_time', '更新时间', 'datetime', 'Date', 'updateTime', '0', '0', '0', '1', '1', NULL, NULL, 'EQ', 'datetime', '', 9, 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09');
INSERT INTO `gen_table_column` VALUES (54, 5, 'is_deleted', NULL, 'tinyint(1)', 'Integer', 'isDeleted', '0', '0', '0', '1', '0', '0', '0', 'EQ', 'input', '', 10, 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09');
INSERT INTO `gen_table_column` VALUES (55, 5, 'delete_time', NULL, 'datetime', 'Date', 'deleteTime', '0', '0', '0', '1', '0', '0', '0', 'EQ', 'datetime', '', 11, 'admin', '2025-11-18 10:20:02', '', '2025-11-18 13:59:09');
INSERT INTO `gen_table_column` VALUES (56, 6, 'id', '资源ID', 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26');
INSERT INTO `gen_table_column` VALUES (57, 6, 'course_id', '所属课程ID', 'bigint', 'Long', 'courseId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26');
INSERT INTO `gen_table_column` VALUES (58, 6, 'name', '资源名称', 'varchar(255)', 'String', 'name', '0', '0', '1', '1', '1', '1', '1', 'LIKE', 'input', '', 3, 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26');
INSERT INTO `gen_table_column` VALUES (59, 6, 'file_type', '文件类型，如pdf、doc、ppt等', 'varchar(50)', 'String', 'fileType', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'select', 'file_type', 4, 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26');
INSERT INTO `gen_table_column` VALUES (60, 6, 'file_size', '文件大小(字节)', 'bigint', 'Long', 'fileSize', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 5, 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26');
INSERT INTO `gen_table_column` VALUES (61, 6, 'file_url', '文件URL', 'varchar(500)', 'String', 'fileUrl', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'textarea', '', 6, 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26');
INSERT INTO `gen_table_column` VALUES (62, 6, 'description', '资源描述', 'varchar(500)', 'String', 'description', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'textarea', '', 7, 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26');
INSERT INTO `gen_table_column` VALUES (63, 6, 'download_count', '下载次数', 'int', 'Long', 'downloadCount', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 8, 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26');
INSERT INTO `gen_table_column` VALUES (64, 6, 'upload_user_id', '上传用户ID', 'bigint', 'Long', 'uploadUserId', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'input', '', 9, 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26');
INSERT INTO `gen_table_column` VALUES (65, 6, 'create_time', '创建时间', 'datetime', 'Date', 'createTime', '0', '0', '0', '1', NULL, NULL, NULL, 'EQ', 'datetime', '', 10, 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26');
INSERT INTO `gen_table_column` VALUES (66, 6, 'update_time', '更新时间', 'datetime', 'Date', 'updateTime', '0', '0', '0', '1', '1', NULL, NULL, 'EQ', 'datetime', '', 11, 'admin', '2025-11-18 10:20:26', '', '2025-11-18 13:34:26');
INSERT INTO `gen_table_column` VALUES (67, 7, 'id', '申请ID', 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-18 10:20:59', '', '2025-11-18 13:07:49');
INSERT INTO `gen_table_column` VALUES (68, 7, 'student_user_id', '学生 user.id', 'bigint', 'Long', 'studentUserId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-18 10:20:59', '', '2025-11-18 13:07:49');
INSERT INTO `gen_table_column` VALUES (69, 7, 'course_id', '申请加入的课程ID', 'bigint', 'Long', 'courseId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 3, 'admin', '2025-11-18 10:20:59', '', '2025-11-18 13:07:49');
INSERT INTO `gen_table_column` VALUES (70, 7, 'status', '申请状态：0=待审核 1=已通过 2=已拒绝', 'tinyint', 'Long', 'status', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'radio', 'enrollment_status', 4, 'admin', '2025-11-18 10:20:59', '', '2025-11-18 13:07:49');
INSERT INTO `gen_table_column` VALUES (71, 7, 'reason', '学生申请理由', 'text', 'String', 'reason', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'textarea', '', 5, 'admin', '2025-11-18 10:20:59', '', '2025-11-18 13:07:49');
INSERT INTO `gen_table_column` VALUES (72, 7, 'review_comment', '教师审核意见', 'text', 'String', 'reviewComment', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'textarea', '', 6, 'admin', '2025-11-18 10:20:59', '', '2025-11-18 13:07:49');
INSERT INTO `gen_table_column` VALUES (73, 7, 'submit_time', NULL, 'datetime', 'Date', 'submitTime', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'datetime', '', 7, 'admin', '2025-11-18 10:20:59', '', '2025-11-18 13:07:49');
INSERT INTO `gen_table_column` VALUES (74, 7, 'review_time', '审核时间', 'datetime', 'Date', 'reviewTime', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'datetime', '', 8, 'admin', '2025-11-18 10:20:59', '', '2025-11-18 13:07:49');
INSERT INTO `gen_table_column` VALUES (80, 9, 'id', NULL, 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-18 10:21:00', '', '2025-11-18 13:44:53');
INSERT INTO `gen_table_column` VALUES (81, 9, 'course_id', NULL, 'bigint', 'Long', 'courseId', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-18 10:21:00', '', '2025-11-18 13:44:53');
INSERT INTO `gen_table_column` VALUES (82, 9, 'student_user_id', '学生 user.id', 'bigint', 'Long', 'studentUserId', '0', '0', '0', '0', '0', '0', '0', 'EQ', 'input', '', 3, 'admin', '2025-11-18 10:21:00', '', '2025-11-18 13:44:53');
INSERT INTO `gen_table_column` VALUES (83, 9, 'enroll_time', NULL, 'datetime', 'Date', 'enrollTime', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'datetime', '', 4, 'admin', '2025-11-18 10:21:00', '', '2025-11-18 13:44:53');
INSERT INTO `gen_table_column` VALUES (84, 9, 'collected', '课程是否被该学生收藏，1为被收藏，0为未被收藏', 'int', 'Long', 'collected', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'radio', 'course_collected', 5, 'admin', '2025-11-18 10:21:00', '', '2025-11-18 13:44:53');
INSERT INTO `gen_table_column` VALUES (85, 9, 'is_deleted', NULL, 'tinyint(1)', 'Integer', 'isDeleted', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 6, 'admin', '2025-11-18 10:21:00', '', '2025-11-18 13:44:53');
INSERT INTO `gen_table_column` VALUES (86, 9, 'delete_time', NULL, 'datetime', 'Date', 'deleteTime', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'datetime', '', 7, 'admin', '2025-11-18 10:21:00', '', '2025-11-18 13:44:53');
INSERT INTO `gen_table_column` VALUES (87, 10, 'id', '行为ID', 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (88, 10, 'student_id', '学生ID', 'bigint', 'Long', 'studentId', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'input', '', 2, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (89, 10, 'video_id', '视频ID', 'bigint', 'Long', 'videoId', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'input', '', 3, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (90, 10, 'watch_duration', '观看时长（秒）', 'int', 'Long', 'watchDuration', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 4, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (91, 10, 'video_duration', '视频总时长（秒）', 'int', 'Long', 'videoDuration', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 5, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (92, 10, 'completion_rate', '完成率（%）', 'decimal(5,2)', 'BigDecimal', 'completionRate', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 6, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (93, 10, 'watch_count', '观看次数', 'int', 'Long', 'watchCount', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 7, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (94, 10, 'heatmap_data', '热力图数据', 'json', 'String', 'heatmapData', '0', '0', '0', '1', '1', '1', '0', 'EQ', NULL, '', 8, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (95, 10, 'is_completed', '是否看完：1-是 0-否', 'tinyint', 'Long', 'isCompleted', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'select', 'video_finished', 9, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (96, 10, 'fast_forward_count', '快进次数', 'int', 'Long', 'fastForwardCount', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 10, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (97, 10, 'pause_count', '暂停次数', 'int', 'Long', 'pauseCount', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 11, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (98, 10, 'playback_speed', '播放倍速', 'decimal(2,1)', 'BigDecimal', 'playbackSpeed', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'input', '', 12, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (99, 10, 'first_watch_at', '首次观看时间', 'timestamp', 'Date', 'firstWatchAt', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'datetime', '', 13, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (100, 10, 'last_watch_at', '最近观看时间', 'timestamp', 'Date', 'lastWatchAt', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'datetime', '', 14, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (101, 10, 'created_at', NULL, 'timestamp', 'Date', 'createdAt', '0', '0', '0', '1', '1', '0', '0', 'EQ', 'datetime', '', 15, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (102, 10, 'updated_at', NULL, 'timestamp', 'Date', 'updatedAt', '0', '0', '0', '1', '1', '0', '0', 'EQ', 'datetime', '', 16, 'admin', '2025-11-18 10:21:20', '', '2025-11-18 14:16:06');
INSERT INTO `gen_table_column` VALUES (118, 12, 'id', '知识图谱ID', 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (119, 12, 'title', '图谱标题', 'varchar(255)', 'String', 'title', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (120, 12, 'description', '图谱描述', 'text', 'String', 'description', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'textarea', '', 3, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (121, 12, 'course_id', '关联课程ID', 'bigint', 'Long', 'courseId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 4, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (122, 12, 'graph_type', '图谱类型：COURSE-课程图谱，CHAPTER-章节图谱', 'varchar(50)', 'String', 'graphType', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'select', '', 5, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (123, 12, 'graph_data', '图谱数据（JSON格式）', 'mediumtext', 'String', 'graphData', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'textarea', '', 6, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (124, 12, 'creator_id', '创建者ID', 'bigint', 'Long', 'creatorId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 7, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (125, 12, 'status', '状态：active-活跃，archived-归档', 'varchar(20)', 'String', 'status', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'radio', '', 8, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (126, 12, 'create_time', '创建时间', 'datetime', 'Date', 'createTime', '0', '0', '0', '1', NULL, NULL, NULL, 'EQ', 'datetime', '', 9, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (127, 12, 'update_time', '更新时间', 'datetime', 'Date', 'updateTime', '0', '0', '0', '1', '1', NULL, NULL, 'EQ', 'datetime', '', 10, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (128, 12, 'is_deleted', NULL, 'tinyint(1)', 'Integer', 'isDeleted', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 11, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (129, 12, 'delete_time', NULL, 'datetime', 'Date', 'deleteTime', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'datetime', '', 12, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 22:28:06');
INSERT INTO `gen_table_column` VALUES (130, 13, 'id', '记录ID', 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (131, 13, 'student_user_id', '学生user.id（关联user表）', 'bigint', 'Long', 'studentUserId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (132, 13, 'course_id', '所属课程ID（关联course表）', 'bigint', 'Long', 'courseId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 3, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (133, 13, 'kp_id', '知识点ID（关联knowledge_point表）', 'bigint', 'Long', 'kpId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 4, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (134, 13, 'correct_count', '答对次数', 'int', 'Long', 'correctCount', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 5, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (135, 13, 'total_count', '总答题次数', 'int', 'Long', 'totalCount', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 6, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (136, 13, 'accuracy', '正确率（自动计算）', 'decimal(5,2)', 'BigDecimal', 'accuracy', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 7, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (137, 13, 'last_test_score', '最近一次测试得分', 'decimal(5,2)', 'BigDecimal', 'lastTestScore', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 8, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (138, 13, 'last_test_time', '最近测试时间', 'timestamp', 'Date', 'lastTestTime', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'datetime', '', 9, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (139, 13, 'trend', '趋势', 'enum(\'improving\',\'stable\',\'declining\')', 'String', 'trend', '0', '0', '0', '1', '1', '1', '1', 'EQ', NULL, '', 10, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (140, 13, 'mastery_score', '掌握指标（0-100分）：按权重计算的综合得分', 'decimal(5,2)', 'BigDecimal', 'masteryScore', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 11, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (141, 13, 'mastery_status', '掌握状态：未学习/学习中/已掌握/薄弱点', 'enum(\'unlearned\',\'learning\',\'mastered\',\'weak\')', 'String', 'masteryStatus', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'radio', '', 12, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (142, 13, 'weight_factors', '权重因子明细：{\"exam_score\":0.4,\"video_behavior\":0.3,\"resource_behavior\":0.2,\"homework_score\":0.1}（可配置）', 'json', 'String', 'weightFactors', '0', '0', '0', '1', '1', '1', '1', 'EQ', NULL, '', 13, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (143, 13, 'last_updated_by', '最后更新来源：system/ai/job', 'varchar(50)', 'String', 'lastUpdatedBy', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 14, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (144, 13, 'create_time', '创建时间', 'datetime', 'Date', 'createTime', '0', '0', '0', '1', NULL, NULL, NULL, 'EQ', 'datetime', '', 15, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (145, 13, 'update_time', '最后计算更新时间', 'datetime', 'Date', 'updateTime', '0', '0', '0', '1', '1', NULL, NULL, 'EQ', 'datetime', '', 16, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (146, 13, 'is_deleted', '软删除标记', 'tinyint(1)', 'Integer', 'isDeleted', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 17, 'admin', '2025-11-21 21:07:30', '', '2025-11-21 21:43:30');
INSERT INTO `gen_table_column` VALUES (147, 14, 'id', NULL, 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (148, 14, 'title', '题干内容', 'text', 'String', 'title', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'textarea', '', 2, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (149, 14, 'question_type', '题型', 'enum(\'single\',\'multiple\',\'true_false\',\'blank\',\'short\',\'code\')', 'String', 'questionType', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'select', '', 3, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (150, 14, 'difficulty', '难度等级，1~5整数', 'tinyint', 'Long', 'difficulty', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 4, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (151, 14, 'correct_answer', '标准答案', 'text', 'String', 'correctAnswer', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'textarea', '', 5, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (152, 14, 'explanation', '答案解析', 'text', 'String', 'explanation', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'textarea', '', 6, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (153, 14, 'knowledge_point', '知识点', 'varchar(100)', 'String', 'knowledgePoint', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 7, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (154, 14, 'course_id', NULL, 'bigint', 'Long', 'courseId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 8, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (155, 14, 'chapter_id', NULL, 'bigint', 'Long', 'chapterId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 9, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (156, 14, 'created_by', '出题教师ID', 'bigint', 'Long', 'createdBy', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 10, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (157, 14, 'create_time', NULL, 'datetime', 'Date', 'createTime', '0', '0', '0', '1', NULL, NULL, NULL, 'EQ', 'datetime', '', 11, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (158, 14, 'update_time', NULL, 'datetime', 'Date', 'updateTime', '0', '0', '0', '1', '1', NULL, NULL, 'EQ', 'datetime', '', 12, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (159, 14, 'is_deleted', NULL, 'tinyint(1)', 'Integer', 'isDeleted', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 13, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (160, 14, 'delete_time', NULL, 'datetime', 'Date', 'deleteTime', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'datetime', '', 14, 'admin', '2025-11-21 21:07:56', '', NULL);
INSERT INTO `gen_table_column` VALUES (161, 15, 'id', NULL, 'bigint', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-21 21:12:10', '', '2025-11-21 21:13:20');
INSERT INTO `gen_table_column` VALUES (162, 15, 'course_id', '所属课程', 'bigint', 'Long', 'courseId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-21 21:12:10', '', '2025-11-21 21:13:20');
INSERT INTO `gen_table_column` VALUES (163, 15, 'title', '知识点名称（如“二分查找”）', 'varchar(200)', 'String', 'title', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 3, 'admin', '2025-11-21 21:12:10', '', '2025-11-21 21:13:20');
INSERT INTO `gen_table_column` VALUES (164, 15, 'description', '详细解释（AI生成）', 'text', 'String', 'description', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'textarea', '', 4, 'admin', '2025-11-21 21:12:10', '', '2025-11-21 21:13:20');
INSERT INTO `gen_table_column` VALUES (165, 15, 'level', '难度', 'enum(\'BASIC\',\'INTERMEDIATE\',\'ADVANCED\')', 'String', 'level', '0', '0', '0', '1', '1', '1', '1', 'EQ', NULL, '', 5, 'admin', '2025-11-21 21:12:10', '', '2025-11-21 21:13:20');
INSERT INTO `gen_table_column` VALUES (166, 15, 'creator_user_id', '创建者 user.id', 'bigint', 'Long', 'creatorUserId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 6, 'admin', '2025-11-21 21:12:10', '', '2025-11-21 21:13:20');
INSERT INTO `gen_table_column` VALUES (167, 15, 'create_time', NULL, 'datetime', 'Date', 'createTime', '0', '0', '0', '1', NULL, NULL, NULL, 'EQ', 'datetime', '', 7, 'admin', '2025-11-21 21:12:10', '', '2025-11-21 21:13:20');
INSERT INTO `gen_table_column` VALUES (168, 15, 'update_time', NULL, 'datetime', 'Date', 'updateTime', '0', '0', '0', '1', '1', NULL, NULL, 'EQ', 'datetime', '', 8, 'admin', '2025-11-21 21:12:10', '', '2025-11-21 21:13:20');
INSERT INTO `gen_table_column` VALUES (169, 15, 'is_deleted', NULL, 'tinyint(1)', 'Integer', 'isDeleted', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 9, 'admin', '2025-11-21 21:12:10', '', '2025-11-21 21:13:20');
INSERT INTO `gen_table_column` VALUES (170, 15, 'delete_time', NULL, 'datetime', 'Date', 'deleteTime', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'datetime', '', 10, 'admin', '2025-11-21 21:12:10', '', '2025-11-21 21:13:20');

-- ----------------------------
-- Table structure for knowledge_graph
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_graph`;
CREATE TABLE `knowledge_graph`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '知识图谱ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图谱标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '图谱描述',
  `course_id` bigint NOT NULL COMMENT '关联课程ID',
  `graph_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'COURSE' COMMENT '图谱类型：COURSE-课程图谱，CHAPTER-章节图谱',
  `graph_data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '图谱数据（JSON格式）',
  `creator_id` bigint NOT NULL COMMENT '创建者ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'active' COMMENT '状态：active-活跃，archived-归档',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_id`(`course_id` ASC) USING BTREE,
  INDEX `idx_creator_id`(`creator_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_knowledge_graph_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_knowledge_graph_creator` FOREIGN KEY (`creator_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识图谱表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of knowledge_graph
-- ----------------------------

-- ----------------------------
-- Table structure for knowledge_point
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_point`;
CREATE TABLE `knowledge_point`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL COMMENT '所属课程',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '知识点名称（如“二分查找”）',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '详细解释（AI生成）',
  `level` enum('BASIC','INTERMEDIATE','ADVANCED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'BASIC' COMMENT '难度',
  `creator_user_id` bigint NOT NULL COMMENT '创建者 user.id',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course`(`course_id` ASC) USING BTREE,
  INDEX `idx_creator`(`creator_user_id` ASC) USING BTREE,
  INDEX `idx_deleted`(`is_deleted` ASC) USING BTREE,
  CONSTRAINT `fk_kp_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_kp_creator` FOREIGN KEY (`creator_user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 64 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识点表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of knowledge_point
-- ----------------------------
INSERT INTO `knowledge_point` VALUES (21, 1, 'HTML基础', 'HTML基础知识', 'BASIC', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (22, 1, 'CSS基础', 'CSS基础知识', 'BASIC', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (23, 1, 'HTML标签', 'HTML常用标签', 'BASIC', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (24, 1, 'JavaScript基础', 'JavaScript基础语法', 'BASIC', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (25, 1, 'HTML5新特性', 'HTML5新增特性', 'INTERMEDIATE', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (26, 1, 'CSS盒模型', 'CSS盒模型概念', 'INTERMEDIATE', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (27, 1, 'DOM操作', 'DOM元素操作', 'INTERMEDIATE', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (28, 1, 'CSS属性', 'CSS样式属性', 'BASIC', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (29, 1, 'CSS选择器', 'CSS选择器类型', 'BASIC', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (30, 1, 'CSS布局', 'CSS布局技术', 'INTERMEDIATE', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (31, 1, 'HTTP协议', 'HTTP协议基础', 'INTERMEDIATE', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (32, 1, 'HTML表格', 'HTML表格使用', 'BASIC', 19, '2025-11-20 23:26:47', '2025-11-20 23:26:47', 0, NULL);
INSERT INTO `knowledge_point` VALUES (33, 2, 'JavaScript闭包', 'JavaScript闭包概念', 'ADVANCED', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (34, 2, 'DOM事件', 'DOM事件处理', 'INTERMEDIATE', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (35, 2, 'JavaScript原型', 'JavaScript原型链', 'ADVANCED', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (36, 2, 'JavaScript数据类型', 'JavaScript数据类型', 'BASIC', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (37, 2, 'JavaScript数组', 'JavaScript数组操作', 'INTERMEDIATE', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (38, 2, 'JavaScript基础', 'JavaScript基础语法', 'BASIC', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (39, 2, 'JavaScript循环', 'JavaScript循环语句', 'BASIC', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (40, 2, 'JavaScript变量', 'JavaScript变量声明', 'BASIC', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (41, 3, 'Vue.js基础', 'Vue.js框架基础', 'BASIC', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (42, 3, 'Vue数据绑定', 'Vue数据绑定机制', 'INTERMEDIATE', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (43, 3, 'Vue组件通信', 'Vue组件通信方式', 'INTERMEDIATE', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (44, 3, 'Vue指令', 'Vue内置指令', 'BASIC', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (45, 3, 'Vue生命周期', 'Vue生命周期钩子', 'INTERMEDIATE', 19, '2025-11-20 23:27:20', '2025-11-20 23:27:20', 0, NULL);
INSERT INTO `knowledge_point` VALUES (46, 4, 'React Hooks', 'React Hooks使用', 'INTERMEDIATE', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (47, 5, '前端工具链', '前端开发工具链', 'INTERMEDIATE', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (48, 6, '网络协议', '计算机网络协议', 'INTERMEDIATE', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (49, 6, 'API设计', 'RESTful API设计', 'INTERMEDIATE', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (50, 6, 'HTTP协议', 'HTTP协议原理', 'INTERMEDIATE', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (51, 6, 'HTTP状态码', 'HTTP状态码含义', 'BASIC', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (52, 6, 'RESTful API', 'RESTful API规范', 'INTERMEDIATE', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (53, 6, '跨域问题', '浏览器跨域解决', 'INTERMEDIATE', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (54, 6, 'HTTP方法', 'HTTP请求方法', 'BASIC', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (55, 7, '响应式设计', '响应式网页设计', 'INTERMEDIATE', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (56, 8, '性能优化', '前端性能优化', 'ADVANCED', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (57, 8, '前端路由', '前端路由实现', 'INTERMEDIATE', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (58, 8, '虚拟DOM', '虚拟DOM和diff算法', 'ADVANCED', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (59, 8, '状态管理', '前端状态管理', 'INTERMEDIATE', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (60, 8, '微前端', '微前端架构', 'ADVANCED', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (61, 8, '性能监控', '前端性能监控', 'ADVANCED', 19, '2025-11-20 23:28:11', '2025-11-20 23:28:11', 0, NULL);

-- ----------------------------
-- Table structure for kp_relation
-- ----------------------------
DROP TABLE IF EXISTS `kp_relation`;
CREATE TABLE `kp_relation`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `from_kp_id` bigint NOT NULL COMMENT '源知识点',
  `to_kp_id` bigint NOT NULL COMMENT '目标知识点',
  `relation_type` enum('prerequisite_of','similar_to','extension_of','derived_from','counterexample_of') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '纯知识点关系：前置/相似/进阶/推导/反例',
  `ai_generated` tinyint(1) NULL DEFAULT 1,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_relation`(`from_kp_id` ASC, `to_kp_id` ASC, `relation_type` ASC) USING BTREE,
  INDEX `idx_to`(`to_kp_id` ASC) USING BTREE,
  CONSTRAINT `fk_rel_from` FOREIGN KEY (`from_kp_id`) REFERENCES `knowledge_point` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_rel_to` FOREIGN KEY (`to_kp_id`) REFERENCES `knowledge_point` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识点关系表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of kp_relation
-- ----------------------------

-- ----------------------------
-- Table structure for learning_performance_relevance
-- ----------------------------
DROP TABLE IF EXISTS `learning_performance_relevance`;
CREATE TABLE `learning_performance_relevance`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `course_id` bigint NOT NULL COMMENT '课程ID',
  `behavior_id` bigint NOT NULL COMMENT '行为ID',
  `avg_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '平均成绩',
  `exam_count` int NULL DEFAULT 0 COMMENT '考试次数',
  `homework_count` int NULL DEFAULT 0 COMMENT '作业次数',
  `correlation_coefficient` decimal(5, 4) NULL DEFAULT NULL COMMENT '相关系数（-1到1）',
  `behavior_grade` enum('excellent','good','average','poor') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '行为评级',
  `stat_period` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '统计周期（如：2024-11）',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_student_course_period`(`student_id` ASC, `course_id` ASC, `stat_period` ASC) USING BTREE,
  INDEX `idx_student_id`(`student_id` ASC) USING BTREE,
  INDEX `idx_course_id`(`course_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学习行为与成绩关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of learning_performance_relevance
-- ----------------------------

-- ----------------------------
-- Table structure for personalized_recommendation
-- ----------------------------
DROP TABLE IF EXISTS `personalized_recommendation`;
CREATE TABLE `personalized_recommendation`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '推荐ID',
  `student_user_id` bigint NOT NULL COMMENT '学生user.id（关联user表）',
  `course_id` bigint NOT NULL COMMENT '所属课程ID（关联course表）',
  `recommend_type` enum('video','exercise','resource','kp_review') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '推荐类型：视频/专项练习/资源/知识点复习',
  `target_id` bigint NOT NULL COMMENT '推荐目标ID：视频→section.id，练习→assignment.id，资源→course_resource.id，知识点→kp_id',
  `recommend_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '推荐理由（AI生成，如“您在图神经网络知识点上表现较弱，建议重新学习第3.2节视频”）',
  `related_kp_ids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联的知识点ID（多个用逗号分隔，如“101,102”）',
  `status` enum('pending','viewed','completed','expired') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '推荐状态：待查看/已查看/已完成/已过期',
  `priority` tinyint NULL DEFAULT 3 COMMENT '推荐优先级（1-5，5最高）',
  `ai_model_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成推荐的AI模型版本（用于追溯）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '推荐生成时间',
  `expire_time` datetime NULL DEFAULT NULL COMMENT '推荐过期时间（如7天后过期）',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '状态更新时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '软删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_student_course`(`student_user_id` ASC, `course_id` ASC) USING BTREE,
  INDEX `idx_recommend_type_status`(`recommend_type` ASC, `status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  INDEX `fk_pr_course`(`course_id` ASC) USING BTREE,
  CONSTRAINT `fk_pr_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_pr_student` FOREIGN KEY (`student_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI个性化推荐记录表（存储学习建议）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of personalized_recommendation
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_blob_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_blob_triggers`;
CREATE TABLE `qrtz_blob_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `blob_data` blob NULL COMMENT '存放持久化Trigger对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_blob_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'Blob类型的触发器表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of qrtz_blob_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_calendars
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_calendars`;
CREATE TABLE `qrtz_calendars`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度名称',
  `calendar_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '日历名称',
  `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
  PRIMARY KEY (`sched_name`, `calendar_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '日历信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of qrtz_calendars
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_cron_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_cron_triggers`;
CREATE TABLE `qrtz_cron_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `cron_expression` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'cron表达式',
  `time_zone_id` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '时区',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_cron_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'Cron类型的触发器表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of qrtz_cron_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_fired_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_fired_triggers`;
CREATE TABLE `qrtz_fired_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度名称',
  `entry_id` varchar(95) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度器实例id',
  `trigger_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `instance_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度器实例名',
  `fired_time` bigint NOT NULL COMMENT '触发的时间',
  `sched_time` bigint NOT NULL COMMENT '定时器制定的时间',
  `priority` int NOT NULL COMMENT '优先级',
  `state` varchar(16) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '状态',
  `job_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '任务组名',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '是否并发',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '是否接受恢复执行',
  PRIMARY KEY (`sched_name`, `entry_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '已触发的触发器表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of qrtz_fired_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_job_details
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_job_details`;
CREATE TABLE `qrtz_job_details`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度名称',
  `job_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '任务组名',
  `description` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `job_class_name` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '执行任务类名称',
  `is_durable` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '是否持久化',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '是否并发',
  `is_update_data` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '是否更新数据',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '是否接受恢复执行',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '任务详细信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of qrtz_job_details
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_locks
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE `qrtz_locks`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度名称',
  `lock_name` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '悲观锁名称',
  PRIMARY KEY (`sched_name`, `lock_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '存储的悲观锁信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of qrtz_locks
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_paused_trigger_grps
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE `qrtz_paused_trigger_grps`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度名称',
  `trigger_group` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  PRIMARY KEY (`sched_name`, `trigger_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '暂停的触发器表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of qrtz_paused_trigger_grps
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_scheduler_state
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE `qrtz_scheduler_state`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度名称',
  `instance_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '实例名称',
  `last_checkin_time` bigint NOT NULL COMMENT '上次检查时间',
  `checkin_interval` bigint NOT NULL COMMENT '检查间隔时间',
  PRIMARY KEY (`sched_name`, `instance_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '调度器状态表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of qrtz_scheduler_state
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simple_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simple_triggers`;
CREATE TABLE `qrtz_simple_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `repeat_count` bigint NOT NULL COMMENT '重复的次数统计',
  `repeat_interval` bigint NOT NULL COMMENT '重复的间隔时间',
  `times_triggered` bigint NOT NULL COMMENT '已经触发的次数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simple_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '简单触发器的信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of qrtz_simple_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simprop_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
CREATE TABLE `qrtz_simprop_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `str_prop_1` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第一个参数',
  `str_prop_2` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第二个参数',
  `str_prop_3` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第三个参数',
  `int_prop_1` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第一个参数',
  `int_prop_2` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第二个参数',
  `long_prop_1` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第一个参数',
  `long_prop_2` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第二个参数',
  `dec_prop_1` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第一个参数',
  `dec_prop_2` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第二个参数',
  `bool_prop_1` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第一个参数',
  `bool_prop_2` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第二个参数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simprop_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '同步机制的行锁表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of qrtz_simprop_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_triggers`;
CREATE TABLE `qrtz_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '触发器的名字',
  `trigger_group` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '触发器所属组的名字',
  `job_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
  `job_group` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
  `description` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `next_fire_time` bigint NULL DEFAULT NULL COMMENT '上一次触发时间（毫秒）',
  `prev_fire_time` bigint NULL DEFAULT NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
  `priority` int NULL DEFAULT NULL COMMENT '优先级',
  `trigger_state` varchar(16) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '触发器状态',
  `trigger_type` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '触发器的类型',
  `start_time` bigint NOT NULL COMMENT '开始时间',
  `end_time` bigint NULL DEFAULT NULL COMMENT '结束时间',
  `calendar_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '日程表名称',
  `misfire_instr` smallint NULL DEFAULT NULL COMMENT '补偿执行的策略',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  INDEX `sched_name`(`sched_name` ASC, `job_name` ASC, `job_group` ASC) USING BTREE,
  CONSTRAINT `qrtz_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `qrtz_job_details` (`sched_name`, `job_name`, `job_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '触发器详细信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of qrtz_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for question
-- ----------------------------
DROP TABLE IF EXISTS `question`;
CREATE TABLE `question`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '题干内容',
  `question_type` enum('single','multiple','true_false','blank','short','code') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '题型',
  `difficulty` tinyint NOT NULL DEFAULT 3 COMMENT '难度等级，1~5整数',
  `correct_answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '标准答案',
  `explanation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '答案解析',
  `knowledge_point` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '知识点',
  `course_id` bigint NOT NULL,
  `chapter_id` bigint NOT NULL,
  `created_by` bigint NOT NULL COMMENT '出题教师ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  INDEX `chapter_id`(`chapter_id` ASC) USING BTREE,
  INDEX `question_ibfk_3`(`created_by` ASC) USING BTREE,
  CONSTRAINT `question_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `question_ibfk_2` FOREIGN KEY (`chapter_id`) REFERENCES `chapter` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `question_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 3071 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of question
-- ----------------------------
INSERT INTO `question` VALUES (1001, '什么是HTML？', 'short', 1, 'HTML是超文本标记语言（HyperText Markup Language）的缩写，是用于创建网页的标准标记语言。', 'HTML是网页开发的基础，用于定义网页的结构和内容。', 'HTML基础', 1, 1, 29, '2025-11-19 20:53:53', '2025-11-19 20:53:53', 0, NULL);
INSERT INTO `question` VALUES (1002, '请列举三种常见的HTML标签。', 'short', 1, '常见的HTML标签包括：<div>、<p>、<span>、<a>、<img>等。', '这些是最基础的HTML标签，用于构建网页结构。', 'HTML标签', 1, 1, 29, '2025-11-19 20:53:53', '2025-11-19 20:53:53', 0, NULL);
INSERT INTO `question` VALUES (1003, 'CSS的全称是什么？', 'short', 1, 'CSS的全称是层叠样式表（Cascading Style Sheets）。', 'CSS用于控制网页的样式和布局。', 'CSS基础', 1, 2, 29, '2025-11-19 20:53:53', '2025-11-19 20:53:53', 0, NULL);
INSERT INTO `question` VALUES (1004, '什么是JavaScript？', 'short', 2, 'JavaScript是一种高级的、解释型的编程语言，主要用于网页开发，可以实现网页的动态交互效果。', 'JavaScript是前端开发的核心技术之一。', 'JavaScript基础', 1, 3, 29, '2025-11-19 20:53:53', '2025-11-19 20:53:53', 0, NULL);
INSERT INTO `question` VALUES (1005, '请解释什么是DOM？', 'short', 2, 'DOM（Document Object Model，文档对象模型）是HTML和XML文档的编程接口，它将文档表示为节点树，允许程序动态访问和更新文档的内容、结构和样式。', 'DOM是JavaScript操作网页的基础。', 'DOM操作', 1, 3, 29, '2025-11-19 20:53:53', '2025-11-19 20:53:53', 0, NULL);
INSERT INTO `question` VALUES (1006, '请解释CSS盒模型的组成部分。', 'short', 3, 'CSS盒模型由四个部分组成：内容（content）、内边距（padding）、边框（border）和外边距（margin）。从内到外依次是：content → padding → border → margin。', '盒模型是CSS布局的基础概念。', 'CSS盒模型', 1, 2, 29, '2025-11-19 20:53:53', '2025-11-19 20:53:53', 0, NULL);
INSERT INTO `question` VALUES (1007, '什么是响应式设计？请简要说明其实现方法。', 'short', 3, '响应式设计是指网页能够根据不同设备的屏幕尺寸自动调整布局和样式。实现方法包括：使用媒体查询（@media）、弹性布局（flexbox）、网格布局（grid）、相对单位（%、em、rem、vw、vh）等。', '响应式设计是现代网页开发的重要技能。', '响应式设计', 7, 2, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1008, '请解释JavaScript中的闭包概念。', 'short', 3, '闭包是指函数能够访问其外部作用域中的变量，即使外部函数已经执行完毕。闭包由函数和其词法环境组成，可以用来创建私有变量、实现数据封装等。', '闭包是JavaScript的重要特性。', 'JavaScript闭包', 2, 3, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1009, '什么是事件冒泡和事件捕获？', 'short', 3, '事件冒泡是指事件从最具体的元素（目标元素）开始触发，然后向上传播到较不具体的元素。事件捕获则相反，从最不具体的元素开始，向下传播到目标元素。DOM事件流包括三个阶段：捕获阶段、目标阶段和冒泡阶段。', '理解事件流对于处理DOM事件很重要。', 'DOM事件', 2, 3, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1010, '请说明Vue.js中的数据双向绑定原理。', 'short', 3, 'Vue.js通过数据劫持结合发布-订阅模式实现双向绑定。Vue 2.x使用Object.defineProperty()劫持数据的getter和setter，当数据变化时通知订阅者更新视图；当视图变化时（如input输入）更新数据。Vue 3.x使用Proxy实现。', 'Vue的核心特性之一。', 'Vue数据绑定', 3, 4, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1011, '请解释JavaScript中的原型链和继承机制。', 'short', 4, 'JavaScript使用原型链实现继承。每个对象都有一个__proto__属性指向其原型对象，原型对象也有自己的原型，形成原型链。当访问对象的属性时，如果对象本身没有，会沿着原型链向上查找。继承方式包括：原型链继承、构造函数继承、组合继承、寄生组合继承、ES6的class继承等。', '原型链是JavaScript面向对象编程的基础。', 'JavaScript原型', 2, 3, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1012, '请说明HTTP和HTTPS的区别，以及HTTPS的工作原理。', 'short', 4, 'HTTP是明文传输，不安全；HTTPS在HTTP基础上加入SSL/TLS加密层，保证数据传输安全。HTTPS工作原理：1)客户端发起请求；2)服务器返回证书；3)客户端验证证书；4)协商加密算法和密钥；5)使用对称加密传输数据。HTTPS使用443端口，HTTP使用80端口。', '网络安全的重要知识点。', '网络协议', 6, 5, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1013, '请解释RESTful API的设计原则和最佳实践。', 'short', 4, 'RESTful API设计原则：1)使用HTTP方法（GET查询、POST创建、PUT更新、DELETE删除）；2)资源用名词表示，使用复数形式；3)使用HTTP状态码表示结果；4)版本控制；5)过滤、排序、分页；6)使用HTTPS；7)返回统一的数据格式（JSON）；8)提供清晰的错误信息。', 'API设计的标准规范。', 'API设计', 6, 5, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1014, '请说明浏览器的渲染流程和性能优化方法。', 'short', 4, '渲染流程：1)解析HTML生成DOM树；2)解析CSS生成CSSOM树；3)合并生成渲染树；4)布局计算元素位置；5)绘制像素到屏幕。优化方法：减少重排重绘、使用CSS3动画、图片懒加载、代码压缩、CDN加速、缓存策略、减少HTTP请求、异步加载JS等。', '前端性能优化的核心知识。', '性能优化', 8, 6, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1015, '请解释Vue组件间通信的几种方式。', 'short', 4, 'Vue组件通信方式：1)props/$emit（父子组件）；2)$parent/$children（父子组件）；3)provide/inject（跨级组件）；4)EventBus（兄弟组件）；5)Vuex（全局状态管理）；6)$attrs/$listeners（跨级组件）；7)ref（父组件访问子组件）。', 'Vue开发中的重要技能。', 'Vue组件通信', 3, 4, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1016, '请设计一个前端路由系统，说明Hash模式和History模式的实现原理及优缺点。', 'short', 5, 'Hash模式：通过监听hashchange事件，URL中#后的内容变化不会向服务器发送请求。优点：兼容性好，无需服务器配置。缺点：URL不美观，SEO不友好。History模式：使用HTML5 History API（pushState、replaceState），监听popstate事件。优点：URL美观，SEO友好。缺点：需要服务器配置，刷新可能404。实现：维护路由表，匹配路径渲染对应组件。', '前端路由是SPA应用的核心。', '前端路由', 8, 4, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1017, '请设计一个虚拟DOM的Diff算法，说明其优化策略。', 'short', 5, 'Diff算法策略：1)同层比较，不跨层级；2)不同类型节点直接替换；3)使用key标识节点，优化列表渲染。具体步骤：1)树级别比较；2)组件级别比较；3)元素级别比较。优化：双端比较算法、最长递增子序列。时间复杂度从O(n³)优化到O(n)。', '虚拟DOM是现代框架的核心技术。', '虚拟DOM', 8, 4, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1018, '请设计一个前端状态管理系统，说明Vuex/Redux的核心原理。', 'short', 5, '核心概念：单一数据源、状态只读、纯函数修改。Vuex：State（状态）、Getter（计算属性）、Mutation（同步修改）、Action（异步操作）、Module（模块化）。原理：通过Vue的响应式系统实现状态变化自动更新视图。Redux：Store、Action、Reducer。原理：发起Action → Reducer处理 → 更新Store → 触发订阅者。', '大型应用的状态管理方案。', '状态管理', 8, 4, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1019, '请设计一个前端微服务架构方案，说明微前端的实现方式。', 'short', 5, '微前端方案：1)iframe隔离；2)Web Components；3)模块联邦（Module Federation）；4)single-spa框架；5)qiankun框架。核心问题：应用隔离（JS、CSS）、通信机制、路由管理、公共依赖。实现要点：主应用负责路由和生命周期，子应用独立开发部署，通过约定的协议通信。', '大型前端项目的架构方案。', '微前端', 8, 6, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (1020, '请设计一个前端性能监控系统，说明关键指标和实现方案。', 'short', 5, '关键指标：FCP（首次内容绘制）、LCP（最大内容绘制）、FID（首次输入延迟）、CLS（累积布局偏移）、TTFB（首字节时间）。实现方案：1)使用Performance API收集数据；2)使用PerformanceObserver监听；3)上报到服务器；4)数据分析和可视化；5)告警机制。监控内容：页面加载、资源加载、接口请求、错误监控、用户行为。', '前端工程化的重要环节。', '性能监控', 8, 6, 29, '2025-11-19 20:53:53', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3001, 'HTML的全称是什么？', 'single', 1, 'A', 'HTML是HyperText Markup Language的缩写，是网页开发的基础标记语言。', 'HTML基础', 1, 1, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3002, '以下哪个标签用于创建超链接？', 'single', 1, 'B', '<a>标签用于创建超链接，href属性指定链接地址。', 'HTML标签', 1, 1, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3003, 'HTML5中新增的语义化标签是？', 'single', 2, 'C', '<header>、<footer>、<nav>、<article>等都是HTML5新增的语义化标签。', 'HTML5新特性', 1, 1, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3004, '以下哪个标签用于定义表格？', 'single', 1, 'D', '<table>标签用于定义HTML表格。', 'HTML表格', 1, 1, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3005, 'CSS的全称是什么？', 'single', 1, 'A', 'CSS是Cascading Style Sheets的缩写，用于控制网页样式。', 'CSS基础', 1, 2, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3006, '以下哪个CSS属性用于设置文字颜色？', 'single', 2, 'B', 'color属性用于设置文字颜色。', 'CSS属性', 1, 2, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3007, 'CSS中的盒模型包括哪些部分？', 'single', 3, 'C', 'CSS盒模型包括内容(content)、内边距(padding)、边框(border)和外边距(margin)。', 'CSS盒模型', 1, 2, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3008, '以下哪个选择器的优先级最高？', 'single', 3, 'D', 'ID选择器的优先级高于类选择器和标签选择器。', 'CSS选择器', 1, 2, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3009, 'JavaScript是一种什么类型的语言？', 'single', 2, 'A', 'JavaScript是一种解释型、动态类型的脚本语言。', 'JavaScript基础', 2, 3, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3010, '以下哪个关键字用于声明变量？', 'single', 2, 'B', 'var、let、const都可以用于声明变量，其中let和const是ES6新增的。', 'JavaScript变量', 2, 3, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3011, 'JavaScript中的数据类型不包括？', 'single', 3, 'C', 'JavaScript的基本数据类型包括：Number、String、Boolean、Undefined、Null、Symbol、BigInt。', 'JavaScript数据类型', 2, 3, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3012, '以下哪个方法用于向数组末尾添加元素？', 'single', 2, 'D', 'push()方法用于向数组末尾添加一个或多个元素。', 'JavaScript数组', 2, 3, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3013, 'Vue.js是由谁创建的？', 'single', 2, 'A', 'Vue.js是由尤雨溪（Evan You）创建的渐进式JavaScript框架。', 'Vue.js基础', 3, 4, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3014, 'React中用于管理组件状态的Hook是？', 'single', 3, 'B', 'useState是React中用于在函数组件中添加状态的Hook。', 'React Hooks', 4, 4, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3015, 'Vue中用于双向数据绑定的指令是？', 'single', 3, 'C', 'v-model指令用于在表单元素上创建双向数据绑定。', 'Vue指令', 3, 4, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3016, '以下哪个不是前端构建工具？', 'single', 3, 'D', 'MySQL是数据库管理系统，不是前端构建工具。Webpack、Vite、Rollup都是前端构建工具。', '前端工具链', 5, 4, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3017, 'HTTP协议默认使用的端口号是？', 'single', 2, 'A', 'HTTP协议默认使用80端口，HTTPS使用443端口。', 'HTTP协议', 6, 5, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3018, '以下哪个HTTP状态码表示\"未找到\"？', 'single', 2, 'B', '404状态码表示请求的资源未找到。', 'HTTP状态码', 6, 5, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3019, 'RESTful API中，用于更新资源的HTTP方法是？', 'single', 3, 'C', 'PUT方法用于更新资源，POST用于创建，GET用于获取，DELETE用于删除。', 'RESTful API', 6, 5, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3020, '以下哪个不是跨域解决方案？', 'single', 4, 'D', 'localStorage是浏览器本地存储，不是跨域解决方案。CORS、JSONP、代理服务器都可以解决跨域问题。', '跨域问题', 6, 5, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3021, '以下哪些是HTML5新增的语义化标签？（多选）', 'multiple', 2, 'A,B,C', 'HTML5新增了多个语义化标签，包括<header>、<footer>、<nav>、<article>、<section>等。', 'HTML5新特性', 1, 1, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3022, 'CSS中可以用来实现居中的方法有哪些？（多选）', 'multiple', 3, 'A,B,C,D', 'CSS实现居中的方法很多，包括flex布局、grid布局、margin: auto、绝对定位+transform等。', 'CSS布局', 1, 2, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3023, 'JavaScript中的循环语句包括哪些？（多选）', 'multiple', 2, 'A,B,C', 'JavaScript的循环语句包括for、while、do-while、for...in、for...of等。', 'JavaScript循环', 2, 3, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3024, '以下哪些是Vue的生命周期钩子？（多选）', 'multiple', 3, 'A,B,D', 'Vue的生命周期钩子包括created、mounted、updated、destroyed等。render不是生命周期钩子。', 'Vue生命周期', 3, 4, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3025, 'HTTP请求方法中，哪些是幂等的？（多选）', 'multiple', 4, 'A,C,D', 'GET、PUT、DELETE是幂等的，POST不是幂等的。幂等是指多次执行相同操作，结果相同。', 'HTTP方法', 6, 5, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3026, 'HTML是一种编程语言。', 'true_false', 1, 'B', 'HTML是标记语言，不是编程语言。编程语言具有逻辑控制、变量等特性。', 'HTML基础', 1, 1, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3027, 'CSS可以用来控制网页的布局和样式。', 'true_false', 1, 'A', 'CSS（层叠样式表）的主要作用就是控制网页的布局和样式。', 'CSS基础', 1, 2, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3028, 'JavaScript是一种静态类型语言。', 'true_false', 2, 'B', 'JavaScript是动态类型语言，变量的类型可以在运行时改变。', 'JavaScript基础', 1, 3, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3029, 'Vue.js是由Facebook开发的前端框架。', 'true_false', 2, 'B', 'Vue.js是由尤雨溪开发的，React才是Facebook开发的。', 'Vue.js基础', 3, 4, 29, '2025-11-20 10:51:26', '2025-11-20 12:12:32', 0, NULL);
INSERT INTO `question` VALUES (3030, 'HTTPS使用443端口作为默认端口。', 'true_false', 2, 'A', 'HTTPS协议默认使用443端口，HTTP使用80端口。', 'HTTP协议', 1, 5, 29, '2025-11-20 10:51:26', '2025-11-20 10:51:26', 0, NULL);
INSERT INTO `question` VALUES (3061, '求极限 lim_{x→0} (sin x) / x', 'short', 2, '1', '基本极限，可用 sin x ≈ x 或夹逼定理得到。', '求极限 lim_{x', 33, 1, 1, '2025-11-22 15:17:14', '2025-11-22 15:30:58', 0, NULL);
INSERT INTO `question` VALUES (3062, '求极限 lim_{x→0} (1 + x)^{1/x}', 'short', 2, 'e', '令 y=(1+x)^{1/x}, 对数化并用 ln(1+x)≈x 得 e。', '求极限 lim_{x', 33, 1, 1, '2025-11-22 15:17:14', '2025-11-22 15:30:58', 0, NULL);
INSERT INTO `question` VALUES (3063, '求极限 lim_{x→0} (cos x - 1) / x^2', 'short', 2, '-1/2', '用 cos x = 1 - x^2/2 + o(x^2)，因此极限为 -1/2。', '求极限 lim_{x', 33, 1, 1, '2025-11-22 15:17:14', '2025-11-22 15:30:58', 0, NULL);
INSERT INTO `question` VALUES (3064, '求极限 lim_{x→0} (e^{x} - 1 - x) / x^2', 'short', 2, '1/2', 'e^x 展开：1 + x + x^2/2 + …，分子主项为 x^2/2。', '求极限 lim_{x', 33, 1, 1, '2025-11-22 15:17:14', '2025-11-22 15:30:58', 0, NULL);
INSERT INTO `question` VALUES (3065, '求极限 lim_{x→∞} (1 + 1/x)^x', 'short', 2, 'e', '经典极限，极限为 e。', '求极限 lim_{x', 33, 1, 1, '2025-11-22 15:17:14', '2025-11-22 15:30:58', 0, NULL);
INSERT INTO `question` VALUES (3066, '求极限 lim_{x→0} (tan x - x) / x^3', 'short', 2, '1/3', 'tan x = x + x^3/3 + …，因此极限为 1/3。', '求极限 lim_{x', 33, 1, 1, '2025-11-22 15:17:14', '2025-11-22 15:30:58', 0, NULL);
INSERT INTO `question` VALUES (3067, '求极限 lim_{x→0} ( (1 + sin x)^{1/x} )', 'short', 2, 'e', 'ln 值为 (1/x) ln(1+sin x) ≈ (1/x) sin x ≈ 1，所以极限为 e。', '求极限 lim_{x', 33, 1, 1, '2025-11-22 15:17:14', '2025-11-22 15:30:58', 0, NULL);
INSERT INTO `question` VALUES (3068, '求极限 lim_{x→0^+} x^x', 'short', 2, '1', '写作 e^{x ln x}, x ln x → 0，极限为 1。', '求极限 lim_{x', 33, 1, 1, '2025-11-22 15:17:14', '2025-11-22 15:30:58', 0, NULL);
INSERT INTO `question` VALUES (3069, '求极限 lim_{x→0} ( (1 + ax)^{1/x} )（a 为常数）', 'short', 2, 'e^{a}', 'ln → a，故极限 e^{a}。', '求极限 lim_{x', 33, 1, 1, '2025-11-22 15:17:14', '2025-11-22 15:30:59', 0, NULL);
INSERT INTO `question` VALUES (3070, '求极限 lim_{x→0} (sin 3x) / (sin 2x)', 'short', 2, '3/2', '用 sin kx ≈ kx，得 3/2。', '求极限 lim_{x', 33, 1, 1, '2025-11-22 15:17:14', '2025-11-22 15:30:59', 0, NULL);

-- ----------------------------
-- Table structure for question_image
-- ----------------------------
DROP TABLE IF EXISTS `question_image`;
CREATE TABLE `question_image`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question_id` bigint NOT NULL,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片URL或路径',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片说明',
  `sequence` int NULL DEFAULT 1 COMMENT '图片显示顺序',
  `upload_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE,
  CONSTRAINT `question_image_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目图片表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of question_image
-- ----------------------------
INSERT INTO `question_image` VALUES (1, 3003, '/upload/questions/html5-semantic-tags.png', 'HTML5语义化标签示意图', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (2, 3004, '/upload/questions/html-table-structure.png', 'HTML表格结构示例', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (3, 3007, '/upload/questions/css-box-model.png', 'CSS盒模型示意图', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (4, 3022, '/upload/questions/css-centering-methods.png', 'CSS居中方法示例', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (5, 1006, '/upload/questions/css-box-model-detail.png', 'CSS盒模型详细说明', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (6, 1008, '/upload/questions/js-closure-example.png', 'JavaScript闭包示例代码', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (7, 1009, '/upload/questions/js-event-bubbling.png', '事件冒泡和捕获流程图', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (8, 1011, '/upload/questions/js-prototype-chain.png', 'JavaScript原型链示意图', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (9, 1010, '/upload/questions/vue-data-binding.png', 'Vue数据双向绑定原理图', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (10, 1015, '/upload/questions/vue-component-communication.png', 'Vue组件通信方式', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (11, 3024, '/upload/questions/vue-lifecycle.png', 'Vue生命周期钩子图', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (12, 1016, '/upload/questions/router-hash-history.png', '前端路由模式对比', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (13, 1017, '/upload/questions/virtual-dom-diff.png', '虚拟DOM Diff算法流程', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (14, 1018, '/upload/questions/vuex-flow.png', 'Vuex状态管理流程图', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (15, 1019, '/upload/questions/micro-frontend-architecture.png', '微前端架构示意图', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (16, 1020, '/upload/questions/performance-monitoring.png', '前端性能监控指标', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (17, 1012, '/upload/questions/https-workflow.png', 'HTTPS工作原理示意图', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (18, 1013, '/upload/questions/restful-api-design.png', 'RESTful API设计规范', 1, '2025-11-20 11:31:26');
INSERT INTO `question_image` VALUES (19, 1014, '/upload/questions/browser-rendering-process.png', '浏览器渲染流程图', 1, '2025-11-20 11:31:26');

-- ----------------------------
-- Table structure for question_option
-- ----------------------------
DROP TABLE IF EXISTS `question_option`;
CREATE TABLE `question_option`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question_id` bigint NOT NULL,
  `option_label` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '选项标识 A/B/C/D/T/F',
  `option_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '选项内容',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE,
  CONSTRAINT `question_option_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 188 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目选项表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of question_option
-- ----------------------------
INSERT INTO `question_option` VALUES (78, 3001, 'A', 'HyperText Markup Language');
INSERT INTO `question_option` VALUES (79, 3001, 'B', 'High Tech Modern Language');
INSERT INTO `question_option` VALUES (80, 3001, 'C', 'Home Tool Markup Language');
INSERT INTO `question_option` VALUES (81, 3001, 'D', 'Hyperlinks and Text Markup Language');
INSERT INTO `question_option` VALUES (82, 3002, 'A', '<link>');
INSERT INTO `question_option` VALUES (83, 3002, 'B', '<a>');
INSERT INTO `question_option` VALUES (84, 3002, 'C', '<href>');
INSERT INTO `question_option` VALUES (85, 3002, 'D', '<url>');
INSERT INTO `question_option` VALUES (86, 3003, 'A', '<div>');
INSERT INTO `question_option` VALUES (87, 3003, 'B', '<span>');
INSERT INTO `question_option` VALUES (88, 3003, 'C', '<header>');
INSERT INTO `question_option` VALUES (89, 3003, 'D', '<section>');
INSERT INTO `question_option` VALUES (90, 3004, 'A', '<tr>');
INSERT INTO `question_option` VALUES (91, 3004, 'B', '<td>');
INSERT INTO `question_option` VALUES (92, 3004, 'C', '<th>');
INSERT INTO `question_option` VALUES (93, 3004, 'D', '<table>');
INSERT INTO `question_option` VALUES (94, 3005, 'A', 'Cascading Style Sheets');
INSERT INTO `question_option` VALUES (95, 3005, 'B', 'Computer Style Sheets');
INSERT INTO `question_option` VALUES (96, 3005, 'C', 'Creative Style Sheets');
INSERT INTO `question_option` VALUES (97, 3005, 'D', 'Colorful Style Sheets');
INSERT INTO `question_option` VALUES (98, 3006, 'A', 'text-color');
INSERT INTO `question_option` VALUES (99, 3006, 'B', 'color');
INSERT INTO `question_option` VALUES (100, 3006, 'C', 'font-color');
INSERT INTO `question_option` VALUES (101, 3006, 'D', 'text-style');
INSERT INTO `question_option` VALUES (102, 3007, 'A', '内容、边框');
INSERT INTO `question_option` VALUES (103, 3007, 'B', '内容、内边距、边框');
INSERT INTO `question_option` VALUES (104, 3007, 'C', '内容、内边距、边框、外边距');
INSERT INTO `question_option` VALUES (105, 3007, 'D', '内容、外边距');
INSERT INTO `question_option` VALUES (106, 3008, 'A', '标签选择器');
INSERT INTO `question_option` VALUES (107, 3008, 'B', '类选择器');
INSERT INTO `question_option` VALUES (108, 3008, 'C', '伪类选择器');
INSERT INTO `question_option` VALUES (109, 3008, 'D', 'ID选择器');
INSERT INTO `question_option` VALUES (110, 3009, 'A', '解释型语言');
INSERT INTO `question_option` VALUES (111, 3009, 'B', '编译型语言');
INSERT INTO `question_option` VALUES (112, 3009, 'C', '汇编语言');
INSERT INTO `question_option` VALUES (113, 3009, 'D', '机器语言');
INSERT INTO `question_option` VALUES (114, 3010, 'A', 'var');
INSERT INTO `question_option` VALUES (115, 3010, 'B', 'let');
INSERT INTO `question_option` VALUES (116, 3010, 'C', 'const');
INSERT INTO `question_option` VALUES (117, 3010, 'D', '以上都可以');
INSERT INTO `question_option` VALUES (118, 3011, 'A', 'Number');
INSERT INTO `question_option` VALUES (119, 3011, 'B', 'String');
INSERT INTO `question_option` VALUES (120, 3011, 'C', 'Float');
INSERT INTO `question_option` VALUES (121, 3011, 'D', 'Boolean');
INSERT INTO `question_option` VALUES (122, 3012, 'A', 'pop()');
INSERT INTO `question_option` VALUES (123, 3012, 'B', 'shift()');
INSERT INTO `question_option` VALUES (124, 3012, 'C', 'unshift()');
INSERT INTO `question_option` VALUES (125, 3012, 'D', 'push()');
INSERT INTO `question_option` VALUES (126, 3013, 'A', '尤雨溪（Evan You）');
INSERT INTO `question_option` VALUES (127, 3013, 'B', 'Jordan Walke');
INSERT INTO `question_option` VALUES (128, 3013, 'C', 'Ryan Dahl');
INSERT INTO `question_option` VALUES (129, 3013, 'D', 'Brendan Eich');
INSERT INTO `question_option` VALUES (130, 3014, 'A', 'useEffect');
INSERT INTO `question_option` VALUES (131, 3014, 'B', 'useState');
INSERT INTO `question_option` VALUES (132, 3014, 'C', 'useContext');
INSERT INTO `question_option` VALUES (133, 3014, 'D', 'useReducer');
INSERT INTO `question_option` VALUES (134, 3015, 'A', 'v-bind');
INSERT INTO `question_option` VALUES (135, 3015, 'B', 'v-on');
INSERT INTO `question_option` VALUES (136, 3015, 'C', 'v-model');
INSERT INTO `question_option` VALUES (137, 3015, 'D', 'v-if');
INSERT INTO `question_option` VALUES (138, 3016, 'A', 'Webpack');
INSERT INTO `question_option` VALUES (139, 3016, 'B', 'Vite');
INSERT INTO `question_option` VALUES (140, 3016, 'C', 'Rollup');
INSERT INTO `question_option` VALUES (141, 3016, 'D', 'MySQL');
INSERT INTO `question_option` VALUES (142, 3017, 'A', '80');
INSERT INTO `question_option` VALUES (143, 3017, 'B', '443');
INSERT INTO `question_option` VALUES (144, 3017, 'C', '8080');
INSERT INTO `question_option` VALUES (145, 3017, 'D', '3306');
INSERT INTO `question_option` VALUES (146, 3018, 'A', '200');
INSERT INTO `question_option` VALUES (147, 3018, 'B', '404');
INSERT INTO `question_option` VALUES (148, 3018, 'C', '500');
INSERT INTO `question_option` VALUES (149, 3018, 'D', '403');
INSERT INTO `question_option` VALUES (150, 3019, 'A', 'GET');
INSERT INTO `question_option` VALUES (151, 3019, 'B', 'POST');
INSERT INTO `question_option` VALUES (152, 3019, 'C', 'PUT');
INSERT INTO `question_option` VALUES (153, 3019, 'D', 'DELETE');
INSERT INTO `question_option` VALUES (154, 3020, 'A', 'CORS');
INSERT INTO `question_option` VALUES (155, 3020, 'B', 'JSONP');
INSERT INTO `question_option` VALUES (156, 3020, 'C', '代理服务器');
INSERT INTO `question_option` VALUES (157, 3020, 'D', 'localStorage');
INSERT INTO `question_option` VALUES (158, 3021, 'A', '<header>');
INSERT INTO `question_option` VALUES (159, 3021, 'B', '<footer>');
INSERT INTO `question_option` VALUES (160, 3021, 'C', '<nav>');
INSERT INTO `question_option` VALUES (161, 3021, 'D', '<div>');
INSERT INTO `question_option` VALUES (162, 3022, 'A', 'display: flex; justify-content: center;');
INSERT INTO `question_option` VALUES (163, 3022, 'B', 'display: grid; place-items: center;');
INSERT INTO `question_option` VALUES (164, 3022, 'C', 'margin: 0 auto;');
INSERT INTO `question_option` VALUES (165, 3022, 'D', 'position: absolute; left: 50%; transform: translateX(-50%);');
INSERT INTO `question_option` VALUES (166, 3023, 'A', 'for');
INSERT INTO `question_option` VALUES (167, 3023, 'B', 'while');
INSERT INTO `question_option` VALUES (168, 3023, 'C', 'do-while');
INSERT INTO `question_option` VALUES (169, 3023, 'D', 'switch');
INSERT INTO `question_option` VALUES (170, 3024, 'A', 'created');
INSERT INTO `question_option` VALUES (171, 3024, 'B', 'mounted');
INSERT INTO `question_option` VALUES (172, 3024, 'C', 'render');
INSERT INTO `question_option` VALUES (173, 3024, 'D', 'destroyed');
INSERT INTO `question_option` VALUES (174, 3025, 'A', 'GET');
INSERT INTO `question_option` VALUES (175, 3025, 'B', 'POST');
INSERT INTO `question_option` VALUES (176, 3025, 'C', 'PUT');
INSERT INTO `question_option` VALUES (177, 3025, 'D', 'DELETE');
INSERT INTO `question_option` VALUES (178, 3026, 'A', '正确');
INSERT INTO `question_option` VALUES (179, 3026, 'B', '错误');
INSERT INTO `question_option` VALUES (180, 3027, 'A', '正确');
INSERT INTO `question_option` VALUES (181, 3027, 'B', '错误');
INSERT INTO `question_option` VALUES (182, 3028, 'A', '正确');
INSERT INTO `question_option` VALUES (183, 3028, 'B', '错误');
INSERT INTO `question_option` VALUES (184, 3029, 'A', '正确');
INSERT INTO `question_option` VALUES (185, 3029, 'B', '错误');
INSERT INTO `question_option` VALUES (186, 3030, 'A', '正确');
INSERT INTO `question_option` VALUES (187, 3030, 'B', '错误');

-- ----------------------------
-- Table structure for question_stats
-- ----------------------------
DROP TABLE IF EXISTS `question_stats`;
CREATE TABLE `question_stats`  (
  `question_id` bigint NOT NULL,
  `answer_count` int NULL DEFAULT 0 COMMENT '答题总数',
  `correct_count` int NULL DEFAULT 0 COMMENT '正确人数',
  `accuracy` decimal(5, 2) NULL DEFAULT 0.00 COMMENT '正确率（百分比）',
  PRIMARY KEY (`question_id`) USING BTREE,
  CONSTRAINT `question_stats_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目统计信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of question_stats
-- ----------------------------

-- ----------------------------
-- Table structure for section
-- ----------------------------
DROP TABLE IF EXISTS `section`;
CREATE TABLE `section`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '小节ID，主键',
  `chapter_id` bigint NOT NULL COMMENT '所属章节ID，外键',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '小节名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '小节简介',
  `video_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '视频播放地址，可对接OSS',
  `duration` int NULL DEFAULT 0 COMMENT '视频时长(秒)',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '小节顺序，用于排序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_chapter_id`(`chapter_id` ASC) USING BTREE,
  INDEX `idx_sort_order`(`sort_order` ASC) USING BTREE,
  INDEX `idx_deleted`(`is_deleted` ASC) USING BTREE,
  CONSTRAINT `fk_section_chapter` FOREIGN KEY (`chapter_id`) REFERENCES `chapter` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 73 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程小节表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of section
-- ----------------------------
INSERT INTO `section` VALUES (1, 10, '什么是极限', '初步了解', '/videos/1.mp4', 0, 0, '2025-11-19 20:22:44', '2025-11-20 23:17:54', 0, NULL);
INSERT INTO `section` VALUES (2, 10, '等价无穷小', '逐渐深入', '/videos/2.mp4', 0, 0, '2025-11-19 20:23:04', '2025-11-20 23:17:56', 0, NULL);
INSERT INTO `section` VALUES (3, 11, '什么是函数', '初步了解', '/videos/3.mp4', 0, 0, '2025-11-20 19:37:05', '2025-11-20 23:17:59', 0, NULL);
INSERT INTO `section` VALUES (4, 11, '函数的应用', '逐渐深入', '/videos/4.mp4', 0, 0, '2025-11-20 19:37:35', '2025-11-20 23:18:02', 0, NULL);

-- ----------------------------
-- Table structure for section_comment
-- ----------------------------
DROP TABLE IF EXISTS `section_comment`;
CREATE TABLE `section_comment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论ID，主键',
  `section_id` bigint NOT NULL COMMENT '所属小节ID，外键',
  `user_id` bigint NOT NULL COMMENT '评论人ID，外键',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论内容',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父评论ID，为NULL表示一级评论',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_section_id`(`section_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `fk_comment_parent` FOREIGN KEY (`parent_id`) REFERENCES `section_comment` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_comment_section` FOREIGN KEY (`section_id`) REFERENCES `section` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 83 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '小节评论表(讨论区)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of section_comment
-- ----------------------------
INSERT INTO `section_comment` VALUES (79, 1, 1, '1', NULL, '2025-11-19 21:48:52', '2025-11-19 21:48:52', 0, NULL);
INSERT INTO `section_comment` VALUES (80, 1, 1, '2', 79, '2025-11-19 21:48:58', '2025-11-19 21:48:58', 0, NULL);
INSERT INTO `section_comment` VALUES (81, 1, 1, '22', NULL, '2025-11-20 13:08:30', '2025-11-20 13:08:30', 0, NULL);
INSERT INTO `section_comment` VALUES (82, 2, 1, '老师讲的真好！我收获很大！', NULL, '2025-11-21 10:43:34', '2025-11-21 10:43:34', 0, NULL);

-- ----------------------------
-- Table structure for section_kp
-- ----------------------------
DROP TABLE IF EXISTS `section_kp`;
CREATE TABLE `section_kp`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `section_id` bigint NOT NULL COMMENT '小节ID',
  `kp_id` bigint NOT NULL COMMENT '知识点ID',
  `sequence` int NULL DEFAULT 1 COMMENT '在小节中的顺序',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_section_kp`(`section_id` ASC, `kp_id` ASC) USING BTREE,
  INDEX `idx_kp`(`kp_id` ASC) USING BTREE,
  CONSTRAINT `fk_sk_kp` FOREIGN KEY (`kp_id`) REFERENCES `knowledge_point` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_sk_section` FOREIGN KEY (`section_id`) REFERENCES `section` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '小节与知识点关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of section_kp
-- ----------------------------

-- ----------------------------
-- Table structure for student
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '学生ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `enrollment_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'ENROLLED' COMMENT '学籍状态',
  `gpa` decimal(3, 2) NULL DEFAULT NULL COMMENT 'GPA',
  `gpa_level` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'GPA等级',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_student_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 20250014 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '学生表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of student
-- ----------------------------

-- ----------------------------
-- Table structure for student_answer
-- ----------------------------
DROP TABLE IF EXISTS `student_answer`;
CREATE TABLE `student_answer`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_user_id` bigint NOT NULL COMMENT '学生 user.id',
  `assignment_id` bigint NOT NULL,
  `question_id` bigint NOT NULL,
  `answer_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '学生答案',
  `is_correct` tinyint(1) NULL DEFAULT NULL COMMENT '是否正确',
  `score` int NULL DEFAULT 0,
  `answer_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `student_id`(`student_user_id` ASC) USING BTREE,
  INDEX `assignment_id`(`assignment_id` ASC) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE,
  CONSTRAINT `fk_student_answer_user` FOREIGN KEY (`student_user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `student_answer_ibfk_2` FOREIGN KEY (`assignment_id`) REFERENCES `assignment` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `student_answer_ibfk_3` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学生答题记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of student_answer
-- ----------------------------

-- ----------------------------
-- Table structure for student_kp_mastery
-- ----------------------------
DROP TABLE IF EXISTS `student_kp_mastery`;
CREATE TABLE `student_kp_mastery`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `student_user_id` bigint NOT NULL COMMENT '学生user.id（关联user表）',
  `course_id` bigint NOT NULL COMMENT '所属课程ID（关联course表）',
  `kp_id` bigint NOT NULL COMMENT '知识点ID（关联knowledge_point表）',
  `correct_count` int NULL DEFAULT 0 COMMENT '答对次数',
  `total_count` int NULL DEFAULT 0 COMMENT '总答题次数',
  `accuracy` decimal(5, 2) NULL DEFAULT NULL COMMENT '正确率（自动计算）',
  `last_test_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '最近一次测试得分',
  `last_test_time` timestamp NULL DEFAULT NULL COMMENT '最近测试时间',
  `trend` enum('improving','stable','declining') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '趋势',
  `mastery_score` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT '掌握指标（0-100分）：按权重计算的综合得分',
  `mastery_status` enum('unlearned','learning','mastered','weak') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'unlearned' COMMENT '掌握状态：未学习/学习中/已掌握/薄弱点',
  `weight_factors` json NULL COMMENT '权重因子明细：{\"exam_score\":0.4,\"video_behavior\":0.3,\"resource_behavior\":0.2,\"homework_score\":0.1}（可配置）',
  `last_updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'system' COMMENT '最后更新来源：system/ai/job',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后计算更新时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '软删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_student_kp`(`student_user_id` ASC, `kp_id` ASC) USING BTREE COMMENT '确保每个学生-知识点记录唯一',
  INDEX `idx_course_kp`(`course_id` ASC, `kp_id` ASC) USING BTREE,
  INDEX `idx_mastery_status`(`mastery_status` ASC) USING BTREE,
  INDEX `fk_skm_kp`(`kp_id` ASC) USING BTREE,
  CONSTRAINT `fk_skm_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_skm_kp` FOREIGN KEY (`kp_id`) REFERENCES `knowledge_point` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_skm_student` FOREIGN KEY (`student_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学生知识点掌握情况表（支撑知识图谱状态标识）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of student_kp_mastery
-- ----------------------------

-- ----------------------------
-- Table structure for student_learning_behavior
-- ----------------------------
DROP TABLE IF EXISTS `student_learning_behavior`;
CREATE TABLE `student_learning_behavior`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '行为ID',
  `student_user_id` bigint NOT NULL COMMENT '学生user.id（关联user表）',
  `course_id` bigint NOT NULL COMMENT '所属课程ID（关联course表）',
  `behavior_type` enum('video_view','resource_view','resource_download','comment') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '行为类型：视频观看/资源查看/资源下载/评论',
  `target_id` bigint NOT NULL COMMENT '行为目标ID：视频→section.id，资源→course_resource.id，评论→section_comment.id',
  `target_type` enum('section','course_resource','section_comment') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '目标类型（与target_id对应）',
  `duration` int NULL DEFAULT 0 COMMENT '行为时长（秒）：视频观看/资源查看时长',
  `count` int NULL DEFAULT 1 COMMENT '行为次数：视频重复观看次数/资源重复查看次数',
  `detail` json NULL COMMENT '行为详情：视频→{\"start_time\":120,\"end_time\":300,\"is_replay\":1}（开始秒/结束秒/是否重复）；资源→{\"view_pages\":\"1-5\",\"is_bookmark\":0}（查看页数/是否收藏）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '行为发生时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '软删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_student_course`(`student_user_id` ASC, `course_id` ASC) USING BTREE,
  INDEX `idx_target`(`target_type` ASC, `target_id` ASC) USING BTREE,
  INDEX `idx_behavior_type`(`behavior_type` ASC) USING BTREE,
  INDEX `fk_sl_behavior_course`(`course_id` ASC) USING BTREE,
  CONSTRAINT `fk_sl_behavior_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_sl_behavior_student` FOREIGN KEY (`student_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学生学习行为记录表（视频/资源/互动行为）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of student_learning_behavior
-- ----------------------------

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '参数配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2025-11-18 16:54:30', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2025-11-18 16:54:30', '', NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2025-11-18 16:54:30', '', NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES (4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 'Y', 'admin', '2025-11-18 16:54:30', '', NULL, '是否开启验证码功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'true', 'Y', 'admin', '2025-11-18 16:54:30', '', NULL, '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2025-11-18 16:54:30', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
INSERT INTO `sys_config` VALUES (7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2025-11-18 16:54:30', '', NULL, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2025-11-18 16:54:30', '', NULL, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '部门名称',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 200 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (100, 0, '0', '若依科技', 0, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-11-18 16:54:29', '', NULL);
INSERT INTO `sys_dept` VALUES (101, 100, '0,100', '深圳总公司', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-11-18 16:54:29', '', NULL);
INSERT INTO `sys_dept` VALUES (102, 100, '0,100', '长沙分公司', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-11-18 16:54:29', '', NULL);
INSERT INTO `sys_dept` VALUES (103, 101, '0,100,101', '研发部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-11-18 16:54:29', '', NULL);
INSERT INTO `sys_dept` VALUES (104, 101, '0,100,101', '市场部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-11-18 16:54:29', '', NULL);
INSERT INTO `sys_dept` VALUES (105, 101, '0,100,101', '测试部门', 3, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-11-18 16:54:29', '', NULL);
INSERT INTO `sys_dept` VALUES (106, 101, '0,100,101', '财务部门', 4, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-11-18 16:54:29', '', NULL);
INSERT INTO `sys_dept` VALUES (107, 101, '0,100,101', '运维部门', 5, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-11-18 16:54:29', '', NULL);
INSERT INTO `sys_dept` VALUES (108, 102, '0,100,102', '市场部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-11-18 16:54:29', '', NULL);
INSERT INTO `sys_dept` VALUES (109, 102, '0,100,102', '财务部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2025-11-18 16:54:29', '', NULL);

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 116 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '字典数据表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '性别未知');
INSERT INTO `sys_dict_data` VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '显示菜单');
INSERT INTO `sys_dict_data` VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '默认分组');
INSERT INTO `sys_dict_data` VALUES (11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '系统分组');
INSERT INTO `sys_dict_data` VALUES (12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '系统默认是');
INSERT INTO `sys_dict_data` VALUES (13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '系统默认否');
INSERT INTO `sys_dict_data` VALUES (14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '通知');
INSERT INTO `sys_dict_data` VALUES (15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '公告');
INSERT INTO `sys_dict_data` VALUES (16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '关闭状态');
INSERT INTO `sys_dict_data` VALUES (18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '其他操作');
INSERT INTO `sys_dict_data` VALUES (19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '新增操作');
INSERT INTO `sys_dict_data` VALUES (20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '修改操作');
INSERT INTO `sys_dict_data` VALUES (21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '删除操作');
INSERT INTO `sys_dict_data` VALUES (22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '授权操作');
INSERT INTO `sys_dict_data` VALUES (23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '导出操作');
INSERT INTO `sys_dict_data` VALUES (24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '导入操作');
INSERT INTO `sys_dict_data` VALUES (25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '强退操作');
INSERT INTO `sys_dict_data` VALUES (26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '生成操作');
INSERT INTO `sys_dict_data` VALUES (27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '清空操作');
INSERT INTO `sys_dict_data` VALUES (28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2025-11-18 10:11:09', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (100, 0, '文科类', '0', 'course_type', NULL, 'default', 'N', '0', 'admin', '2025-11-18 11:52:17', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (101, 1, '理科类', '1', 'course_type', NULL, 'default', 'N', '0', 'admin', '2025-11-18 11:52:29', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (102, 2, '工科类', '2', 'course_type', NULL, 'default', 'N', '0', 'admin', '2025-11-18 11:52:40', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (103, 3, '艺术类', '3', 'course_type', NULL, 'default', 'N', '0', 'admin', '2025-11-18 11:52:54', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (104, 0, '进行中', '0', 'course_status', NULL, 'default', 'N', '0', 'admin', '2025-11-18 11:55:07', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (105, 1, '已结束', '1', 'course_status', NULL, 'default', 'N', '0', 'admin', '2025-11-18 11:55:14', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (106, 0, '待审核', '0', 'enrollment_status', NULL, 'default', 'N', '0', 'admin', '2025-11-18 13:05:20', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (107, 1, '已通过', '1', 'enrollment_status', NULL, 'default', 'N', '0', 'admin', '2025-11-18 13:05:28', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (108, 2, '已拒绝', '2', 'enrollment_status', NULL, 'default', 'N', '0', 'admin', '2025-11-18 13:05:35', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (109, 0, 'pdf', '0', 'file_type', NULL, 'default', 'N', '0', 'admin', '2025-11-18 13:18:52', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (110, 1, 'doc/docx', '1', 'file_type', NULL, 'default', 'N', '0', 'admin', '2025-11-18 13:19:07', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (111, 2, 'ppt', '2', 'file_type', NULL, 'default', 'N', '0', 'admin', '2025-11-18 13:19:13', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (112, 0, '未收藏', '0', 'course_collected', NULL, 'default', 'N', '0', 'admin', '2025-11-18 13:40:23', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (113, 1, '已收藏', '1', 'course_collected', NULL, 'default', 'N', '0', 'admin', '2025-11-18 13:40:31', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (114, 0, '未看完', '0', 'video_finished', NULL, 'default', 'N', '0', 'admin', '2025-11-18 14:15:03', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (115, 1, '已看完', '1', 'video_finished', NULL, 'default', 'N', '0', 'admin', '2025-11-18 14:15:09', '', NULL, NULL);

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 106 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '字典类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2025-11-18 16:54:30', '', NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2025-11-18 16:54:30', '', NULL, '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2025-11-18 16:54:30', '', NULL, '系统开关列表');
INSERT INTO `sys_dict_type` VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2025-11-18 16:54:30', '', NULL, '任务状态列表');
INSERT INTO `sys_dict_type` VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2025-11-18 16:54:30', '', NULL, '任务分组列表');
INSERT INTO `sys_dict_type` VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2025-11-18 16:54:30', '', NULL, '系统是否列表');
INSERT INTO `sys_dict_type` VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2025-11-18 16:54:30', '', NULL, '通知类型列表');
INSERT INTO `sys_dict_type` VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2025-11-18 16:54:30', '', NULL, '通知状态列表');
INSERT INTO `sys_dict_type` VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2025-11-18 16:54:30', '', NULL, '操作类型列表');
INSERT INTO `sys_dict_type` VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2025-11-18 16:54:30', '', NULL, '登录状态列表');
INSERT INTO `sys_dict_type` VALUES (100, '课程类型', 'course_type', '0', 'admin', '2025-11-18 11:51:35', '', NULL, NULL);
INSERT INTO `sys_dict_type` VALUES (101, '课程状态', 'course_status', '0', 'admin', '2025-11-18 11:54:49', '', NULL, NULL);
INSERT INTO `sys_dict_type` VALUES (102, '学生申请课程状态', 'enrollment_status', '0', 'admin', '2025-11-18 13:04:39', '', NULL, NULL);
INSERT INTO `sys_dict_type` VALUES (103, '文件类型', 'file_type', '0', 'admin', '2025-11-18 13:18:38', '', NULL, NULL);
INSERT INTO `sys_dict_type` VALUES (104, '课程收藏', 'course_collected', '0', 'admin', '2025-11-18 13:40:03', '', NULL, NULL);
INSERT INTO `sys_dict_type` VALUES (105, '视频是否看完', 'video_finished', '0', 'admin', '2025-11-18 14:14:51', '', NULL, NULL);

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS `sys_job`;
CREATE TABLE `sys_job`  (
  `job_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '定时任务调度表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_job
-- ----------------------------
INSERT INTO `sys_job` VALUES (1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2025-11-18 16:54:30', '', NULL, '');
INSERT INTO `sys_job` VALUES (2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(\'ry\')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2025-11-18 16:54:30', '', NULL, '');
INSERT INTO `sys_job` VALUES (3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2025-11-18 16:54:30', '', NULL, '');

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_job_log`;
CREATE TABLE `sys_job_log`  (
  `job_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '日志信息',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '异常信息',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '定时任务调度日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` bigint NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 194 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统访问记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------
INSERT INTO `sys_logininfor` VALUES (100, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-18 17:18:12');
INSERT INTO `sys_logininfor` VALUES (101, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2025-11-18 17:20:27');
INSERT INTO `sys_logininfor` VALUES (102, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '用户不存在/密码错误', '2025-11-18 17:20:37');
INSERT INTO `sys_logininfor` VALUES (103, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-18 17:21:23');
INSERT INTO `sys_logininfor` VALUES (104, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2025-11-18 17:21:46');
INSERT INTO `sys_logininfor` VALUES (105, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-18 17:21:59');
INSERT INTO `sys_logininfor` VALUES (106, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2025-11-18 17:22:54');
INSERT INTO `sys_logininfor` VALUES (107, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-18 17:23:05');
INSERT INTO `sys_logininfor` VALUES (108, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2025-11-18 17:23:58');
INSERT INTO `sys_logininfor` VALUES (109, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-18 17:24:02');
INSERT INTO `sys_logininfor` VALUES (110, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2025-11-18 17:24:33');
INSERT INTO `sys_logininfor` VALUES (111, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-18 17:24:45');
INSERT INTO `sys_logininfor` VALUES (112, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2025-11-18 17:50:46');
INSERT INTO `sys_logininfor` VALUES (113, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-18 17:50:50');
INSERT INTO `sys_logininfor` VALUES (114, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2025-11-18 17:54:34');
INSERT INTO `sys_logininfor` VALUES (115, 'test-student', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-18 17:54:50');
INSERT INTO `sys_logininfor` VALUES (116, 'test-student', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2025-11-18 18:06:36');
INSERT INTO `sys_logininfor` VALUES (117, 'admin', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '1', '验证码错误', '2025-11-18 18:16:36');
INSERT INTO `sys_logininfor` VALUES (118, 'admin', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '1', '验证码错误', '2025-11-18 18:16:39');
INSERT INTO `sys_logininfor` VALUES (119, 'admin', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 18:16:44');
INSERT INTO `sys_logininfor` VALUES (120, 'admin', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 18:17:55');
INSERT INTO `sys_logininfor` VALUES (121, 'admin', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 18:24:37');
INSERT INTO `sys_logininfor` VALUES (122, 'admin', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 18:24:50');
INSERT INTO `sys_logininfor` VALUES (123, 'admin', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 18:27:15');
INSERT INTO `sys_logininfor` VALUES (124, 'admin', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 18:27:56');
INSERT INTO `sys_logininfor` VALUES (125, '1234', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '注册成功', '2025-11-18 18:48:02');
INSERT INTO `sys_logininfor` VALUES (126, '1234', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '1', '用户不存在/密码错误', '2025-11-18 18:48:18');
INSERT INTO `sys_logininfor` VALUES (127, '1234', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 18:48:27');
INSERT INTO `sys_logininfor` VALUES (128, '1234', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 18:50:21');
INSERT INTO `sys_logininfor` VALUES (129, '1234', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 18:50:33');
INSERT INTO `sys_logininfor` VALUES (130, '1234', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 18:55:02');
INSERT INTO `sys_logininfor` VALUES (131, 'ljy', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '注册成功', '2025-11-18 18:55:17');
INSERT INTO `sys_logininfor` VALUES (132, 'ljy', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 18:55:34');
INSERT INTO `sys_logininfor` VALUES (133, 'admin', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 20:55:27');
INSERT INTO `sys_logininfor` VALUES (134, 'admin', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 21:05:26');
INSERT INTO `sys_logininfor` VALUES (135, '123', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '注册成功', '2025-11-18 21:05:42');
INSERT INTO `sys_logininfor` VALUES (136, '123aa', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '注册成功', '2025-11-18 21:06:13');
INSERT INTO `sys_logininfor` VALUES (137, '123aa', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '注册成功', '2025-11-18 21:07:49');
INSERT INTO `sys_logininfor` VALUES (138, '123aa', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '注册成功', '2025-11-18 21:08:35');
INSERT INTO `sys_logininfor` VALUES (139, 'wma', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '注册成功', '2025-11-18 21:10:26');
INSERT INTO `sys_logininfor` VALUES (140, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '注册成功', '2025-11-18 21:17:37');
INSERT INTO `sys_logininfor` VALUES (141, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 21:17:56');
INSERT INTO `sys_logininfor` VALUES (142, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 22:41:53');
INSERT INTO `sys_logininfor` VALUES (143, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 22:42:01');
INSERT INTO `sys_logininfor` VALUES (144, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '1', '验证码已失效', '2025-11-18 22:46:38');
INSERT INTO `sys_logininfor` VALUES (145, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 22:46:42');
INSERT INTO `sys_logininfor` VALUES (146, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 22:46:47');
INSERT INTO `sys_logininfor` VALUES (147, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 22:46:54');
INSERT INTO `sys_logininfor` VALUES (148, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 22:53:27');
INSERT INTO `sys_logininfor` VALUES (149, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 22:53:32');
INSERT INTO `sys_logininfor` VALUES (150, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 22:53:38');
INSERT INTO `sys_logininfor` VALUES (151, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '1', '身份验证失败：您选择的是教师登录，但您的账号角色是学生', '2025-11-18 22:54:11');
INSERT INTO `sys_logininfor` VALUES (152, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 22:54:16');
INSERT INTO `sys_logininfor` VALUES (153, 'qwhrei', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 22:54:40');
INSERT INTO `sys_logininfor` VALUES (154, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '1', '身份验证失败：您选择的是学生登录，但您的账号角色是教师', '2025-11-18 22:54:49');
INSERT INTO `sys_logininfor` VALUES (155, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 22:54:54');
INSERT INTO `sys_logininfor` VALUES (156, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-18 22:55:01');
INSERT INTO `sys_logininfor` VALUES (157, 'we', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '注册成功', '2025-11-18 22:55:20');
INSERT INTO `sys_logininfor` VALUES (158, 'we', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '1', '身份验证失败：您选择的是教师登录，但您的账号角色是学生', '2025-11-18 22:55:34');
INSERT INTO `sys_logininfor` VALUES (159, 'we', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-18 22:55:39');
INSERT INTO `sys_logininfor` VALUES (160, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-19 16:39:01');
INSERT INTO `sys_logininfor` VALUES (161, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-19 16:39:06');
INSERT INTO `sys_logininfor` VALUES (162, 'wangwu', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '1', '身份验证失败：您选择的是学生登录，但您的账号角色是教师', '2025-11-19 16:39:16');
INSERT INTO `sys_logininfor` VALUES (163, 'we', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '1', '身份验证失败：您选择的是教师登录，但您的账号角色是学生', '2025-11-19 16:39:24');
INSERT INTO `sys_logininfor` VALUES (164, 'we', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-19 16:39:30');
INSERT INTO `sys_logininfor` VALUES (165, 'we', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '退出成功', '2025-11-19 16:40:14');
INSERT INTO `sys_logininfor` VALUES (166, '123456', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '注册成功', '2025-11-19 16:40:36');
INSERT INTO `sys_logininfor` VALUES (167, '123456', '127.0.0.1', '内网IP', 'Chrome 12', 'Windows 10', '0', '登录成功', '2025-11-19 16:40:47');
INSERT INTO `sys_logininfor` VALUES (168, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-19 19:48:26');
INSERT INTO `sys_logininfor` VALUES (169, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-19 21:47:55');
INSERT INTO `sys_logininfor` VALUES (170, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-20 10:45:38');
INSERT INTO `sys_logininfor` VALUES (171, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '验证码已失效', '2025-11-20 14:20:42');
INSERT INTO `sys_logininfor` VALUES (172, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-20 14:20:45');
INSERT INTO `sys_logininfor` VALUES (173, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-20 17:50:14');
INSERT INTO `sys_logininfor` VALUES (174, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-20 23:22:05');
INSERT INTO `sys_logininfor` VALUES (175, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-21 09:26:45');
INSERT INTO `sys_logininfor` VALUES (176, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-21 10:29:07');
INSERT INTO `sys_logininfor` VALUES (177, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-21 12:16:42');
INSERT INTO `sys_logininfor` VALUES (178, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-21 12:59:30');
INSERT INTO `sys_logininfor` VALUES (179, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-21 15:09:34');
INSERT INTO `sys_logininfor` VALUES (180, 'admin', '127.0.0.1', '内网IP', 'Chrome 11', 'Windows 10', '0', '登录成功', '2025-11-21 15:14:50');
INSERT INTO `sys_logininfor` VALUES (181, 'admin', '127.0.0.1', '内网IP', 'Chrome 11', 'Windows 10', '0', '退出成功', '2025-11-21 15:30:29');
INSERT INTO `sys_logininfor` VALUES (182, 'admin', '127.0.0.1', '内网IP', 'Chrome 11', 'Windows 10', '0', '登录成功', '2025-11-21 15:30:39');
INSERT INTO `sys_logininfor` VALUES (183, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-21 15:47:03');
INSERT INTO `sys_logininfor` VALUES (184, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-21 20:48:30');
INSERT INTO `sys_logininfor` VALUES (185, 'admin', '127.0.0.1', '内网IP', 'Chrome 11', 'Windows 10', '0', '登录成功', '2025-11-21 22:10:29');
INSERT INTO `sys_logininfor` VALUES (186, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-22 02:10:58');
INSERT INTO `sys_logininfor` VALUES (187, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2025-11-22 02:38:05');
INSERT INTO `sys_logininfor` VALUES (188, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-22 02:38:18');
INSERT INTO `sys_logininfor` VALUES (189, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-22 03:18:49');
INSERT INTO `sys_logininfor` VALUES (190, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-22 14:37:49');
INSERT INTO `sys_logininfor` VALUES (191, 'admin', '127.0.0.1', '内网IP', 'Chrome 11', 'Windows 10', '0', '登录成功', '2025-11-22 16:02:06');
INSERT INTO `sys_logininfor` VALUES (192, 'admin', '127.0.0.1', '内网IP', 'Chrome 11', 'Windows 10', '0', '登录成功', '2025-11-22 18:39:48');
INSERT INTO `sys_logininfor` VALUES (193, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2025-11-22 18:42:37');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '路由名称',
  `is_frame` int NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2128 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜单权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '系统管理', 0, 1, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2025-11-18 10:11:08', '', NULL, '系统管理目录');
INSERT INTO `sys_menu` VALUES (2, '系统监控', 0, 2, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2025-11-18 10:11:08', '', NULL, '系统监控目录');
INSERT INTO `sys_menu` VALUES (3, '系统工具', 0, 3, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2025-11-18 10:11:08', '', NULL, '系统工具目录');
INSERT INTO `sys_menu` VALUES (4, '若依官网', 0, 4, 'http://ruoyi.vip', NULL, '', '', 0, 0, 'M', '0', '0', '', 'guide', 'admin', '2025-11-18 10:11:08', '', NULL, '若依官网地址');
INSERT INTO `sys_menu` VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2025-11-18 10:11:08', '', NULL, '用户管理菜单');
INSERT INTO `sys_menu` VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2025-11-18 10:11:08', '', NULL, '角色管理菜单');
INSERT INTO `sys_menu` VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2025-11-18 10:11:08', '', NULL, '菜单管理菜单');
INSERT INTO `sys_menu` VALUES (103, '部门管理', 1, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2025-11-18 10:11:08', '', NULL, '部门管理菜单');
INSERT INTO `sys_menu` VALUES (104, '岗位管理', 1, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2025-11-18 10:11:08', '', NULL, '岗位管理菜单');
INSERT INTO `sys_menu` VALUES (105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2025-11-18 10:11:08', '', NULL, '字典管理菜单');
INSERT INTO `sys_menu` VALUES (106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2025-11-18 10:11:08', '', NULL, '参数设置菜单');
INSERT INTO `sys_menu` VALUES (107, '通知公告', 1, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2025-11-18 10:11:08', '', NULL, '通知公告菜单');
INSERT INTO `sys_menu` VALUES (108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2025-11-18 10:11:08', '', NULL, '日志管理菜单');
INSERT INTO `sys_menu` VALUES (109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2025-11-18 10:11:08', '', NULL, '在线用户菜单');
INSERT INTO `sys_menu` VALUES (110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2025-11-18 10:11:08', '', NULL, '定时任务菜单');
INSERT INTO `sys_menu` VALUES (111, '数据监控', 2, 3, 'druid', 'monitor/druid/index', '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list', 'druid', 'admin', '2025-11-18 10:11:08', '', NULL, '数据监控菜单');
INSERT INTO `sys_menu` VALUES (112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2025-11-18 10:11:08', '', NULL, '服务监控菜单');
INSERT INTO `sys_menu` VALUES (113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', 'admin', '2025-11-18 10:11:08', '', NULL, '缓存监控菜单');
INSERT INTO `sys_menu` VALUES (114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', 'admin', '2025-11-18 10:11:08', '', NULL, '缓存列表菜单');
INSERT INTO `sys_menu` VALUES (115, '表单构建', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', 'admin', '2025-11-18 10:11:08', '', NULL, '表单构建菜单');
INSERT INTO `sys_menu` VALUES (116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2025-11-18 10:11:08', '', NULL, '代码生成菜单');
INSERT INTO `sys_menu` VALUES (117, '系统接口', 3, 3, 'swagger', 'tool/swagger/index', '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', 'admin', '2025-11-18 10:11:08', '', NULL, '系统接口菜单');
INSERT INTO `sys_menu` VALUES (500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', 'admin', '2025-11-18 10:11:08', '', NULL, '操作日志菜单');
INSERT INTO `sys_menu` VALUES (501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', 'admin', '2025-11-18 10:11:08', '', NULL, '登录日志菜单');
INSERT INTO `sys_menu` VALUES (1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1016, '部门查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1017, '部门新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1018, '部门修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1019, '部门删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1020, '岗位查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1021, '岗位新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1022, '岗位修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1023, '岗位删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1024, '岗位导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2025-11-18 10:11:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1055, '生成查询', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1056, '生成修改', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1057, '生成删除', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1058, '导入代码', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1059, '预览代码', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1060, '生成代码', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2025-11-18 10:11:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2000, '题目练习', 1, 1, 'courses', 'system/question/courses', NULL, '', 1, 0, 'C', '0', '0', 'system:question:list', 'education', 'admin', '2025-11-19 20:59:12', 'admin', '2025-11-21 12:25:00', '选择课程进入题目练习');
INSERT INTO `sys_menu` VALUES (2001, '题目查询', 2000, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:question:query', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2002, '题目新增', 2000, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:question:add', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2003, '题目修改', 2000, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:question:edit', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2004, '题目删除', 2000, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:question:remove', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2005, '题目导出', 2000, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:question:export', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2006, '课程', 1, 1, 'course', 'system/course/index', NULL, '', 1, 0, 'C', '0', '0', 'system:course:list', '#', 'admin', '2025-11-18 11:59:04', '', NULL, '课程菜单');
INSERT INTO `sys_menu` VALUES (2007, '课程查询', 2006, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:course:query', '#', 'admin', '2025-11-18 11:59:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2008, '课程新增', 2006, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:course:add', '#', 'admin', '2025-11-18 11:59:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2009, '课程修改', 2006, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:course:edit', '#', 'admin', '2025-11-18 11:59:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2010, '课程删除', 2006, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:course:remove', '#', 'admin', '2025-11-18 11:59:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2011, '课程导出', 2006, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:course:export', '#', 'admin', '2025-11-18 11:59:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2012, '选课申请', 1, 1, 'request', 'system/request/index', NULL, '', 1, 0, 'C', '0', '0', 'system:request:list', '#', 'admin', '2025-11-18 13:08:19', '', NULL, '选课申请菜单');
INSERT INTO `sys_menu` VALUES (2013, '选课申请查询', 2012, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:request:query', '#', 'admin', '2025-11-18 13:08:19', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2014, '选课申请新增', 2012, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:request:add', '#', 'admin', '2025-11-18 13:08:19', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2015, '选课申请修改', 2012, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:request:edit', '#', 'admin', '2025-11-18 13:08:19', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2016, '选课申请删除', 2012, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:request:remove', '#', 'admin', '2025-11-18 13:08:19', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2017, '选课申请导出', 2012, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:request:export', '#', 'admin', '2025-11-18 13:08:19', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2024, '课程资源', 0, 1, 'resource', 'system/resource/index', NULL, '', 1, 0, 'C', '0', '0', 'system:resource:list', 'search', 'admin', '2025-11-18 13:36:56', 'admin', '2025-11-21 15:51:36', '课程资源菜单');
INSERT INTO `sys_menu` VALUES (2025, '课程资源查询', 2024, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:resource:query', '#', 'admin', '2025-11-18 13:36:56', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2026, '课程资源新增', 2024, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:resource:add', '#', 'admin', '2025-11-18 13:36:56', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2027, '课程资源修改', 2024, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:resource:edit', '#', 'admin', '2025-11-18 13:36:56', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2028, '课程资源删除', 2024, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:resource:remove', '#', 'admin', '2025-11-18 13:36:56', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2029, '课程资源导出', 2024, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:resource:export', '#', 'admin', '2025-11-18 13:36:56', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2030, '我的课程', 1, 1, 'student', 'system/student/index', NULL, '', 1, 0, 'C', '0', '0', 'system:student:list', '#', 'admin', '2025-11-18 13:49:04', 'admin', '2025-11-18 15:54:39', '学生选课菜单');
INSERT INTO `sys_menu` VALUES (2031, '学生选课查询', 2030, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:student:query', '#', 'admin', '2025-11-18 13:49:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2032, '学生选课新增', 2030, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:student:add', '#', 'admin', '2025-11-18 13:49:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2033, '学生选课修改', 2030, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:student:edit', '#', 'admin', '2025-11-18 13:49:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2034, '学生选课删除', 2030, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:student:remove', '#', 'admin', '2025-11-18 13:49:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2035, '学生选课导出', 2030, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:student:export', '#', 'admin', '2025-11-18 13:49:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2036, '课程章节', 2030, 1, 'chapter', 'system/chapter/index', NULL, '', 1, 0, 'C', '0', '0', 'system:chapter:list', '#', 'admin', '2025-11-18 13:56:43', 'admin', '2025-11-18 16:13:12', '课程章节菜单');
INSERT INTO `sys_menu` VALUES (2037, '课程章节查询', 2036, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:chapter:query', '#', 'admin', '2025-11-18 13:56:43', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2038, '课程章节新增', 2036, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:chapter:add', '#', 'admin', '2025-11-18 13:56:43', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2039, '课程章节修改', 2036, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:chapter:edit', '#', 'admin', '2025-11-18 13:56:43', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2040, '课程章节删除', 2036, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:chapter:remove', '#', 'admin', '2025-11-18 13:56:43', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2041, '课程章节导出', 2036, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:chapter:export', '#', 'admin', '2025-11-18 13:56:43', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2042, '课程小节', 2036, 1, 'section', 'system/section/index', NULL, '', 1, 0, 'C', '0', '0', 'system:section:list', '#', 'admin', '2025-11-18 14:00:44', '', NULL, '课程小节菜单');
INSERT INTO `sys_menu` VALUES (2043, '课程小节查询', 2042, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:section:query', '#', 'admin', '2025-11-18 14:00:44', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2044, '课程小节新增', 2042, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:section:add', '#', 'admin', '2025-11-18 14:00:44', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2045, '课程小节修改', 2042, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:section:edit', '#', 'admin', '2025-11-18 14:00:44', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2046, '课程小节删除', 2042, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:section:remove', '#', 'admin', '2025-11-18 14:00:44', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2047, '课程小节导出', 2042, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:section:export', '#', 'admin', '2025-11-18 14:00:44', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2048, '小节评论(讨论区)', 2042, 1, 'comment', 'system/comment/index', NULL, '', 1, 0, 'C', '0', '0', 'system:comment:list', '#', 'admin', '2025-11-18 14:05:15', '', NULL, '小节评论(讨论区)菜单');
INSERT INTO `sys_menu` VALUES (2049, '小节评论(讨论区)查询', 2048, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:comment:query', '#', 'admin', '2025-11-18 14:05:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2050, '小节评论(讨论区)新增', 2048, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:comment:add', '#', 'admin', '2025-11-18 14:05:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2051, '小节评论(讨论区)修改', 2048, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:comment:edit', '#', 'admin', '2025-11-18 14:05:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2052, '小节评论(讨论区)删除', 2048, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:comment:remove', '#', 'admin', '2025-11-18 14:05:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2053, '小节评论(讨论区)导出', 2048, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:comment:export', '#', 'admin', '2025-11-18 14:05:15', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2060, '我的视频学习', 1, 1, 'behavior', 'system/behavior/index', NULL, '', 1, 0, 'C', '0', '0', 'system:behavior:list', '#', 'admin', '2025-11-18 14:17:40', 'admin', '2025-11-20 15:08:09', '视频学习行为菜单');
INSERT INTO `sys_menu` VALUES (2061, '视频学习行为查询', 2060, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:behavior:query', '#', 'admin', '2025-11-18 14:17:40', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2062, '视频学习行为新增', 2060, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:behavior:add', '#', 'admin', '2025-11-18 14:17:40', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2063, '视频学习行为修改', 2060, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:behavior:edit', '#', 'admin', '2025-11-18 14:17:40', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2064, '视频学习行为删除', 2060, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:behavior:remove', '#', 'admin', '2025-11-18 14:17:40', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2065, '视频学习行为导出', 2060, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:behavior:export', '#', 'admin', '2025-11-18 14:17:40', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2066, '视频', 2042, 1, 'video', 'system/video/index', NULL, '', 1, 0, 'C', '0', '0', 'system:video:list', '#', 'admin', '2025-11-20 19:10:50', 'admin', '2025-11-20 19:39:03', '视频菜单');
INSERT INTO `sys_menu` VALUES (2067, '视频查询', 2066, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:video:query', '#', 'admin', '2025-11-20 19:10:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2068, '视频新增', 2066, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:video:add', '#', 'admin', '2025-11-20 19:10:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2069, '视频修改', 2066, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:video:edit', '#', 'admin', '2025-11-20 19:10:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2070, '视频删除', 2066, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:video:remove', '#', 'admin', '2025-11-20 19:10:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2071, '视频导出', 2066, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:video:export', '#', 'admin', '2025-11-20 19:10:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2100, '作业考试', 1, 2, 'assignment', 'system/assignment/index', NULL, '', 1, 0, 'C', '0', '0', 'system:assignment:list', 'form', 'admin', '2025-11-19 20:59:12', 'admin', '2025-11-21 12:24:51', '作业考试菜单');
INSERT INTO `sys_menu` VALUES (2101, '作业查询', 2100, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:assignment:query', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2102, '作业新增', 2100, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:assignment:add', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2103, '作业修改', 2100, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:assignment:edit', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2104, '作业删除', 2100, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:assignment:remove', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2105, '作业导出', 2100, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:assignment:export', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2106, '作业提交', 2100, 6, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:assignment:submit', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2107, '题目练习', 2000, 2, 'practice', 'system/question/index', NULL, '', 1, 0, 'C', '1', '0', 'system:question:list', 'edit', 'admin', '2025-11-20 12:19:19', '', NULL, '课程题目练习页面（隐藏）');
INSERT INTO `sys_menu` VALUES (2108, '题目练习', 2000, 2, 'practice', 'system/question/index', NULL, '', 1, 0, 'C', '1', '0', 'system:question:list', 'edit', 'admin', '2025-11-20 12:54:52', '', NULL, '课程题目练习页面（隐藏）');
INSERT INTO `sys_menu` VALUES (2109, '题目答题', 2000, 6, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:question:answer', '#', 'admin', '2025-11-19 20:59:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2110, '知识点', 3, 1, 'point', 'system/point/index', NULL, '', 1, 0, 'C', '0', '0', 'system:point:list', '#', 'admin', '2025-11-21 21:20:07', '', NULL, '知识点菜单');
INSERT INTO `sys_menu` VALUES (2111, '知识点查询', 2110, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:point:query', '#', 'admin', '2025-11-21 21:20:07', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2112, '知识点新增', 2110, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:point:add', '#', 'admin', '2025-11-21 21:20:07', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2113, '知识点修改', 2110, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:point:edit', '#', 'admin', '2025-11-21 21:20:07', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2114, '知识点删除', 2110, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:point:remove', '#', 'admin', '2025-11-21 21:20:07', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2115, '知识点导出', 2110, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:point:export', '#', 'admin', '2025-11-21 21:20:07', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2116, '学生知识点掌握情况（支撑知识图谱状态标识）', 3, 1, 'mastery', 'system/mastery/index', NULL, '', 1, 0, 'C', '0', '0', 'system:mastery:list', '#', 'admin', '2025-11-21 21:48:25', '', NULL, '学生知识点掌握情况（支撑知识图谱状态标识）菜单');
INSERT INTO `sys_menu` VALUES (2117, '学生知识点掌握情况（支撑知识图谱状态标识）查询', 2116, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:mastery:query', '#', 'admin', '2025-11-21 21:48:25', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2118, '学生知识点掌握情况（支撑知识图谱状态标识）新增', 2116, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:mastery:add', '#', 'admin', '2025-11-21 21:48:25', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2119, '学生知识点掌握情况（支撑知识图谱状态标识）修改', 2116, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:mastery:edit', '#', 'admin', '2025-11-21 21:48:25', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2120, '学生知识点掌握情况（支撑知识图谱状态标识）删除', 2116, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:mastery:remove', '#', 'admin', '2025-11-21 21:48:25', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2121, '学生知识点掌握情况（支撑知识图谱状态标识）导出', 2116, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:mastery:export', '#', 'admin', '2025-11-21 21:48:25', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2122, '知识图谱', 3, 1, 'graph', 'system/graph/index', NULL, '', 1, 0, 'C', '0', '0', 'system:graph:list', '#', 'admin', '2025-11-21 22:39:56', '', NULL, '知识图谱菜单');
INSERT INTO `sys_menu` VALUES (2123, '知识图谱查询', 2122, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:graph:query', '#', 'admin', '2025-11-21 22:39:56', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2124, '知识图谱新增', 2122, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:graph:add', '#', 'admin', '2025-11-21 22:39:56', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2125, '知识图谱修改', 2122, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:graph:edit', '#', 'admin', '2025-11-21 22:39:56', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2126, '知识图谱删除', 2122, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:graph:remove', '#', 'admin', '2025-11-21 22:39:56', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2127, '知识图谱导出', 2122, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'system:graph:export', '#', 'admin', '2025-11-21 22:39:56', '', NULL, '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `notice_id` int NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob NULL COMMENT '公告内容',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '通知公告表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO `sys_notice` VALUES (1, '温馨提醒：2018-07-01 若依新版本发布啦', '2', 0xE696B0E78988E69CACE58685E5AEB9, '0', 'admin', '2025-11-18 16:54:30', '', NULL, '管理员');
INSERT INTO `sys_notice` VALUES (2, '维护通知：2018-07-01 若依系统凌晨维护', '1', 0xE7BBB4E68AA4E58685E5AEB9, '0', 'admin', '2025-11-18 16:54:30', '', NULL, '管理员');

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint NULL DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 283 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '操作日志记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (100, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"course,chapter,section_comment\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 10:19:15', 343);
INSERT INTO `sys_oper_log` VALUES (101, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"section,course_class\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 10:20:02', 92);
INSERT INTO `sys_oper_log` VALUES (102, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"course_resource\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 10:20:26', 39);
INSERT INTO `sys_oper_log` VALUES (103, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"course_enrollment_request,course_resource_kp,course_student\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 10:21:00', 163);
INSERT INTO `sys_oper_log` VALUES (104, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"video_learning_behavior\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 10:21:20', 47);
INSERT INTO `sys_oper_log` VALUES (105, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"video\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 10:23:50', 49);
INSERT INTO `sys_oper_log` VALUES (106, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"video\",\"className\":\"Video\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"视频ID\",\"columnId\":103,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"课程ID\",\"columnId\":104,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Title\",\"columnComment\":\"视频标题\",\"columnId\":105,\"columnName\":\"title\",\"columnType\":\"varchar(200)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"title\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Description\",\"columnComment\":\"视频描述\",\"columnId\":106,\"columnName\":\"description\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"textarea\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"0', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 10:45:37', 57);
INSERT INTO `sys_oper_log` VALUES (107, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"video\"}', NULL, 0, NULL, '2025-11-18 10:45:51', 621);
INSERT INTO `sys_oper_log` VALUES (108, '视频', 1, 'com.ruoyi.system.VideoController.add()', 'POST', 1, 'admin', '研发部门', '/system/video', '127.0.0.1', '内网IP', '{\"courseId\":1,\"coverImage\":\"/profile/upload/2025/11/18/8440142_20251118105728A001.jpg\",\"description\":\"fdg\",\"duration\":1,\"filePath\":\"21434d\",\"fileSize\":1,\"id\":1,\"params\":{},\"title\":\"dfg\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 10:57:49', 54);
INSERT INTO `sys_oper_log` VALUES (109, '视频', 5, 'com.ruoyi.system.VideoController.export()', 'POST', 1, 'admin', '研发部门', '/system/video/export', '127.0.0.1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\"}', NULL, 0, NULL, '2025-11-18 10:58:11', 1698);
INSERT INTO `sys_oper_log` VALUES (110, '视频', 3, 'com.ruoyi.system.VideoController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/video/1', '127.0.0.1', '内网IP', '[1]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 10:58:22', 18);
INSERT INTO `sys_oper_log` VALUES (111, '代码生成', 3, 'com.ruoyi.generator.controller.GenController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/gen/8', '127.0.0.1', '内网IP', '[8]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 11:23:53', 92);
INSERT INTO `sys_oper_log` VALUES (112, '字典类型', 1, 'com.ruoyi.web.controller.system.SysDictTypeController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/type', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"dictName\":\"课程类型\",\"dictType\":\"course_type\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 11:51:35', 23);
INSERT INTO `sys_oper_log` VALUES (113, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"文科类\",\"dictSort\":0,\"dictType\":\"course_type\",\"dictValue\":\"0\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 11:52:17', 14);
INSERT INTO `sys_oper_log` VALUES (114, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"理科类\",\"dictSort\":1,\"dictType\":\"course_type\",\"dictValue\":\"1\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 11:52:29', 9);
INSERT INTO `sys_oper_log` VALUES (115, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"工科类\",\"dictSort\":2,\"dictType\":\"course_type\",\"dictValue\":\"2\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 11:52:40', 15);
INSERT INTO `sys_oper_log` VALUES (116, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"艺术类\",\"dictSort\":3,\"dictType\":\"course_type\",\"dictValue\":\"3\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 11:52:54', 14);
INSERT INTO `sys_oper_log` VALUES (117, '字典类型', 9, 'com.ruoyi.web.controller.system.SysDictTypeController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/dict/type/refreshCache', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 11:53:38', 20);
INSERT INTO `sys_oper_log` VALUES (118, '字典类型', 1, 'com.ruoyi.web.controller.system.SysDictTypeController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/type', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"dictName\":\"课程状态\",\"dictType\":\"course_status\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 11:54:49', 17);
INSERT INTO `sys_oper_log` VALUES (119, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"进行中\",\"dictSort\":0,\"dictType\":\"course_status\",\"dictValue\":\"0\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 11:55:07', 10);
INSERT INTO `sys_oper_log` VALUES (120, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"已结束\",\"dictSort\":1,\"dictType\":\"course_status\",\"dictValue\":\"1\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 11:55:14', 11);
INSERT INTO `sys_oper_log` VALUES (121, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"course\",\"className\":\"Course\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"课程ID\",\"columnId\":10,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:15\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Title\",\"columnComment\":\"课程名称\",\"columnId\":11,\"columnName\":\"title\",\"columnType\":\"varchar(100)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:15\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"title\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Description\",\"columnComment\":\"课程描述\",\"columnId\":12,\"columnName\":\"description\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:15\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"textarea\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"1\",\"javaField\":\"description\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":2,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CoverImage\",\"columnComment\":\"课程封面图片\",\"columnId\":13,\"columnName\":\"cover_image\",\"columnType\":\"varchar(500)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:15\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"imageUpload\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"1\",\"ja', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 11:57:23', 61);
INSERT INTO `sys_oper_log` VALUES (122, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"course\"}', NULL, 0, NULL, '2025-11-18 11:57:28', 439);
INSERT INTO `sys_oper_log` VALUES (123, '字典类型', 1, 'com.ruoyi.web.controller.system.SysDictTypeController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/type', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"dictName\":\"学生申请课程状态\",\"dictType\":\"enrollment_status\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:04:39', 37);
INSERT INTO `sys_oper_log` VALUES (124, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"待审核\",\"dictSort\":0,\"dictType\":\"enrollment_status\",\"dictValue\":\"0\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:05:20', 17);
INSERT INTO `sys_oper_log` VALUES (125, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"已通过\",\"dictSort\":1,\"dictType\":\"enrollment_status\",\"dictValue\":\"1\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:05:28', 13);
INSERT INTO `sys_oper_log` VALUES (126, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"已拒绝\",\"dictSort\":2,\"dictType\":\"enrollment_status\",\"dictValue\":\"2\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:05:35', 16);
INSERT INTO `sys_oper_log` VALUES (127, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"request\",\"className\":\"CourseEnrollmentRequest\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"申请ID\",\"columnId\":67,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:59\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":7,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"StudentUserId\",\"columnComment\":\"学生 user.id\",\"columnId\":68,\"columnName\":\"student_user_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:59\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"studentUserId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":7,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"申请加入的课程ID\",\"columnId\":69,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:59\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":7,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Status\",\"columnComment\":\"申请状态：0=待审核 1=已通过 2=已拒绝\",\"columnId\":70,\"columnName\":\"status\",\"columnType\":\"tinyint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:59\",\"dictType\":\"enrollment_status\",\"edit\":true,\"htmlType\":\"radio\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:07:49', 128);
INSERT INTO `sys_oper_log` VALUES (128, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"course_enrollment_request\"}', NULL, 0, NULL, '2025-11-18 13:07:58', 505);
INSERT INTO `sys_oper_log` VALUES (129, '字典类型', 1, 'com.ruoyi.web.controller.system.SysDictTypeController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/type', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"dictName\":\"文件类型\",\"dictType\":\"file_type\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:18:38', 37);
INSERT INTO `sys_oper_log` VALUES (130, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"pdf\",\"dictSort\":0,\"dictType\":\"file_type\",\"dictValue\":\"0\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:18:52', 14);
INSERT INTO `sys_oper_log` VALUES (131, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"doc/docx\",\"dictSort\":1,\"dictType\":\"file_type\",\"dictValue\":\"1\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:19:07', 13);
INSERT INTO `sys_oper_log` VALUES (132, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"ppt\",\"dictSort\":2,\"dictType\":\"file_type\",\"dictValue\":\"2\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:19:14', 14);
INSERT INTO `sys_oper_log` VALUES (133, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"resource\",\"className\":\"CourseResource\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"资源ID\",\"columnId\":56,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":6,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"所属课程ID\",\"columnId\":57,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":6,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Name\",\"columnComment\":\"资源名称\",\"columnId\":58,\"columnName\":\"name\",\"columnType\":\"varchar(255)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"name\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"LIKE\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":6,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"FileType\",\"columnComment\":\"文件类型，如pdf、doc、ppt等\",\"columnId\":59,\"columnName\":\"file_type\",\"columnType\":\"varchar(50)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"file_type\",\"edit\":true,\"htmlType\":\"select\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequire', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:20:45', 74);
INSERT INTO `sys_oper_log` VALUES (134, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"course_resource\"}', NULL, 0, NULL, '2025-11-18 13:20:52', 112);
INSERT INTO `sys_oper_log` VALUES (135, '课程', 1, 'com.ruoyi.system.CourseController.add()', 'POST', 1, 'admin', '研发部门', '/system/course', '127.0.0.1', '内网IP', '{\"averageScore\":1,\"courseType\":\"0\",\"coverImage\":\"/profile/upload/2025/11/18/8440142_20251118132430A001.jpg\",\"createTime\":\"2025-11-18 13:24:44\",\"credit\":3,\"description\":\"www\",\"endTime\":\"2025-11-27\",\"params\":{},\"startTime\":\"2025-11-11\",\"status\":\"0\",\"studentCount\":1,\"teacherUserId\":1,\"term\":\"1\",\"title\":\"www\"}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Cannot add or update a child row: a foreign key constraint fails (`education_platform`.`course`, CONSTRAINT `fk_course_teacher_user` FOREIGN KEY (`teacher_user_id`) REFERENCES `user` (`id`))\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\CourseMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.CourseMapper.insertCourse-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into course          ( title,             description,             cover_image,             credit,             course_type,             start_time,             end_time,             teacher_user_id,             status,             term,             student_count,             average_score,             create_time )           values ( ?,             ?,             ?,             ?,             ?,             ?,             ?,             ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Cannot add or update a child row: a foreign key constraint fails (`education_platform`.`course`, CONSTRAINT `fk_course_teacher_user` FOREIGN KEY (`teacher_user_id`) REFERENCES `user` (`id`))\n; Cannot add or update a child row: a foreign key constraint fails (`education_platform`.`course`, CONSTRAINT `fk_course_teacher_user` FOREIGN KEY (`teacher_user_id`) REFERENCES `user` (`id`)); nested exception is java.sql.SQLIntegrityConstraintViolationException: Cannot add or update a child row: a foreign key constraint fails (`education_platform`.`course`, CONSTRAINT `fk_course_teacher_user` FOREIGN KEY (`teacher_user_id`) REFERENCES `user` (`id`))', '2025-11-18 13:24:44', 197);
INSERT INTO `sys_oper_log` VALUES (136, '课程', 1, 'com.ruoyi.system.CourseController.add()', 'POST', 1, 'admin', '研发部门', '/system/course', '127.0.0.1', '内网IP', '{\"averageScore\":1,\"courseType\":\"0\",\"coverImage\":\"/profile/upload/2025/11/18/8440142_20251118132430A001.jpg\",\"createTime\":\"2025-11-18 13:26:39\",\"credit\":3,\"description\":\"www\",\"endTime\":\"2025-11-27\",\"id\":31,\"params\":{},\"startTime\":\"2025-11-11\",\"status\":\"0\",\"studentCount\":1,\"teacherUserId\":1,\"term\":\"1\",\"title\":\"www\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:26:39', 14);
INSERT INTO `sys_oper_log` VALUES (137, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"resource\",\"className\":\"CourseResource\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"资源ID\",\"columnId\":56,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":6,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 13:20:45\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"所属课程ID\",\"columnId\":57,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":6,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 13:20:45\",\"usableColumn\":false},{\"capJavaField\":\"Name\",\"columnComment\":\"资源名称\",\"columnId\":58,\"columnName\":\"name\",\"columnType\":\"varchar(255)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"name\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"LIKE\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":6,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 13:20:45\",\"usableColumn\":false},{\"capJavaField\":\"FileType\",\"columnComment\":\"文件类型，如pdf、doc、ppt等\",\"columnId\":59,\"columnName\":\"file_type\",\"columnType\":\"varchar(50)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"file_type\",\"edit\":true,\"htmlType\":\"select\",\"increment\":false,\"in', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:27:59', 171);
INSERT INTO `sys_oper_log` VALUES (138, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.synchDb()', 'GET', 1, 'admin', '研发部门', '/tool/gen/synchDb/course_resource', '127.0.0.1', '内网IP', '{}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:28:14', 102);
INSERT INTO `sys_oper_log` VALUES (139, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"resource\",\"className\":\"CourseResource\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"资源ID\",\"columnId\":56,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":6,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 13:28:14\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"所属课程ID\",\"columnId\":57,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":6,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 13:28:14\",\"usableColumn\":false},{\"capJavaField\":\"Name\",\"columnComment\":\"资源名称\",\"columnId\":58,\"columnName\":\"name\",\"columnType\":\"varchar(255)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"name\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"LIKE\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":6,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 13:28:14\",\"usableColumn\":false},{\"capJavaField\":\"FileType\",\"columnComment\":\"文件类型，如pdf、doc、ppt等\",\"columnId\":59,\"columnName\":\"file_type\",\"columnType\":\"varchar(50)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:26\",\"dictType\":\"file_type\",\"edit\":true,\"htmlType\":\"select\",\"increment\":false,\"in', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:34:26', 28);
INSERT INTO `sys_oper_log` VALUES (140, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"course_resource\"}', NULL, 0, NULL, '2025-11-18 13:34:32', 192);
INSERT INTO `sys_oper_log` VALUES (141, '字典类型', 1, 'com.ruoyi.web.controller.system.SysDictTypeController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/type', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"dictName\":\"课程收藏\",\"dictType\":\"course_collected\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:40:03', 14);
INSERT INTO `sys_oper_log` VALUES (142, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"未收藏\",\"dictSort\":0,\"dictType\":\"course_collected\",\"dictValue\":\"0\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:40:23', 18);
INSERT INTO `sys_oper_log` VALUES (143, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"已收藏\",\"dictSort\":1,\"dictType\":\"course_collected\",\"dictValue\":\"1\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:40:31', 11);
INSERT INTO `sys_oper_log` VALUES (144, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"student\",\"className\":\"CourseStudent\",\"columns\":[{\"capJavaField\":\"Id\",\"columnId\":80,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:00\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":9,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnId\":81,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:00\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":9,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"StudentUserId\",\"columnComment\":\"学生 user.id\",\"columnId\":82,\"columnName\":\"student_user_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:00\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":false,\"insert\":false,\"isEdit\":\"0\",\"isIncrement\":\"0\",\"isInsert\":\"0\",\"isList\":\"0\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"0\",\"javaField\":\"studentUserId\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":3,\"superColumn\":false,\"tableId\":9,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"EnrollTime\",\"columnId\":83,\"columnName\":\"enroll_time\",\"columnType\":\"datetime\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:00\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"datetime\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"0\",\"javaField\":\"enrollTime\",\"javaType\":\"Date\",\"list\":true,\"', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:43:12', 47);
INSERT INTO `sys_oper_log` VALUES (145, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"student\",\"className\":\"CourseStudent\",\"columns\":[{\"capJavaField\":\"Id\",\"columnId\":80,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:00\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":9,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 13:43:12\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnId\":81,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:00\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"0\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":false,\"sort\":2,\"superColumn\":false,\"tableId\":9,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 13:43:12\",\"usableColumn\":false},{\"capJavaField\":\"StudentUserId\",\"columnComment\":\"学生 user.id\",\"columnId\":82,\"columnName\":\"student_user_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:00\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":false,\"insert\":false,\"isEdit\":\"0\",\"isIncrement\":\"0\",\"isInsert\":\"0\",\"isList\":\"0\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"0\",\"javaField\":\"studentUserId\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":3,\"superColumn\":false,\"tableId\":9,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 13:43:12\",\"usableColumn\":false},{\"capJavaField\":\"EnrollTime\",\"columnId\":83,\"columnName\":\"enroll_time\",\"columnType\":\"datetime\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:00\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"datetime\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isLi', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:44:53', 37);
INSERT INTO `sys_oper_log` VALUES (146, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"course_student\"}', NULL, 0, NULL, '2025-11-18 13:44:58', 58);
INSERT INTO `sys_oper_log` VALUES (147, '代码生成', 3, 'com.ruoyi.generator.controller.GenController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/gen/4', '127.0.0.1', '内网IP', '[4]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:51:28', 67);
INSERT INTO `sys_oper_log` VALUES (148, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"chapter\",\"className\":\"Chapter\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"章节ID，主键\",\"columnId\":1,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:14\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":1,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"所属课程ID，外键\",\"columnId\":2,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:14\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":1,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Title\",\"columnComment\":\"章节名称\",\"columnId\":3,\"columnName\":\"title\",\"columnType\":\"varchar(255)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:14\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"title\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":1,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Description\",\"columnId\":4,\"columnName\":\"description\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:15\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"textarea\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"0\",\"javaField\":\"description\",\"javaType\":\"String', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:54:49', 118);
INSERT INTO `sys_oper_log` VALUES (149, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"chapter\"}', NULL, 0, NULL, '2025-11-18 13:55:10', 116);
INSERT INTO `sys_oper_log` VALUES (150, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"section\",\"className\":\"Section\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"小节ID，主键\",\"columnId\":45,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:02\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":5,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"ChapterId\",\"columnComment\":\"所属章节ID，外键\",\"columnId\":46,\"columnName\":\"chapter_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:02\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"chapterId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":5,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Title\",\"columnComment\":\"小节名称\",\"columnId\":47,\"columnName\":\"title\",\"columnType\":\"varchar(255)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:02\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"title\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":5,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Description\",\"columnComment\":\"小节简介\",\"columnId\":48,\"columnName\":\"description\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:20:02\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"textarea\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"0\",\"javaField\":\"d', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 13:59:09', 65);
INSERT INTO `sys_oper_log` VALUES (151, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"section\"}', NULL, 0, NULL, '2025-11-18 13:59:15', 188);
INSERT INTO `sys_oper_log` VALUES (152, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"comment\",\"className\":\"SectionComment\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"评论ID，主键\",\"columnId\":27,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:15\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":3,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"SectionId\",\"columnComment\":\"所属小节ID，外键\",\"columnId\":28,\"columnName\":\"section_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:15\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"sectionId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":3,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"UserId\",\"columnComment\":\"评论人ID，外键\",\"columnId\":29,\"columnName\":\"user_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:15\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"1\",\"javaField\":\"userId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":3,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Content\",\"columnComment\":\"评论内容\",\"columnId\":30,\"columnName\":\"content\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:19:15\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"editor\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"1\",\"javaField\":\"con', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 14:03:27', 166);
INSERT INTO `sys_oper_log` VALUES (153, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"section_comment\"}', NULL, 0, NULL, '2025-11-18 14:03:50', 474);
INSERT INTO `sys_oper_log` VALUES (154, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"video\",\"className\":\"Video\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"视频ID\",\"columnId\":103,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 10:45:37\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"课程ID\",\"columnId\":104,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 10:45:37\",\"usableColumn\":false},{\"capJavaField\":\"Title\",\"columnComment\":\"视频标题\",\"columnId\":105,\"columnName\":\"title\",\"columnType\":\"varchar(200)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"title\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 10:45:37\",\"usableColumn\":false},{\"capJavaField\":\"Description\",\"columnComment\":\"视频描述\",\"columnId\":106,\"columnName\":\"description\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"textarea\",\"increment\":false,\"insert\"', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 14:08:12', 121);
INSERT INTO `sys_oper_log` VALUES (155, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"video\"}', NULL, 0, NULL, '2025-11-18 14:08:16', 252);
INSERT INTO `sys_oper_log` VALUES (156, '字典类型', 1, 'com.ruoyi.web.controller.system.SysDictTypeController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/type', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"dictName\":\"视频是否看完\",\"dictType\":\"video_finished\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 14:14:51', 37);
INSERT INTO `sys_oper_log` VALUES (157, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"未看完\",\"dictSort\":0,\"dictType\":\"video_finished\",\"dictValue\":\"0\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 14:15:03', 15);
INSERT INTO `sys_oper_log` VALUES (158, '字典数据', 1, 'com.ruoyi.web.controller.system.SysDictDataController.add()', 'POST', 1, 'admin', '研发部门', '/system/dict/data', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"default\":false,\"dictLabel\":\"已看完\",\"dictSort\":1,\"dictType\":\"video_finished\",\"dictValue\":\"1\",\"listClass\":\"default\",\"params\":{},\"status\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 14:15:09', 12);
INSERT INTO `sys_oper_log` VALUES (159, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"behavior\",\"className\":\"VideoLearningBehavior\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"行为ID\",\"columnId\":87,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:20\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":10,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"StudentId\",\"columnComment\":\"学生ID\",\"columnId\":88,\"columnName\":\"student_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:20\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"1\",\"javaField\":\"studentId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":10,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"VideoId\",\"columnComment\":\"视频ID\",\"columnId\":89,\"columnName\":\"video_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:20\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"1\",\"javaField\":\"videoId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":false,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":10,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"WatchDuration\",\"columnComment\":\"观看时长（秒）\",\"columnId\":90,\"columnName\":\"watch_duration\",\"columnType\":\"int\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:21:20\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"0\",\"isRequired\":\"0\"', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 14:16:07', 100);
INSERT INTO `sys_oper_log` VALUES (160, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"video_learning_behavior\"}', NULL, 0, NULL, '2025-11-18 14:16:12', 115);
INSERT INTO `sys_oper_log` VALUES (161, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/chapter/index\",\"createTime\":\"2025-11-18 13:56:43\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2036,\"menuName\":\"课程章节\",\"menuType\":\"M\",\"orderNum\":0,\"params\":{},\"parentId\":2030,\"path\":\"chapter\",\"perms\":\"system:chapter:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 15:49:17', 26);
INSERT INTO `sys_oper_log` VALUES (162, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/chapter/index\",\"createTime\":\"2025-11-18 13:56:43\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2036,\"menuName\":\"课程章节\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":2030,\"path\":\"chapter\",\"perms\":\"system:chapter:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 15:49:58', 15);
INSERT INTO `sys_oper_log` VALUES (163, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/student/index\",\"createTime\":\"2025-11-18 13:49:04\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2030,\"menuName\":\"我的课程\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":1,\"path\":\"student\",\"perms\":\"system:student:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 15:50:55', 9);
INSERT INTO `sys_oper_log` VALUES (164, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/resource/index\",\"createTime\":\"2025-11-18 13:36:56\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2024,\"menuName\":\"课程资源\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":2030,\"path\":\"resource\",\"perms\":\"system:resource:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 15:52:22', 17);
INSERT INTO `sys_oper_log` VALUES (165, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/student/index\",\"createTime\":\"2025-11-18 13:49:04\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2030,\"menuName\":\"我的课程\",\"menuType\":\"M\",\"orderNum\":1,\"params\":{},\"parentId\":1,\"path\":\"student\",\"perms\":\"system:student:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 15:53:56', 16);
INSERT INTO `sys_oper_log` VALUES (166, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/student/index\",\"createTime\":\"2025-11-18 13:49:04\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2030,\"menuName\":\"我的课程\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":1,\"path\":\"student\",\"perms\":\"system:student:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 15:54:39', 18);
INSERT INTO `sys_oper_log` VALUES (167, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/resource/index\",\"createTime\":\"2025-11-18 13:36:56\",\"icon\":\"search\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2024,\"menuName\":\"课程资源\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":2030,\"path\":\"resource\",\"perms\":\"system:resource:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 16:03:52', 16);
INSERT INTO `sys_oper_log` VALUES (168, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/resource/index\",\"createTime\":\"2025-11-18 13:36:56\",\"icon\":\"search\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2024,\"menuName\":\"课程资源\",\"menuType\":\"F\",\"orderNum\":1,\"params\":{},\"parentId\":2030,\"path\":\"resource\",\"perms\":\"system:resource:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 16:07:02', 8);
INSERT INTO `sys_oper_log` VALUES (169, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/chapter/index\",\"createTime\":\"2025-11-18 13:56:43\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2036,\"menuName\":\"课程章节\",\"menuType\":\"F\",\"orderNum\":1,\"params\":{},\"parentId\":2030,\"path\":\"chapter\",\"perms\":\"system:chapter:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 16:07:10', 22);
INSERT INTO `sys_oper_log` VALUES (170, '角色管理', 2, 'com.ruoyi.web.controller.system.SysRoleController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/role', '127.0.0.1', '内网IP', '{\"admin\":true,\"createTime\":\"2025-11-18 10:11:08\",\"dataScope\":\"1\",\"delFlag\":\"0\",\"deptCheckStrictly\":true,\"flag\":false,\"menuCheckStrictly\":true,\"menuIds\":[1,100,1000,1001,1002,1003,1004,1005,1006,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2030,2024,2025,2026,2027,2028,2029,2031,2036,2037,2042,2043,2048,2049,2050,2051,2052,2053,2054,2055,2060,2061,2062,2063,2064,2065,2056,2057,2058,2059,2044,2045,2046,2047,2038,2039,2040,2041,2032,2033,2034,2035,101,1007,1008,1009,1010,1011,102,1012,1013,1014,1015,103,1016,1017,1018,1019,104,1020,1021,1022,1023,1024,105,1025,1026,1027,1028,1029,106,1030,1031,1032,1033,1034,107,1035,1036,1037,1038,108,500,1039,1040,1041,501,1042,1043,1044,1045,2,109,1046,1047,1048,110,1049,1050,1051,1052,1053,1054,111,112,113,114,3,115,116,1055,1056,1057,1058,1059,1060,117,4],\"params\":{},\"remark\":\"超级管理员\",\"roleId\":1,\"roleKey\":\"admin\",\"roleName\":\"超级管理员\",\"roleSort\":1,\"status\":\"0\"}', NULL, 1, '不允许操作超级管理员角色', '2025-11-18 16:08:58', 3);
INSERT INTO `sys_oper_log` VALUES (171, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/chapter/index\",\"createTime\":\"2025-11-18 13:56:43\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2036,\"menuName\":\"课程章节\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":2030,\"path\":\"chapter\",\"perms\":\"system:chapter:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 16:13:12', 14);
INSERT INTO `sys_oper_log` VALUES (172, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/resource/index\",\"createTime\":\"2025-11-18 13:36:56\",\"icon\":\"search\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2024,\"menuName\":\"课程资源\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":2030,\"path\":\"resource\",\"perms\":\"system:resource:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 16:13:22', 14);
INSERT INTO `sys_oper_log` VALUES (173, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"course_class\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 17:02:09', 194);
INSERT INTO `sys_oper_log` VALUES (174, '代码生成', 3, 'com.ruoyi.generator.controller.GenController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/gen/12', '127.0.0.1', '内网IP', '[12]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-18 17:02:20', 19);
INSERT INTO `sys_oper_log` VALUES (175, '选课申请', 3, 'com.ruoyi.system.CourseEnrollmentRequestController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/request/1', '127.0.0.1', '内网IP', '[1]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 11:42:02', 35);
INSERT INTO `sys_oper_log` VALUES (176, '小节评论(讨论区)', 1, 'com.ruoyi.system.SectionCommentController.add()', 'POST', 1, 'admin', '研发部门', '/system/comment', '127.0.0.1', '内网IP', '{\"children\":[],\"content\":\"111\",\"createTime\":\"2025-11-19 16:55:06\",\"params\":{},\"sectionId\":1}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'user_id\' doesn\'t have a default value\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\SectionCommentMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.SectionCommentMapper.insertSectionComment-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into section_comment          ( section_id,                          content,                          create_time )           values ( ?,                          ?,                          ? )\r\n### Cause: java.sql.SQLException: Field \'user_id\' doesn\'t have a default value\n; Field \'user_id\' doesn\'t have a default value; nested exception is java.sql.SQLException: Field \'user_id\' doesn\'t have a default value', '2025-11-19 16:55:06', 173);
INSERT INTO `sys_oper_log` VALUES (177, '小节评论(讨论区)', 1, 'com.ruoyi.system.SectionCommentController.add()', 'POST', 1, 'admin', '研发部门', '/system/comment', '127.0.0.1', '内网IP', '{\"children\":[],\"content\":\"111\",\"createTime\":\"2025-11-19 17:01:52\",\"id\":79,\"params\":{},\"sectionId\":1,\"userId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 17:01:53', 331);
INSERT INTO `sys_oper_log` VALUES (178, '小节评论(讨论区)', 1, 'com.ruoyi.system.SectionCommentController.add()', 'POST', 1, 'admin', '研发部门', '/system/comment', '127.0.0.1', '内网IP', '{\"children\":[],\"content\":\"哈哈哈\",\"createTime\":\"2025-11-19 17:01:59\",\"id\":80,\"params\":{},\"parentId\":79,\"sectionId\":1,\"userId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 17:01:59', 10);
INSERT INTO `sys_oper_log` VALUES (179, '小节评论(讨论区)', 1, 'com.ruoyi.system.SectionCommentController.add()', 'POST', 1, 'admin', '研发部门', '/system/comment', '127.0.0.1', '内网IP', '{\"children\":[],\"content\":\"33\",\"createTime\":\"2025-11-19 17:02:13\",\"id\":81,\"params\":{},\"parentId\":79,\"sectionId\":1,\"userId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 17:02:13', 10);
INSERT INTO `sys_oper_log` VALUES (180, '课程', 1, 'com.ruoyi.system.CourseController.add()', 'POST', 1, 'admin', '研发部门', '/system/course', '127.0.0.1', '内网IP', '{\"averageScore\":86.4,\"courseType\":\"2\",\"coverImage\":\"/profile/upload/2025/11/19/下载_20251119174810A001.jpg\",\"createTime\":\"2025-11-19 17:48:23\",\"credit\":3,\"description\":\"数据结构\",\"endTime\":\"2025-11-05\",\"id\":32,\"params\":{},\"startTime\":\"2025-09-03\",\"status\":\"1\",\"studentCount\":56,\"teacherUserId\":1,\"term\":\"1\",\"title\":\"数据结构\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 17:48:23', 365);
INSERT INTO `sys_oper_log` VALUES (181, '课程', 2, 'com.ruoyi.system.CourseController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/course', '127.0.0.1', '内网IP', '{\"averageScore\":86.4,\"courseType\":\"2\",\"coverImage\":\"/profile/upload/2025/11/19/下载_20251119174810A001.jpg\",\"createTime\":\"2025-11-19 17:48:23\",\"credit\":3,\"description\":\"数据结构\",\"endTime\":\"2025-11-05\",\"id\":32,\"isDeleted\":0,\"params\":{},\"startTime\":\"2025-09-03\",\"status\":\"1\",\"studentCount\":56,\"teacherUserId\":1,\"term\":\"2025年秋季学期\",\"title\":\"数据结构\",\"updateTime\":\"2025-11-19 17:49:24\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 17:49:24', 23);
INSERT INTO `sys_oper_log` VALUES (182, '课程', 1, 'com.ruoyi.system.CourseController.add()', 'POST', 1, 'admin', '研发部门', '/system/course', '127.0.0.1', '内网IP', '{\"courseType\":\"1\",\"coverImage\":\"/profile/upload/2025/11/19/OIP-C_20251119175018A002.jpg\",\"createTime\":\"2025-11-19 17:50:53\",\"credit\":5,\"description\":\"高等数学\",\"endTime\":\"2026-01-08\",\"id\":33,\"params\":{},\"startTime\":\"2025-09-01\",\"status\":\"0\",\"studentCount\":132,\"teacherUserId\":1,\"term\":\"2025年秋季学期\",\"title\":\"高等数学\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 17:50:53', 15);
INSERT INTO `sys_oper_log` VALUES (183, '课程', 1, 'com.ruoyi.system.CourseController.add()', 'POST', 1, 'admin', '研发部门', '/system/course', '127.0.0.1', '内网IP', '{\"courseType\":\"0\",\"coverImage\":\"/profile/upload/2025/11/19/下载2_20251119175145A003.jpg\",\"createTime\":\"2025-11-19 17:52:18\",\"credit\":5,\"description\":\"大学英语\",\"endTime\":\"2026-01-01\",\"id\":34,\"params\":{},\"startTime\":\"2025-09-01\",\"status\":\"0\",\"studentCount\":145,\"teacherUserId\":1,\"term\":\"2025年秋季\",\"title\":\"大学英语\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 17:52:19', 11);
INSERT INTO `sys_oper_log` VALUES (184, '课程', 1, 'com.ruoyi.system.CourseController.add()', 'POST', 1, 'admin', '研发部门', '/system/course', '127.0.0.1', '内网IP', '{\"courseType\":\"3\",\"coverImage\":\"/profile/upload/2025/11/19/OIP-Ch_20251119175305A004.jpg\",\"createTime\":\"2025-11-19 17:53:48\",\"credit\":2,\"description\":\"茶艺\",\"endTime\":\"2025-12-25\",\"id\":35,\"params\":{},\"startTime\":\"2025-11-01\",\"status\":\"0\",\"studentCount\":45,\"teacherUserId\":1,\"term\":\"2025年秋季\",\"title\":\"茶艺\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 17:53:48', 17);
INSERT INTO `sys_oper_log` VALUES (185, '课程', 1, 'com.ruoyi.system.CourseController.add()', 'POST', 1, 'admin', '研发部门', '/system/course', '127.0.0.1', '内网IP', '{\"averageScore\":88,\"courseType\":\"0\",\"coverImage\":\"/profile/upload/2025/11/19/O_20251119175652A005.jpg\",\"createTime\":\"2025-11-19 17:57:14\",\"credit\":2,\"description\":\"心理学\",\"endTime\":\"2025-10-08\",\"id\":36,\"params\":{},\"startTime\":\"2025-09-10\",\"status\":\"1\",\"studentCount\":32,\"teacherUserId\":1,\"term\":\"2025年秋季\",\"title\":\"心理学\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 17:57:14', 15);
INSERT INTO `sys_oper_log` VALUES (186, '课程', 3, 'com.ruoyi.system.CourseController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/course/1', '127.0.0.1', '内网IP', '[1]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 17:57:18', 29);
INSERT INTO `sys_oper_log` VALUES (187, '选课申请', 3, 'com.ruoyi.system.CourseEnrollmentRequestController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/request/4', '127.0.0.1', '内网IP', '[4]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 17:59:39', 7);
INSERT INTO `sys_oper_log` VALUES (188, '小节评论(讨论区)', 1, 'com.ruoyi.system.SectionCommentController.add()', 'POST', 1, 'admin', '研发部门', '/system/comment', '127.0.0.1', '内网IP', '{\"children\":[],\"content\":\"1\",\"createTime\":\"2025-11-19 21:48:52\",\"id\":79,\"params\":{},\"sectionId\":1,\"userId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 21:48:52', 43);
INSERT INTO `sys_oper_log` VALUES (189, '小节评论(讨论区)', 1, 'com.ruoyi.system.SectionCommentController.add()', 'POST', 1, 'admin', '研发部门', '/system/comment', '127.0.0.1', '内网IP', '{\"children\":[],\"content\":\"2\",\"createTime\":\"2025-11-19 21:48:58\",\"id\":80,\"params\":{},\"parentId\":79,\"sectionId\":1,\"userId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-19 21:48:58', 7);
INSERT INTO `sys_oper_log` VALUES (190, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/1', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-19 22:17:16', 132);
INSERT INTO `sys_oper_log` VALUES (191, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/1', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-19 22:19:43', 22);
INSERT INTO `sys_oper_log` VALUES (192, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/1', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-19 22:21:13', 51);
INSERT INTO `sys_oper_log` VALUES (193, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/1', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-19 22:27:13', 35);
INSERT INTO `sys_oper_log` VALUES (194, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/1', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-19 22:27:22', 17);
INSERT INTO `sys_oper_log` VALUES (195, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/1', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-19 22:28:09', 20);
INSERT INTO `sys_oper_log` VALUES (196, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/resource/index\",\"createTime\":\"2025-11-18 13:36:56\",\"icon\":\"search\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2024,\"menuName\":\"课程资源\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":1,\"path\":\"resource\",\"perms\":\"system:resource:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 10:46:10', 47);
INSERT INTO `sys_oper_log` VALUES (197, '课程资源', 3, 'com.ruoyi.system.CourseResourceController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/resource/1', '127.0.0.1', '内网IP', '[1]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 10:46:20', 22);
INSERT INTO `sys_oper_log` VALUES (198, '课程资源', 1, 'com.ruoyi.system.CourseResourceController.add()', 'POST', 1, 'admin', '研发部门', '/system/resource', '127.0.0.1', '内网IP', '{\"courseId\":33,\"createTime\":\"2025-11-20 10:47:21\",\"description\":\"第一章学习内容\",\"downloadCount\":0,\"fileType\":\"0\",\"fileUrl\":\"/profile/upload/2025/11/20/第一章_20251120104711A001.pdf\",\"name\":\"第一章概述\",\"params\":{}}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'file_size\' doesn\'t have a default value\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\CourseResourceMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.CourseResourceMapper.insertCourseResource-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into course_resource          ( course_id,             name,             file_type,                          file_url,             description,             download_count,                          create_time )           values ( ?,             ?,             ?,                          ?,             ?,             ?,                          ? )\r\n### Cause: java.sql.SQLException: Field \'file_size\' doesn\'t have a default value\n; Field \'file_size\' doesn\'t have a default value; nested exception is java.sql.SQLException: Field \'file_size\' doesn\'t have a default value', '2025-11-20 10:47:21', 147);
INSERT INTO `sys_oper_log` VALUES (199, '课程资源', 1, 'com.ruoyi.system.CourseResourceController.add()', 'POST', 1, 'admin', '研发部门', '/system/resource', '127.0.0.1', '内网IP', '{\"courseId\":33,\"createTime\":\"2025-11-20 10:52:53\",\"description\":\"1\",\"downloadCount\":0,\"fileSize\":668281,\"fileType\":\"0\",\"fileUrl\":\"/profile/upload/2025/11/20/第一章_20251120105250A002.pdf\",\"name\":\"第一章\",\"params\":{}}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'upload_user_id\' doesn\'t have a default value\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\CourseResourceMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.CourseResourceMapper.insertCourseResource-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into course_resource          ( course_id,             name,             file_type,             file_size,             file_url,             description,             download_count,                          create_time )           values ( ?,             ?,             ?,             ?,             ?,             ?,             ?,                          ? )\r\n### Cause: java.sql.SQLException: Field \'upload_user_id\' doesn\'t have a default value\n; Field \'upload_user_id\' doesn\'t have a default value; nested exception is java.sql.SQLException: Field \'upload_user_id\' doesn\'t have a default value', '2025-11-20 10:52:53', 50);
INSERT INTO `sys_oper_log` VALUES (200, '课程资源', 1, 'com.ruoyi.system.CourseResourceController.add()', 'POST', 1, 'admin', '研发部门', '/system/resource', '127.0.0.1', '内网IP', '{\"courseId\":33,\"createTime\":\"2025-11-20 10:53:21\",\"description\":\"1\",\"downloadCount\":0,\"fileSize\":668281,\"fileType\":\"0\",\"fileUrl\":\"/profile/upload/2025/11/20/第一章_20251120105317A003.pdf\",\"name\":\"第一章\",\"params\":{}}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'upload_user_id\' doesn\'t have a default value\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\CourseResourceMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.CourseResourceMapper.insertCourseResource-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into course_resource          ( course_id,             name,             file_type,             file_size,             file_url,             description,             download_count,                          create_time )           values ( ?,             ?,             ?,             ?,             ?,             ?,             ?,                          ? )\r\n### Cause: java.sql.SQLException: Field \'upload_user_id\' doesn\'t have a default value\n; Field \'upload_user_id\' doesn\'t have a default value; nested exception is java.sql.SQLException: Field \'upload_user_id\' doesn\'t have a default value', '2025-11-20 10:53:21', 12);
INSERT INTO `sys_oper_log` VALUES (201, '课程资源', 1, 'com.ruoyi.system.CourseResourceController.add()', 'POST', 1, 'admin', '研发部门', '/system/resource', '127.0.0.1', '内网IP', '{\"courseId\":33,\"createBy\":\"admin\",\"createTime\":\"2025-11-20 10:56:06\",\"description\":\"1\",\"downloadCount\":0,\"fileSize\":668281,\"fileType\":\"0\",\"fileUrl\":\"/profile/upload/2025/11/20/第一章_20251120105602A002.pdf\",\"id\":6,\"name\":\"第一章\",\"params\":{},\"uploadUserId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 10:56:07', 308);
INSERT INTO `sys_oper_log` VALUES (202, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/6', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-20 11:02:22', 204);
INSERT INTO `sys_oper_log` VALUES (203, '课程资源', 3, 'com.ruoyi.system.CourseResourceController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/resource/6', '127.0.0.1', '内网IP', '[6]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 11:02:33', 21);
INSERT INTO `sys_oper_log` VALUES (204, '课程资源', 1, 'com.ruoyi.system.CourseResourceController.add()', 'POST', 1, 'admin', '研发部门', '/system/resource', '127.0.0.1', '内网IP', '{\"courseId\":33,\"createBy\":\"admin\",\"createTime\":\"2025-11-20 11:02:44\",\"description\":\"1\",\"downloadCount\":0,\"fileSize\":668281,\"fileType\":\"0\",\"fileUrl\":\"/profile/upload/2025/11/20/第一章_20251120110240A001.pdf\",\"id\":7,\"name\":\"第一章\",\"params\":{},\"uploadUserId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 11:02:44', 36);
INSERT INTO `sys_oper_log` VALUES (205, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/7', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-20 11:02:50', 38);
INSERT INTO `sys_oper_log` VALUES (206, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/7', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-20 11:03:33', 30);
INSERT INTO `sys_oper_log` VALUES (207, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/7', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-20 11:04:17', 86);
INSERT INTO `sys_oper_log` VALUES (208, '课程资源', 3, 'com.ruoyi.system.CourseResourceController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/resource/7', '127.0.0.1', '内网IP', '[7]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 11:10:22', 36);
INSERT INTO `sys_oper_log` VALUES (209, '课程资源', 1, 'com.ruoyi.system.CourseResourceController.add()', 'POST', 1, 'admin', '研发部门', '/system/resource', '127.0.0.1', '内网IP', '{\"courseId\":33,\"createBy\":\"admin\",\"createTime\":\"2025-11-20 11:10:37\",\"description\":\"1\",\"downloadCount\":0,\"fileSize\":668281,\"fileType\":\"pdf\",\"fileUrl\":\"/profile/upload/2025/11/20/第一章_20251120111030A001.pdf\",\"id\":8,\"name\":\"第一章\",\"params\":{},\"uploadUserId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 11:10:37', 44);
INSERT INTO `sys_oper_log` VALUES (210, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/8', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-20 11:10:38', 58);
INSERT INTO `sys_oper_log` VALUES (211, '课程资源', 1, 'com.ruoyi.system.CourseResourceController.add()', 'POST', 1, 'admin', '研发部门', '/system/resource', '127.0.0.1', '内网IP', '{\"courseId\":33,\"createBy\":\"admin\",\"createTime\":\"2025-11-20 11:12:37\",\"description\":\"2\",\"downloadCount\":0,\"fileSize\":3594236,\"fileType\":\"pdf\",\"fileUrl\":\"/profile/upload/2025/11/20/第二章_20251120111233A002.pdf\",\"id\":9,\"name\":\"第二章\",\"params\":{},\"uploadUserId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 11:12:37', 8);
INSERT INTO `sys_oper_log` VALUES (212, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/9', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-20 11:12:49', 66);
INSERT INTO `sys_oper_log` VALUES (213, '课程资源', 1, 'com.ruoyi.system.CourseResourceController.add()', 'POST', 1, 'admin', '研发部门', '/system/resource', '127.0.0.1', '内网IP', '{\"courseId\":33,\"createBy\":\"admin\",\"createTime\":\"2025-11-20 11:14:17\",\"description\":\"1\",\"downloadCount\":0,\"fileSize\":23298,\"fileType\":\"docx\",\"fileUrl\":\"/profile/upload/2025/11/20/大作业_20251120111411A003.docx\",\"id\":10,\"name\":\"大作业\",\"params\":{},\"uploadUserId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 11:14:17', 12);
INSERT INTO `sys_oper_log` VALUES (214, '课程资源下载', 0, 'com.ruoyi.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/10', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-20 11:14:19', 30);
INSERT INTO `sys_oper_log` VALUES (215, '课程资源', 1, 'com.ruoyi.system.CourseResourceController.add()', 'POST', 1, 'admin', '研发部门', '/system/resource', '127.0.0.1', '内网IP', '{\"courseId\":33,\"createBy\":\"admin\",\"createTime\":\"2025-11-20 11:15:52\",\"downloadCount\":0,\"fileSize\":48762,\"fileType\":\"xls\",\"fileUrl\":\"/profile/upload/2025/11/20/推荐书目_20251120111545A004.xls\",\"id\":11,\"name\":\"推荐书目\",\"params\":{},\"uploadUserId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 11:15:52', 19);
INSERT INTO `sys_oper_log` VALUES (216, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/resource/index\",\"createTime\":\"2025-11-18 13:36:56\",\"icon\":\"search\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2024,\"menuName\":\"课程资源\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":2036,\"path\":\"resource\",\"perms\":\"system:resource:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 11:17:00', 42);
INSERT INTO `sys_oper_log` VALUES (217, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/behavior/index\",\"createTime\":\"2025-11-18 14:17:40\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2060,\"menuName\":\"视频学习行为\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":1,\"path\":\"behavior\",\"perms\":\"system:behavior:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 12:02:14', 85);
INSERT INTO `sys_oper_log` VALUES (218, '小节评论(讨论区)', 1, 'com.ruoyi.system.SectionCommentController.add()', 'POST', 1, 'admin', '研发部门', '/system/comment', '127.0.0.1', '内网IP', '{\"children\":[],\"content\":\"22\",\"createTime\":\"2025-11-20 13:08:30\",\"id\":81,\"params\":{},\"sectionId\":1,\"userId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 13:08:30', 566);
INSERT INTO `sys_oper_log` VALUES (219, '视频学习行为', 1, 'com.ruoyi.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":0.5512679162072767,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":10,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":10}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at )           values ( ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\n; Field \'student_id\' doesn\'t have a default value; nested exception is java.sql.SQLException: Field \'student_id\' doesn\'t have a default value', '2025-11-20 14:51:00', 407);
INSERT INTO `sys_oper_log` VALUES (220, '视频学习行为', 1, 'com.ruoyi.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":1.1025358324145533,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":20,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":20}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at )           values ( ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\n; Field \'student_id\' doesn\'t have a default value; nested exception is java.sql.SQLException: Field \'student_id\' doesn\'t have a default value', '2025-11-20 14:51:09', 11);
INSERT INTO `sys_oper_log` VALUES (221, '视频学习行为', 1, 'com.ruoyi.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":1.6538037486218304,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":30,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":30}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at )           values ( ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\n; Field \'student_id\' doesn\'t have a default value; nested exception is java.sql.SQLException: Field \'student_id\' doesn\'t have a default value', '2025-11-20 14:51:20', 10);
INSERT INTO `sys_oper_log` VALUES (222, '视频学习行为', 1, 'com.ruoyi.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":2.2050716648291067,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":40,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":40}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at )           values ( ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\n; Field \'student_id\' doesn\'t have a default value; nested exception is java.sql.SQLException: Field \'student_id\' doesn\'t have a default value', '2025-11-20 14:51:34', 12);
INSERT INTO `sys_oper_log` VALUES (223, '视频学习行为', 1, 'com.ruoyi.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":0.5512679162072767,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":10,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":10}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at )           values ( ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\n; Field \'student_id\' doesn\'t have a default value; nested exception is java.sql.SQLException: Field \'student_id\' doesn\'t have a default value', '2025-11-20 14:56:54', 42);
INSERT INTO `sys_oper_log` VALUES (224, '视频学习行为', 1, 'com.ruoyi.web.controller.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":0.5512679162072767,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":10,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":10}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'last_position\' in \'field list\'\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at,             last_position )           values ( ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'last_position\' in \'field list\'\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Unknown column \'last_position\' in \'field list\'', '2025-11-20 15:06:34', 440);
INSERT INTO `sys_oper_log` VALUES (225, '视频学习行为', 1, 'com.ruoyi.web.controller.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":1.1025358324145533,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":20,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":20}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'last_position\' in \'field list\'\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at,             last_position )           values ( ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'last_position\' in \'field list\'\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Unknown column \'last_position\' in \'field list\'', '2025-11-20 15:06:42', 79);
INSERT INTO `sys_oper_log` VALUES (226, '视频学习行为', 1, 'com.ruoyi.web.controller.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":1.6538037486218304,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":30,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":30}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'last_position\' in \'field list\'\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at,             last_position )           values ( ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'last_position\' in \'field list\'\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Unknown column \'last_position\' in \'field list\'', '2025-11-20 15:06:52', 15);
INSERT INTO `sys_oper_log` VALUES (227, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/behavior/index\",\"createTime\":\"2025-11-18 14:17:40\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2060,\"menuName\":\"我的视频学习\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":1,\"path\":\"behavior\",\"perms\":\"system:behavior:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 15:08:09', 28);
INSERT INTO `sys_oper_log` VALUES (228, '视频学习行为', 1, 'com.ruoyi.web.controller.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":0.5512679162072767,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":10,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":10}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at,             last_position )           values ( ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLException: Field \'student_id\' doesn\'t have a default value\n; Field \'student_id\' doesn\'t have a default value; nested exception is java.sql.SQLException: Field \'student_id\' doesn\'t have a default value', '2025-11-20 15:11:52', 24);
INSERT INTO `sys_oper_log` VALUES (229, '视频学习行为', 1, 'com.ruoyi.web.controller.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":0.5512679162072767,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"id\":1,\"isCompleted\":0,\"lastPosition\":10,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"studentId\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":10}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 15:17:52', 60);
INSERT INTO `sys_oper_log` VALUES (230, '视频学习行为', 1, 'com.ruoyi.web.controller.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":1.1025358324145533,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":20,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"studentId\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":20}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( student_id,             video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at,             last_position )           values ( ?,             ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'\n; Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'', '2025-11-20 15:18:02', 20);
INSERT INTO `sys_oper_log` VALUES (231, '视频学习行为', 1, 'com.ruoyi.web.controller.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":1.6538037486218304,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":30,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"studentId\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":30}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( student_id,             video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at,             last_position )           values ( ?,             ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'\n; Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'', '2025-11-20 15:18:12', 7);
INSERT INTO `sys_oper_log` VALUES (232, '视频学习行为', 1, 'com.ruoyi.web.controller.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":0.5512679162072767,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"id\":4,\"isCompleted\":0,\"lastPosition\":10,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"studentId\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":10}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 15:23:47', 20);
INSERT INTO `sys_oper_log` VALUES (233, '视频学习行为', 1, 'com.ruoyi.web.controller.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":1.1025358324145533,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":20,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"studentId\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":20}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( student_id,             video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at,             last_position )           values ( ?,             ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'\n; Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'', '2025-11-20 15:23:57', 16);
INSERT INTO `sys_oper_log` VALUES (234, '视频学习行为', 1, 'com.ruoyi.web.controller.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":0.5512679162072767,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"id\":6,\"isCompleted\":0,\"lastPosition\":10,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"studentId\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":10}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 15:30:27', 37);
INSERT INTO `sys_oper_log` VALUES (235, '视频学习行为', 1, 'com.ruoyi.web.controller.system.VideoLearningBehaviorController.add()', 'POST', 1, 'admin', '研发部门', '/system/behavior', '127.0.0.1', '内网IP', '{\"completionRate\":1.1025358324145533,\"fastForwardCount\":0,\"firstWatchAt\":\"2025-11-20\",\"isCompleted\":0,\"lastPosition\":20,\"lastWatchAt\":\"2025-11-20\",\"params\":{},\"pauseCount\":0,\"playbackSpeed\":1,\"studentId\":1,\"videoDuration\":1814,\"videoId\":1,\"watchCount\":1,\"watchDuration\":20}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'\r\n### The error may exist in file [C:\\smartclassv2\\RuoYi-Vue-master\\ruoyi-system\\target\\classes\\mapper\\system\\VideoLearningBehaviorMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.VideoLearningBehaviorMapper.insertVideoLearningBehavior-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into video_learning_behavior          ( student_id,             video_id,             watch_duration,             video_duration,             completion_rate,             watch_count,                          is_completed,             fast_forward_count,             pause_count,             playback_speed,             first_watch_at,             last_watch_at,             last_position )           values ( ?,             ?,             ?,             ?,             ?,             ?,                          ?,             ?,             ?,             ?,             ?,             ?,             ? )\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'\n; Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'; nested exception is java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1-1\' for key \'video_learning_behavior.uk_student_video\'', '2025-11-20 15:30:37', 6);
INSERT INTO `sys_oper_log` VALUES (236, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/video/index\",\"createTime\":\"2025-11-18 14:10:06\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2054,\"menuName\":\"视频\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":0,\"path\":\"video\",\"perms\":\"system:video:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 18:44:25', 67);
INSERT INTO `sys_oper_log` VALUES (237, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"video\",\"className\":\"Video\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"视频ID\",\"columnId\":103,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 14:08:12\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"课程ID\",\"columnId\":104,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 14:08:12\",\"usableColumn\":false},{\"capJavaField\":\"Title\",\"columnComment\":\"视频标题\",\"columnId\":105,\"columnName\":\"title\",\"columnType\":\"varchar(200)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"title\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"updateTime\":\"2025-11-18 14:08:12\",\"usableColumn\":false},{\"capJavaField\":\"Description\",\"columnComment\":\"视频描述\",\"columnId\":106,\"columnName\":\"description\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"textarea\",\"increment\":false,\"insert\"', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:01:59', 262);
INSERT INTO `sys_oper_log` VALUES (238, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.synchDb()', 'GET', 1, 'admin', '研发部门', '/tool/gen/synchDb/video', '127.0.0.1', '内网IP', '{}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:02:10', 114);
INSERT INTO `sys_oper_log` VALUES (239, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"video\"}', NULL, 0, NULL, '2025-11-20 19:02:12', 408);
INSERT INTO `sys_oper_log` VALUES (240, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"video\",\"className\":\"Video\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"视频ID\",\"columnId\":103,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"updateTime\":\"2025-11-20 19:02:10\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"课程ID\",\"columnId\":104,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"updateTime\":\"2025-11-20 19:02:10\",\"usableColumn\":false},{\"capJavaField\":\"Title\",\"columnComment\":\"视频标题\",\"columnId\":105,\"columnName\":\"title\",\"columnType\":\"varchar(200)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"title\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":11,\"updateBy\":\"\",\"updateTime\":\"2025-11-20 19:02:10\",\"usableColumn\":false},{\"capJavaField\":\"Description\",\"columnComment\":\"视频描述\",\"columnId\":106,\"columnName\":\"description\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-11-18 10:23:50\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"textarea\",\"increment\":false,\"insert\"', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:08:28', 112);
INSERT INTO `sys_oper_log` VALUES (241, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"video\"}', NULL, 0, NULL, '2025-11-20 19:08:48', 136);
INSERT INTO `sys_oper_log` VALUES (242, '菜单管理', 3, 'com.ruoyi.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/2054', '127.0.0.1', '内网IP', '2054', '{\"msg\":\"存在子菜单,不允许删除\",\"code\":601}', 0, NULL, '2025-11-20 19:11:12', 16);
INSERT INTO `sys_oper_log` VALUES (243, '菜单管理', 3, 'com.ruoyi.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/2055', '127.0.0.1', '内网IP', '2055', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:11:17', 38);
INSERT INTO `sys_oper_log` VALUES (244, '菜单管理', 3, 'com.ruoyi.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/2057', '127.0.0.1', '内网IP', '2057', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:11:21', 13);
INSERT INTO `sys_oper_log` VALUES (245, '菜单管理', 3, 'com.ruoyi.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/2056', '127.0.0.1', '内网IP', '2056', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:11:23', 12);
INSERT INTO `sys_oper_log` VALUES (246, '菜单管理', 3, 'com.ruoyi.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/2058', '127.0.0.1', '内网IP', '2058', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:11:25', 13);
INSERT INTO `sys_oper_log` VALUES (247, '菜单管理', 3, 'com.ruoyi.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/2059', '127.0.0.1', '内网IP', '2059', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:11:27', 14);
INSERT INTO `sys_oper_log` VALUES (248, '菜单管理', 3, 'com.ruoyi.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/2054', '127.0.0.1', '内网IP', '2054', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:11:30', 13);
INSERT INTO `sys_oper_log` VALUES (249, '视频', 1, 'com.ruoyi.web.controller.system.VideoController.add()', 'POST', 1, 'admin', '研发部门', '/system/video', '127.0.0.1', '内网IP', '{\"courseId\":33,\"coverImage\":\"/profile/upload/2025/11/20/2_20251120193202A004.jpg\",\"filePath\":\"/profile/upload/2025/11/20/1_20251120193138A003.mp4\",\"fileSize\":147906858,\"id\":1,\"params\":{},\"title\":\"1\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:32:05', 452);
INSERT INTO `sys_oper_log` VALUES (250, '视频', 1, 'com.ruoyi.web.controller.system.VideoController.add()', 'POST', 1, 'admin', '研发部门', '/system/video', '127.0.0.1', '内网IP', '{\"courseId\":33,\"coverImage\":\"/profile/upload/2025/11/20/2_20251120193445A006.jpg\",\"filePath\":\"/profile/upload/2025/11/20/2_20251120193433A005.mp4\",\"fileSize\":246070345,\"id\":2,\"params\":{},\"title\":\"2\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:34:50', 11);
INSERT INTO `sys_oper_log` VALUES (251, '视频', 1, 'com.ruoyi.web.controller.system.VideoController.add()', 'POST', 1, 'admin', '研发部门', '/system/video', '127.0.0.1', '内网IP', '{\"courseId\":33,\"coverImage\":\"/profile/upload/2025/11/20/2_20251120193521A008.jpg\",\"filePath\":\"/profile/upload/2025/11/20/3_20251120193505A007.mp4\",\"fileSize\":158089476,\"id\":3,\"params\":{},\"title\":\"3\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:35:22', 26);
INSERT INTO `sys_oper_log` VALUES (252, '视频', 1, 'com.ruoyi.web.controller.system.VideoController.add()', 'POST', 1, 'admin', '研发部门', '/system/video', '127.0.0.1', '内网IP', '{\"courseId\":33,\"coverImage\":\"/profile/upload/2025/11/20/2_20251120193541A009.jpg\",\"filePath\":\"/profile/upload/2025/11/20/4_20251120193544A010.mp4\",\"fileSize\":397140764,\"id\":4,\"params\":{},\"title\":\"4\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:35:53', 10);
INSERT INTO `sys_oper_log` VALUES (253, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/video/index\",\"createTime\":\"2025-11-20 19:10:50\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2066,\"menuName\":\"视频\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":2042,\"path\":\"video\",\"perms\":\"system:video:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-20 19:39:03', 50);
INSERT INTO `sys_oper_log` VALUES (254, '学生退课', 3, 'com.ruoyi.web.controller.system.CourseStudentController.withdrawCourse()', 'DELETE', 1, 'admin', '研发部门', '/system/student/withdraw/32', '127.0.0.1', '内网IP', '32', '{\"msg\":\"退课成功\",\"code\":200}', 0, NULL, '2025-11-20 19:54:44', 42);
INSERT INTO `sys_oper_log` VALUES (255, '小节评论(讨论区)', 1, 'com.ruoyi.web.controller.system.SectionCommentController.add()', 'POST', 1, 'admin', '研发部门', '/system/comment', '127.0.0.1', '内网IP', '{\"children\":[],\"content\":\"老师讲的真好！我收获很大！\",\"createTime\":\"2025-11-21 10:43:34\",\"id\":82,\"params\":{},\"sectionId\":2,\"userId\":1}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 10:43:34', 100);
INSERT INTO `sys_oper_log` VALUES (256, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/question/courses\",\"createTime\":\"2025-11-19 20:59:12\",\"icon\":\"education\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2000,\"menuName\":\"题目练习\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":0,\"path\":\"courses\",\"perms\":\"system:question:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 12:24:34', 39);
INSERT INTO `sys_oper_log` VALUES (257, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/assignment/index\",\"createTime\":\"2025-11-19 20:59:12\",\"icon\":\"form\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2100,\"menuName\":\"作业考试\",\"menuType\":\"C\",\"orderNum\":2,\"params\":{},\"parentId\":0,\"path\":\"assignment\",\"perms\":\"system:assignment:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 12:24:41', 13);
INSERT INTO `sys_oper_log` VALUES (258, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/assignment/index\",\"createTime\":\"2025-11-19 20:59:12\",\"icon\":\"form\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2100,\"menuName\":\"作业考试\",\"menuType\":\"C\",\"orderNum\":2,\"params\":{},\"parentId\":1,\"path\":\"assignment\",\"perms\":\"system:assignment:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 12:24:51', 13);
INSERT INTO `sys_oper_log` VALUES (259, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/question/courses\",\"createTime\":\"2025-11-19 20:59:12\",\"icon\":\"education\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2000,\"menuName\":\"题目练习\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":1,\"path\":\"courses\",\"perms\":\"system:question:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 12:25:00', 9);
INSERT INTO `sys_oper_log` VALUES (260, '学生退课', 3, 'com.ruoyi.web.controller.system.CourseStudentController.withdrawCourse()', 'DELETE', 1, 'admin', '研发部门', '/system/student/withdraw/35', '127.0.0.1', '内网IP', '35', '{\"msg\":\"退课成功\",\"code\":200}', 0, NULL, '2025-11-21 12:59:46', 23);
INSERT INTO `sys_oper_log` VALUES (261, '课程资源下载', 0, 'com.ruoyi.web.controller.system.CourseResourceController.resourceDownload()', 'GET', 1, 'admin', '研发部门', '/system/resource/download/11', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2025-11-21 15:50:55', 75);
INSERT INTO `sys_oper_log` VALUES (262, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/resource/index\",\"createTime\":\"2025-11-18 13:36:56\",\"icon\":\"search\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2024,\"menuName\":\"课程资源\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":0,\"path\":\"resource\",\"perms\":\"system:resource:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 15:51:36', 37);
INSERT INTO `sys_oper_log` VALUES (263, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"knowledge_graph,student_kp_mastery\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 21:07:30', 141);
INSERT INTO `sys_oper_log` VALUES (264, '代码生成', 3, 'com.ruoyi.generator.controller.GenController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/gen/11', '127.0.0.1', '内网IP', '[11]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 21:07:36', 35);
INSERT INTO `sys_oper_log` VALUES (265, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"question\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 21:07:56', 45);
INSERT INTO `sys_oper_log` VALUES (266, '代码生成', 6, 'com.ruoyi.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '127.0.0.1', '内网IP', '{\"tables\":\"knowledge_point\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 21:12:10', 42);
INSERT INTO `sys_oper_log` VALUES (267, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"point\",\"className\":\"KnowledgePoint\",\"columns\":[{\"capJavaField\":\"Id\",\"columnId\":161,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:12:10\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":15,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"所属课程\",\"columnId\":162,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:12:10\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":15,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Title\",\"columnComment\":\"知识点名称（如“二分查找”）\",\"columnId\":163,\"columnName\":\"title\",\"columnType\":\"varchar(200)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:12:10\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"title\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":15,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Description\",\"columnComment\":\"详细解释（AI生成）\",\"columnId\":164,\"columnName\":\"description\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:12:10\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"textarea\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"0\",\"javaField\":\"descrip', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 21:13:20', 62);
INSERT INTO `sys_oper_log` VALUES (268, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"knowledge_point\"}', NULL, 0, NULL, '2025-11-21 21:13:25', 426);
INSERT INTO `sys_oper_log` VALUES (269, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"mastery\",\"className\":\"StudentKpMastery\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"记录ID\",\"columnId\":130,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:07:30\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":13,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"StudentUserId\",\"columnComment\":\"学生user.id（关联user表）\",\"columnId\":131,\"columnName\":\"student_user_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:07:30\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"studentUserId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":13,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"所属课程ID（关联course表）\",\"columnId\":132,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:07:30\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"courseId\",\"javaType\":\"Long\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":3,\"superColumn\":false,\"tableId\":13,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"KpId\",\"columnComment\":\"知识点ID（关联knowledge_point表）\",\"columnId\":133,\"columnName\":\"kp_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:07:30\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\"', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 21:43:31', 237);
INSERT INTO `sys_oper_log` VALUES (270, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"student_kp_mastery\"}', NULL, 0, NULL, '2025-11-21 21:43:53', 118);
INSERT INTO `sys_oper_log` VALUES (271, '代码生成', 2, 'com.ruoyi.generator.controller.GenController.editSave()', 'PUT', 1, 'admin', '研发部门', '/tool/gen', '127.0.0.1', '内网IP', '{\"businessName\":\"graph\",\"className\":\"KnowledgeGraph\",\"columns\":[{\"capJavaField\":\"Id\",\"columnComment\":\"知识图谱ID\",\"columnId\":118,\"columnName\":\"id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:07:30\",\"dictType\":\"\",\"edit\":false,\"htmlType\":\"input\",\"increment\":true,\"insert\":true,\"isIncrement\":\"1\",\"isInsert\":\"1\",\"isPk\":\"1\",\"isRequired\":\"0\",\"javaField\":\"id\",\"javaType\":\"Long\",\"list\":false,\"params\":{},\"pk\":true,\"query\":false,\"queryType\":\"EQ\",\"required\":false,\"sort\":1,\"superColumn\":false,\"tableId\":12,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Title\",\"columnComment\":\"图谱标题\",\"columnId\":119,\"columnName\":\"title\",\"columnType\":\"varchar(255)\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:07:30\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"javaField\":\"title\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":true,\"sort\":2,\"superColumn\":false,\"tableId\":12,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"Description\",\"columnComment\":\"图谱描述\",\"columnId\":120,\"columnName\":\"description\",\"columnType\":\"text\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:07:30\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"textarea\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"0\",\"javaField\":\"description\",\"javaType\":\"String\",\"list\":true,\"params\":{},\"pk\":false,\"query\":true,\"queryType\":\"EQ\",\"required\":false,\"sort\":3,\"superColumn\":false,\"tableId\":12,\"updateBy\":\"\",\"usableColumn\":false},{\"capJavaField\":\"CourseId\",\"columnComment\":\"关联课程ID\",\"columnId\":121,\"columnName\":\"course_id\",\"columnType\":\"bigint\",\"createBy\":\"admin\",\"createTime\":\"2025-11-21 21:07:30\",\"dictType\":\"\",\"edit\":true,\"htmlType\":\"input\",\"increment\":false,\"insert\":true,\"isEdit\":\"1\",\"isIncrement\":\"0\",\"isInsert\":\"1\",\"isList\":\"1\",\"isPk\":\"0\",\"isQuery\":\"1\",\"isRequired\":\"1\",\"ja', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-21 22:28:06', 160);
INSERT INTO `sys_oper_log` VALUES (272, '代码生成', 8, 'com.ruoyi.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '127.0.0.1', '内网IP', '{\"tables\":\"knowledge_graph\"}', NULL, 0, NULL, '2025-11-21 22:28:12', 750);
INSERT INTO `sys_oper_log` VALUES (273, '知识点', 3, 'com.ruoyi.web.controller.system.KnowledgePointController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/point/62', '127.0.0.1', '内网IP', '[62]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-22 15:38:50', 109);
INSERT INTO `sys_oper_log` VALUES (274, '知识点', 3, 'com.ruoyi.web.controller.system.KnowledgePointController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/point/63', '127.0.0.1', '内网IP', '[63]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-22 15:38:55', 15);
INSERT INTO `sys_oper_log` VALUES (275, '知识图谱', 3, 'com.ruoyi.web.controller.system.KnowledgeGraphController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/graph/7', '127.0.0.1', '内网IP', '[7]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-22 15:39:22', 14);
INSERT INTO `sys_oper_log` VALUES (276, '知识图谱', 3, 'com.ruoyi.web.controller.system.KnowledgeGraphController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/graph/6', '127.0.0.1', '内网IP', '[6]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-22 15:39:25', 20);
INSERT INTO `sys_oper_log` VALUES (277, '知识图谱', 3, 'com.ruoyi.web.controller.system.KnowledgeGraphController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/graph/5', '127.0.0.1', '内网IP', '[5]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-22 15:39:28', 15);
INSERT INTO `sys_oper_log` VALUES (278, '知识图谱', 3, 'com.ruoyi.web.controller.system.KnowledgeGraphController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/graph/4', '127.0.0.1', '内网IP', '[4]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-22 15:39:34', 19);
INSERT INTO `sys_oper_log` VALUES (279, '知识图谱', 3, 'com.ruoyi.web.controller.system.KnowledgeGraphController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/graph/8', '127.0.0.1', '内网IP', '[8]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-22 18:45:35', 71);
INSERT INTO `sys_oper_log` VALUES (280, '知识图谱', 3, 'com.ruoyi.web.controller.system.KnowledgeGraphController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/graph/9', '127.0.0.1', '内网IP', '[9]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-22 18:45:46', 19);
INSERT INTO `sys_oper_log` VALUES (281, '知识图谱', 3, 'com.ruoyi.web.controller.system.KnowledgeGraphController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/graph/10', '127.0.0.1', '内网IP', '[10]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-22 18:45:52', 19);
INSERT INTO `sys_oper_log` VALUES (282, '知识图谱', 3, 'com.ruoyi.web.controller.system.KnowledgeGraphController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/graph/11', '127.0.0.1', '内网IP', '[11]', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-22 18:46:02', 20);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` bigint NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '岗位信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (1, 'ceo', '董事长', 1, '0', 'admin', '2025-11-18 16:54:30', '', NULL, '');
INSERT INTO `sys_post` VALUES (2, 'se', '项目经理', 2, '0', 'admin', '2025-11-18 16:54:30', '', NULL, '');
INSERT INTO `sys_post` VALUES (3, 'hr', '人力资源', 3, '0', 'admin', '2025-11-18 16:54:30', '', NULL, '');
INSERT INTO `sys_post` VALUES (4, 'user', '普通员工', 4, '0', 'admin', '2025-11-18 16:54:30', '', NULL, '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 102 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '角色信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2025-11-18 16:54:30', '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (2, '普通角色', 'common', 2, '2', 1, 1, '0', '0', 'admin', '2025-11-18 16:54:30', 'admin', '2025-11-18 18:27:30', '普通角色');
INSERT INTO `sys_role` VALUES (100, '学生角色', 'student', 3, '1', 1, 1, '0', '0', '', '2025-11-18 17:47:44', 'admin', '2025-11-18 20:59:30', NULL);
INSERT INTO `sys_role` VALUES (101, '教师角色', 'teacher', 9, '1', 1, 1, '0', '0', '', '2025-11-18 17:47:44', 'admin', '2025-11-18 17:54:24', NULL);

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '角色和部门关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------
INSERT INTO `sys_role_dept` VALUES (2, 100);
INSERT INTO `sys_role_dept` VALUES (2, 101);
INSERT INTO `sys_role_dept` VALUES (2, 105);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 2);
INSERT INTO `sys_role_menu` VALUES (2, 3);
INSERT INTO `sys_role_menu` VALUES (2, 4);
INSERT INTO `sys_role_menu` VALUES (2, 100);
INSERT INTO `sys_role_menu` VALUES (2, 101);
INSERT INTO `sys_role_menu` VALUES (2, 102);
INSERT INTO `sys_role_menu` VALUES (2, 103);
INSERT INTO `sys_role_menu` VALUES (2, 104);
INSERT INTO `sys_role_menu` VALUES (2, 105);
INSERT INTO `sys_role_menu` VALUES (2, 106);
INSERT INTO `sys_role_menu` VALUES (2, 107);
INSERT INTO `sys_role_menu` VALUES (2, 108);
INSERT INTO `sys_role_menu` VALUES (2, 109);
INSERT INTO `sys_role_menu` VALUES (2, 110);
INSERT INTO `sys_role_menu` VALUES (2, 111);
INSERT INTO `sys_role_menu` VALUES (2, 112);
INSERT INTO `sys_role_menu` VALUES (2, 113);
INSERT INTO `sys_role_menu` VALUES (2, 114);
INSERT INTO `sys_role_menu` VALUES (2, 115);
INSERT INTO `sys_role_menu` VALUES (2, 116);
INSERT INTO `sys_role_menu` VALUES (2, 117);
INSERT INTO `sys_role_menu` VALUES (2, 500);
INSERT INTO `sys_role_menu` VALUES (2, 501);
INSERT INTO `sys_role_menu` VALUES (2, 1000);
INSERT INTO `sys_role_menu` VALUES (2, 1001);
INSERT INTO `sys_role_menu` VALUES (2, 1002);
INSERT INTO `sys_role_menu` VALUES (2, 1003);
INSERT INTO `sys_role_menu` VALUES (2, 1004);
INSERT INTO `sys_role_menu` VALUES (2, 1005);
INSERT INTO `sys_role_menu` VALUES (2, 1006);
INSERT INTO `sys_role_menu` VALUES (2, 1007);
INSERT INTO `sys_role_menu` VALUES (2, 1008);
INSERT INTO `sys_role_menu` VALUES (2, 1009);
INSERT INTO `sys_role_menu` VALUES (2, 1010);
INSERT INTO `sys_role_menu` VALUES (2, 1011);
INSERT INTO `sys_role_menu` VALUES (2, 1012);
INSERT INTO `sys_role_menu` VALUES (2, 1013);
INSERT INTO `sys_role_menu` VALUES (2, 1014);
INSERT INTO `sys_role_menu` VALUES (2, 1015);
INSERT INTO `sys_role_menu` VALUES (2, 1016);
INSERT INTO `sys_role_menu` VALUES (2, 1017);
INSERT INTO `sys_role_menu` VALUES (2, 1018);
INSERT INTO `sys_role_menu` VALUES (2, 1019);
INSERT INTO `sys_role_menu` VALUES (2, 1020);
INSERT INTO `sys_role_menu` VALUES (2, 1021);
INSERT INTO `sys_role_menu` VALUES (2, 1022);
INSERT INTO `sys_role_menu` VALUES (2, 1023);
INSERT INTO `sys_role_menu` VALUES (2, 1024);
INSERT INTO `sys_role_menu` VALUES (2, 1025);
INSERT INTO `sys_role_menu` VALUES (2, 1026);
INSERT INTO `sys_role_menu` VALUES (2, 1027);
INSERT INTO `sys_role_menu` VALUES (2, 1028);
INSERT INTO `sys_role_menu` VALUES (2, 1029);
INSERT INTO `sys_role_menu` VALUES (2, 1030);
INSERT INTO `sys_role_menu` VALUES (2, 1031);
INSERT INTO `sys_role_menu` VALUES (2, 1032);
INSERT INTO `sys_role_menu` VALUES (2, 1033);
INSERT INTO `sys_role_menu` VALUES (2, 1034);
INSERT INTO `sys_role_menu` VALUES (2, 1035);
INSERT INTO `sys_role_menu` VALUES (2, 1036);
INSERT INTO `sys_role_menu` VALUES (2, 1037);
INSERT INTO `sys_role_menu` VALUES (2, 1038);
INSERT INTO `sys_role_menu` VALUES (2, 1039);
INSERT INTO `sys_role_menu` VALUES (2, 1040);
INSERT INTO `sys_role_menu` VALUES (2, 1041);
INSERT INTO `sys_role_menu` VALUES (2, 1042);
INSERT INTO `sys_role_menu` VALUES (2, 1043);
INSERT INTO `sys_role_menu` VALUES (2, 1044);
INSERT INTO `sys_role_menu` VALUES (2, 1045);
INSERT INTO `sys_role_menu` VALUES (2, 1046);
INSERT INTO `sys_role_menu` VALUES (2, 1047);
INSERT INTO `sys_role_menu` VALUES (2, 1048);
INSERT INTO `sys_role_menu` VALUES (2, 1049);
INSERT INTO `sys_role_menu` VALUES (2, 1050);
INSERT INTO `sys_role_menu` VALUES (2, 1051);
INSERT INTO `sys_role_menu` VALUES (2, 1052);
INSERT INTO `sys_role_menu` VALUES (2, 1053);
INSERT INTO `sys_role_menu` VALUES (2, 1054);
INSERT INTO `sys_role_menu` VALUES (2, 1055);
INSERT INTO `sys_role_menu` VALUES (2, 1056);
INSERT INTO `sys_role_menu` VALUES (2, 1057);
INSERT INTO `sys_role_menu` VALUES (2, 1058);
INSERT INTO `sys_role_menu` VALUES (2, 1059);
INSERT INTO `sys_role_menu` VALUES (2, 1060);
INSERT INTO `sys_role_menu` VALUES (100, 1);
INSERT INTO `sys_role_menu` VALUES (100, 2);
INSERT INTO `sys_role_menu` VALUES (100, 3);
INSERT INTO `sys_role_menu` VALUES (100, 4);
INSERT INTO `sys_role_menu` VALUES (100, 100);
INSERT INTO `sys_role_menu` VALUES (100, 101);
INSERT INTO `sys_role_menu` VALUES (100, 102);
INSERT INTO `sys_role_menu` VALUES (100, 103);
INSERT INTO `sys_role_menu` VALUES (100, 104);
INSERT INTO `sys_role_menu` VALUES (100, 105);
INSERT INTO `sys_role_menu` VALUES (100, 106);
INSERT INTO `sys_role_menu` VALUES (100, 107);
INSERT INTO `sys_role_menu` VALUES (100, 108);
INSERT INTO `sys_role_menu` VALUES (100, 109);
INSERT INTO `sys_role_menu` VALUES (100, 110);
INSERT INTO `sys_role_menu` VALUES (100, 111);
INSERT INTO `sys_role_menu` VALUES (100, 112);
INSERT INTO `sys_role_menu` VALUES (100, 113);
INSERT INTO `sys_role_menu` VALUES (100, 114);
INSERT INTO `sys_role_menu` VALUES (100, 115);
INSERT INTO `sys_role_menu` VALUES (100, 116);
INSERT INTO `sys_role_menu` VALUES (100, 117);
INSERT INTO `sys_role_menu` VALUES (100, 500);
INSERT INTO `sys_role_menu` VALUES (100, 501);
INSERT INTO `sys_role_menu` VALUES (100, 1000);
INSERT INTO `sys_role_menu` VALUES (100, 1001);
INSERT INTO `sys_role_menu` VALUES (100, 1002);
INSERT INTO `sys_role_menu` VALUES (100, 1003);
INSERT INTO `sys_role_menu` VALUES (100, 1004);
INSERT INTO `sys_role_menu` VALUES (100, 1005);
INSERT INTO `sys_role_menu` VALUES (100, 1006);
INSERT INTO `sys_role_menu` VALUES (100, 1007);
INSERT INTO `sys_role_menu` VALUES (100, 1008);
INSERT INTO `sys_role_menu` VALUES (100, 1009);
INSERT INTO `sys_role_menu` VALUES (100, 1010);
INSERT INTO `sys_role_menu` VALUES (100, 1011);
INSERT INTO `sys_role_menu` VALUES (100, 1012);
INSERT INTO `sys_role_menu` VALUES (100, 1013);
INSERT INTO `sys_role_menu` VALUES (100, 1014);
INSERT INTO `sys_role_menu` VALUES (100, 1015);
INSERT INTO `sys_role_menu` VALUES (100, 1016);
INSERT INTO `sys_role_menu` VALUES (100, 1017);
INSERT INTO `sys_role_menu` VALUES (100, 1018);
INSERT INTO `sys_role_menu` VALUES (100, 1019);
INSERT INTO `sys_role_menu` VALUES (100, 1020);
INSERT INTO `sys_role_menu` VALUES (100, 1021);
INSERT INTO `sys_role_menu` VALUES (100, 1022);
INSERT INTO `sys_role_menu` VALUES (100, 1023);
INSERT INTO `sys_role_menu` VALUES (100, 1024);
INSERT INTO `sys_role_menu` VALUES (100, 1025);
INSERT INTO `sys_role_menu` VALUES (100, 1026);
INSERT INTO `sys_role_menu` VALUES (100, 1027);
INSERT INTO `sys_role_menu` VALUES (100, 1028);
INSERT INTO `sys_role_menu` VALUES (100, 1029);
INSERT INTO `sys_role_menu` VALUES (100, 1030);
INSERT INTO `sys_role_menu` VALUES (100, 1031);
INSERT INTO `sys_role_menu` VALUES (100, 1032);
INSERT INTO `sys_role_menu` VALUES (100, 1033);
INSERT INTO `sys_role_menu` VALUES (100, 1034);
INSERT INTO `sys_role_menu` VALUES (100, 1035);
INSERT INTO `sys_role_menu` VALUES (100, 1036);
INSERT INTO `sys_role_menu` VALUES (100, 1037);
INSERT INTO `sys_role_menu` VALUES (100, 1038);
INSERT INTO `sys_role_menu` VALUES (100, 1039);
INSERT INTO `sys_role_menu` VALUES (100, 1040);
INSERT INTO `sys_role_menu` VALUES (100, 1041);
INSERT INTO `sys_role_menu` VALUES (100, 1042);
INSERT INTO `sys_role_menu` VALUES (100, 1043);
INSERT INTO `sys_role_menu` VALUES (100, 1044);
INSERT INTO `sys_role_menu` VALUES (100, 1045);
INSERT INTO `sys_role_menu` VALUES (100, 1046);
INSERT INTO `sys_role_menu` VALUES (100, 1047);
INSERT INTO `sys_role_menu` VALUES (100, 1048);
INSERT INTO `sys_role_menu` VALUES (100, 1049);
INSERT INTO `sys_role_menu` VALUES (100, 1050);
INSERT INTO `sys_role_menu` VALUES (100, 1051);
INSERT INTO `sys_role_menu` VALUES (100, 1052);
INSERT INTO `sys_role_menu` VALUES (100, 1053);
INSERT INTO `sys_role_menu` VALUES (100, 1054);
INSERT INTO `sys_role_menu` VALUES (100, 1055);
INSERT INTO `sys_role_menu` VALUES (100, 1056);
INSERT INTO `sys_role_menu` VALUES (100, 1057);
INSERT INTO `sys_role_menu` VALUES (100, 1058);
INSERT INTO `sys_role_menu` VALUES (100, 1059);
INSERT INTO `sys_role_menu` VALUES (100, 1060);
INSERT INTO `sys_role_menu` VALUES (101, 1);
INSERT INTO `sys_role_menu` VALUES (101, 2);
INSERT INTO `sys_role_menu` VALUES (101, 3);
INSERT INTO `sys_role_menu` VALUES (101, 4);
INSERT INTO `sys_role_menu` VALUES (101, 100);
INSERT INTO `sys_role_menu` VALUES (101, 101);
INSERT INTO `sys_role_menu` VALUES (101, 102);
INSERT INTO `sys_role_menu` VALUES (101, 103);
INSERT INTO `sys_role_menu` VALUES (101, 104);
INSERT INTO `sys_role_menu` VALUES (101, 105);
INSERT INTO `sys_role_menu` VALUES (101, 106);
INSERT INTO `sys_role_menu` VALUES (101, 107);
INSERT INTO `sys_role_menu` VALUES (101, 108);
INSERT INTO `sys_role_menu` VALUES (101, 109);
INSERT INTO `sys_role_menu` VALUES (101, 110);
INSERT INTO `sys_role_menu` VALUES (101, 111);
INSERT INTO `sys_role_menu` VALUES (101, 112);
INSERT INTO `sys_role_menu` VALUES (101, 113);
INSERT INTO `sys_role_menu` VALUES (101, 114);
INSERT INTO `sys_role_menu` VALUES (101, 115);
INSERT INTO `sys_role_menu` VALUES (101, 116);
INSERT INTO `sys_role_menu` VALUES (101, 117);
INSERT INTO `sys_role_menu` VALUES (101, 500);
INSERT INTO `sys_role_menu` VALUES (101, 501);
INSERT INTO `sys_role_menu` VALUES (101, 1000);
INSERT INTO `sys_role_menu` VALUES (101, 1001);
INSERT INTO `sys_role_menu` VALUES (101, 1002);
INSERT INTO `sys_role_menu` VALUES (101, 1003);
INSERT INTO `sys_role_menu` VALUES (101, 1004);
INSERT INTO `sys_role_menu` VALUES (101, 1005);
INSERT INTO `sys_role_menu` VALUES (101, 1006);
INSERT INTO `sys_role_menu` VALUES (101, 1007);
INSERT INTO `sys_role_menu` VALUES (101, 1008);
INSERT INTO `sys_role_menu` VALUES (101, 1009);
INSERT INTO `sys_role_menu` VALUES (101, 1010);
INSERT INTO `sys_role_menu` VALUES (101, 1011);
INSERT INTO `sys_role_menu` VALUES (101, 1012);
INSERT INTO `sys_role_menu` VALUES (101, 1013);
INSERT INTO `sys_role_menu` VALUES (101, 1014);
INSERT INTO `sys_role_menu` VALUES (101, 1015);
INSERT INTO `sys_role_menu` VALUES (101, 1016);
INSERT INTO `sys_role_menu` VALUES (101, 1017);
INSERT INTO `sys_role_menu` VALUES (101, 1018);
INSERT INTO `sys_role_menu` VALUES (101, 1019);
INSERT INTO `sys_role_menu` VALUES (101, 1020);
INSERT INTO `sys_role_menu` VALUES (101, 1021);
INSERT INTO `sys_role_menu` VALUES (101, 1022);
INSERT INTO `sys_role_menu` VALUES (101, 1023);
INSERT INTO `sys_role_menu` VALUES (101, 1024);
INSERT INTO `sys_role_menu` VALUES (101, 1025);
INSERT INTO `sys_role_menu` VALUES (101, 1026);
INSERT INTO `sys_role_menu` VALUES (101, 1027);
INSERT INTO `sys_role_menu` VALUES (101, 1028);
INSERT INTO `sys_role_menu` VALUES (101, 1029);
INSERT INTO `sys_role_menu` VALUES (101, 1030);
INSERT INTO `sys_role_menu` VALUES (101, 1031);
INSERT INTO `sys_role_menu` VALUES (101, 1032);
INSERT INTO `sys_role_menu` VALUES (101, 1033);
INSERT INTO `sys_role_menu` VALUES (101, 1034);
INSERT INTO `sys_role_menu` VALUES (101, 1035);
INSERT INTO `sys_role_menu` VALUES (101, 1036);
INSERT INTO `sys_role_menu` VALUES (101, 1037);
INSERT INTO `sys_role_menu` VALUES (101, 1038);
INSERT INTO `sys_role_menu` VALUES (101, 1039);
INSERT INTO `sys_role_menu` VALUES (101, 1040);
INSERT INTO `sys_role_menu` VALUES (101, 1041);
INSERT INTO `sys_role_menu` VALUES (101, 1042);
INSERT INTO `sys_role_menu` VALUES (101, 1043);
INSERT INTO `sys_role_menu` VALUES (101, 1044);
INSERT INTO `sys_role_menu` VALUES (101, 1045);
INSERT INTO `sys_role_menu` VALUES (101, 1046);
INSERT INTO `sys_role_menu` VALUES (101, 1047);
INSERT INTO `sys_role_menu` VALUES (101, 1048);
INSERT INTO `sys_role_menu` VALUES (101, 1049);
INSERT INTO `sys_role_menu` VALUES (101, 1050);
INSERT INTO `sys_role_menu` VALUES (101, 1051);
INSERT INTO `sys_role_menu` VALUES (101, 1052);
INSERT INTO `sys_role_menu` VALUES (101, 1053);
INSERT INTO `sys_role_menu` VALUES (101, 1054);
INSERT INTO `sys_role_menu` VALUES (101, 1055);
INSERT INTO `sys_role_menu` VALUES (101, 1056);
INSERT INTO `sys_role_menu` VALUES (101, 1057);
INSERT INTO `sys_role_menu` VALUES (101, 1058);
INSERT INTO `sys_role_menu` VALUES (101, 1059);
INSERT INTO `sys_role_menu` VALUES (101, 1060);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime NULL DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 219 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '用户信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 103, 'admin', '若依', '00', 'ry@163.com', '15888888888', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2025-11-22 18:42:37', '2025-11-18 16:54:30', 'admin', '2025-11-18 16:54:30', '', '2025-11-22 18:42:37', '管理员');
INSERT INTO `sys_user` VALUES (2, 105, 'ry', '若依', '00', 'ry@qq.com', '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2025-11-18 16:54:30', '2025-11-18 16:54:30', 'admin', '2025-11-18 16:54:30', '', NULL, '测试员');
INSERT INTO `sys_user` VALUES (201, 103, 'wangwu', '王五', '00', 'wangwu@ry.com', '15888888888', '1', '', '$2a$10$3FOi3w6sPI7DrG9/XG3YvOzfzItqfGpZ1/2QAjVFlY534mOzb/VR6', '0', '0', '127.0.0.1', '2025-11-19 16:39:02', '2025-11-18 17:21:36', 'admin', '2025-11-18 17:19:58', '', '2025-11-19 16:39:01', '测试学生用户');
INSERT INTO `sys_user` VALUES (204, NULL, 'test_student_001', '测试学生001', '00', 'student001@test.com', '13800000001', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE/sttKGf6ItRm', '0', '0', '', NULL, NULL, '', '2025-11-18 17:49:25', '', NULL, NULL);
INSERT INTO `sys_user` VALUES (206, NULL, 'test-student', '测试学生', '00', '', '', '0', '', '$2a$10$FvcQHDYly7TI0.dG9bmVueQcXttEc1IhMQZW1F5RMg/t2KYOtjHMC', '0', '0', '127.0.0.1', '2025-11-18 17:54:50', NULL, 'admin', '2025-11-18 17:52:39', '', '2025-11-18 17:54:50', NULL);
INSERT INTO `sys_user` VALUES (209, NULL, '1234', 'lll', '00', 'qwkhrkhe@qq.com', '19823452345', '0', '', '$2a$10$f6hZLNe7jsmX5XSKSB2GreY7ztliJfdrXHfmNaUu8FVkBjXE4AWaS', '0', '0', '127.0.0.1', '2025-11-18 18:50:33', '2025-11-18 18:48:02', '', '2025-11-18 18:48:02', '', '2025-11-18 18:50:33', NULL);
INSERT INTO `sys_user` VALUES (210, NULL, 'ljy', 'ljy', '00', '', '', '0', '', '$2a$10$OAkliFSH3o5ScnsZLwMMluPYQLx36rlzFOu116OAoHAN04Yyi9Za6', '0', '0', '127.0.0.1', '2025-11-18 18:55:34', '2025-11-18 18:55:17', '', '2025-11-18 18:55:17', '', '2025-11-18 18:55:34', NULL);
INSERT INTO `sys_user` VALUES (211, NULL, '123', '123', '00', '', '', '0', '', '$2a$10$k89FTghIgYMXQe2mjtV9/eUBJ9etMhZRc2iznjKrXfzlfqNY1BiG6', '0', '0', '', NULL, '2025-11-18 21:05:42', '', '2025-11-18 21:05:42', '', NULL, NULL);
INSERT INTO `sys_user` VALUES (215, NULL, 'wma', 'wma', '00', '', '', '0', '', '$2a$10$A6OJkbRsVDScEkEYCLjx/Otj6aYTxS2N4bcCJfJqSaFv7dktY931.', '0', '0', '', NULL, '2025-11-18 21:10:26', '', '2025-11-18 21:10:25', '', NULL, NULL);
INSERT INTO `sys_user` VALUES (216, NULL, 'qwhrei', 'qwhrei', '00', '', '', '0', '', '$2a$10$FYz5jHUXHmepAMHcrc1Un.H1MXz9LeryaECc5qoTDSJmiTBV1usDK', '0', '0', '127.0.0.1', '2025-11-18 22:54:16', '2025-11-18 21:17:37', '', '2025-11-18 21:17:37', '', '2025-11-18 22:54:16', NULL);
INSERT INTO `sys_user` VALUES (217, NULL, 'we', 'we', '00', '', '', '0', '', '$2a$10$jILpJWswxfthwF8AjwPw6ufZTVW/eH4/dx393PrejDFUUrZd8X.oe', '0', '0', '127.0.0.1', '2025-11-19 16:39:30', '2025-11-18 22:55:20', '', '2025-11-18 22:55:20', '', '2025-11-19 16:39:30', NULL);
INSERT INTO `sys_user` VALUES (218, NULL, '123456', '123456', '00', '2138642@qq.con', '15425356782', '1', '', '$2a$10$ADUK1SwsO3YovM5yjHCFbOy4PdJ4LhTuNQU.doqVOg03i0OnU18bq', '0', '0', '127.0.0.1', '2025-11-19 16:40:47', '2025-11-19 16:40:37', '', '2025-11-19 16:40:36', '', '2025-11-19 16:42:18', NULL);

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '用户与岗位关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO `sys_user_post` VALUES (1, 1);
INSERT INTO `sys_user_post` VALUES (2, 2);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '用户和角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (2, 2);
INSERT INTO `sys_user_role` VALUES (216, 100);
INSERT INTO `sys_user_role` VALUES (217, 100);
INSERT INTO `sys_user_role` VALUES (218, 100);

-- ----------------------------
-- Table structure for teacher
-- ----------------------------
DROP TABLE IF EXISTS `teacher`;
CREATE TABLE `teacher`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '教师ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '所属院系',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '职称',
  `education` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '学历',
  `specialty` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '专业领域',
  `introduction` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '个人简介',
  `office_location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '办公地点',
  `office_hours` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '办公时间',
  `contact_email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系邮箱',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系电话',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `hire_date` datetime NULL DEFAULT NULL COMMENT '入职日期',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delete_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_department`(`department` ASC) USING BTREE,
  CONSTRAINT `fk_teacher_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2025005 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '教师表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of teacher
-- ----------------------------
INSERT INTO `teacher` VALUES (1, 1, '数学组', '主任', 'null', 'bull', 'null', 'null', '4', '1234556', '1233454667', 'ACTIVE', NULL, '2025-11-19 19:12:42', '2025-11-19 19:14:51', 0, NULL);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `sys_user_id` bigint NULL DEFAULT NULL COMMENT '关联sys_user表的user_id',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码(加密)',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `role` enum('STUDENT','TEACHER','ADMIN') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'STUDENT' COMMENT '用户角色: STUDENT=学生, TEACHER=教师, ADMIN=管理员',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE,
  UNIQUE INDEX `uk_sys_user_id`(`sys_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_user_sys_user` FOREIGN KEY (`sys_user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 1, 'admin', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 'ry@163.com', '若依', '', 'STUDENT', 'ACTIVE', '2025-11-19 19:14:42', '2025-11-22 18:42:37');
INSERT INTO `user` VALUES (19, 201, 'wangwu', '$2a$10$3FOi3w6sPI7DrG9/XG3YvOzfzItqfGpZ1/2QAjVFlY534mOzb/VR6', 'wangwu@ry.com', '王五', '', 'TEACHER', 'ACTIVE', '2025-11-18 17:19:58', '2025-11-19 16:39:01');
INSERT INTO `user` VALUES (22, 204, 'test_student_001', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE/sttKGf6ItRm', 'student001@test.com', '测试学生001', '', 'STUDENT', 'ACTIVE', '2025-11-18 17:49:25', NULL);
INSERT INTO `user` VALUES (24, 206, 'test-student', '$2a$10$FvcQHDYly7TI0.dG9bmVueQcXttEc1IhMQZW1F5RMg/t2KYOtjHMC', NULL, '测试学生', '', 'STUDENT', 'ACTIVE', '2025-11-18 17:52:39', '2025-11-18 18:45:35');
INSERT INTO `user` VALUES (27, 209, '1234', '$2a$10$f6hZLNe7jsmX5XSKSB2GreY7ztliJfdrXHfmNaUu8FVkBjXE4AWaS', 'qwkhrkhe@qq.com', 'lll', '', 'STUDENT', 'ACTIVE', '2025-11-18 18:48:02', '2025-11-18 18:50:33');
INSERT INTO `user` VALUES (28, 210, 'ljy', '$2a$10$OAkliFSH3o5ScnsZLwMMluPYQLx36rlzFOu116OAoHAN04Yyi9Za6', NULL, 'ljy', '', 'STUDENT', 'ACTIVE', '2025-11-18 18:55:17', '2025-11-18 18:55:34');
INSERT INTO `user` VALUES (29, 211, '123', '$2a$10$k89FTghIgYMXQe2mjtV9/eUBJ9etMhZRc2iznjKrXfzlfqNY1BiG6', NULL, '123', '', 'STUDENT', 'ACTIVE', '2025-11-18 21:05:42', NULL);
INSERT INTO `user` VALUES (33, 215, 'wma', '$2a$10$A6OJkbRsVDScEkEYCLjx/Otj6aYTxS2N4bcCJfJqSaFv7dktY931.', NULL, 'wma', '', 'STUDENT', 'ACTIVE', '2025-11-18 21:10:25', NULL);
INSERT INTO `user` VALUES (34, 216, 'qwhrei', '$2a$10$FYz5jHUXHmepAMHcrc1Un.H1MXz9LeryaECc5qoTDSJmiTBV1usDK', NULL, 'qwhrei', '', 'STUDENT', 'ACTIVE', '2025-11-18 21:17:37', '2025-11-18 22:54:16');
INSERT INTO `user` VALUES (35, 217, 'we', '$2a$10$jILpJWswxfthwF8AjwPw6ufZTVW/eH4/dx393PrejDFUUrZd8X.oe', NULL, 'we', '', 'STUDENT', 'ACTIVE', '2025-11-18 22:55:20', '2025-11-19 16:39:30');
INSERT INTO `user` VALUES (36, 218, '123456', '$2a$10$ADUK1SwsO3YovM5yjHCFbOy4PdJ4LhTuNQU.doqVOg03i0OnU18bq', '2138642@qq.con', '123456', '', 'STUDENT', 'ACTIVE', '2025-11-19 16:40:36', '2025-11-19 16:42:18');

-- ----------------------------
-- Table structure for video
-- ----------------------------
DROP TABLE IF EXISTS `video`;
CREATE TABLE `video`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '视频ID',
  `course_id` bigint NOT NULL COMMENT '课程ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '视频标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '视频描述',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '视频文件路径',
  `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小（字节）',
  `duration` int NULL DEFAULT NULL COMMENT '时长（秒）',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图片路径',
  `resolution` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分辨率（如：1080p）',
  `knowledge_point_ids` json NULL COMMENT '关联的知识点ID列表',
  `status` enum('uploading','processing','published','offline') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'uploading' COMMENT '状态',
  `view_count` int NULL DEFAULT 0 COMMENT '观看次数',
  `uploaded_by` bigint NULL DEFAULT NULL COMMENT '上传者ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_id`(`course_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_uploaded_by`(`uploaded_by` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '视频表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of video
-- ----------------------------
INSERT INTO `video` VALUES (1, 33, '1', NULL, '/profile/upload/2025/11/20/1_20251120193138A003.mp4', 147906858, NULL, '/profile/upload/2025/11/20/2_20251120193202A004.jpg', NULL, NULL, 'uploading', 0, NULL, '2025-11-20 19:32:04', '2025-11-20 19:32:04');
INSERT INTO `video` VALUES (2, 33, '2', NULL, '/profile/upload/2025/11/20/2_20251120193433A005.mp4', 246070345, NULL, '/profile/upload/2025/11/20/2_20251120193445A006.jpg', NULL, NULL, 'uploading', 0, NULL, '2025-11-20 19:34:50', '2025-11-20 19:34:50');
INSERT INTO `video` VALUES (3, 33, '3', NULL, '/profile/upload/2025/11/20/3_20251120193505A007.mp4', 158089476, NULL, '/profile/upload/2025/11/20/2_20251120193521A008.jpg', NULL, NULL, 'uploading', 0, NULL, '2025-11-20 19:35:22', '2025-11-20 19:35:22');
INSERT INTO `video` VALUES (4, 33, '4', NULL, '/profile/upload/2025/11/20/4_20251120193544A010.mp4', 397140764, NULL, '/profile/upload/2025/11/20/2_20251120193541A009.jpg', NULL, NULL, 'uploading', 0, NULL, '2025-11-20 19:35:53', '2025-11-20 19:35:53');

-- ----------------------------
-- Table structure for video_learning_behavior
-- ----------------------------
DROP TABLE IF EXISTS `video_learning_behavior`;
CREATE TABLE `video_learning_behavior`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '行为ID',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `video_id` bigint NOT NULL COMMENT '视频ID',
  `watch_duration` int NULL DEFAULT 0 COMMENT '观看时长（秒）',
  `video_duration` int NULL DEFAULT NULL COMMENT '视频总时长（秒）',
  `completion_rate` decimal(5, 2) NULL DEFAULT NULL COMMENT '完成率（%）',
  `watch_count` int NULL DEFAULT 1 COMMENT '观看次数',
  `heatmap_data` json NULL COMMENT '热力图数据',
  `is_completed` tinyint NULL DEFAULT 0 COMMENT '是否看完：1-是 0-否',
  `fast_forward_count` int NULL DEFAULT 0 COMMENT '快进次数',
  `pause_count` int NULL DEFAULT 0 COMMENT '暂停次数',
  `playback_speed` decimal(2, 1) NULL DEFAULT 1.0 COMMENT '播放倍速',
  `first_watch_at` timestamp NULL DEFAULT NULL COMMENT '首次观看时间',
  `last_watch_at` timestamp NULL DEFAULT NULL COMMENT '最近观看时间',
  `last_position` bigint NULL DEFAULT 0 COMMENT '上次观看位置（秒）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_student_video`(`student_id` ASC, `video_id` ASC) USING BTREE,
  INDEX `idx_student_id`(`student_id` ASC) USING BTREE,
  INDEX `idx_video_id`(`video_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '视频学习行为表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of video_learning_behavior
-- ----------------------------
INSERT INTO `video_learning_behavior` VALUES (89, 1, 1, 12, 1814, 0.66, 9, NULL, 0, 0, 0, 1.0, '2025-11-20 00:00:00', '2025-11-21 00:00:00', 10, '2025-11-20 20:32:11', '2025-11-21 20:54:20');
INSERT INTO `video_learning_behavior` VALUES (92, 1, 2, 2871, 2871, 100.00, 9, NULL, 1, 5, 2, 2.0, '2025-11-20 00:00:00', '2025-11-21 00:00:00', 3, '2025-11-20 20:37:03', '2025-11-21 13:11:23');
INSERT INTO `video_learning_behavior` VALUES (96, 1, 3, 10, 1946, 0.51, 5, NULL, 0, 0, 0, 1.0, '2025-11-20 00:00:00', '2025-11-21 00:00:00', 10, '2025-11-20 20:37:44', '2025-11-21 13:11:25');

-- ----------------------------
-- Triggers structure for table sys_user
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_sys_user_insert`;
delimiter ;;
CREATE TRIGGER `trg_sys_user_insert` AFTER INSERT ON `sys_user` FOR EACH ROW BEGIN
    INSERT INTO `user` (
        `sys_user_id`,
        `username`,
        `password`,
        `email`,
        `real_name`,
        `avatar`,
        `role`,
        `status`,
        `create_time`,
        `update_time`
    ) VALUES (
        NEW.user_id,
        NEW.user_name,
        NEW.password,
        NULLIF(NEW.email, ''),
        NEW.nick_name,
        NEW.avatar,
        CASE
            WHEN NEW.user_type = 'STUDENT' THEN 'STUDENT'
            WHEN NEW.user_type = 'TEACHER' THEN 'TEACHER'
            ELSE 'STUDENT'
        END,
        CASE
            WHEN NEW.status = '0' THEN 'ACTIVE'
            WHEN NEW.status = '1' THEN 'INACTIVE'
            ELSE 'ACTIVE'
        END,
        NEW.create_time,
        NEW.update_time
    );
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table sys_user
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_sys_user_delete`;
delimiter ;;
CREATE TRIGGER `trg_sys_user_delete` AFTER UPDATE ON `sys_user` FOR EACH ROW BEGIN
    -- 若依使用软删除（del_flag = '2'）
    IF NEW.del_flag = '2' THEN
        UPDATE `user` SET
            `status` = 'DELETED',
            `update_time` = NOW()
        WHERE `sys_user_id` = NEW.user_id;
    END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table sys_user
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_sys_user_update`;
delimiter ;;
CREATE TRIGGER `trg_sys_user_update` AFTER UPDATE ON `sys_user` FOR EACH ROW BEGIN
    UPDATE `user` SET
        `username` = NEW.user_name,
        `password` = NEW.password,
        `email` = NULLIF(NEW.email, ''),
        `real_name` = NEW.nick_name,
        `avatar` = NEW.avatar,
        `status` = CASE
            WHEN NEW.status = '0' THEN 'ACTIVE'
            WHEN NEW.status = '1' THEN 'INACTIVE'
            ELSE 'ACTIVE'
        END,
        `update_time` = NEW.update_time
    WHERE `sys_user_id` = NEW.user_id;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
