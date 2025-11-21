-- 使用占位图片服务（临时方案）
-- 这样可以先让系统运行起来，之后再替换真实图片

UPDATE course SET cover_image = 'https://via.placeholder.com/800x600/4A90E2/FFFFFF?text=Frontend+Basic' WHERE id = 1;
UPDATE course SET cover_image = 'https://via.placeholder.com/800x600/E94B3C/FFFFFF?text=JavaScript+Advanced' WHERE id = 2;
UPDATE course SET cover_image = 'https://via.placeholder.com/800x600/50C878/FFFFFF?text=Vue.js+Framework' WHERE id = 3;
UPDATE course SET cover_image = 'https://via.placeholder.com/800x600/9B59B6/FFFFFF?text=React+Framework' WHERE id = 4;
UPDATE course SET cover_image = 'https://via.placeholder.com/800x600/F39C12/FFFFFF?text=Frontend+Engineering' WHERE id = 5;
UPDATE course SET cover_image = 'https://via.placeholder.com/800x600/1ABC9C/FFFFFF?text=Node.js+Backend' WHERE id = 6;
UPDATE course SET cover_image = 'https://via.placeholder.com/800x600/E74C3C/FFFFFF?text=Mobile+Development' WHERE id = 7;
UPDATE course SET cover_image = 'https://via.placeholder.com/800x600/3498DB/FFFFFF?text=Performance+Optimization' WHERE id = 8;

-- 验证
SELECT id, title, cover_image FROM course ORDER BY id;

