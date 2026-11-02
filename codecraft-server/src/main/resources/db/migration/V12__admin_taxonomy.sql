-- V12__admin_taxonomy.sql
-- 管理员后台：标签增加「归属项目」维度
-- category_id 为 NULL 表示全局标签（所有项目可用）

ALTER TABLE `tag`
    ADD COLUMN `category_id` BIGINT NULL COMMENT '归属项目(分类)ID，NULL=全局标签' AFTER `name`;

ALTER TABLE `tag`
    ADD KEY `idx_tag_category` (`category_id`);

-- 存量标签归属到现有项目（取最早创建的分类，兼容各环境）
UPDATE `tag`
SET `category_id` = (SELECT `min_id` FROM (SELECT MIN(`id`) AS min_id FROM `category` WHERE `deleted` = 0) t)
WHERE `deleted` = 0 AND `category_id` IS NULL;