-- 知识点数据填充：tlias 员工管理系统 - 18条学习笔记级知识点
-- 每条包含：接口定义、Controller/Service/Mapper三层代码、执行流程
-- category_id = 13 (tlias 员工管理系统), author_id = 1 (system)


-- 知识点 1: 项目概述
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '项目概述 — tlias 员工管理系统', '## 项目简介

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
| Spring Boot 3 | 快速搭建 Spring 应用的脚手架，内嵌 Tomcat |
| Spring Web MVC | 提供 RESTful 接口支持 |
| MyBatis | 持久层框架，将 Java 方法映射为 SQL 语句 |
| PageHelper | MyBatis 分页插件，自动拼接 LIMIT |
| MySQL 8.0 | 关系型数据库 |
| Lombok | 注解自动生成 getter/setter/toString |
| JWT (jjwt) | 无状态令牌实现鉴权 |
| 阿里云 OSS | 对象存储，存储上传图片 |
| AOP | 面向切面编程，自动记录操作日志 |
| Filter | Servlet 过滤器，统一校验 JWT |
| ThreadLocal | 线程本地变量，传递登录用户 ID |

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

## 数据库设计

数据库 tlias，utf8mb4 编码，7 张表：
- **dept** — 部门表
- **emp** — 员工表（关联 dept.id）
- **emp_expr** — 工作经历表（关联 emp.id）
- **emp_log** — 员工操作日志表
- **operate_log** — AOP 操作日志表
- **clazz** — 班级表
- **student** — 学员表（关联 clazz.id）
', 'tlias 员工管理系统整体介绍：六大模块、技术栈、项目结构、7张表设计', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 2: 三层架构
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '三层架构 — Controller / Service / Mapper', '## 架构图

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
@Slf4j                          // Lombok 自动生成 log 日志对象
@RequestMapping("/depts")       // 类级别路径映射
@RestController                 // 标记为控制器，返回 JSON
public class DeptController {
    @Autowired                  // Spring 自动注入 Service
    private DeptService deptService;

    @GetMapping                 // 映射 GET /depts
    public Result list() {
        log.info("查询全部部门数据");
        List<Dept> deptsList = deptService.findAll();
        return Result.success(deptsList);  // 包装成统一响应
    }
}
```

**关键注解：**
- `@RestController` = `@Controller` + `@ResponseBody`，返回 JSON 而非页面
- `@RequestMapping("/depts")` 类级别路径，所有接口以 /depts 开头
- `@GetMapping` 映射 GET 请求
- `@Autowired` Spring 自动注入依赖

## Service 层示例

```java
@Service                       // 标记为业务层组件，交给 Spring 管理
public class DeptServiceImpl implements DeptService {
    @Autowired                // 自动注入 Mapper
    private DeptMapper deptMapper;

    @Override
    public List<Dept> findAll() {
        return deptMapper.findAll();  // 调用 Mapper 查询
    }
}
```

**关键点：**
- Service 负责业务逻辑（如设置时间、事务管理），不处理 HTTP
- `@Service` 标记为 Spring Bean，交给 IoC 容器管理
- 接口 + 实现类分离，便于维护和测试

## Mapper 层示例

```java
@Mapper                       // MyBatis 映射接口，Spring 创建代理对象
public interface DeptMapper {
    @Select("select id, name, create_time createTime, update_time updateTime " +
            "from dept order by update_time desc")
    List<Dept> findAll();
}
```

**关键点：**
- `@Mapper` 让 MyBatis 为接口创建代理实现类
- `@Select` 注解写 SQL，字段别名对应 Java 属性名
- 也可以用 XML 映射文件写动态 SQL

## 完整执行流程

```
第1步 → 浏览器发送 GET /depts
第2步 → TokenFilter 校验 JWT 令牌
第3步 → Spring MVC 根据 @GetMapping 路由到 DeptController.list()
第4步 → list() 调用 deptService.findAll()
第5步 → DeptServiceImpl 调用 deptMapper.findAll()
第6步 → MyBatis 执行 SQL: select id, name ... from dept order by update_time desc
第7步 → MySQL 返回数据，MyBatis 映射为 List<Dept>
第8步 → Controller 包装 Result.success(deptsList)
第9步 → Spring MVC 序列化为 JSON 返回浏览器
```
', '三层架构图解、各层职责、关键注解、完整代码示例与执行流程', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 3: 数据库设计
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '数据库设计 — 7 张表与关联关系', '## 7 张表总览

| 表名 | 说明 | 关键关联 |
|------|------|----------|
| dept | 部门 | — |
| emp | 员工 | emp.dept_id → dept.id |
| emp_expr | 工作经历 | emp_expr.emp_id → emp.id |
| emp_log | 员工日志 | — |
| operate_log | 操作日志 | — |
| clazz | 班级 | clazz.master_id → emp.id |
| student | 学员 | student.clazz_id → clazz.id |

## 部门表 dept

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT, 主键, 自增 | 部门 ID |
| name | VARCHAR | 部门名称 |
| create_time | DATETIME | 创建时间 |
| update_time | DATETIME | 修改时间 |

## 员工表 emp

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT, 主键, 自增 | 员工 ID |
| username | VARCHAR | 登录用户名 |
| password | VARCHAR | 登录密码 |
| name | VARCHAR | 员工姓名 |
| gender | INT | 性别 (1男 2女) |
| phone | VARCHAR | 手机号 |
| job | INT | 职位 (1学工部 2教研部 3咨询部 4就业部 5人事部) |
| salary | DECIMAL | 薪资 |
| image | VARCHAR | 头像 URL |
| entry_date | DATE | 入职日期 |
| dept_id | INT | 所属部门 ID (外键) |
| create_time | DATETIME | 创建时间 |
| update_time | DATETIME | 修改时间 |

## 工作经历表 emp_expr

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT, 主键, 自增 | 工作经历 ID |
| emp_id | INT | 关联的员工 ID |
| begin | DATE | 工作开始日期 |
| end | DATE | 工作结束日期 |
| company | VARCHAR | 公司名称 |
| job | VARCHAR | 职位名称 |

## 操作日志表 operate_log

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT, 主键 | 日志 ID |
| operate_emp_id | INT | 操作人 ID |
| operate_time | DATETIME | 操作时间 |
| class_name | VARCHAR | 操作的类名 |
| method_name | VARCHAR | 方法名 |
| method_params | VARCHAR | 方法参数 |
| return_value | VARCHAR | 返回值 |
| cost_time | BIGINT | 耗时(毫秒) |

## 班级表 clazz

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT, 主键 | 班级 ID |
| name | VARCHAR | 班级名称 |
| room | VARCHAR | 教室 |
| begin_date | DATE | 开课日期 |
| end_date | DATE | 结课日期 |
| master_id | INT | 班主任 ID (关联 emp.id) |
| subject | VARCHAR | 学科 |
| create_time | DATETIME | 创建时间 |
| update_time | DATETIME | 修改时间 |

## 设计要点

1. **外键关联**：emp.dept_id → dept.id，emp_expr.emp_id → emp.id，clazz.master_id → emp.id
2. **时间字段**：每张业务表都有 create_time 和 update_time，用于审计追踪
3. **一对多关系**：一个员工有多条工作经历（emp → emp_expr），一个部门有多个员工（dept → emp）
4. **日志分离**：emp_log 记录业务操作日志，operate_log 记录 AOP 自动采集的系统操作日志
', '7张表结构详解、字段说明、关联关系、设计要点', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 4: 部门管理 — 查询与新增
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '部门管理 — 完整 CRUD 接口开发', '## 接口清单

| 方法 | URL | 功能 |
|------|-----|------|
| GET | /depts | 查询全部部门 |
| GET | /depts/{id} | 根据ID查询 |
| POST | /depts | 新增部门 |
| PUT | /depts | 修改部门 |
| DELETE | /depts?id=xxx | 删除部门 |

## 1. 查询全部部门

### Controller

```java
@GetMapping
public Result list() {
    log.info("查询全部部门数据");
    List<Dept> deptsList = deptService.findAll();
    return Result.success(deptsList);
}
```

### Service

```java
@Override
public List<Dept> findAll() {
    return deptMapper.findAll();
}
```

### Mapper

```java
@Select("select id, name, create_time createTime, update_time updateTime " +
        "from dept order by update_time desc")
List<Dept> findAll();
```

**要点：** 字段别名 `create_time createTime` 是为了让数据库下划线命名匹配 Java 驼峰属性。

## 2. 新增部门

### Controller

```java
@Log                        // 自定义注解，标记需要 AOP 记录操作日志
@PostMapping
public Result add(@RequestBody Dept dept) {
    log.info("添加部门{}", dept);
    deptService.add(dept);
    return Result.success();
}
```

**要点：** `@RequestBody` 将请求体 JSON 自动反序列化为 Java 对象。

### Service

```java
@Override
public void add(Dept dept) {
    dept.setCreateTime(LocalDateTime.now());  // Service 层负责设置时间
    dept.setUpdateTime(LocalDateTime.now());
    deptMapper.insert(dept);
}
```

### Mapper

```java
@Insert("insert into dept (name, create_time, update_time) " +
        "values(#{name}, #{createTime}, #{updateTime})")
void insert(Dept dept);
```

**要点：** `#{name}` 是 MyBatis 参数占位符，从 Dept 对象属性取值，防止 SQL 注入。

## 3. 修改部门

### Controller

```java
@Log
@PutMapping
public Result update(@RequestBody Dept dept) {
    log.info("修改部门{}", dept);
    deptService.update(dept);
    return Result.success();
}
```

### Service

```java
@Override
public void update(Dept dept) {
    dept.setUpdateTime(LocalDateTime.now());  // 只更新 updateTime
    deptMapper.update(dept);
}
```

### Mapper

```java
@Update("update dept set name = #{name}, update_time = #{updateTime} where id = #{id}")
void update(Dept dept);
```

## 4. 删除部门

### Controller

```java
@Log
@DeleteMapping
public Result delete(Integer id) {     // ?id=xxx 自动绑定
    log.info("删除部门{}", id);
    deptService.deleteById(id);
    return Result.success();
}
```

### Mapper

```java
@Delete("delete from dept where id = #{id}")
void deleteById(Integer id);
```

## 完整执行流程（以新增为例）

```
第1步 → 浏览器 POST /depts，请求体: {"name":"研发部"}
第2步 → TokenFilter 校验 JWT
第3步 → @Log 触发 AOP 切面，开始计时
第4步 → @RequestBody 将 JSON 转为 Dept 对象
第5步 → Service 设置 createTime/updateTime
第6步 → Mapper 执行 SQL: insert into dept (name, ...) values(''研发部'', ...)
第7步 → MySQL 插入记录
第8步 → Controller 返回 Result.success()
第9步 → AOP 切面记录操作日志到 operate_log 表
第10步 → JSON 响应返回浏览器
```
', '部门管理5个接口的完整三层代码、关键注解、执行流程', 1, 0, 13, NOW(), NOW(), 0, 0);
