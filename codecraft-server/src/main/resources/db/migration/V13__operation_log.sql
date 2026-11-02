-- V13__operation_log.sql
-- 操作日志（审计）：记录所有写操作，谁在何时对什么目标做了什么
CREATE TABLE IF NOT EXISTS `operation_log` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT,
    `user_id`     BIGINT       NULL COMMENT '操作人ID（未登录为NULL）',
    `username`    VARCHAR(50)  NULL COMMENT '操作人用户名',
    `module`      VARCHAR(30)  NOT NULL COMMENT '模块：AUTH/POST/COMMENT/LIKE/FOLLOW/STUDY/ADMIN',
    `action`      VARCHAR(50)  NOT NULL COMMENT '动作：LOGIN/REGISTER/LOGOUT/CREATE/UPDATE/DELETE/RESTORE/LIKE/UNLIKE/FOLLOW/UNFOLLOW/SET_STATUS等',
    `target_type` VARCHAR(30)  NULL COMMENT '目标类型：POST/COMMENT/USER/CATEGORY/TAG',
    `target_id`   BIGINT       NULL COMMENT '目标ID',
    `detail`      VARCHAR(500) NULL COMMENT '操作详情',
    `ip`          VARCHAR(64)  NULL COMMENT '来源IP',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    PRIMARY KEY (`id`),
    KEY `idx_log_user` (`user_id`),
    KEY `idx_log_module` (`module`),
    KEY `idx_log_created` (`created_at`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '操作日志';