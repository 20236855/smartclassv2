-- =============================================
-- 更新题目练习菜单配置
-- =============================================
USE smartclassv2;

-- 修改原有的题目练习菜单，改为课程选择页面
UPDATE sys_menu
SET
    menu_name = '题目练习',
    path = 'courses',
    component = 'system/question/courses',
    perms = 'system:question:list',
    icon = 'education',
    remark = '选择课程进入题目练习'
WHERE menu_id = 2000;

-- 添加题目练习子菜单（隐藏，通过课程选择页面跳转）
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES 
('题目练习', 2000, 2, 'practice', 'system/question/index', 1, 0, 'C', '1', '0', 'system:question:list', 'edit', 'admin', NOW(), '', NULL, '课程题目练习页面（隐藏）')
ON DUPLICATE KEY UPDATE 
    menu_name = '题目练习',
    parent_id = 2000,
    path = 'practice',
    component = 'system/question/index',
    visible = '1';

-- 验证菜单配置
SELECT menu_id, menu_name, parent_id, path, component, visible, perms 
FROM sys_menu 
WHERE menu_id = 2000 OR parent_id = 2000
ORDER BY order_num;

