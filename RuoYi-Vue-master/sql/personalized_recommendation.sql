/*
 Navicat Premium Data Transfer

 Source Server         : 111
 Source Server Type    : MySQL
 Source Server Version : 90300 (9.3.0)
 Source Host           : localhost:3306
 Source Schema         : smartclassv2

 Target Server Type    : MySQL
 Target Server Version : 90300 (9.3.0)
 File Encoding         : 65001

 Date: 30/11/2025 13:17:28
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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
  `batch_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '推荐批次ID（每次获取推荐生成唯一值）',
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
) ENGINE = InnoDB AUTO_INCREMENT = 271 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI个性化推荐记录表（存储学习建议）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of personalized_recommendation
-- ----------------------------
INSERT INTO `personalized_recommendation` VALUES (67, 24, 123, 'video', 10001, '2. **推荐动作：观看视频**  \n   **视频URL**：http://edu-platform.com/videos/123/10005.mp4  \n   **重点关注内容**：【3.2 日志分析与断点调试】日志定位与IDE断点使用  \n   **对应错题**：作业《算法数据结构&Python实践专项作业》（ID：30000）第7题  \n   **执行建议**：掌握日志分析技巧，熟悉IDE断点调试操作，提升问题定位能力。', '1002', 'viewed', 3, 'qwen-turbo', '2dee23b2126d4102a8fcd95db9e311a7', '2025-11-24 00:24:29', '2025-12-01 00:24:30', '2025-11-24 00:32:00', 0);
INSERT INTO `personalized_recommendation` VALUES (68, 24, 123, 'video', 10005, '3. **推荐动作：复习知识点**  \n   **重点关注内容**：【1.1 时间复杂度分析实战】大O表示法、时间复杂度计算步骤  \n   **对应错题**：作业《算法数据结构&Python实践专项作业》（ID：30000）第2题、第4题、第7题、第9题  \n   **执行建议**：回顾时间复杂度分析的计算方式，强化对常见算法的时间复杂度判断能力。', '4001', 'pending', 3, 'qwen-turbo', '2dee23b2126d4102a8fcd95db9e311a7', '2025-11-24 00:24:29', '2025-12-01 00:24:30', '2025-11-24 00:24:29', 0);
INSERT INTO `personalized_recommendation` VALUES (69, 24, 123, 'kp_review', 1001, '4. **推荐动作：复习知识点**  \n   **重点关注内容**：【2.2 二叉树遍历实战】前/中/后序遍历（递归+迭代）  \n   **对应错题**：作业《算法数据结构&Python实践专项作业》（ID：30000）第4题、第10题  \n   **执行建议**：巩固二叉树遍历的实现逻辑，尤其注意递归与迭代的转换方式。', '1001', 'pending', 3, 'qwen-turbo', '2dee23b2126d4102a8fcd95db9e311a7', '2025-11-24 00:24:29', '2025-12-01 00:24:30', '2025-11-24 00:24:29', 0);
INSERT INTO `personalized_recommendation` VALUES (70, 24, 123, 'kp_review', 2002, '5. **推荐动作：完成习题**  \n   **重点关注内容**：【1.2 空间复杂度优化技巧】空间复杂度优化相关题目  \n   **对应错题**：作业《算法数据结构&Python实践专项作业》（ID：30000）第2题、第9题  \n   **执行建议**：通过练习题强化对空间复杂度优化的理解，提高代码效率。', '2002', 'pending', 3, 'qwen-turbo', '2dee23b2126d4102a8fcd95db9e311a7', '2025-11-24 00:24:29', '2025-12-01 00:24:30', '2025-11-24 00:24:29', 0);
INSERT INTO `personalized_recommendation` VALUES (71, 24, 123, 'exercise', 300002, '6. **推荐动作：完成习题**  \n   **重点关注内容**：【3.2 日志分析与断点调试】日志定位与IDE断点使用  \n   **对应错题**：作业《算法数据结构&Python实践专项作业》（ID：30000）第7题  \n   **执行建议**：针对日志分析技巧进行专项训练，提升调试能力。', '1002', 'pending', 3, 'qwen-turbo', '2dee23b2126d4102a8fcd95db9e311a7', '2025-11-24 00:24:29', '2025-12-01 00:24:30', '2025-11-24 00:24:29', 0);
INSERT INTO `personalized_recommendation` VALUES (98, 37, 123, 'video', 10002, ' 2. 【空间复杂度优化】  \n- **推荐动作**：观看视频  \n- **视频URL**：http://edu-platform.com/videos/123/10001.mp4  \n- **重点关注内容**：【1.2 空间复杂度优化技巧】原地算法、内存占用优化，贪心策略应用  \n- **对应错题**：作业《算法数据结构&Python实践专项作业》（ID：30000）第2题、第9题  \n- **执行建议**：复习如何通过优化算法减少内存使用', '2001', 'pending', 3, 'qwen-turbo', 'c0f0c82b75304b889d05d583eda81186', '2025-11-25 16:53:50', '2025-12-02 16:53:50', '2025-11-25 16:55:32', 0);
INSERT INTO `personalized_recommendation` VALUES (99, 37, 123, 'video', 10001, '### 3. 【Python语法规范】  \n- **推荐动作**：观看视频  \n- **视频URL**：http://edu-platform.com/videos/123/10004.mp4  \n- **重点关注内容**：【3.1 Python语法规范与框架调用】PEP8规范、requests/pandas框架调用  \n- **对应错题**：作业《算法数据结构&Python实践专项作业》（ID：30000）第5题  \n- **执行建议**：注意代码风格和常用库的正确使用方法', '1002', 'pending', 3, 'qwen-turbo', 'c0f0c82b75304b889d05d583eda81186', '2025-11-25 16:53:50', '2025-12-02 16:53:50', '2025-11-25 16:53:50', 0);
INSERT INTO `personalized_recommendation` VALUES (100, 37, 123, 'video', 10004, '### 4. 【时间复杂度分析】  \n- **推荐动作**：观看视频  \n- **视频URL**：http://edu-platform.com/videos/123/10000.mp4  \n- **重点关注内容**：【1.1 时间复杂度分析实战】大O表示法、时间复杂度计算步骤，真题案例拆解  \n- **对应错题**：作业《算法数据结构&Python实践专项作业》（ID：30000）第2题、第9题  \n- **执行建议**：强化对常见算法的时间复杂度分析能力', '3001', 'pending', 3, 'qwen-turbo', 'c0f0c82b75304b889d05d583eda81186', '2025-11-25 16:53:50', '2025-12-02 16:53:50', '2025-11-25 16:53:50', 0);
INSERT INTO `personalized_recommendation` VALUES (101, 37, 123, 'video', 10000, '### 5. 【二叉树遍历】  \n- **推荐动作**：观看视频  \n- **视频URL**：http://edu-platform.com/videos/123/10003.mp4  \n- **重点关注内容**：【2.2 二叉树遍历实战】前/中/后序遍历（递归+迭代）  \n- **对应错题**：作业《算法数据结构&Python实践专项作业》（ID：30000）第4题、第10题  \n- **执行建议**：练习不同遍历方式的实现逻辑', '1001', 'pending', 3, 'qwen-turbo', 'c0f0c82b75304b889d05d583eda81186', '2025-11-25 16:53:50', '2025-12-02 16:53:50', '2025-11-25 16:53:50', 0);
INSERT INTO `personalized_recommendation` VALUES (102, 37, 123, 'video', 10003, '### 6. 【Python框架调用】  \n- **推荐动作**：观看视频  \n- **视频URL**：http://edu-platform.com/videos/123/10004.mp4  \n- **重点关注内容**：【3.1 Python语法规范与框架调用】PEP8规范、requests/pandas框架调用  \n- **对应错题**：作业《算法数据结构&Python实践专项作业》（ID：30000）第6题  \n- **执行建议**：熟悉常用Python库的调用方式和规范', '2002', 'pending', 3, 'qwen-turbo', 'c0f0c82b75304b889d05d583eda81186', '2025-11-25 16:53:50', '2025-12-02 16:53:50', '2025-11-25 16:53:50', 0);
INSERT INTO `personalized_recommendation` VALUES (103, 37, 123, 'video', 10004, '### 7. 【日志分析技巧】  \n- **推荐动作**：观看视频  \n- **视频URL**：http://edu-platform.com/videos/123/10005.mp4  \n- **重点关注内容**：【3.2 日志分析与断点调试】日志定位、IDE断点调试方法  \n- **对应错题**：作业《算法数据结构&Python实践专项作业》（ID：30000）第7题  \n- **执行建议**：学习如何通过日志快速定位程序问题', '3002', 'pending', 3, 'qwen-turbo', 'c0f0c82b75304b889d05d583eda81186', '2025-11-25 16:53:50', '2025-12-02 16:53:50', '2025-11-25 16:53:50', 0);
INSERT INTO `personalized_recommendation` VALUES (104, 37, 123, 'video', 10005, '以上推荐内容已按规则严格整理，可直接用于学生学习路径规划。如需进一步定制习题或资料推荐，也可继续补充。', '4001', 'pending', 3, 'qwen-turbo', 'c0f0c82b75304b889d05d583eda81186', '2025-11-25 16:53:50', '2025-12-02 16:53:50', '2025-11-25 16:53:50', 0);
INSERT INTO `personalized_recommendation` VALUES (193, 1, 33, 'resource', 4001, '2、知识点ID=4005（等价无穷小）  \n- 推荐动作：复习等价无穷小替换技巧，提升解题准确率  \n- 视频位置：【1.极限】等价无穷小  \n- 重点关注内容：【1.极限】等价无穷小 等价无穷小替换技巧  \n- 对应错题：作业《第一章 极限基础练习》（ID：4001）第5题\n- 执行建议：加强对等价无穷小的应用方法，尤其是结合极限计算 关联知识点：4005,4010 目标ID：4001,4002', '4005,4010', 'pending', 3, 'qwen-turbo', '6c9bc2499e37451ab1e8524caafeb8d9', '2025-11-26 16:44:40', '2025-12-03 16:44:40', '2025-11-26 16:44:40', 0);
INSERT INTO `personalized_recommendation` VALUES (194, 1, 33, 'resource', 4001, '3、知识点ID=4032（反函数的图像对称性）  \n- 推荐动作：观看视频，理解反函数与原函数图像的对称关系  \n- 视频位置：【2.函数】函数的应用  \n- 重点关注内容：【2.函数】函数的应用 反函数的图像对称性原理  \n- 对应错题：作业《第一章 极限基础练习》（ID：4001）第5题\n- 执行建议：通过视频学习对称性质，配合例题加深理解 关联知识点：4032,4005 目标ID：4004,4015', '4005,4010', 'pending', 3, 'qwen-turbo', '6c9bc2499e37451ab1e8524caafeb8d9', '2025-11-26 16:44:40', '2025-12-03 16:44:40', '2025-11-26 16:44:40', 0);
INSERT INTO `personalized_recommendation` VALUES (195, 1, 33, 'video', 4004, '4、知识点ID=4021（函数的单调性）  \n- 推荐动作：强化函数单调性判断方法，提高解题正确率  \n- 视频位置：【2.函数】函数的应用  \n- 重点关注内容：【2.函数】函数的应用 函数的单调性判定方法  \n- 对应错题：无\n- 执行建议：结合单调性定义与导数分析，提升解题能力 关联知识点：4021,4015 目标ID：4003,4004', '4005,4032', 'pending', 3, 'qwen-turbo', '6c9bc2499e37451ab1e8524caafeb8d9', '2025-11-26 16:44:40', '2025-12-03 16:44:40', '2025-11-26 16:44:40', 0);
INSERT INTO `personalized_recommendation` VALUES (196, 1, 33, 'resource', 4003, '5、知识点ID=4009（洛必达法则）  \n- 推荐动作：复习洛必达法则的应用条件和步骤  \n- 视频位置：【1.极限】等价无穷小  \n- 重点关注内容：【1.极限】等价无穷小 洛必达法则的应用场景  \n- 对应错题：无\n- 执行建议：掌握洛必达法则适用条件，避免误用 关联知识点：4009,4005 目标ID：4002,4004', '4015,4021', 'pending', 3, 'qwen-turbo', '6c9bc2499e37451ab1e8524caafeb8d9', '2025-11-26 16:44:40', '2025-12-03 16:44:40', '2025-11-26 16:44:40', 0);
INSERT INTO `personalized_recommendation` VALUES (197, 1, 33, 'resource', 4002, '6、知识点ID=4008（泰勒展开）  \n- 推荐动作：学习泰勒展开在极限计算中的应用方法  \n- 视频位置：【1.极限】等价无穷小  \n- 重点关注内容：【1.极限】等价无穷小 泰勒展开用于极限计算  \n- 对应错题：无\n- 执行建议：结合泰勒展开公式进行极限问题训练 关联知识点：4008,4005 目标ID：4002,4004', '4005,4009', 'pending', 3, 'qwen-turbo', '6c9bc2499e37451ab1e8524caafeb8d9', '2025-11-26 16:44:40', '2025-12-03 16:44:40', '2025-11-26 16:44:40', 0);
INSERT INTO `personalized_recommendation` VALUES (198, 1, 33, 'resource', 4002, '总结建议：  \n针对“极限的唯一性（4010）”“等价无穷小（4005）”“反函数的图像对称性（4032）”等薄弱知识点，建议优先观看视频掌握核心概念，再通过对应错题和习题强化训练；“函数的单调性（4021）”需重点巩固解题技巧，提升准确率。', '4005,4008', 'pending', 3, 'qwen-turbo', '6c9bc2499e37451ab1e8524caafeb8d9', '2025-11-26 16:44:40', '2025-12-03 16:44:40', '2025-11-26 16:44:40', 0);

SET FOREIGN_KEY_CHECKS = 1;
