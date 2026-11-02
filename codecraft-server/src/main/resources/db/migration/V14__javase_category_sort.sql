-- V14: JavaSE基础项目排序
-- 项目导航按 sort_order 升序展示，JavaSE基础置顶

INSERT INTO category (name, description, sort_order)
SELECT 'JavaSE基础', 'Java SE 基础：核心语法、流程控制、数组、方法与算法综合训练', 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM category WHERE name = 'JavaSE基础' AND deleted = 0
);

UPDATE category SET sort_order = 0 WHERE name = 'JavaSE基础' AND deleted = 0;
UPDATE category SET sort_order = 1 WHERE name = 'tlias 员工管理系统' AND deleted = 0;