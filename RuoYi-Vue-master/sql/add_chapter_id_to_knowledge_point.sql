-- 给 knowledge_point 表添加 chapter_id 字段
ALTER TABLE `knowledge_point` 
ADD COLUMN `chapter_id` bigint NULL COMMENT '所属章节ID（可选，用于章节图谱）' AFTER `course_id`,
ADD INDEX `idx_chapter_id` (`chapter_id`);

-- 添加外键约束（可选）
ALTER TABLE `knowledge_point`
ADD CONSTRAINT `fk_kp_chapter` FOREIGN KEY (`chapter_id`) REFERENCES `chapter` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

