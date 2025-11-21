-- 使用网络图片作为课程封面（示例/演示用）
-- 图片来源：Unsplash（免费高质量图片服务）
-- 注意：这些是示例图片，最终会被替换为实际的课程数据

-- 1. 前端开发基础 - HTML/CSS/JavaScript基础
UPDATE course SET cover_image = 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&h=600&fit=crop' WHERE id = 1;

-- 2. JavaScript高级编程 - 代码编程
UPDATE course SET cover_image = 'https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=800&h=600&fit=crop' WHERE id = 2;

-- 3. Vue.js框架开发 - 现代前端框架
UPDATE course SET cover_image = 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=800&h=600&fit=crop' WHERE id = 3;

-- 4. React框架实战 - 组件化开发
UPDATE course SET cover_image = 'https://images.unsplash.com/photo-1633356122102-3fe601e05bd2?w=800&h=600&fit=crop' WHERE id = 4;

-- 5. 前端工程化实践 - 工具和流程
UPDATE course SET cover_image = 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800&h=600&fit=crop' WHERE id = 5;

-- 6. Node.js后端开发 - 服务器端开发
UPDATE course SET cover_image = 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&h=600&fit=crop' WHERE id = 6;

-- 7. 移动端开发 - 手机应用开发
UPDATE course SET cover_image = 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800&h=600&fit=crop' WHERE id = 7;

-- 8. 前端性能优化 - 性能监控和优化
UPDATE course SET cover_image = 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=600&fit=crop' WHERE id = 8;

-- 备选方案：使用 Picsum（随机精美图片）
-- UPDATE course SET cover_image = 'https://picsum.photos/800/600?random=1' WHERE id = 1;
-- UPDATE course SET cover_image = 'https://picsum.photos/800/600?random=2' WHERE id = 2;
-- UPDATE course SET cover_image = 'https://picsum.photos/800/600?random=3' WHERE id = 3;
-- UPDATE course SET cover_image = 'https://picsum.photos/800/600?random=4' WHERE id = 4;
-- UPDATE course SET cover_image = 'https://picsum.photos/800/600?random=5' WHERE id = 5;
-- UPDATE course SET cover_image = 'https://picsum.photos/800/600?random=6' WHERE id = 6;
-- UPDATE course SET cover_image = 'https://picsum.photos/800/600?random=7' WHERE id = 7;
-- UPDATE course SET cover_image = 'https://picsum.photos/800/600?random=8' WHERE id = 8;

-- 验证更新结果
SELECT id, title, cover_image FROM course ORDER BY id;

