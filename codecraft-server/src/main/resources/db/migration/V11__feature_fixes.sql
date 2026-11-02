-- V11__feature_fixes.sql
-- 1. post_tag 增加自增主键与唯一约束（先去重；兼容旧库已有的复合主键）
-- 2. 新增 user_post_progress：学习进度改为「按用户」维度
-- 3. 迁移存量 study_status 后移除 post.study_status 全局字段
-- 说明：脚本可重复执行（失败后重跑安全），且不依赖存储过程。

-- ---------- 1. post_tag 去重 ----------
CREATE TEMPORARY TABLE IF NOT EXISTS `post_tag_dedup` AS
SELECT DISTINCT `post_id`, `tag_id` FROM `post_tag`;

TRUNCATE TABLE `post_tag`;

INSERT INTO `post_tag` (`post_id`, `tag_id`)
SELECT `post_id`, `tag_id` FROM `post_tag_dedup`;

DROP TEMPORARY TABLE IF EXISTS `post_tag_dedup`;

-- ---------- 2. 若存在旧的复合主键则先移除（动态判断，兼容新旧库） ----------
SET @v11_has_pk = (
    SELECT COUNT(*) FROM `information_schema`.`statistics`
    WHERE `table_schema` = DATABASE()
      AND `table_name` = 'post_tag'
      AND `index_name` = 'PRIMARY'
);
SET @v11_sql = IF(@v11_has_pk > 0, 'ALTER TABLE `post_tag` DROP PRIMARY KEY', 'DO 0');
PREPARE v11_stmt FROM @v11_sql;
EXECUTE v11_stmt;
DEALLOCATE PREPARE v11_stmt;

-- ---------- 3. 自增主键 + 唯一约束 ----------
ALTER TABLE `post_tag`
    ADD COLUMN `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE `post_tag`
    ADD UNIQUE KEY `uk_post_tag` (`post_id`, `tag_id`);

-- ---------- 4. 用户个人学习进度 ----------
CREATE TABLE IF NOT EXISTS `user_post_progress` (
    `id`         BIGINT   NOT NULL AUTO_INCREMENT,
    `user_id`    BIGINT   NOT NULL COMMENT '用户ID',
    `post_id`    BIGINT   NOT NULL COMMENT '知识点ID',
    `status`     INT      NOT NULL DEFAULT 0 COMMENT '0待学 1学习中 2已掌握',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_post` (`user_id`, `post_id`),
    KEY `idx_progress_user` (`user_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户学习进度';

-- ---------- 5. 迁移存量全局学习状态（归属给知识点作者） ----------
INSERT INTO `user_post_progress` (`user_id`, `post_id`, `status`, `created_at`, `updated_at`)
SELECT `author_id`, `id`, `study_status`, NOW(), NOW()
FROM `post`
WHERE `deleted` = 0 AND `study_status` IS NOT NULL AND `study_status` > 0;

ALTER TABLE `post` DROP COLUMN `study_status`;