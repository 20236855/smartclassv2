-- 更新课程封面图片
-- 使用方式：将图片文件放到 D:\ruoyi\uploadPath\courses\ 目录下
-- 然后执行此SQL脚本

-- 方式1：使用简单的数字命名
UPDATE course SET cover_image = '/profile/courses/course-1.jpg' WHERE id = 1;
UPDATE course SET cover_image = '/profile/courses/course-2.jpg' WHERE id = 2;
UPDATE course SET cover_image = '/profile/courses/course-3.jpg' WHERE id = 3;
UPDATE course SET cover_image = '/profile/courses/course-4.jpg' WHERE id = 4;
UPDATE course SET cover_image = '/profile/courses/course-5.jpg' WHERE id = 5;
UPDATE course SET cover_image = '/profile/courses/course-6.jpg' WHERE id = 6;
UPDATE course SET cover_image = '/profile/courses/course-7.jpg' WHERE id = 7;
UPDATE course SET cover_image = '/profile/courses/course-8.jpg' WHERE id = 8;

-- 方式2：使用有意义的命名（注释掉，如果需要可以取消注释）
-- UPDATE course SET cover_image = '/profile/courses/frontend-basic.jpg' WHERE id = 1;
-- UPDATE course SET cover_image = '/profile/courses/javascript-advanced.jpg' WHERE id = 2;
-- UPDATE course SET cover_image = '/profile/courses/vue-framework.jpg' WHERE id = 3;
-- UPDATE course SET cover_image = '/profile/courses/react-framework.jpg' WHERE id = 4;
-- UPDATE course SET cover_image = '/profile/courses/frontend-engineering.jpg' WHERE id = 5;
-- UPDATE course SET cover_image = '/profile/courses/nodejs-backend.jpg' WHERE id = 6;
-- UPDATE course SET cover_image = '/profile/courses/mobile-development.jpg' WHERE id = 7;
-- UPDATE course SET cover_image = '/profile/courses/performance-optimization.jpg' WHERE id = 8;

-- 方式3：使用网络图片URL（示例）
-- UPDATE course SET cover_image = 'https://example.com/images/course1.jpg' WHERE id = 1;
-- UPDATE course SET cover_image = 'https://example.com/images/course2.jpg' WHERE id = 2;
-- 等等...

-- 验证更新结果
SELECT id, title, cover_image FROM course ORDER BY id;

