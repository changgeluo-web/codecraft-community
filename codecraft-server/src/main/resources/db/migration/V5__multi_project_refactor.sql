-- V5: 改造为多项目知识记录系统
-- 1. category 表增加 project 维度标识
-- 2. post 表增加学习进度字段 (study_status)
-- 3. 更新现有 category 为项目维度

-- 给 category 表增加 sort_order 字段（排序用）
ALTER TABLE `category` ADD COLUMN `sort_order` INT DEFAULT 0 COMMENT '排序序号';

-- 给 post 表增加学习进度字段
ALTER TABLE `post` ADD COLUMN `study_status` INT DEFAULT 0 COMMENT '学习状态: 0待学 1学习中 2已掌握';

-- 更新现有分类为项目维度
-- 原来12个技术主题分类 → 改为1个项目分类 + 技术主题用 tag 区分
DELETE FROM `post_tag` WHERE post_id IN (SELECT id FROM `post`);
DELETE FROM `post` WHERE deleted = 0;
DELETE FROM `category` WHERE deleted = 0;

-- 重新创建分类：项目作为一级分类
INSERT INTO `category` (`name`, `description`, `sort_order`, `created_at`) VALUES
('tlias 员工管理系统', 'Spring Boot + MyBatis + JWT + AOP 综合实战项目', 1, NOW());

-- 技术主题不再作为 category，用 tag 管理
-- 保留现有 tag 不变（22个技术标签）
