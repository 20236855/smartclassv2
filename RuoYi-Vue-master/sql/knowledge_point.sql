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

 Date: 28/11/2025 14:38:52
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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
) ENGINE = InnoDB AUTO_INCREMENT = 4128 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识点表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `knowledge_point` VALUES (1001, 123, '时间复杂度分析', '掌握大O表示法、时间复杂度计算方法', 'INTERMEDIATE', 19, '2025-11-20 11:12:33', '2025-11-20 22:34:56', 0, NULL);
INSERT INTO `knowledge_point` VALUES (1002, 123, '空间复杂度优化', '学习减少内存占用的算法优化技巧', 'ADVANCED', 19, '2025-11-20 11:12:33', '2025-11-20 22:35:01', 0, NULL);
INSERT INTO `knowledge_point` VALUES (2001, 123, '链表原理与实现', '单链表、双链表的构造与常用操作', 'BASIC', 19, '2025-11-20 11:12:33', '2025-11-20 22:35:05', 0, NULL);
INSERT INTO `knowledge_point` VALUES (2002, 123, '二叉树遍历', '前序、中序、后序遍历的递归/迭代实现', 'INTERMEDIATE', 19, '2025-11-20 11:12:33', '2025-11-20 22:35:11', 0, NULL);
INSERT INTO `knowledge_point` VALUES (3001, 123, 'Python语法规范', 'PEP8规范、代码可读性优化', 'BASIC', 19, '2025-11-20 11:12:33', '2025-11-20 22:35:15', 0, NULL);
INSERT INTO `knowledge_point` VALUES (3002, 123, 'Python框架调用', '学习requests、pandas等常用框架使用', 'INTERMEDIATE', 19, '2025-11-20 11:12:33', '2025-11-20 22:35:19', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4001, 123, '日志分析技巧', '通过日志定位代码执行异常', 'INTERMEDIATE', 19, '2025-11-20 11:12:33', '2025-11-20 22:35:23', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4002, 123, '断点调试方法', '使用IDE断点调试Python代码', 'BASIC', 19, '2025-11-20 11:12:33', '2025-11-20 11:12:33', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4003, 33, '数列极限', '数列极限是指当n趋近于无穷大时，数列的项趋近于某个特定值。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:00:31', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4004, 33, '极限的四则运算法则', '两个函数极限的和、差、积、商（分母极限不为0）等于极限的相应运算结果。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:00:36', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4005, 33, '等价无穷小', '在极限运算中，当x趋近于0时，不同函数的极限趋于0，但它们之间可以用等价无穷小替换计算。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:00:41', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4006, 33, '夹逼定理', '用于求被两个极限相同的函数夹在中间的函数的极限。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:00:46', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4007, 33, '无穷小量', '当x趋近于某点时，函数值趋近于0的量。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:00:50', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4008, 33, '泰勒展开', '用多项式近似表示函数的一种方法，用于求极限时可以替换无穷小量。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:00:58', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4009, 33, '洛必达法则', '用于求解0/0或∞/∞型未定式极限的一种方法。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:01:04', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4010, 33, '极限的唯一性', '若一个极限存在，则其值唯一。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:01:09', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4011, 33, '极限的局部有界性', '若一个极限存在，则在x足够接近某点时，函数值有界。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:01:13', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4012, 33, '极限的局部保号性', '若一个极限存在且为正，函数值在x足够接近某点时也保持正号。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:01:19', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4013, 33, '连续的充要条件', '函数在某点连续的充要条件是其极限值等于函数值。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:01:33', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4014, 33, '函数的定义域', '函数的定义域是使函数有意义的自变量x的取值范围。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:01:39', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4015, 33, '反函数', '反函数是原函数中因变量和自变量互换后的新函数。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:01:44', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4016, 33, '奇函数', '满足f(-x) = -f(x)的函数。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:01:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4017, 33, '偶函数', '满足f(-x) = f(x)的函数。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:01:55', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4018, 33, '周期函数', '函数的取值在一定周期后重复出现的函数。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:02:02', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4019, 33, '复合函数的定义域', '复合函数的定义域是内层函数的定义域且同时满足外层函数的定义域。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4020, 33, '初等函数的连续性', '初等函数在其定义域内是连续的。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4021, 33, '函数的单调性', '函数在某个区间内随着自变量的增加而增大或减小的性质。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4022, 33, '极限的性质', '极限具有唯一性、局部有界性、局部保号性等性质。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4023, 33, '严格单调函数', '在整个定义域内单调递增或递减的函数。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4024, 33, '基本初等函数', '基本的函数类型，包括幂函数、指数函数、对数函数、三角函数及反三角函数。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4025, 33, '反函数的对称性', '原函数与反函数的图像关于直线y=x对称。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4026, 33, '反函数的定义域和值域互换', '反函数的定义域是原函数的值域，值域是原函数的定义域。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4027, 33, '极限不存在的情况', '当函数值在趋近过程中不断振荡或无限增加时，极限不存在。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4028, 33, '函数的连续性', '函数在某点连续是指极限值等于函数值。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4029, 33, '洛必达法则的应用', '用于计算0/0或∞/∞型极限的方法。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4030, 33, '等价无穷小替换', '在极限计算中，某些函数可以近似表示为其他等价形式以简化计算。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4031, 33, '反函数的单调性', '单调函数一定存在反函数。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4032, 33, '反函数的图像对称性', '原函数和其反函数的图像关于y=x对称。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4033, 33, '给定函数求值域', '通过函数的定义及其变化趋势确定所有可能的函数输出值。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4034, 33, '奇函数的性质', '奇函数在原点处定义时，函数值为0。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4035, 33, '复合函数的周期', '多个函数组合成的函数周期会受到内部函数的周期影响。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4036, 33, '泰勒展开用于极限计算', '通过将函数展开为泰勒级数来近似求解极限的方法。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4037, 33, '函数可导性', '函数在其定义域内是否有导数的能力。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4038, 33, '函数定义域的变化', '在复合函数中，需要考虑内部函数和外部函数定义域的交集。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4039, 33, '反函数的计算', '将原函数中的变量互换并解出以得到反函数。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4040, 33, '函数图像的对称性', '奇函数图像关于原点对称，偶函数图像关于y轴对称。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4041, 33, '函数的周期性', '函数在一定周期后重复出现的特性。', 'BASIC', 19, '2025-11-25 21:34:43', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4042, 33, '函数的定义', '函数是从一个集合到另一个集合的映射，每个自变量对应唯一的因变量', 'BASIC', 19, '2025-11-25 22:54:38', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4043, 33, '函数的值域', '函数的值域是指所有可能的因变量值的集合', 'BASIC', 19, '2025-11-25 22:54:38', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4044, 33, '函数的对应法则', '函数的对应法则是指从定义域到值域的映射规则', 'BASIC', 19, '2025-11-25 22:54:38', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4045, 33, '函数的奇偶性', '函数的奇偶性是指函数关于原点或y轴对称的性质', 'BASIC', 19, '2025-11-25 22:54:38', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4046, 33, '导数的定义', '导数是函数在某一点的变化率，即函数值的增量与自变量增量的比值的极限', 'BASIC', 19, '2025-11-25 22:54:38', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4047, 33, '导数的几何意义', '导数的几何意义是函数图像在某一点的切线斜率', 'BASIC', 19, '2025-11-25 22:54:38', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4048, 33, '连续性的定义', '函数在某一点连续是指该点的极限值等于函数值', 'BASIC', 19, '2025-11-25 22:54:38', '2025-11-26 10:10:22', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4049, 33, '数列极限', '对于任意ε>0，存在N，当n>N时，|xₙ - a| < ε成立，则称数列{xₙ}收敛于a', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4050, 33, '极限', '函数在某点趋近于某个值的趋势，定义为当自变量接近某个值时，函数值趋近于确定的值', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4051, 33, '无穷小量', '当x→0时，函数值趋近于0的量', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4052, 33, '函数连续性', '函数在某点连续的充要条件是：lim(x→x₀) f(x) = f(x₀)，即极限值等于函数值', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4053, 33, '极限的四则运算法则', '两个函数极限的和等于极限的和；差、积、商（分母极限不为0）也遵循相同规则', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4054, 33, '等价无穷小', '当x→0时，两个无穷小量的比值的极限为1，称为等价无穷小', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4055, 33, '夹逼定理', '适用于被两个极限相同的函数夹在中间的函数求极限', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4056, 33, '洛必达法则', '用于求解0/0或∞/∞类型的极限，通过求导分子分母再求极限', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4057, 33, '泰勒展开', '将函数在某一点附近用无穷级数展开的方法，用于近似计算极限', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4058, 33, '反函数', '若函数f(x)为一一对应，则存在反函数f⁻¹(x)，其定义域与值域交换', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4059, 33, '函数解析表达式', '用数学公式表示函数的具体形式', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4060, 33, '变量替换法', '通过替换变量以简化函数表达式的方法', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4061, 33, '配方法', '对二次函数进行整理以化为标准形式的方法', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4062, 33, '函数的定义域', '使得函数有意义的自变量的取值范围', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4063, 33, '函数的值域', '函数所有可能的输出值的集合', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4064, 33, '二次函数', '形如 f(x) = ax² + bx + c 的函数', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4065, 33, '代数变换', '通过代数运算将函数表达式转化为等价形式', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4066, 33, '函数等价变形', '通过代数操作将函数表达式转换为等价形式', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4067, 33, '变量替换', '用另一个变量代替原变量以解释函数关系的方法', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:50', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4068, 33, '简化函数表达式', '消除冗余项，使函数表达式更简洁', 'BASIC', 1, '2025-11-27 18:31:50', '2025-11-27 18:31:50', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4069, 33, '隐函数', '由方程F(x, y)=0所确定的函数，其中y不能显式地表示为x的函数', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:39', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4070, 33, '显函数', '可以用解析式直接表示为y=f(x)的函数', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:39', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4071, 33, '导数', '函数在某一点的瞬时变化率', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4072, 33, '隐函数求导', '对隐函数F(x, y)=0两边同时对x求导，然后解出dy/dx的方法', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4073, 33, '对数求导法', '在求导前，将方程两边取对数，再对x求导的方法', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4074, 33, '参数方程求导', '对于用参数方程表示的曲线，求其切线斜率的方法是通过参数对时间求导并计算dy/dx', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4075, 33, '链式法则', '复合函数求导法则，即外函数对内函数的导数乘以内函数对自变量的导数', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4076, 33, '复合函数', '由基本函数通过运算组合而成的函数，例如y=f(g(x))', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4077, 33, '单调性', '函数在定义域内递增或递减的性质，且每个x值对应唯一y值', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4078, 33, '导数的应用', '通过求导解决实际问题，如瞬时变化率、函数极值等', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4079, 33, '参数方程', '由参数方程确定的函数，其自变量通过参数间接联系', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4080, 33, '高阶导数', '对一个函数的一阶导数再次求导得到的导数，通常表示为二阶导数', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4081, 33, '极限', '当自变量趋近于某个值时，函数值的趋向性', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4082, 33, '微分法则', '求导的基本规则，包括和差、积商、链式法则等', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4083, 33, '最速降线问题', '历史上的经典问题，寻找两点间使物体在重力作用下以最短时间滑到的曲线', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4084, 33, '相关变化率', '两个相关变量随时间变化而变化，已知其中一个的变化率求另一个的变化率', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4085, 33, '切线斜率', '曲线在某点处的切线的斜率，即该点处的导数', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4086, 33, '体积与高度的关系', '容器内水体积随水面高度变化的关系，可用于相关变化率问题', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4087, 33, '切线', '与曲线在某一点相切的直线', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4088, 33, '求导法则', '求导的运算规则，包括链式法则、乘积法则等', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4089, 33, '数列极限', '对于任意ε>0，存在N，当n>N时，|xₙ - a| < ε成立，则称数列{xₙ}收敛于a', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4090, 33, '极限的四则运算法则', '两个函数极限的和、差、积、商（分母极限不为0）等于它们的和、差、积、商的极限', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4091, 33, '等价无穷小', '当x→0时，某些函数趋于0的速度相近，它们可以相互替代以简化极限计算', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4092, 33, '无穷大量', '当x→a时，若函数f(x)的极限为无穷大，则称f(x)为x→a时的无穷大量', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4093, 33, '夹逼定理', '适用于被两个极限相同的函数夹在中间的函数求极限', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4094, 33, '函数连续性', '函数在某点连续的充要条件是：lim(x→x₀) f(x) = f(x₀)，即极限值等于函数值', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4095, 33, '极限的唯一性', '若极限存在，则其值唯一', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4096, 33, '极限的局部有界性', '若极限存在，则在该点附近函数是有界的', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4097, 33, '极限的局部保号性', '若极限存在且为正，则在该点附近函数值为正', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4098, 33, '函数表达式变换', '通过变量替换将函数的自变量进行转换，以简化函数形式', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4099, 33, '配方法', '将多项式通过重新排列和组合，转化为平方项或其他标准形式的方法', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4100, 33, '代数替换法', '用一个新变量代替原函数中的某个表达式，进而化简函数', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4101, 33, '函数求值', '代入自变量的值计算函数的具体结果', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4102, 33, '二次函数', '形如 f(x) = ax² + bx + c 的多项式函数', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4103, 33, '变量替换', '在数学中，用另一个变量代替原变量以简化表达式或问题', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4104, 33, '函数形式化简', '将函数表达式转化为更简单的等价形式', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4105, 33, '函数定义域', '使函数有意义的自变量取值范围', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4106, 33, '数学代数运算', '进行加减乘除、指数、开方等数学运算以化简式子', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4107, 33, '函数等价变换', '通过代数操作将函数表达式转换为等价形式', 'BASIC', 1, '2025-11-27 18:35:40', '2025-11-27 18:35:40', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4108, 33, '单射', '一个函数若满足不同的输入有不同的输出，即对于任意x1≠x2，有f(x1)≠f(x2)，则称为单射。', 'BASIC', 1, '2025-11-27 21:42:07', '2025-11-27 21:42:06', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4109, 33, '函数的映射', '函数将定义域中的每个元素按照特定规则唯一对应到值域中的某个元素。', 'BASIC', 1, '2025-11-27 21:42:07', '2025-11-27 21:42:06', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4110, 33, '函数的逆函数', '若函数f存在一个反函数f⁻¹，使得f⁻¹(f(x))=x且f(f⁻¹(x))=x，则称f⁻¹为f的逆函数。', 'BASIC', 1, '2025-11-27 21:42:07', '2025-11-27 21:42:06', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4111, 33, '函数的图像', '函数的图像表示定义域中的每个x值与对应f(x)值的点的集合。', 'BASIC', 1, '2025-11-27 21:42:07', '2025-11-27 21:42:06', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4112, 33, '函数的对称性', '反函数的图像与原函数的图像关于直线y=x对称。', 'BASIC', 1, '2025-11-27 21:42:07', '2025-11-27 21:42:06', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4113, 33, '函数的复合条件', '两个函数可以复合当且仅当第一个函数的值域与第二个函数的定义域有非空交集。', 'BASIC', 1, '2025-11-27 21:42:07', '2025-11-27 21:42:06', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4114, 33, '导数的运算规则', '包括加减乘除、幂函数、指数函数等函数的导数运算方法', 'BASIC', 1, '2025-11-27 21:42:07', '2025-11-27 21:42:06', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4115, 33, '导数的高阶导数', '对函数的导数再次求导，得到函数的二阶导数或更高阶导数', 'BASIC', 1, '2025-11-27 21:42:07', '2025-11-27 21:42:06', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4116, 33, '体积变化率', '体积随时间变化的导数，用于求解与体积相关的物理量变化率', 'BASIC', 1, '2025-11-27 21:42:07', '2025-11-27 21:42:06', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4117, 33, '切线方程', '经过曲线某一点并与曲线在该点处相切的直线方程', 'BASIC', 1, '2025-11-27 21:42:07', '2025-11-27 21:42:06', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4118, 33, '函数', '对于每一个实数X，按照确定的法则有唯一的实数Y与之对应', 'BASIC', 1, '2025-11-28 12:45:50', '2025-11-28 12:45:49', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4119, 33, '定义域', '使得函数有定义的X的取值范围', 'BASIC', 1, '2025-11-28 12:45:50', '2025-11-28 12:45:50', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4120, 33, '对应法则', '函数中由X到Y的确定映射规则', 'BASIC', 1, '2025-11-28 12:45:50', '2025-11-28 12:45:50', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4121, 33, '函数的有界性', '存在实数M，使得函数的所有值都不超过M或不低于M', 'BASIC', 1, '2025-11-28 12:45:51', '2025-11-28 12:45:50', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4122, 33, '上界', '所有函数值都不超过的实数', 'BASIC', 1, '2025-11-28 12:45:51', '2025-11-28 12:45:50', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4123, 33, '下界', '所有函数值都不低于的实数', 'BASIC', 1, '2025-11-28 12:45:51', '2025-11-28 12:45:50', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4124, 33, '无界函数', '对于任意大的M，函数值都能超过M', 'BASIC', 1, '2025-11-28 12:45:51', '2025-11-28 12:45:50', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4125, 33, '绝对值函数', '对于X，取其与0的绝对差，即|X|', 'BASIC', 1, '2025-11-28 12:45:51', '2025-11-28 12:45:50', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4126, 33, '取整函数', '不超过X的最大整数，记为floor(X)', 'BASIC', 1, '2025-11-28 12:45:51', '2025-11-28 12:45:51', 0, NULL);
INSERT INTO `knowledge_point` VALUES (4127, 33, '函数图像', '函数解析式的几何表示，反映函数值随自变量变化的规律', 'BASIC', 1, '2025-11-28 12:45:51', '2025-11-28 12:45:51', 0, NULL);

SET FOREIGN_KEY_CHECKS = 1;
