-- V4__redesign_to_knowledge_base.sql
-- 将码匠社区数据库重构为「知识记录系统」
-- 清空所有旧业务数据，重建分类为学习模块，预填充 tlias 技术文档中的知识点摘要

-- ============================================================
-- 第1步：清空所有业务数据（保留表结构）
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE `post_tag`;
TRUNCATE TABLE `like_record`;
TRUNCATE TABLE `comment`;
TRUNCATE TABLE `notification`;
TRUNCATE TABLE `follow`;
TRUNCATE TABLE `post`;
TRUNCATE TABLE `tag`;
TRUNCATE TABLE `category`;
TRUNCATE TABLE `user`;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 第2步：创建系统用户（知识点发布者）
-- ============================================================

INSERT INTO `user` (`id`, `username`, `nickname`, `password`, `email`, `bio`, `avatar`, `role`, `status`, `created_at`, `updated_at`, `deleted`) VALUES
(1, 'system', '知识库', '$2a$10$G1ZWWjAkUIg4pK6WvXqWZ.1rtfHqzXRxi7cQJTTwcAJsa9hUNZFs2', 'system@knowledge.local', '系统知识库账号，用于发布预设知识点', NULL, 'ADMIN', 1, NOW(), NOW(), 0);

-- ============================================================
-- 第3步：重建分类 — 对应 tlias 文档的学习模块
-- ============================================================

INSERT INTO `category` (`id`, `name`, `description`) VALUES
(1, '项目概述', 'tlias 员工管理系统整体介绍、技术栈、项目结构'),
(2, '三层架构', 'Controller → Service → Mapper 三层架构设计与职责分离'),
(3, '数据库设计', 'MySQL 建表、字段映射、外键关联、utf8mb4 编码'),
(4, '部门管理', '部门 CRUD 接口、MyBatis 注解开发、执行流程'),
(5, '员工管理', '员工分页查询、新增含工作经历、批量删除、修改、resultMap 关联查询'),
(6, '班级管理', '班级分页查询、业务校验（有学员禁止删除）、CASE WHEN 状态计算'),
(7, '登录鉴权', 'JWT 令牌生成与解析、TokenFilter 过滤器、无状态认证'),
(8, '文件上传', 'MultipartFile、阿里云 OSS 对象存储、form-data 上传'),
(9, '报表统计', 'GROUP BY 聚合查询、CASE WHEN、IF 函数、图表数据组装'),
(10, '进阶技术', 'AOP 操作日志、ThreadLocal、事务传播行为、全局异常处理'),
(11, 'MyBatis 核心', '动态 SQL、resultMap、PageHelper 分页、foreach 批量操作'),
(12, 'Spring Boot', '自动配置、依赖注入、@RestController、@Transactional');

-- ============================================================
-- 第4步：重建标签 — 技术关键词
-- ============================================================

INSERT INTO `tag` (`id`, `name`) VALUES
(1,  'Java 17'),
(2,  'Spring Boot 3'),
(3,  'Spring Web MVC'),
(4,  'MyBatis'),
(5,  'MyBatis-Plus'),
(6,  'MySQL 8.0'),
(7,  'Lombok'),
(8,  'JWT'),
(9,  'AOP'),
(10, 'Filter'),
(11, 'ThreadLocal'),
(12, 'SLF4J'),
(13, '阿里云 OSS'),
(14, 'PageHelper'),
(15, 'RESTful'),
(16, 'JSON'),
(17, '事务管理'),
(18, '异常处理'),
(19, '分页查询'),
(20, '动态SQL'),
(21, 'resultMap'),
(22, 'Flyway');

-- ============================================================
-- 第5步：预填充知识点 — 来自 tlias 完整技术文档（精简摘要）
-- ============================================================

INSERT INTO `post` (`id`, `author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`) VALUES
-- 知识点 1: 项目概述
(1, 1, 'tlias 员工管理系统 — 项目概述',
'## 项目简介\n\ntlias 是一个**员工管理系统**，实现了部门管理、员工管理、班级管理、登录鉴权、文件上传、报表统计六大模块。\n\n## 六大模块\n\n| 模块 | 主要功能 |\n|------|--------|\n| 部门管理 | 查询全部、根据ID查询、新增、修改、删除 |\n| 员工管理 | 分页查询、新增（含工作经历）、删除、修改、登录 |\n| 班级管理 | 分页查询、新增、修改、删除（有学员时禁止） |\n| 登录模块 | 用户名密码登录、JWT 令牌签发 |\n| 文件上传 | 上传到阿里云 OSS，返回访问 URL |\n| 报表统计 | 统计员工职位人数、性别人数 |\n\n## 核心特点\n\n- Controller → Service → Mapper 三层架构\n- 前后端分离，RESTful API + JSON\n- 面向 Java 初学者',
'tlias 员工管理系统整体介绍，六大功能模块概览', 1, 0, 1, NOW(), NOW(), 0),

-- 知识点 2: 技术栈
(2, 1, 'tlias 技术栈清单',
'## 13 项核心技术\n\n| 技术 | 用途 |\n|------|------|\n| Java 17 | 编程语言 |\n| Spring Boot 3 | 应用脚手架，内嵌 Tomcat |\n| Spring Web MVC | RESTful 接口支持 |\n| MyBatis | 持久层框架，SQL 映射 |\n| PageHelper | MyBatis 分页插件 |\n| MySQL 8.0 | 关系型数据库 |\n| Lombok | 自动生成 getter/setter |\n| JWT (jjwt) | 无状态令牌鉴权 |\n| 阿里云 OSS | 文件对象存储 |\n| AOP | 操作日志自动记录 |\n| Filter | JWT 令牌校验 |\n| ThreadLocal | 请求内跨层传递用户ID |\n| SLF4J + Logback | 日志输出 |\n\n## 关键理解\n\n- Spring Boot 是 Spring 的脚手架，简化配置\n- MyBatis 是半自动 ORM，SQL 自己写，映射自动做\n- PageHelper 通过拦截器自动拼接 LIMIT',
'Java 17、Spring Boot 3、MyBatis、JWT、AOP 等 13 项核心技术一览', 1, 0, 1, NOW(), NOW(), 0),

-- 知识点 3: 三层架构
(3, 1, '三层架构 — Controller / Service / Mapper',
'## 架构图\n\n```\n浏览器 → Filter(JWT校验) → Controller → Service → Mapper → MySQL\n```\n\n## 各层职责\n\n| 层 | 做什么 | 不做什么 |\n|----|-------|---------|\n| Controller | 接收参数、调用Service、返回响应 | 不写业务逻辑、不碰数据库 |\n| Service | 业务逻辑、事务控制 | 不处理HTTP、不写SQL |\n| Mapper | 执行SQL、增删改查 | 不写业务逻辑 |\n\n## 核心原则\n\n**各层只做自己的事，互不越界。**\n\n- `@RestController` = `@Controller` + `@ResponseBody`\n- `@RequestMapping` 类级别路径前缀\n- AOP 切面横跨 Service 层之上，通过 `@Around` 拦截 `@Log` 方法',
'三层架构核心：Controller接收请求、Service处理业务、Mapper操作数据库，各层互不越界', 1, 0, 2, NOW(), NOW(), 0),

-- 知识点 4: 数据库设计
(4, 1, 'tlias 数据库设计 — 7 张表',
'## 7 张表\n\n| 表名 | 说明 | 关键关联 |\n|------|------|----------|\n| dept | 部门 | — |\n| emp | 员工 | emp.dept_id → dept.id |\n| emp_expr | 工作经历 | emp_expr.emp_id → emp.id |\n| emp_log | 员工日志 | — |\n| operate_log | 操作日志 | — |\n| clazz | 班级 | clazz.master_id → emp.id |\n| student | 学员 | student.clazz_id → clazz.id |\n\n## 命名规范\n\n- 数据库：下划线 `create_time`\n- Java：驼峰 `createTime`\n- MyBatis：`map-underscore-to-camel-case: true` 自动映射\n\n## 编码\n\nutf8mb4（支持 emoji 等 4 字节字符）',
'tlias 数据库 7 张表设计，外键关联关系，下划线与驼峰命名映射', 1, 0, 3, NOW(), NOW(), 0),

-- 知识点 5: 部门管理 CRUD
(5, 1, '部门管理 — 完整 CRUD 接口',
'## 接口清单\n\n| 方法 | URL | 功能 |\n|------|-----|------|\n| GET | /depts | 查询全部 |\n| GET | /depts/{id} | 根据ID查询 |\n| POST | /depts | 新增 |\n| PUT | /depts | 修改 |\n| DELETE | /depts?id=xxx | 删除 |\n\n## Mapper 注解开发\n\n```java\n@Select("select id, name, create_time createTime from dept order by update_time desc")\nList<Dept> findAll();\n```\n\n## 执行流程（简化）\n\n浏览器请求 → TokenFilter校验 → Controller接收 → Service处理 → Mapper查SQL → MySQL返回 → MyBatis映射 → 包装Result → 序列化JSON → 响应\n\n## 关键注解\n\n- `@PathVariable` 从URL提取参数\n- `@RequestBody` JSON转Java对象\n- `@Log` 触发AOP日志',
'部门管理CRUD接口、MyBatis注解开发、13步执行流程、关键注解', 1, 0, 4, NOW(), NOW(), 0),

-- 知识点 6: 员工分页查询
(6, 1, '员工分页查询 — PageHelper + 动态条件',
'## PageHelper 三步\n\n```java\nPageHelper.startPage(page, pageSize);  // 1.启动分页\nList<Emp> list = empMapper.list(param);  // 2.执行查询\nPage<Emp> p = (Page<Emp>) list;         // 3.转为Page\nreturn new PageResult(p.getTotal(), p.getResult());\n```\n\n## 动态 SQL\n\n```xml\n<where>\n    <if test="name != null and name != \'\'">\n        e.name like concat(\'%\',#{name},\'%\')\n    </if>\n    <if test="gender != null">\n        and e.gender = #{gender}\n    </if>\n</where>\n```\n\n## 关键点\n\n1. PageHelper 用 ThreadLocal 存分页参数，拦截器自动拼 LIMIT\n2. `<where>` 自动处理 AND 前缀，条件全空时不加 WHERE\n3. `<if>` 用 OGNL 表达式判断参数\n4. LEFT JOIN 左连接部门表',
'PageHelper分页三步、动态SQL的where/if标签、LEFT JOIN关联查询', 1, 0, 5, NOW(), NOW(), 0),

-- 知识点 7: 新增员工 + 事务
(7, 1, '新增员工 — 事务管理 + 批量插入工作经历',
'## Service 核心逻辑\n\n```java\n@Transactional(rollbackFor = Exception.class)\npublic void save(Emp emp) {\n    try {\n        empMapper.insert(emp);  // 自增ID回填\n        if (!CollectionUtils.isEmpty(exprList)) {\n            exprList.forEach(e -> e.setEmpid(emp.getId()));\n            empExprMapper.insertBatch(exprList);\n        }\n    } finally {\n        empLogService.insertLog(log);  // REQUIRES_NEW 独立事务\n    }\n}\n```\n\n## foreach 批量插入\n\n```xml\n<insert id="insertBatch">\n    insert into emp_expr (emp_id, begin, end, company, job) values\n    <foreach collection="empList" item="emp" separator=",">\n        (#{emp.empid}, #{emp.begin}, #{emp.end}, #{emp.company}, #{emp.job})\n    </foreach>\n</insert>\n```\n\n## 关键点\n\n1. `@Options(useGeneratedKeys=true, keyProperty="id")` 自增主键回填\n2. `@Transactional(rollbackFor=Exception)` 任何异常都回滚\n3. `<foreach>` 一条SQL插入多条记录\n4. `REQUIRES_NEW` 日志独立事务，主事务回滚日志不丢',
'事务管理、自增ID回填、foreach批量插入、REQUIRES_NEW独立事务', 1, 0, 5, NOW(), NOW(), 0),

-- 知识点 8: resultMap 关联查询
(8, 1, 'resultMap 一对多关联 — 员工 + 工作经历',
'## resultMap 定义\n\n```xml\n<resultMap id="empResultMap" type="Emp">\n    <id property="id" column="id"/>\n    <result property="name" column="name"/>\n    <collection property="exprList" ofType="EmpExpr">\n        <id property="id" column="ee_id"/>\n        <result property="company" column="ee_company"/>\n    </collection>\n</resultMap>\n```\n\n## 关联查询\n\n```xml\n<select id="getById" resultMap="empResultMap">\n    select e.*, ee.id as ee_id, ee.company as ee_company\n    from emp e left join emp_expr ee on e.id = ee.emp_id\n    where e.id = #{id}\n</select>\n```\n\n## MyBatis 合并机制\n\nMySQL 返回多行 → MyBatis 用 `<id>` 判断同一对象 → 合并多行为一个 Emp → 每行的 ee_* 组装成 EmpExpr 加入 exprList\n\n## 关键标签\n\n- `<id>` 主键映射，判断是否同一对象\n- `<collection>` 一对多，`ofType` 指定元素类型\n- 字段别名避免冲突',
'resultMap一对多映射、collection标签、MyBatis多行合并为一个对象', 1, 0, 5, NOW(), NOW(), 0),

-- 知识点 9: 班级管理 + 业务校验
(9, 1, '班级管理 — 业务校验与 CASE WHEN',
'## 业务校验：有学员禁止删除\n\n```java\npublic void deleteById(Integer id) {\n    Integer count = studentMapper.countByClazzId(id);\n    if (count > 0) {\n        throw new BusinessException("班级下有学员, 不能直接删除~");\n    }\n    clazzMapper.deleteById(id);\n}\n```\n\n## CASE WHEN 计算状态\n\n```xml\n(case\n    when begin_date > now() then \'未开班\'\n    when now() > end_date then \'已结课\'\n    else \'在读中\'\nend) status\n```\n\n## 关键点\n\n1. BusinessException 被 GlobalExceptionHandler 捕获返回友好错误\n2. CASE WHEN 在SQL中动态计算状态（非数据库字段）\n3. XML中 `>` 需转义为 `&gt;`\n4. 业务校验在 Service 层',
'业务校验（有学员禁止删除）、CASE WHEN动态计算状态、BusinessException', 1, 0, 6, NOW(), NOW(), 0),

-- 知识点 10: JWT 鉴权
(10, 1, 'JWT 鉴权完整流程',
'## JWT 结构\n\n```\nheader.payload.signature\nheader:    {"alg":"HS256","typ":"JWT"} → Base64\npayload:   {"id":1,"username":"admin"} → Base64\nsignature: HMAC-SHA256(base64(header)+"."+base64(payload), "6aaZ5a+G")\n```\n\n## TokenFilter 校验流程\n\n```\n请求进来\n  ├─ 是/login？→ 放行\n  ├─ 无令牌 → 401\n  ├─ parseToken失败 → 401\n  ├─ 成功 → CurrentHolder.setCurrentId(id)\n  ├─ chain.doFilter() → 放行\n  └─ finally: CurrentHolder.remove() → 清理ThreadLocal\n```\n\n## 关键点\n\n1. 无状态认证——服务器不存session\n2. HS256对称加密，同一密钥签发和验证\n3. ThreadLocal线程隔离，一次请求内跨层传递\n4. finally清理——线程池复用必须remove',
'JWT结构、登录签发、TokenFilter校验流程、ThreadLocal存储用户ID', 1, 0, 7, NOW(), NOW(), 0),

-- 知识点 11: AOP 操作日志
(11, 1, 'AOP 操作日志 — @Log + 环绕通知',
'## @Log 注解\n\n```java\n@Target(METHOD)\n@Retention(RUNTIME)\npublic @interface Log {}\n```\n\n## 环绕通知\n\n```java\n@Around("@annotation(com.changge.anno.Log)")\npublic Object around(ProceedingJoinPoint pjp) throws Throwable {\n    long start = System.currentTimeMillis();\n    Integer operateEmpId = CurrentHolder.getCurrentId();\n    String className = pjp.getTarget().getClass().getName();\n    String methodName = pjp.getSignature().getName();\n    Object result = pjp.proceed();  // 执行目标方法\n    long costTime = System.currentTimeMillis() - start;\n    operateLogMapper.insert(new OperateLog(..., costTime));\n    return result;\n}\n```\n\n## 关键点\n\n1. `@Around` 环绕通知，包裹目标方法\n2. `@annotation()` 拦截有特定注解的方法\n3. `proceed()` 执行目标方法\n4. 横切关注点：日志、事务、权限与业务逻辑分离',
'AOP环绕通知、@Log自定义注解、ProceedingJoinPoint、自动记录操作日志', 1, 0, 10, NOW(), NOW(), 0),

-- 知识点 12: 事务传播行为
(12, 1, '事务传播行为 — REQUIRES_NEW',
'## 场景\n\n新增员工无论成功失败都要记日志。\n\n## 7 种传播行为\n\n| 传播行为 | 说明 |\n|---------|------|\n| REQUIRED (默认) | 有事务加入，没有新建 |\n| **REQUIRES_NEW** | 总是新建独立事务，挂起当前 |\n| SUPPORTS | 有事务加入，没有非事务运行 |\n| NOT_SUPPORTED | 非事务运行，有事务挂起 |\n| NEVER | 非事务运行，有事务抛异常 |\n| MANDATORY | 必须在事务中，没有抛异常 |\n| NESTED | 嵌套事务，可部分回滚 |\n\n## 为什么用 REQUIRES_NEW？\n\n主事务回滚 → 日志在独立事务中已提交，不丢失。\n\n```\n┌─ 主事务 (save) ──────────────┐\n│  insert(emp)                 │\n│  insertBatch(exprList)       │\n│  finally {                   │\n│    ┌─ REQUIRES_NEW ────────┐ │\n│    │  insert(log) 独立提交  │ │\n│    └───────────────────────┘ │\n│  }                           │\n└─────────────────────────────┘\n```',
'Spring事务7种传播行为、REQUIRES_NEW独立事务、主事务回滚日志不丢', 1, 0, 10, NOW(), NOW(), 0),

-- 知识点 13: 文件上传
(13, 1, '文件上传 — MultipartFile + 阿里云 OSS',
'## 接口\n\n`POST /upload` — multipart/form-data\n\n## 流程\n\n```\n浏览器发送文件 → Spring MVC绑定MultipartFile\n→ file.getBytes()获取字节数组\n→ aliyunOSSOperator.upload(bytes, filename)\n  - UUID生成唯一文件名\n  - OSS SDK上传到Bucket\n  - 返回公网URL\n→ Result.success(url)\n```\n\n## 关键点\n\n1. `MultipartFile` Spring文件上传接口\n2. `multipart/form-data` 文件上传编码类型\n3. `@ConfigurationProperties(prefix="aliyun.oss")` 读取yml配置\n4. UUID+原始名 避免重名覆盖',
'MultipartFile文件上传、阿里云OSS对象存储、UUID唯一文件名', 1, 0, 8, NOW(), NOW(), 0),

-- 知识点 14: 报表统计
(14, 1, '报表统计 — GROUP BY + CASE WHEN + IF',
'## 职位人数统计\n\n```sql\nselect\n    (case when job=1 then \'学工部\'\n          when job=2 then \'教研部\'\n          ...\n     end) pos,\n    count(*) num\nfrom emp group by job order by num;\n```\n\n## 性别人数统计\n\n```sql\nselect if(gender=1, \'男性员工\', \'女性员工\') as name,\n       count(*) as value\nfrom emp group by gender;\n```\n\n## Stream API 组装\n\n```java\nList<Map<String,Object>> list = empMapper.countEmpJobData();\nList<Object> jobList = list.stream().map(m -> m.get("pos")).toList();\nList<Object> dataList = list.stream().map(m -> m.get("num")).toList();\nreturn new JobOption(jobList, dataList);\n```\n\n## 关键点\n\n1. GROUP BY 分组 + COUNT 聚合\n2. CASE WHEN / IF 条件判断\n3. Stream API `stream().map().toList()` 链式操作',
'GROUP BY聚合、CASE WHEN条件判断、IF函数、Stream API数据组装', 1, 0, 9, NOW(), NOW(), 0),

-- 知识点 15: 全局异常处理
(15, 1, '全局异常处理 — @ControllerAdvice',
'## GlobalExceptionHandler\n\n```java\n@ControllerAdvice\npublic class GlobalExceptionHandler {\n    @ExceptionHandler(Exception.class)\n    public Result handle(Exception e) { return Result.error("出错啦"); }\n\n    @ExceptionHandler(BusinessException.class)\n    public Result handleBiz(BusinessException e) { return Result.error(e.getMessage()); }\n}\n```\n\n## 异常传播链\n\n```\nService抛出 → Controller传播 → Handler捕获 → Result.error(msg) → JSON响应\n```\n\n## 关键点\n\n1. `@ControllerAdvice` 全局控制器增强\n2. `@ExceptionHandler` 指定捕获类型\n3. BusinessException extends RuntimeException\n4. 避免异常堆栈暴露给用户',
'全局异常处理@ControllerAdvice、BusinessException、异常传播链', 1, 0, 10, NOW(), NOW(), 0),

-- 知识点 16: ThreadLocal
(16, 1, 'ThreadLocal — 线程隔离的上下文传递',
'## 为什么需要 ThreadLocal？\n\nTomcat 线程池处理并发请求，需在 Filter → Controller → Service → AOP 间传递用户ID，但不直接传参。\n\n## CurrentHolder\n\n```java\npublic class CurrentHolder {\n    private static final ThreadLocal<Integer> CURRENT_ID = new ThreadLocal<>();\n    public static void setCurrentId(Integer id) { CURRENT_ID.set(id); }\n    public static Integer getCurrentId() { return CURRENT_ID.get(); }\n    public static void remove() { CURRENT_ID.remove(); }\n}\n```\n\n## 使用位置\n\n| 位置 | 操作 |\n|-----|------|\n| TokenFilter | setCurrentId(id) 存入 |\n| AOP切面 | getCurrentId() 取出 |\n| TokenFilter finally | remove() 清理 |\n\n## 关键点\n\n1. 线程隔离——每个线程独立副本\n2. 无需传参——跨层获取\n3. **必须清理**——线程池复用不remove会内存泄漏',
'ThreadLocal线程隔离、CurrentHolder实现、跨层传递用户ID、finally清理防泄漏', 1, 0, 10, NOW(), NOW(), 0),

-- 知识点 17: 动态 SQL
(17, 1, 'MyBatis 动态 SQL — if/where/set/foreach',
'## 四大标签\n\n### `<if>` 条件判断\n```xml\n<if test="name != null and name != \'\'">\n    e.name like concat(\'%\',#{name},\'%\')\n</if>\n```\n\n### `<where>` 自动处理WHERE\n- 条件全空时不加WHERE\n- 自动去掉第一个多余AND\n\n### `<set>` 自动处理逗号\n- 自动去掉末尾多余逗号\n- 只更新非空字段\n\n### `<foreach>` 遍历集合\n```xml\n<foreach collection="ids" item="id" separator="," open="(" close=")">\n    #{id}\n</foreach>\n```\n- collection 集合参数名\n- item 循环变量\n- separator 分隔符\n- open/close 首尾包裹',
'MyBatis动态SQL四大标签：if条件、where处理WHERE、set处理逗号、foreach遍历', 1, 0, 11, NOW(), NOW(), 0),

-- 知识点 18: 统一响应格式
(18, 1, '统一响应格式 — Result + PageResult',
'## Result 结构\n\n```json\n// 成功\n{"code": 1, "msg": null, "data": {...}}\n// 失败\n{"code": 0, "msg": "错误信息", "data": null}\n```\n\n## PageResult 分页\n\n```json\n{"code": 1, "msg": null, "data": {"total": 7, "rows": [...]}}\n```\n\n## 设计原则\n\n1. 统一格式——所有接口相同结构\n2. code语义——1成功，0失败\n3. data灵活——对象/数组/null\n4. `Result.success()` / `Result.error()` 静态工厂方法',
'Result统一响应格式、PageResult分页响应、code/msg/data三字段设计', 1, 0, 12, NOW(), NOW(), 0);

-- ============================================================
-- 第6步：帖子-标签关联
-- ============================================================

INSERT INTO `post_tag` (`post_id`, `tag_id`) VALUES
-- 知识点1: 项目概述
(1, 1), (1, 2), (1, 15),
-- 知识点2: 技术栈
(2, 1), (2, 2), (2, 3), (2, 4), (2, 6), (2, 7), (2, 8), (2, 9), (2, 10), (2, 11), (2, 12), (2, 13),
-- 知识点3: 三层架构
(3, 2), (3, 3), (3, 9), (3, 15),
-- 知识点4: 数据库设计
(4, 4), (4, 6),
-- 知识点5: 部门管理
(5, 3), (5, 4), (5, 15), (5, 16),
-- 知识点6: 员工分页查询
(6, 4), (6, 14), (6, 19), (6, 20),
-- 知识点7: 新增员工+事务
(7, 2), (7, 4), (7, 17), (7, 20),
-- 知识点8: resultMap
(8, 4), (8, 21), (8, 20),
-- 知识点9: 班级管理
(9, 4), (9, 18),
-- 知识点10: JWT
(10, 8), (10, 10), (10, 11),
-- 知识点11: AOP
(11, 2), (11, 9),
-- 知识点12: 事务传播
(12, 2), (12, 17),
-- 知识点13: 文件上传
(13, 2), (13, 3), (13, 13),
-- 知识点14: 报表统计
(14, 4), (14, 6),
-- 知识点15: 全局异常
(15, 2), (15, 18),
-- 知识点16: ThreadLocal
(16, 11),
-- 知识点17: 动态SQL
(17, 4), (17, 20), (17, 21),
-- 知识点18: 统一响应
(18, 15), (18, 16);
