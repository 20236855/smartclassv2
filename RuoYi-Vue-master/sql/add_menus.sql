-- =============================================
-- 添加题目和作业菜单
-- =============================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
USE smartclassv2;

-- 添加"学习中心"一级菜单
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) 
VALUES (5, '学习中心', 0, 5, 'learning', NULL, 1, 0, 'M', '0', '0', '', 'education', 'admin', NOW(), '', NULL, '学习中心目录');

-- 添加"题目练习"菜单
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) 
VALUES (2000, '题目练习', 5, 1, 'question', 'system/question/index', 1, 0, 'C', '0', '0', 'system:question:list', 'edit', 'admin', NOW(), '', NULL, '题目练习菜单');

-- 添加"作业考试"菜单
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) 
VALUES (2100, '作业考试', 5, 2, 'assignment', 'system/assignment/index', 1, 0, 'C', '0', '0', 'system:assignment:list', 'form', 'admin', NOW(), '', NULL, '作业考试菜单');

-- 添加题目练习的按钮权限
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2001, '题目查询', 2000, 1, '#', '', 1, 0, 'F', '0', '0', 'system:question:query', '#', 'admin', NOW(), '', NULL, ''),
(2002, '题目新增', 2000, 2, '#', '', 1, 0, 'F', '0', '0', 'system:question:add', '#', 'admin', NOW(), '', NULL, ''),
(2003, '题目修改', 2000, 3, '#', '', 1, 0, 'F', '0', '0', 'system:question:edit', '#', 'admin', NOW(), '', NULL, ''),
(2004, '题目删除', 2000, 4, '#', '', 1, 0, 'F', '0', '0', 'system:question:remove', '#', 'admin', NOW(), '', NULL, ''),
(2005, '题目导出', 2000, 5, '#', '', 1, 0, 'F', '0', '0', 'system:question:export', '#', 'admin', NOW(), '', NULL, ''),
(2006, '题目答题', 2000, 6, '#', '', 1, 0, 'F', '0', '0', 'system:question:answer', '#', 'admin', NOW(), '', NULL, '');

-- 添加作业考试的按钮权限
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2101, '作业查询', 2100, 1, '#', '', 1, 0, 'F', '0', '0', 'system:assignment:query', '#', 'admin', NOW(), '', NULL, ''),
(2102, '作业新增', 2100, 2, '#', '', 1, 0, 'F', '0', '0', 'system:assignment:add', '#', 'admin', NOW(), '', NULL, ''),
(2103, '作业修改', 2100, 3, '#', '', 1, 0, 'F', '0', '0', 'system:assignment:edit', '#', 'admin', NOW(), '', NULL, ''),
(2104, '作业删除', 2100, 4, '#', '', 1, 0, 'F', '0', '0', 'system:assignment:remove', '#', 'admin', NOW(), '', NULL, ''),
(2105, '作业导出', 2100, 5, '#', '', 1, 0, 'F', '0', '0', 'system:assignment:export', '#', 'admin', NOW(), '', NULL, ''),
(2106, '作业提交', 2100, 6, '#', '', 1, 0, 'F', '0', '0', 'system:assignment:submit', '#', 'admin', NOW(), '', NULL, '');

-- 为管理员角色分配菜单权限
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(1, 5),    -- 学习中心
(1, 2000), -- 题目练习
(1, 2001), -- 题目查询
(1, 2002), -- 题目新增
(1, 2003), -- 题目修改
(1, 2004), -- 题目删除
(1, 2005), -- 题目导出
(1, 2006), -- 题目答题
(1, 2100), -- 作业考试
(1, 2101), -- 作业查询
(1, 2102), -- 作业新增
(1, 2103), -- 作业修改
(1, 2104), -- 作业删除
(1, 2105), -- 作业导出
(1, 2106); -- 作业提交

-- 显示添加结果
SELECT '菜单添加完成！' AS message;
SELECT menu_id, menu_name, parent_id, path, component FROM sys_menu WHERE menu_id >= 5 AND menu_id <= 2106 ORDER BY menu_id;

