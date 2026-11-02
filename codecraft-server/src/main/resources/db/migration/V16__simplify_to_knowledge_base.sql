-- V16: 裁剪社区功能，收敛为个人知识库 CRUD
-- 删除 评论/点赞/通知/关注/操作日志 表，以及 post.view_count 列
-- 幂等：DROP IF EXISTS；列存在才 DROP

DROP TABLE IF EXISTS `comment`;
DROP TABLE IF EXISTS `like_record`;
DROP TABLE IF EXISTS `notification`;
DROP TABLE IF EXISTS `follow`;
DROP TABLE IF EXISTS `operation_log`;

SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'post' AND column_name = 'view_count'
);
SET @ddl = IF(@col_exists > 0,
    'ALTER TABLE post DROP COLUMN view_count',
    'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
