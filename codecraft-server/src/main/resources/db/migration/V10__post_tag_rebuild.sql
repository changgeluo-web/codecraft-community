-- 批次5: 重建 post_tag 关联 + 更新 Flyway 记录

-- 获取刚插入的 18 条知识点的 ID
-- 由于 INSERT 是顺序的，post 表从空开始，ID 应该是 1-18
-- 但为安全起见，用子查询关联

-- 知识点与标签的关联关系
-- 标签 ID 参考（22个标签，按插入顺序）：
-- 假设 tag 表 ID 为 1-22，对应：
-- 1.Java17 2.Spring Boot3 3.MVC 4.MyBatis 5.MyBatis-Plus 6.MySQL8.0
-- 7.Lombok 8.JWT 9.AOP 10.Filter 11.ThreadLocal 12.SLF4J
-- 13.阿里云OSS 14.PageHelper 15.RESTful 16.JSON 17.事务管理
-- 18.异常处理 19.分页查询 20.动态SQL 21.resultMap 22.Flyway

-- 先确认 tag ID
-- 知识点1: 项目概述 → Java17, Spring Boot3, MySQL8.0, Flyway
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '项目概述%' AND t.name IN ('Java17','Spring Boot3','MySQL8.0','Flyway') AND p.deleted=0 AND t.deleted=0;

-- 知识点2: 三层架构 → Spring Boot3, MVC, MyBatis, Lombok, RESTful
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '三层架构%' AND t.name IN ('Spring Boot3','MVC','MyBatis','Lombok','RESTful') AND p.deleted=0 AND t.deleted=0;

-- 知识点3: 数据库设计 → MySQL8.0, MyBatis
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '数据库设计%' AND t.name IN ('MySQL8.0','MyBatis') AND p.deleted=0 AND t.deleted=0;

-- 知识点4: 部门管理CRUD → Spring Boot3, MyBatis, RESTful, AOP, Lombok
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '部门管理%' AND t.name IN ('Spring Boot3','MyBatis','RESTful','AOP','Lombok') AND p.deleted=0 AND t.deleted=0;

-- 知识点5: 员工分页查询 → PageHelper, MyBatis, 动态SQL, 分页查询
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '员工分页%' AND t.name IN ('PageHelper','MyBatis','动态SQL','分页查询') AND p.deleted=0 AND t.deleted=0;

-- 知识点6: 新增员工 → 事务管理, MyBatis, 动态SQL
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '新增员工%' AND t.name IN ('事务管理','MyBatis','动态SQL') AND p.deleted=0 AND t.deleted=0;

-- 知识点7: resultMap一对多 → resultMap, MyBatis
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE 'resultMap%' AND t.name IN ('resultMap','MyBatis') AND p.deleted=0 AND t.deleted=0;

-- 知识点8: 批量删除员工 → 事务管理, MyBatis, 动态SQL
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '批量删除%' AND t.name IN ('事务管理','MyBatis','动态SQL') AND p.deleted=0 AND t.deleted=0;

-- 知识点9: 班级管理 → MyBatis, MySQL8.0, 异常处理
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '班级管理%' AND t.name IN ('MyBatis','MySQL8.0','异常处理') AND p.deleted=0 AND t.deleted=0;

-- 知识点10: JWT鉴权 → JWT, Filter, ThreadLocal
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE 'JWT鉴权%' AND t.name IN ('JWT','Filter','ThreadLocal') AND p.deleted=0 AND t.deleted=0;

-- 知识点11: AOP操作日志 → AOP, SLF4J, ThreadLocal
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE 'AOP操作日志%' AND t.name IN ('AOP','SLF4J','ThreadLocal') AND p.deleted=0 AND t.deleted=0;

-- 知识点12: 事务传播 → 事务管理
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '事务传播%' AND t.name IN ('事务管理') AND p.deleted=0 AND t.deleted=0;

-- 知识点13: 文件上传 → 阿里云OSS
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '文件上传%' AND t.name IN ('阿里云OSS') AND p.deleted=0 AND t.deleted=0;

-- 知识点14: 报表统计 → MySQL8.0, MyBatis
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '报表统计%' AND t.name IN ('MySQL8.0','MyBatis') AND p.deleted=0 AND t.deleted=0;

-- 知识点15: 全局异常 → 异常处理, Spring Boot3
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '全局异常%' AND t.name IN ('异常处理','Spring Boot3') AND p.deleted=0 AND t.deleted=0;

-- 知识点16: ThreadLocal → ThreadLocal, Filter
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE 'ThreadLocal%' AND t.name IN ('ThreadLocal','Filter') AND p.deleted=0 AND t.deleted=0;

-- 知识点17: 动态SQL → 动态SQL, MyBatis
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE 'MyBatis动态SQL%' AND t.name IN ('动态SQL','MyBatis') AND p.deleted=0 AND t.deleted=0;

-- 知识点18: 统一响应 → RESTful, JSON, Spring Boot3
INSERT INTO post_tag (post_id, tag_id)
SELECT p.id, t.id FROM post p, tag t
WHERE p.title LIKE '统一响应%' AND t.name IN ('RESTful','JSON','Spring Boot3') AND p.deleted=0 AND t.deleted=0;

