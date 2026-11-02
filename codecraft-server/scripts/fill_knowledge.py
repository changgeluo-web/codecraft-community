#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""批量写入知识点内容到 MySQL，避免 SQL 转义问题"""
import os
import pymysql
import sys

# 连接配置
conn = pymysql.connect(
    host='localhost', port=3306, user='root', password=os.environ.get('MYSQL_PASSWORD', ''),
    database='jiangma', charset='utf8mb4', autocommit=False
)
cursor = conn.cursor()

# 获取 category_id (tlias 项目)
cursor.execute("SELECT id FROM category WHERE name LIKE 'tlias%' AND deleted=0 LIMIT 1")
cat_id = cursor.fetchone()[0]

# 获取系统用户 ID
cursor.execute("SELECT id FROM user WHERE username='system' LIMIT 1")
author_id = cursor.fetchone()[0]

# 知识点数据：每条 (title, summary, content)
knowledge_points = [
    (
        '员工分页查询 — PageHelper + 动态条件',
        'PageHelper分页原理、动态SQL条件查询、EmpQueryParam参数对象、执行流程',
        '''## 接口定义

`GET /emps?name=xxx&gender=xxx&begin=xxx&end=xxx&page=1&pageSize=10`

分页 + 条件查询员工列表，返回 PageResult。

## Controller 层

```java
@Slf4j
@RequestMapping("/emps")
@RestController
public class EmpController {
    @Autowired
    private EmpService empService;

    @GetMapping
    public Result page(EmpQueryParam empQueryParam) {
        // EmpQueryParam 包含 name, gender, begin, end, page, pageSize
        // Spring MVC 自动将请求参数绑定到对象属性
        log.info("分页查询:{}", empQueryParam);
        PageResult<Emp> pageResult = empService.page(empQueryParam);
        return Result.success(pageResult);
    }
}
```

**要点：** 用查询参数对象 `EmpQueryParam` 接收多个参数，比逐个声明更清晰。

## Service 层

```java
@Override
public PageResult<Emp> page(EmpQueryParam empQueryParam) {
    // 第1步：启动 PageHelper 分页拦截器
    PageHelper.startPage(empQueryParam.getPage(), empQueryParam.getPageSize());

    // 第2步：执行查询（PageHelper 会在 SQL 后自动拼 LIMIT）
    List<Emp> empList = empMapper.list(empQueryParam);

    // 第3步：PageHelper 将结果包装为 Page 对象（含 total 总记录数）
    Page<Emp> p = (Page<Emp>) empList;

    // 第4步：组装 PageResult 返回
    return new PageResult<Emp>(p.getTotal(), p.getResult());
}
```

## Mapper 层 — EmpMapper.xml 动态 SQL

```xml
<select id="list" resultType="com.changge.pojo.Emp">
    select e.id, e.username, e.name, e.gender, e.phone,
           e.job, e.salary, e.image, e.entry_date as entryDate,
           e.dept_id as deptId, e.create_time as createTime,
           e.update_time as updateTime, d.name as deptName
    from emp e
    left join dept d on e.dept_id = d.id
    <where>
        <if test="name != null and name != ''">
            e.name like concat('%',#{name},'%')
        </if>
        <if test="gender != null and gender != ''">
            and e.gender = #{gender}
        </if>
        <if test="begin != null and end != null">
            and e.entry_date between #{begin} and #{end}
        </if>
    </where>
    order by e.update_time desc
</select>
```

## 动态 SQL 标签详解

| 标签 | 作用 |
|------|------|
| `<where>` | 自动处理 AND 前缀，条件全空时不加 WHERE |
| `<if test="...">` | 条件为 true 时拼接 SQL 片段 |
| `concat('%',#{name},'%')` | 模糊查询，% 包裹参数 |
| `left join` | 左连接，员工没有部门也显示 |

## PageHelper 分页原理

```
第1步 → PageHelper.startPage(1, 10) 将分页参数存入 ThreadLocal
第2步 → MyBatis 执行查询前，PageHelper 拦截器从 ThreadLocal 取出参数
第3步 → 自动在 SQL 后拼接 LIMIT 0, 10
第4步 → 额外执行 COUNT(*) 查询获取总记录数
第5步 → 将结果包装为 Page 对象（继承 ArrayList，额外含 total）
第6步 → 清除 ThreadLocal 中的分页参数
```

## 执行流程

```
第1步 → GET /emps?name=张&gender=1&page=1&pageSize=10
第2步 → 参数绑定到 EmpQueryParam 对象
第3步 → PageHelper.startPage(1, 10) 设置分页
第4步 → empMapper.list() 执行动态 SQL
第5步 → PageHelper 执行 COUNT 获取 total
第6步 → 组装 PageResult(total=7, rows=[...10条])
第7步 → 返回 JSON: {"code":1, "data":{"total":7, "rows":[...]}}
```
'''
    ),
    (
        '新增员工 — 事务管理 + 批量插入工作经历',
        '事务管理、主键回填、foreach批量插入、REQUIRES_NEW独立事务、执行流程',
        '''## 接口定义

`POST /emps` — 新增员工，可同时携带工作经历列表

```json
{
  "username": "zhangsan",
  "name": "张三",
  "gender": 1,
  "deptId": 1,
  "exprList": [
    {"begin": "2020-01", "end": "2022-06", "company": "腾讯", "job": "后端"}
  ]
}
```

## Controller 层

```java
@PostMapping
public Result save(@RequestBody Emp emp) {
    log.info("新增员工：{}", emp);
    empService.save(emp);
    return Result.success();
}
```

## Service 层 — 事务 + 独立日志事务

```java
@Transactional(rollbackFor = Exception.class)
@Override
public void save(Emp emp) {
    try {
        emp.setCreateTime(LocalDateTime.now());
        emp.setUpdateTime(LocalDateTime.now());

        // @Options(useGeneratedKeys=true, keyProperty="id")
        // 插入后自增主键自动回填到 emp.id
        empMapper.insert(emp);

        List<EmpExpr> exprList = emp.getExprList();
        if (!CollectionUtils.isEmpty(exprList)) {
            exprList.forEach(expr -> expr.setEmpid(emp.getId()));
            empExprMapper.insertBatch(exprList);
        }
    } finally {
        // 无论成败都记录日志
        // REQUIRES_NEW 独立事务，主事务回滚日志也保留
        EmpLog empLog = new EmpLog(null, LocalDateTime.now(), "添加员工");
        empLogService.insertLog(empLog);
    }
}
```

## Mapper — 员工插入（主键回填）

```java
@Options(useGeneratedKeys = true, keyProperty = "id")
@Insert("insert into emp (username, password, name, gender, phone, job, " +
        "salary, image, entry_date, dept_id, create_time, update_time) " +
        "values (#{username}, #{password}, #{name}, #{gender}, #{phone}, " +
        "#{job}, #{salary}, #{image}, #{entryDate}, #{deptId}, " +
        "#{createTime}, #{updateTime})")
void insert(Emp emp);
```

## Mapper — 工作经历批量插入（XML foreach）

```xml
<insert id="insertBatch">
    insert into emp_expr (emp_id, begin, end, company, job) values
    <foreach collection="empList" item="emp" separator=",">
        (#{emp.empid}, #{emp.begin}, #{emp.end}, #{emp.company}, #{emp.job})
    </foreach>
</insert>
```

**生成 SQL：** `insert into emp_expr (...) values (8, ...), (8, ...)`

## EmpLogService — 独立事务

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)
@Override
public void insertLog(EmpLog empLog) {
    empLogMapper.insert(empLog);
}
```

## 执行流程

```
第1步 → POST /emps，请求体含员工信息 + exprList
第2步 → 事务开启
第3步 → empMapper.insert(emp) 插入员工，自增ID回填
第4步 → 遍历 exprList 设置 empId
第5步 → empExprMapper.insertBatch() 批量插入工作经历
第6步 → finally: empLogService.insertLog() 独立事务记录日志
第7步 → 事务提交
第8步 → 返回 Result.success()
```

## 为什么用 REQUIRES_NEW？

工作经历插入失败时主事务回滚，但日志在独立事务中已提交，保留了操作记录。如果用默认 REQUIRED，日志跟着主事务一起回滚，丢失操作记录。
'''
    ),
    (
        'resultMap 一对多关联 — 员工 + 工作经历',
        'resultMap定义、collection一对多映射、列名别名避免冲突、MyBatis合并行原理',
        '''## 接口定义

`GET /emps/{id}` — 查询单个员工详细信息，包含工作经历列表

## Mapper 层 — EmpMapper.xml（核心）

```xml
<resultMap id="empResultMap" type="com.changge.pojo.Emp">
    <id property="id" column="id"/>
    <result property="username" column="username"/>
    <result property="name" column="name"/>
    <result property="gender" column="gender"/>
    <result property="phone" column="phone"/>
    <result property="job" column="job"/>
    <result property="salary" column="salary"/>
    <result property="entryDate" column="entry_date"/>
    <result property="deptId" column="dept_id"/>

    <!-- collection：映射一对多关系 -->
    <collection property="exprList" ofType="com.changge.pojo.EmpExpr">
        <id property="id" column="ee_id"/>
        <result property="empid" column="ee_empid"/>
        <result property="begin" column="ee_begin"/>
        <result property="end" column="ee_end"/>
        <result property="company" column="ee_company"/>
        <result property="job" column="ee_job"/>
    </collection>
</resultMap>

<select id="getById" resultMap="empResultMap">
    select e.*, ee.id as ee_id, ee.emp_id as ee_empid,
           ee.begin as ee_begin, ee.end as ee_end,
           ee.company as ee_company, ee.job as ee_job
    from emp e
        left join emp_expr ee on e.id = ee.emp_id
    where e.id = #{id}
</select>
```

## resultMap 标签详解

| 标签 | 作用 |
|------|------|
| `<resultMap>` | 定义结果映射规则 |
| `<id>` | 主键映射，MyBatis 用它判断是否同一对象（合并行去重） |
| `<result>` | 普通字段映射 |
| `<collection>` | 一对多关系，property 是集合属性名，ofType 是元素类型 |

## 为什么用别名 ee_id, ee_empid？

两个表都有 id 字段，不用别名 MyBatis 无法区分 emp.id 和 emp_expr.id。用 `ee_` 前缀避免列名冲突。

## MyBatis 合并行原理

```
SQL 返回多行（每行一条工作经历）:
  | id=5 | name=张无忌 | ee_id=1 | company=腾讯 |
  | id=5 | name=张无忌 | ee_id=2 | company=阿里 |

MyBatis 根据 <id column="id"/> 判断 id=5 是同一个员工
→ 合并为一个 Emp 对象
→ 每行 ee_* 组装成 EmpExpr 加入 exprList
→ 最终: Emp(id=5, name=张无忌, exprList=[腾讯, 阿里])
```

## 执行流程

```
第1步 → GET /emps/5
第2步 → empMapper.getById(5) 执行关联查询
第3步 → MySQL 返回多行（每行一条工作经历）
第4步 → MyBatis 根据 resultMap 合并行
第5步 → 返回 Emp 对象（含 exprList）
第6步 → JSON: {"code":1, "data":{"id":5, "name":"张无忌", "exprList":[...]}}
```
'''
    ),
    (
        '批量删除员工 — foreach + 事务保证一致性',
        'foreach生成IN列表、@RequestParam绑定List、事务保证关联数据一致性',
        '''## 接口定义

`DELETE /emps?ids=1,2,3` — 批量删除员工，同时删除关联工作经历

## Controller 层

```java
@DeleteMapping
public Result delete(@RequestParam List<Integer> ids) {
    // ids=1,2,3 自动绑定为 List<Integer>
    log.info("删除员工信息：{}", ids);
    empService.delete(ids);
    return Result.success();
}
```

## Service 层 — 事务保证

```java
@Transactional(rollbackFor = Exception.class)
@Override
public void delete(List<Integer> ids) {
    empMapper.deleteByIds(ids);        // 删除员工
    empExprMapper.deleteByEmpIds(ids); // 删除工作经历
    // 第2步失败 → 第1步也回滚
}
```

## Mapper — 批量删除（XML foreach）

```xml
<delete id="deleteByIds">
    delete from emp where id in
    <foreach collection="ids" item="id" separator="," open="(" close=")">
        #{id}
    </foreach>
</delete>
```

生成 SQL: `delete from emp where id in (1, 2, 3)`

## Mapper — 批量删除工作经历

```xml
<delete id="deleteByEmpIds">
    delete from emp_expr where emp_id in
    <foreach collection="empIds" item="empId" separator="," open="(" close=")">
        #{empId}
    </foreach>
</delete>
```

## 执行流程

```
第1步 → DELETE /emps?ids=1,2,3
第2步 → 参数绑定为 List<Integer> [1, 2, 3]
第3步 → 事务开启
第4步 → deleteByIds: delete from emp where id in (1, 2, 3)
第5步 → deleteByEmpIds: delete from emp_expr where emp_id in (1, 2, 3)
第6步 → 两步都成功 → 事务提交
        如果第5步失败 → 第4步也回滚
第7步 → 返回 Result.success()
```

## 事务的作用

没有事务：删了员工但工作经历没删 → 脏数据
有事务：两步在同一事务中，要么都成功要么都回滚 → 数据一致性
'''
    ),
    (
        '班级管理 — 业务校验与 CASE WHEN 状态计算',
        'CASE WHEN动态计算状态、BusinessException业务校验、删除前校验学员数',
        '''## 接口清单

| 方法 | URL | 功能 |
|------|-----|------|
| GET | /clazzs | 分页查询 |
| POST | /clazzs | 新增 |
| GET | /clazzs/{id} | 根据ID查询 |
| PUT | /clazzs | 修改 |
| DELETE | /clazzs/{id} | 删除（有学员时禁止） |

## 1. 分页查询 — CASE WHEN 计算状态

### Mapper XML

```xml
<select id="list" resultType="com.changge.pojo.Clazz">
    select c.*, e.name masterName,
    (case
        when begin_date &gt; now() then '未开班'
        when now() &gt; end_date then '已结课'
        else '在读中'
     end) status
    from clazz c left join emp e on c.master_id = e.id
    <where>
        <if test="name != null and name != ''">
            c.name like concat('%',#{name},'%')
        </if>
    </where>
    order by c.update_time desc
</select>
```

**CASE WHEN 逻辑：** 开课日期 > 当前 → 未开班；当前 > 结课 → 已结课；其他 → 在读中

**注意：** XML 中 `>` 写成 `&gt;`

## 2. 删除班级 — 业务校验

### Service

```java
@Override
public void deleteById(Integer id) {
    Integer count = studentMapper.countByClazzId(id);
    if (count > 0) {
        throw new BusinessException("班级下有学员, 不能直接删除~");
    }
    clazzMapper.deleteById(id);
}
```

### BusinessException

```java
public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}
```

## 执行流程（删除有学员的班级）

```
第1步 → DELETE /clazzs/1
第2步 → studentMapper.countByClazzId(1) → count=5
第3步 → count > 0 → throw BusinessException
第4步 → GlobalExceptionHandler 捕获
第5步 → 返回 Result.error("班级下有学员, 不能直接删除~")
第6步 → JSON: {"code":0, "msg":"班级下有学员, 不能直接删除~"}
```

## 设计要点

1. 业务校验在 Service 层，不在 Controller 判断
2. 抛异常而非返回错误码，全局异常处理器统一处理
3. CASE WHEN 在 SQL 层动态计算状态，不需要单独字段
'''
    ),
    (
        'JWT 鉴权完整流程 — 登录签发 + Filter 校验',
        'JWT三段结构、登录签发令牌、TokenFilter校验流程、ThreadLocal存储用户ID',
        '''## JWT 三段式结构

```
header.payload.signature

header:    {"alg":"HS256","typ":"JWT"}              → Base64
payload:   {"id":1,"username":"admin","exp":...}     → Base64
signature: HMAC-SHA256(base64(header)+"."+base64(payload), "6aaZ5a+G")
```

## 1. 登录签发令牌

### Service

```java
@Override
public LoginInfo login(Emp emp) {
    Emp e = empMapper.selectByUsernameAndPassword(emp);
    if (e != null) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("id", e.getId());
        claims.put("username", e.getUsername());
        String jwt = JwtUtils.generateJwt(claims);
        return new LoginInfo(e.getId(), e.getUsername(), e.getName(), jwt);
    }
    return null;
}
```

## 2. TokenFilter 校验令牌

```java
@WebFilter(urlPatterns = "/*")
public class TokenFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) {
        HttpServletRequest request = (HttpServletRequest) req;
        String path = request.getRequestURI();

        // /login 放行
        if (path.contains("/login")) {
            chain.doFilter(req, resp);
            return;
        }

        String token = request.getHeader("Authorization");
        if (token == null || token.isEmpty()) {
            response.setStatus(401);
            return;
        }

        try {
            Claims claims = JwtUtils.parseToken(token);
            Integer id = Integer.valueOf(claims.get("id").toString());
            CurrentHolder.setCurrentId(id);  // 存入 ThreadLocal
        } catch (Exception e) {
            response.setStatus(401);
            return;
        }

        chain.doFilter(req, resp);       // 放行
        CurrentHolder.remove();          // finally 清除
    }
}
```

## 完整鉴权流程

```
【登录】
第1步 → POST /login {"username":"admin","password":"<管理员密码>"}
第2步 → TokenFilter 放行 /login
第3步 → 查询 emp 表验证
第4步 → 生成 JWT 令牌
第5步 → 返回 LoginInfo(含 token)
第6步 → 前端保存 token

【访问业务接口】
第7步 → 请求带 Authorization: xxx.yyy.zzz
第8步 → TokenFilter 拦截
第9步 → 不是 /login → 获取 token
第10步 → 解析失败 → 401
第11步 → 解析成功 → CurrentHolder.setCurrentId(id)
第12步 → 放行到 Controller
第13步 → finally: CurrentHolder.remove()
```

## 为什么 finally 要 remove？

Tomcat 线程池复用线程。不清除 ThreadLocal，下一个请求复用线程时读到上一个请求的用户 ID，造成数据错乱。
'''
    ),
    (
        'AOP 操作日志 — @Log 注解 + 环绕通知',
        'AOP核心概念、@Log自定义注解、@Around环绕通知、自动记录操作日志',
        '''## AOP 核心概念

| 术语 | 解释 | 本项目对应 |
|------|------|-----------|
| 切面(Aspect) | 横切逻辑模块化 | OperationLogAspect |
| 切入点(Pointcut) | 拦截规则 | @annotation(com.changge.anno.Log) |
| 通知(Advice) | 拦截后执行的逻辑 | @Around 环绕通知 |

## @Log 注解

```java
@Target(METHOD)
@Retention(RUNTIME)
public @interface Log {}
```

## OperationLogAspect 切面

```java
@Aspect
@Component
public class OperationLogAspect {
    @Autowired
    private OperateLogMapper operateLogMapper;

    @Around("@annotation(com.changge.anno.Log)")
    public Object recordLog(ProceedingJoinPoint joinPoint) throws Throwable {
        long begin = System.currentTimeMillis();
        Integer operateEmpId = CurrentHolder.getCurrentId();
        String className = joinPoint.getTarget().getClass().getName();
        String methodName = joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs();

        Object result = joinPoint.proceed();  // 执行目标方法

        long costTime = System.currentTimeMillis() - begin;
        OperateLog log = new OperateLog();
        log.setOperateEmpId(operateEmpId);
        log.setOperateTime(LocalDateTime.now());
        log.setClassName(className);
        log.setMethodName(methodName);
        log.setMethodParams(Arrays.toString(args));
        log.setCostTime(costTime);
        operateLogMapper.insert(log);

        return result;
    }
}
```

## 使用方式

```java
@Log
@PostMapping
public Result add(@RequestBody Dept dept) {
    deptService.add(dept);
    return Result.success();
}
// AOP 自动记录: DeptController.add, 参数, 返回值, 耗时
```

## 执行流程

```
第1步 → POST /depts
第2步 → TokenFilter 存 id 到 ThreadLocal
第3步 → AOP 检测到 @Log → 环绕通知开始
第4步 → 记录开始时间、获取操作人 ID、类名方法名参数
第5步 → proceed() 执行目标方法
第6步 → 获取返回值、计算耗时
第7步 → 插入 operate_log 表
第8步 → 返回原始返回值
```
'''
    ),
    (
        '事务传播行为 — REQUIRES_NEW 独立日志事务',
        'REQUIRES_NEW独立事务、主子事务关系、七种传播行为对比',
        '''## 场景

新增员工时无论成败都要记录日志。用 REQUIRES_NEW 让日志在独立事务中提交。

## 主事务

```java
@Transactional(rollbackFor = Exception.class)
@Override
public void save(Emp emp) {
    try {
        empMapper.insert(emp);
        empExprMapper.insertBatch(exprList);
    } finally {
        EmpLog empLog = new EmpLog(null, LocalDateTime.now(), "添加员工");
        empLogService.insertLog(empLog);  // 独立事务
    }
}
```

## 子事务

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)
@Override
public void insertLog(EmpLog empLog) {
    empLogMapper.insert(empLog);
}
```

## 传播行为图解

```
┌─────────────────────────────────────────┐
│  主事务 (save)                           │
│  操作1: empMapper.insert(emp)            │
│  操作2: empExprMapper.insertBatch()      │
│  finally {                               │
│    ┌─────────────────────────────────┐  │
│    │  子事务 (insertLog, REQUIRES_NEW) │  │
│    │  操作3: empLogMapper.insert(log) │  │
│    │  ★ 独立事务，不受主事务影响        │  │
│    │  ★ 主事务回滚 → 子事务不回滚       │  │
│    └─────────────────────────────────┘  │
│  }                                       │
│  主事务提交/回滚                          │
└─────────────────────────────────────────┘
```

## 七种传播行为

| 传播行为 | 说明 |
|---------|------|
| REQUIRED (默认) | 有事务就加入，没有就新建 |
| REQUIRES_NEW | 总是新建独立事务，挂起当前事务 |
| SUPPORTS | 有事务就加入，没有就非事务运行 |
| NOT_SUPPORTED | 非事务运行，有事务就挂起 |

## 为什么用 REQUIRES_NEW？

工作经历插入失败 → 主事务回滚 → 但日志在独立事务中已提交 → 保留了操作记录
'''
    ),
    (
        '文件上传 — MultipartFile + 阿里云 OSS',
        'MultipartFile文件接收、阿里云OSS上传、@ConfigurationProperties配置外部化',
        '''## 接口定义

`POST /upload` — 上传文件，返回 OSS 访问 URL

## Controller

```java
@PostMapping("/upload")
public Result upload(MultipartFile file) throws Exception {
    log.info("文件上传：{}", file.getOriginalFilename());
    String url = aliyunOSSOperator.upload(
        file.getBytes(), file.getOriginalFilename());
    return Result.success(url);
}
```

## OSS 配置

```yaml
aliyun:
  oss:
    endpoint: https://oss-cn-beijing.aliyuncs.com
    bucketName: changge-web-tlias
    region: cn-beijing
```

## OSS 工具类上传逻辑

```java
public String upload(byte[] content, String originalFilename) {
    // 1. 生成唯一文件名: yyyy/MM/dd/uuid-原文件名
    String fileName = LocalDate.now() + "/" + UUID.randomUUID() + "-" + originalFilename;
    // 2. OSS SDK 上传
    ossClient.putObject(bucketName, fileName, new ByteArrayInputStream(content));
    // 3. 返回公网 URL
    return "https://" + bucketName + "." + endpoint + "/" + fileName;
}
```

## 执行流程

```
第1步 → POST /upload, multipart/form-data
第2步 → Spring MVC 绑定文件到 MultipartFile
第3步 → file.getBytes() 获取字节数组
第4步 → OSS 上传，生成唯一文件名
第5步 → 返回访问 URL
第6步 → 前端用 URL 设置头像等
```

## 关键点

1. MultipartFile 是 Spring 内置接口
2. UUID 防止重名覆盖
3. @ConfigurationProperties 从 yml 读取配置
4. AccessKey 从环境变量读取，不硬编码
'''
    ),
    (
        '报表统计 — GROUP BY + CASE WHEN + IF 聚合查询',
        'GROUP BY分组统计、CASE WHEN多路分支、IF两路分支、Stream API提取数据',
        '''## 接口清单

| 方法 | URL | 功能 |
|------|-----|------|
| GET | /report/empJobData | 各职位人数（饼图） |
| GET | /report/empGenderData | 男女人数（柱状图） |

## 1. 统计职位人数

### Mapper XML

```xml
<select id="countEmpJobData" resultType="java.util.Map">
    select
        (case
             when job=1 then '学工部'
             when job=2 then '教研部'
             when job=3 then '咨询部'
             when job=4 then '就业部'
             when job=5 then '人事部'
             else '其他' end) pos,
        count(*) num
    from emp
    group by job
    order by num
</select>
```

### Service — Stream API 提取

```java
@Override
public JobOption getEmpJobData() {
    List<Map<String, Object>> list = empMapper.countEmpJobData();
    List<Object> jobList = list.stream().map(m -> m.get("pos")).toList();
    List<Object> dataList = list.stream().map(m -> m.get("num")).toList();
    return new JobOption(jobList, dataList);
}
```

## 2. 统计性别人数

```xml
<select id="countEmpGenderData" resultType="java.util.Map">
    select if(gender = 1, '男性员工', '女性员工') as name,
           count(*) as value
    from emp
    group by gender
</select>
```

## IF vs CASE WHEN

- `IF(cond, true, false)` — 两路分支
- `CASE WHEN ... THEN ... ELSE ... END` — 多路分支

## 执行流程

```
第1步 → GET /report/empJobData
第2步 → SQL: select (case when job=1 then '学工部'...) pos, count(*) num from emp group by job
第3步 → 返回 [{pos:"学工部", num:2}, ...]
第4步 → Stream API 提取 jobList 和 dataList
第5步 → 组装 JobOption 返回前端渲染饼图
```
'''
    ),
    (
        '全局异常处理 — @ControllerAdvice 统一捕获',
        '@ControllerAdvice全局捕获、@ExceptionHandler分类处理、BusinessException业务异常',
        '''## 问题

Controller 抛异常 → 500 错误页面，体验差，可能暴露内部信息。

## GlobalExceptionHandler

```java
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    @ResponseBody
    public Result handleException(Exception e) {
        return Result.error("出错啦");
    }

    @ExceptionHandler(DuplicateKeyException.class)
    @ResponseBody
    public Result handleDuplicateKey(DuplicateKeyException e) {
        return Result.error("数据已存在");
    }
}
```

## BusinessException

```java
public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}
```

继承 RuntimeException：不需要 try-catch，由全局处理器统一捕获。

## 使用场景

```java
// 班级删除校验
if (count > 0) {
    throw new BusinessException("班级下有学员, 不能直接删除~");
}
```

## 异常处理流程

```
第1步 → throw BusinessException("班级下有学员...")
第2步 → 异常向上抛: Service → Controller
第3步 → @ControllerAdvice 捕获
第4步 → @ExceptionHandler 匹配
第5步 → 返回 Result.error(...)
第6步 → JSON: {"code":0, "msg":"..."}
```

## 设计要点

1. 系统异常返回通用提示，业务异常返回具体原因
2. 不暴露堆栈，详细记录在日志中
3. 所有异常通过 Result 统一返回
'''
    ),
    (
        'ThreadLocal — 线程隔离的上下文传递',
        'ThreadLocal线程隔离原理、CurrentHolder实现、Filter存AOP取、必须remove',
        '''## 问题

需要在请求的任意层（Filter → Controller → Service → AOP）获取当前登录用户 ID，但层之间不直接传参。

## CurrentHolder

```java
public class CurrentHolder {
    private static final ThreadLocal<Integer> CURRENT_ID = new ThreadLocal<>();

    public static void setCurrentId(Integer id) { CURRENT_ID.set(id); }
    public static Integer getCurrentId() { return CURRENT_ID.get(); }
    public static void remove() { CURRENT_ID.remove(); }
}
```

## 原理

```
线程1 → ThreadLocal 存 id=1 → Controller → Service → AOP 取 id=1
线程2 → ThreadLocal 存 id=2 → Controller → Service → AOP 取 id=2
线程3 → ThreadLocal 存 id=3 → Controller → Service → AOP 取 id=3

每个线程有独立副本，互不干扰。
```

## 使用位置

| 位置 | 操作 |
|------|------|
| TokenFilter | setCurrentId(id) |
| OperationLogAspect | getCurrentId() |
| TokenFilter (finally) | remove() |

## 为什么必须 remove？

```
线程1 处理请求A(id=1) → 没清除 → 归还线程池
线程1 复用处理请求B(id=2) → ThreadLocal 残留 id=1 → 数据错乱！
```

## 内存泄漏

线程池线程长期存活，ThreadLocal 引用的对象无法 GC。用完就 remove，不要存大对象。
'''
    ),
    (
        'MyBatis 动态 SQL — if/where/set/foreach',
        'if条件拼接、where自动处理AND、set自动处理逗号、foreach批量操作',
        '''## 动态 SQL 标签

| 标签 | 作用 | 场景 |
|------|------|------|
| `<if>` | 条件成立时拼接 | 按需筛选 |
| `<where>` | 自动处理 AND 前缀 | 多条件查询 |
| `<set>` | 自动处理末尾逗号 | 动态更新 |
| `<foreach>` | 遍历集合 | 批量操作 |

## 1. 条件查询

```xml
<select id="list">
    select * from emp
    <where>
        <if test="name != null and name != ''">
            name like concat('%',#{name},'%')
        </if>
        <if test="gender != null">
            and gender = #{gender}
        </if>
    </where>
</select>
```

`<where>` 自动处理 AND 前缀，条件全空不加 WHERE。

## 2. 动态更新

```xml
<update id="updateById">
    update emp
    <set>
        <if test="name != null">name = #{name},</if>
        <if test="salary != null">salary = #{salary},</if>
        <if test="updateTime != null">update_time = #{updateTime}</if>
    </set>
    where id = #{id}
</update>
```

`<set>` 自动去掉末尾逗号，只更新非空字段。

## 3. 批量操作

```xml
<delete id="deleteByIds">
    delete from emp where id in
    <foreach collection="ids" item="id" separator="," open="(" close=")">
        #{id}
    </foreach>
</delete>
```

生成: `delete from emp where id in (1, 2, 3)`

## #{} vs ${}

| 写法 | 说明 | 安全性 |
|------|------|--------|
| `#{name}` | 预编译参数 | 防注入 |
| `${name}` | 字符串拼接 | 有注入风险 |

**始终用 #{}**
'''
    ),
    (
        '统一响应格式 — Result + PageResult',
        'Result统一响应类、PageResult分页封装、code/msg/data三字段设计',
        '''## Result 类

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Result {
    private Integer code;    // 1=成功, 0=失败
    private String msg;      // 错误信息
    private Object data;     // 业务数据

    public static Result success() { return new Result(1, null, null); }
    public static Result success(Object data) { return new Result(1, null, data); }
    public static Result error(String msg) { return new Result(0, msg, null); }
}
```

## PageResult 类

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PageResult {
    private Long total;    // 总记录数
    private List rows;     // 当前页数据
}
```

## 响应格式

```json
// 成功
{"code": 1, "msg": null, "data": {"id": 3, "name": "教研部"}}

// 分页
{"code": 1, "msg": null, "data": {"total": 7, "rows": [...]}}

// 失败
{"code": 0, "msg": "用户名或密码错误", "data": null}
```

## Controller 使用

```java
// 查询
return Result.success(dept);        // {code:1, data:{...}}

// 增删改
return Result.success();            // {code:1, data:null}

// 失败
return Result.error("错误信息");     // {code:0, msg:"..."}
```

## 前端解析

```javascript
if (response.data.code === 1) {
    console.log(response.data.data);
} else {
    alert(response.data.msg);
}
```

## 设计要点

1. 统一格式 {code, msg, data}
2. code=1 成功，code=0 失败
3. 静态工厂方法让代码简洁
4. PageResult 独立封装分页数据
'''
    ),
]

# 清除之前只有4条的问题，删除旧数据重新插入
cursor.execute("SET FOREIGN_KEY_CHECKS=0")
cursor.execute("DELETE FROM post_tag")
cursor.execute("DELETE FROM post WHERE deleted=0")
cursor.execute("SET FOREIGN_KEY_CHECKS=1")
conn.commit()

# 插入知识点
insert_sql = """
INSERT INTO post (author_id, title, content, summary, status, view_count, category_id, created_at, updated_at, deleted, study_status)
VALUES (%s, %s, %s, %s, 1, 0, %s, NOW(), NOW(), 0, 0)
"""

inserted_ids = []
for i, (title, summary, content) in enumerate(knowledge_points):
    cursor.execute(insert_sql, (author_id, title, content, summary, cat_id))
    inserted_ids.append(cursor.lastrowid)
    print(f"  [{i+1}/{len(knowledge_points)}] {title} ({len(content)} chars)")

conn.commit()
print(f"\nInserted {len(inserted_ids)} knowledge points, IDs: {inserted_ids}")

# 重建 post_tag 关联
# 获取 tag ID 映射
cursor.execute("SELECT id, name FROM tag WHERE deleted=0")
tag_map = {name: tid for tid, name in cursor.fetchall()}

# 知识点-标签关联
post_tag_map = {
    0: ['PageHelper','MyBatis','动态SQL','分页查询'],           # 员工分页查询
    1: ['事务管理','MyBatis','动态SQL'],                         # 新增员工
    2: ['resultMap','MyBatis'],                                  # resultMap一对多
    3: ['事务管理','MyBatis','动态SQL'],                         # 批量删除员工
    4: ['MyBatis','MySQL8.0','异常处理'],                        # 班级管理
    5: ['JWT','Filter','ThreadLocal'],                           # JWT鉴权
    6: ['AOP','SLF4J','ThreadLocal'],                            # AOP操作日志
    7: ['事务管理'],                                             # 事务传播
    8: ['阿里云OSS'],                                            # 文件上传
    9: ['MySQL8.0','MyBatis'],                                   # 报表统计
    10: ['异常处理','Spring Boot3'],                             # 全局异常
    11: ['ThreadLocal','Filter'],                                # ThreadLocal
    12: ['动态SQL','MyBatis'],                                   # 动态SQL
    13: ['RESTful','JSON','Spring Boot3'],                       # 统一响应
}

tag_insert_sql = "INSERT INTO post_tag (post_id, tag_id) VALUES (%s, %s)"
tag_count = 0
for idx, tag_names in post_tag_map.items():
    post_id = inserted_ids[idx]
    for tag_name in tag_names:
        if tag_name in tag_map:
            cursor.execute(tag_insert_sql, (post_id, tag_map[tag_name]))
            tag_count += 1

conn.commit()
print(f"Inserted {tag_count} post_tag relations")

# 验证
cursor.execute("SELECT COUNT(*) FROM post WHERE deleted=0")
total_posts = cursor.fetchone()[0]
cursor.execute("SELECT AVG(CHAR_LENGTH(content)) FROM post WHERE deleted=0")
avg_len = cursor.fetchone()[0]
cursor.execute("SELECT COUNT(*) FROM post_tag")
total_tags = cursor.fetchone()[0]
print(f"\n=== Verification ===")
print(f"Total posts: {total_posts}")
print(f"Avg content length: {avg_len:.0f} chars")
print(f"Total post_tag relations: {total_tags}")

cursor.close()
conn.close()
print("\nDone!")
