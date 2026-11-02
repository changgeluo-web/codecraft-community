#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""补充前4条知识点"""
import os
import pymysql

conn = pymysql.connect(
    host='localhost', port=3306, user='root', password=os.environ.get('MYSQL_PASSWORD', ''),
    database='jiangma', charset='utf8mb4', autocommit=False
)
cursor = conn.cursor()

cursor.execute("SELECT id FROM category WHERE name LIKE 'tlias%' AND deleted=0 LIMIT 1")
cat_id = cursor.fetchone()[0]
cursor.execute("SELECT id FROM user WHERE username='system' LIMIT 1")
author_id = cursor.fetchone()[0]

missing = [
    (
        '项目概述 — tlias 员工管理系统',
        'tlias员工管理系统整体介绍：六大模块、技术栈、项目结构、7张表设计',
        '''## 项目简介

tlias（Training Learning Information Administration System）是一个**员工管理系统**，实现了部门管理、员工管理、班级管理、登录鉴权、文件上传、报表统计六大模块。项目采用经典的 **Controller → Service → Mapper** 三层架构，前后端分离，后端提供 RESTful API，前端通过 HTTP 请求获取 JSON 数据。

## 核心功能一览

| 模块 | 主要功能 |
|------|---------|
| 部门管理 | 查询全部、根据ID查询、新增、修改、删除 |
| 员工管理 | 分页查询、新增（含工作经历）、删除、根据ID查询、修改、登录 |
| 班级管理 | 分页查询、新增、根据ID查询、修改、删除（有学员时禁止删除） |
| 登录模块 | 用户名密码登录、JWT 令牌签发 |
| 文件上传 | 上传文件到阿里云 OSS，返回访问 URL |
| 报表统计 | 统计员工职位人数、性别人数 |

## 技术栈

| 技术 | 一句话解释 |
|------|-----------|
| Java 17 | 编程语言 |
| Spring Boot 3 | 快速搭建 Spring 应用，内嵌 Tomcat |
| Spring Web MVC | 提供 RESTful 接口支持 |
| MyBatis | 持久层框架，将 Java 方法映射为 SQL 语句 |
| PageHelper | MyBatis 分页插件，自动拼接 LIMIT |
| MySQL 8.0 | 关系型数据库 |
| Lombok | 注解自动生成 getter/setter/toString |
| JWT (jjwt) | 无状态令牌实现鉴权 |
| 阿里云 OSS | 对象存储，存储上传图片 |
| AOP | 面向切面编程，自动记录操作日志 |

## 项目结构

```
com.changge
├── controller/     // 控制层
├── service/        // 业务层
│   └── impl/       // 业务实现类
├── mapper/         // 持久层
├── pojo/           // 实体类
├── anno/           // 自定义注解
├── filter/         // 过滤器
├── aop/            // 切面
├── exception/      // 异常处理
└── utils/          // 工具类
```

## 数据库 7 张表

dept（部门）、emp（员工）、emp_expr（工作经历）、emp_log（员工日志）、operate_log（操作日志）、clazz（班级）、student（学员）
'''
    ),
    (
        '三层架构 — Controller / Service / Mapper',
        '三层架构图解、各层职责、关键注解、完整代码示例与执行流程',
        '''## 架构图

```
浏览器 → Filter(JWT校验) → Controller → Service → Mapper → MySQL
```

## 各层职责

| 层 | 做什么 | 不做什么 |
|----|-------|---------|
| Controller | 接收参数、调用Service、返回响应 | 不写业务逻辑、不碰数据库 |
| Service | 业务逻辑、事务控制、调用Mapper | 不处理HTTP、不写SQL |
| Mapper | 执行SQL、增删改查 | 不写业务逻辑 |

## Controller 层示例

```java
@Slf4j
@RequestMapping("/depts")
@RestController
public class DeptController {
    @Autowired
    private DeptService deptService;

    @GetMapping
    public Result list() {
        log.info("查询全部部门数据");
        List<Dept> deptsList = deptService.findAll();
        return Result.success(deptsList);
    }
}
```

**关键注解：**
- `@RestController` = `@Controller` + `@ResponseBody`，返回 JSON
- `@RequestMapping("/depts")` 类级别路径
- `@GetMapping` 映射 GET 请求
- `@Autowired` Spring 自动注入依赖

## Service 层示例

```java
@Service
public class DeptServiceImpl implements DeptService {
    @Autowired
    private DeptMapper deptMapper;

    @Override
    public List<Dept> findAll() {
        return deptMapper.findAll();
    }
}
```

- `@Service` 标记为 Spring Bean
- 接口 + 实现类分离

## Mapper 层示例

```java
@Mapper
public interface DeptMapper {
    @Select("select id, name, create_time createTime, update_time updateTime " +
            "from dept order by update_time desc")
    List<Dept> findAll();
}
```

- `@Mapper` MyBatis 创建代理实现类
- `@Select` 注解写 SQL，别名对应 Java 属性

## 完整执行流程

```
第1步 → GET /depts
第2步 → TokenFilter 校验 JWT
第3步 → Spring MVC 路由到 DeptController.list()
第4步 → 调用 deptService.findAll()
第5步 → DeptServiceImpl 调用 deptMapper.findAll()
第6步 → MyBatis 执行 SQL
第7步 → MySQL 返回数据，映射为 List<Dept>
第8步 → 包装 Result.success(deptsList)
第9步 → JSON 返回浏览器
```
'''
    ),
    (
        '数据库设计 — 7 张表与关联关系',
        '7张表结构详解、字段说明、关联关系、设计要点',
        '''## 7 张表总览

| 表名 | 说明 | 关键关联 |
|------|------|----------|
| dept | 部门 | — |
| emp | 员工 | emp.dept_id → dept.id |
| emp_expr | 工作经历 | emp_expr.emp_id → emp.id |
| emp_log | 员工日志 | — |
| operate_log | 操作日志 | — |
| clazz | 班级 | clazz.master_id → emp.id |
| student | 学员 | student.clazz_id → clazz.id |

## 员工表 emp 关键字段

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT, 主键, 自增 | 员工 ID |
| username | VARCHAR | 登录用户名 |
| password | VARCHAR | 登录密码 |
| name | VARCHAR | 员工姓名 |
| gender | INT | 性别 (1男 2女) |
| job | INT | 职位 (1学工部 2教研部 3咨询部 4就业部 5人事部) |
| salary | DECIMAL | 薪资 |
| dept_id | INT | 所属部门 ID (外键) |

## 工作经历表 emp_expr

| 字段 | 说明 |
|------|------|
| emp_id | 关联员工 ID |
| begin/end | 工作起止日期 |
| company | 公司名称 |
| job | 职位 |

## 设计要点

1. **外键关联**：emp.dept_id → dept.id，emp_expr.emp_id → emp.id
2. **一对多**：一个员工多条工作经历，一个部门多个员工
3. **日志分离**：emp_log 业务日志，operate_log AOP 系统日志
4. **时间字段**：每张表都有 create_time 和 update_time
'''
    ),
    (
        '部门管理 — 完整 CRUD 接口开发',
        '部门管理5个接口的完整三层代码、关键注解、执行流程',
        '''## 接口清单

| 方法 | URL | 功能 |
|------|-----|------|
| GET | /depts | 查询全部 |
| GET | /depts/{id} | 根据ID查询 |
| POST | /depts | 新增 |
| PUT | /depts | 修改 |
| DELETE | /depts?id=xxx | 删除 |

## 1. 查询全部

```java
// Controller
@GetMapping
public Result list() {
    List<Dept> deptsList = deptService.findAll();
    return Result.success(deptsList);
}

// Service
public List<Dept> findAll() {
    return deptMapper.findAll();
}

// Mapper
@Select("select id, name, create_time createTime, update_time updateTime " +
        "from dept order by update_time desc")
List<Dept> findAll();
```

## 2. 新增

```java
// Controller
@Log
@PostMapping
public Result add(@RequestBody Dept dept) {
    deptService.add(dept);
    return Result.success();
}

// Service
public void add(Dept dept) {
    dept.setCreateTime(LocalDateTime.now());
    dept.setUpdateTime(LocalDateTime.now());
    deptMapper.insert(dept);
}

// Mapper
@Insert("insert into dept (name, create_time, update_time) " +
        "values(#{name}, #{createTime}, #{updateTime})")
void insert(Dept dept);
```

## 3. 修改

```java
@Log
@PutMapping
public Result update(@RequestBody Dept dept) {
    deptService.update(dept);
    return Result.success();
}

// Mapper
@Update("update dept set name = #{name}, update_time = #{updateTime} where id = #{id}")
void update(Dept dept);
```

## 4. 删除

```java
@Log
@DeleteMapping
public Result delete(Integer id) {
    deptService.deleteById(id);
    return Result.success();
}

// Mapper
@Delete("delete from dept where id = #{id}")
void deleteById(Integer id);
```

## 执行流程（新增为例）

```
第1步 → POST /depts {"name":"研发部"}
第2步 → @RequestBody JSON → Dept 对象
第3步 → Service 设置 createTime/updateTime
第4步 → Mapper 执行 insert SQL
第5步 → @Log 触发 AOP 记录操作日志
第6步 → 返回 Result.success()
```

## 关键注解

- `@RequestBody`：JSON → Java 对象
- `@PathVariable`：URL 路径变量 → 方法参数
- `@RequestParam`：请求参数 → 方法参数
- `#{name}`：MyBatis 参数占位符，防 SQL 注入
'''
    ),
]

insert_sql = """
INSERT INTO post (author_id, title, content, summary, status, view_count, category_id, created_at, updated_at, deleted, study_status)
VALUES (%s, %s, %s, %s, 1, 0, %s, NOW(), NOW(), 0, 0)
"""

# 获取现有知识点标题
cursor.execute("SELECT title FROM post WHERE deleted=0")
existing_titles = {row[0] for row in cursor.fetchall()}

inserted_ids = []
for title, summary, content in missing:
    if title in existing_titles:
        print(f"  SKIP (exists): {title}")
        continue
    cursor.execute(insert_sql, (author_id, title, content, summary, cat_id))
    inserted_ids.append(cursor.lastrowid)
    print(f"  INSERTED: {title} ({len(content)} chars)")

# 补充 post_tag
cursor.execute("SELECT id, name FROM tag WHERE deleted=0")
tag_map = {name: tid for tid, name in cursor.fetchall()}

tag_map_data = {
    0: ['Java17','Spring Boot3','MySQL8.0','Flyway'],
    1: ['Spring Boot3','MVC','MyBatis','Lombok','RESTful'],
    2: ['MySQL8.0','MyBatis'],
    3: ['Spring Boot3','MyBatis','RESTful','AOP','Lombok'],
}

tag_count = 0
for idx, tag_names in tag_map_data.items():
    if idx >= len(inserted_ids):
        continue
    post_id = inserted_ids[idx]
    for tag_name in tag_names:
        if tag_name in tag_map:
            cursor.execute("INSERT INTO post_tag (post_id, tag_id) VALUES (%s, %s)", (post_id, tag_map[tag_name]))
            tag_count += 1

conn.commit()

# 最终验证
cursor.execute("SELECT COUNT(*) FROM post WHERE deleted=0")
total = cursor.fetchone()[0]
cursor.execute("SELECT COUNT(*) FROM post_tag")
tags = cursor.fetchone()[0]
cursor.execute("SELECT MIN(CHAR_LENGTH(content)), MAX(CHAR_LENGTH(content)), AVG(CHAR_LENGTH(content)) FROM post WHERE deleted=0")
min_len, max_len, avg_len = cursor.fetchone()
print(f"\n=== Final Verification ===")
print(f"Total posts: {total}")
print(f"Content length: min={min_len}, max={max_len}, avg={avg_len:.0f}")
print(f"Post-tag relations: {tags}")

cursor.close()
conn.close()
