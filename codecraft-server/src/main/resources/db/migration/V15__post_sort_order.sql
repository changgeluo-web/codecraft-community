-- V15: 项目内知识点排序
-- post 增加 sort_order：同一项目内的展示顺序，小的在前；NULL 表示自动按 id 排序
-- 幂等写法：列已存在时跳过 ALTER

SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'post' AND column_name = 'sort_order'
);
SET @ddl = IF(@col_exists = 0,
    'ALTER TABLE post ADD COLUMN sort_order INT NULL DEFAULT NULL COMMENT ''项目内排序序号，小的在前，NULL=按id自动排序'' AFTER view_count',
    'SELECT 1');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- tlias 员工管理系统：按传统项目开发顺序重排
-- 概述 -> 数据库设计 -> 三层架构 -> 统一响应 -> 异常处理 -> 部门CRUD
-- -> 动态SQL -> 员工分页 -> 新增员工 -> 一对多 -> 批量删除 -> 文件上传
-- -> JWT鉴权 -> ThreadLocal -> AOP日志 -> 事务传播 -> 报表统计 -> 班级管理
UPDATE post SET sort_order = 1  WHERE id = 37;
UPDATE post SET sort_order = 2  WHERE id = 39;
UPDATE post SET sort_order = 3  WHERE id = 38;
UPDATE post SET sort_order = 4  WHERE id = 36;
UPDATE post SET sort_order = 5  WHERE id = 33;
UPDATE post SET sort_order = 6  WHERE id = 40;
UPDATE post SET sort_order = 7  WHERE id = 35;
UPDATE post SET sort_order = 8  WHERE id = 23;
UPDATE post SET sort_order = 9  WHERE id = 24;
UPDATE post SET sort_order = 10 WHERE id = 25;
UPDATE post SET sort_order = 11 WHERE id = 26;
UPDATE post SET sort_order = 12 WHERE id = 31;
UPDATE post SET sort_order = 13 WHERE id = 28;
UPDATE post SET sort_order = 14 WHERE id = 34;
UPDATE post SET sort_order = 15 WHERE id = 29;
UPDATE post SET sort_order = 16 WHERE id = 30;
UPDATE post SET sort_order = 17 WHERE id = 32;
UPDATE post SET sort_order = 18 WHERE id = 27;