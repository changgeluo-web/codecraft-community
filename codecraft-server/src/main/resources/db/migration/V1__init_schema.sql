-- V1__init_schema.sql
-- 初始化数据库表结构（全新环境从这里开始）。
-- 注意：本脚本刻意保持「V4/V5 改造之前」的原始结构，
-- sort_order / study_status 等字段由后续版本脚本增量添加，
-- 以保证与既有 V4、V5 迁移完全兼容。

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `user` (
    `id`         BIGINT       NOT NULL AUTO_INCREMENT,
    `username`   VARCHAR(50)  NOT NULL COMMENT '用户名',
    `nickname`   VARCHAR(50)  DEFAULT NULL COMMENT '昵称',
    `password`   VARCHAR(100) NOT NULL COMMENT 'BCrypt 密码',
    `email`      VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `bio`        VARCHAR(500) DEFAULT NULL COMMENT '个人简介',
    `avatar`     VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
    `role`       VARCHAR(20)  NOT NULL DEFAULT 'USER' COMMENT 'USER/ADMIN/MODERATOR',
    `status`     INT          NOT NULL DEFAULT 1 COMMENT '1正常 0禁用',
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted`    INT          NOT NULL DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_email` (`email`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户';

CREATE TABLE IF NOT EXISTS `category` (
    `id`          BIGINT      NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(100) NOT NULL COMMENT '分类名',
    `description` VARCHAR(500) DEFAULT NULL COMMENT '描述',
    `created_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted`     INT         NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '分类（学习项目）';

CREATE TABLE IF NOT EXISTS `tag` (
    `id`         BIGINT      NOT NULL AUTO_INCREMENT,
    `name`       VARCHAR(50) NOT NULL COMMENT '标签名',
    `created_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted`    INT         NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tag_name` (`name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '标签';

CREATE TABLE IF NOT EXISTS `post` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT,
    `author_id`   BIGINT       NOT NULL COMMENT '作者ID',
    `title`       VARCHAR(200) NOT NULL COMMENT '标题',
    `content`     LONGTEXT     COMMENT '正文（Markdown）',
    `summary`     VARCHAR(500) DEFAULT NULL COMMENT '摘要',
    `cover_image` VARCHAR(255) DEFAULT NULL COMMENT '封面URL',
    `status`      INT          NOT NULL DEFAULT 1 COMMENT '1发布 0草稿',
    `view_count`  INT          NOT NULL DEFAULT 0 COMMENT '浏览数',
    `category_id` BIGINT       DEFAULT NULL COMMENT '分类ID',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted`     INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_post_author` (`author_id`),
    KEY `idx_post_category` (`category_id`),
    KEY `idx_post_created` (`created_at`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '帖子/知识点';

CREATE TABLE IF NOT EXISTS `post_tag` (
    `post_id` BIGINT NOT NULL,
    `tag_id`  BIGINT NOT NULL,
    KEY `idx_pt_post` (`post_id`),
    KEY `idx_pt_tag` (`tag_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '帖子-标签关联';

CREATE TABLE IF NOT EXISTS `comment` (
    `id`         BIGINT   NOT NULL AUTO_INCREMENT,
    `post_id`    BIGINT   NOT NULL COMMENT '帖子ID',
    `author_id`  BIGINT   NOT NULL COMMENT '评论者ID',
    `parent_id`  BIGINT   DEFAULT NULL COMMENT '父评论ID（NULL为顶级）',
    `content`    TEXT     NOT NULL COMMENT '评论内容',
    `status`     INT      NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted`    INT      NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_comment_post` (`post_id`),
    KEY `idx_comment_parent` (`parent_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '评论';

CREATE TABLE IF NOT EXISTS `like_record` (
    `id`          BIGINT   NOT NULL AUTO_INCREMENT,
    `user_id`     BIGINT   NOT NULL COMMENT '点赞用户',
    `target_id`   BIGINT   NOT NULL COMMENT '目标ID',
    `target_type` INT      NOT NULL COMMENT '1帖子 2评论',
    `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted`     INT      NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_like` (`user_id`, `target_id`, `target_type`),
    KEY `idx_like_target` (`target_id`, `target_type`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '点赞记录';

CREATE TABLE IF NOT EXISTS `follow` (
    `id`           BIGINT   NOT NULL AUTO_INCREMENT,
    `follower_id`  BIGINT   NOT NULL COMMENT '关注者（粉丝）',
    `following_id` BIGINT   NOT NULL COMMENT '被关注者',
    `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted`      INT      NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_follow` (`follower_id`, `following_id`),
    KEY `idx_follow_following` (`following_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '关注关系';

CREATE TABLE IF NOT EXISTS `notification` (
    `id`         BIGINT      NOT NULL AUTO_INCREMENT,
    `user_id`    BIGINT      NOT NULL COMMENT '接收者',
    `actor_id`   BIGINT      DEFAULT NULL COMMENT '触发者',
    `type`       INT         NOT NULL DEFAULT 5 COMMENT '1评论 2回复 3关注 4点赞 5系统',
    `target_id`  BIGINT      DEFAULT NULL COMMENT '目标（帖子/用户）',
    `content`    VARCHAR(255) DEFAULT NULL COMMENT '摘要内容',
    `is_read`    INT         NOT NULL DEFAULT 0,
    `created_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted`    INT         NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_notify_user` (`user_id`, `is_read`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '通知';