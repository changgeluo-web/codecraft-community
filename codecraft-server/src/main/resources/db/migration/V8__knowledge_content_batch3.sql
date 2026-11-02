-- 批次3: 知识点 9-13 (班级管理、登录鉴权、文件上传、报表统计、AOP日志)

-- 知识点 9: 班级管理 — 业务校验与 CASE WHEN
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '班级管理 — 业务校验与 CASE WHEN 状态计算', '## 接口清单

| 方法 | URL | 功能 |
|------|-----|------|
| GET | /clazzs | 分页查询班级 |
| POST | /clazzs | 新增班级 |
| GET | /clazzs/{id} | 根据ID查询 |
| PUT | /clazzs | 修改班级 |
| DELETE | /clazzs/{id} | 删除班级（有学员时禁止） |

## 1. 分页查询 — CASE WHEN 计算班级状态

### Controller

```java
@GetMapping
public Result page(String name,
                   @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate begin,
                   @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate end,
                   @RequestParam(defaultValue = "1") Integer page,
                   @RequestParam(defaultValue = "10") Integer pageSize) {
    PageResult pageResult = clazzService.page(name, begin, end, page, pageSize);
    return Result.success(pageResult);
}
```

### Mapper XML — CASE WHEN 动态计算状态

```xml
<select id="list" resultType="com.changge.pojo.Clazz">
    select
    c.*,
    e.name masterName,
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
        <if test="begin != null and end != null">
            and c.end_date between #{begin} and #{end}
        </if>
    </where>
    order by c.update_time desc
</select>
```

**CASE WHEN 逻辑：**
- 开课日期 > 当前日期 → 「未开班」
- 当前日期 > 结课日期 → 「已结课」
- 其他 → 「在读中」

**注意：** XML 中 `>` 要写成 `&gt;`，因为 `>` 是 XML 标签结束符。

## 2. 删除班级 — 业务校验

### Service

```java
@Override
public void deleteById(Integer id) {
    // 第1步：查询班级下有多少学员
    Integer count = studentMapper.countByClazzId(id);

    // 第2步：有学员则抛出业务异常，禁止删除
    if (count > 0) {
        throw new BusinessException("班级下有学员, 不能直接删除~");
    }

    // 第3步：无学员才允许删除
    clazzMapper.deleteById(id);
}
```

### StudentMapper

```java
@Select("select count(*) from student where clazz_id = #{id}")
Integer countByClazzId(Integer id);
```

### BusinessException

```java
// 自定义业务异常，继承 RuntimeException
// 不需要 try-catch，由全局异常处理器统一捕获
public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}
```

## 执行流程（删除有学员的班级）

```
第1步 → DELETE /clazzs/1
第2步 → studentMapper.countByClazzId(1)
        SQL: select count(*) from student where clazz_id = 1
        返回 count=5
第3步 → count > 0 → 抛出 BusinessException("班级下有学员, 不能直接删除~")
第4步 → GlobalExceptionHandler 捕获异常
第5步 → 返回 Result.error("班级下有学员, 不能直接删除~")
第6步 → JSON: {"code":0, "msg":"班级下有学员, 不能直接删除~"}
```

## 设计要点

1. **业务校验在 Service 层**：不在 Controller 判断，保持 Controller 简洁
2. **抛异常而非返回错误码**：让全局异常处理器统一处理，代码更清晰
3. **CASE WHEN 在 SQL 层**：状态是动态计算的，不需要单独字段存储
4. **@DateTimeFormat**：指定日期参数格式，Spring MVC 自动解析
', 'CASE WHEN动态计算状态、BusinessException业务校验、删除前校验学员数', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 10: JWT 鉴权完整流程
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, 'JWT 鉴权完整流程 — 登录签发 + Filter 校验', '## JWT 三段式结构

```
header.payload.signature

header:    {"alg":"HS256","typ":"JWT"}              → Base64 编码
payload:   {"id":1,"username":"admin","exp":...}     → Base64 编码（载荷数据）
signature: HMAC-SHA256(base64(header)+"."+base64(payload), "6aaZ5a+G")  → 签名
```

## 1. 登录签发令牌

### Controller

```java
@PostMapping("/login")
public Result login(@RequestBody Emp emp) {
    log.info("登录：{}", emp);
    LoginInfo info = empService.login(emp);
    if (info != null) {
        return Result.success(info);
    }
    return Result.error("用户名或密码错误");
}
```

### Service

```java
@Override
public LoginInfo login(Emp emp) {
    Emp e = empMapper.selectByUsernameAndPassword(emp);
    if (e != null) {
        // 构建 JWT 载荷
        Map<String, Object> claims = new HashMap<>();
        claims.put("id", e.getId());
        claims.put("username", e.getUsername());
        // 生成令牌
        String jwt = JwtUtils.generateJwt(claims);
        return new LoginInfo(e.getId(), e.getUsername(), e.getName(), jwt);
    }
    return null;
}
```

### Mapper

```java
@Select("select id, username, name from emp " +
        "where username = #{username} and password = #{password}")
Emp selectByUsernameAndPassword(Emp emp);
```

## 2. TokenFilter 校验令牌

```java
@WebFilter(urlPatterns = "/*")
public class TokenFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;

        // 1. 获取请求路径
        String path = request.getRequestURI();

        // 2. /login 放行
        if (path.contains("/login")) {
            chain.doFilter(req, resp);
            return;
        }

        // 3. 获取令牌
        String token = request.getHeader("Authorization");
        if (token == null || token.isEmpty()) {
            response.setStatus(401);
            return;
        }

        // 4. 解析令牌
        try {
            Claims claims = JwtUtils.parseToken(token);
            Integer id = Integer.valueOf(claims.get("id").toString());
            // 5. 存入 ThreadLocal
            CurrentHolder.setCurrentId(id);
        } catch (Exception e) {
            response.setStatus(401);
            return;
        }

        // 6. 放行
        chain.doFilter(req, resp);

        // 7. 清除 ThreadLocal（防止内存泄漏）
        CurrentHolder.remove();
    }
}
```

## 完整鉴权流程

```
【登录阶段】
第1步 → POST /login，请求体: {"username":"admin","password":"123456"}
第2步 → TokenFilter 检测到 /login，直接放行
第3步 → 查询 emp 表验证用户名密码
第4步 → 构建 claims: {id:1, username:"admin"}
第5步 → JwtUtils.generateJwt(claims) 生成令牌
第6步 → 返回 LoginInfo(含 token)
第7步 → 前端保存 token 到 localStorage

【访问业务接口】
第8步 → 前端发请求，Header: Authorization: xxx.yyy.zzz
第9步 → TokenFilter 拦截
第10步 → 不是 /login → 获取 Authorization 头
第11步 → 令牌为空 → 返回 401
第12步 → JwtUtils.parseToken(token) 解析
第13步 → 解析失败（伪造/过期）→ 返回 401
第14步 → 解析成功 → CurrentHolder.setCurrentId(id)
第15步 → chain.doFilter() 放行到 Controller
第16步 → 请求处理完毕
第17步 → finally: CurrentHolder.remove() 清除 ThreadLocal
```

## 为什么 finally 要 remove？

Tomcat 使用线程池，线程会被复用。如果不清除 ThreadLocal，下一个请求复用这个线程时，会读到上一个请求的用户 ID，造成数据错乱。这是 ThreadLocal 内存泄漏的经典陷阱。
', 'JWT三段结构、登录签发令牌、TokenFilter校验流程、ThreadLocal存储用户ID、finally清除防止内存泄漏', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 11: AOP 操作日志
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, 'AOP 操作日志 — @Log 注解 + 环绕通知', '## AOP 核心概念

AOP（Aspect-Oriented Programming）将横切关注点（日志、事务、权限）从业务逻辑中分离出来。

| 术语 | 解释 | 本项目对应 |
|------|------|-----------|
| 切面(Aspect) | 横切逻辑的模块化 | OperationLogAspect |
| 连接点(JoinPoint) | 可以被拦截的点 | Controller 的方法 |
| 切入点(Pointcut) | 拦截规则 | @annotation(com.changge.anno.Log) |
| 通知(Advice) | 拦截后执行的逻辑 | @Around 环绕通知 |
| 目标方法 | 被拦截的方法 | 标注了 @Log 的方法 |

## @Log 自定义注解

```java
@Target(METHOD)        // 只能加在方法上
@Retention(RUNTIME)    // 运行时保留，反射可读取
public @interface Log {
    // 标记注解，无属性
    // 作用：标记需要被 OperationLogAspect 拦截的方法
}
```

## OperationLogAspect 切面

```java
@Aspect         // 声明为切面
@Component      // 交给 Spring 管理
public class OperationLogAspect {
    @Autowired
    private OperateLogMapper operateLogMapper;

    // 环绕通知：拦截所有标注 @Log 的方法
    @Around("@annotation(com.changge.anno.Log)")
    public Object recordLog(ProceedingJoinPoint joinPoint) throws Throwable {
        // 第1步：记录开始时间
        long begin = System.currentTimeMillis();

        // 第2步：获取当前操作人 ID（从 ThreadLocal）
        Integer operateEmpId = CurrentHolder.getCurrentId();

        // 第3步：获取目标方法信息
        String className = joinPoint.getTarget().getClass().getName();
        String methodName = joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs();
        String methodParams = Arrays.toString(args);

        // 第4步：执行目标方法
        Object result = joinPoint.proceed();

        // 第5步：计算耗时
        long end = System.currentTimeMillis();
        long costTime = end - begin;

        // 第6步：组装日志并插入
        OperateLog log = new OperateLog();
        log.setOperateEmpId(operateEmpId);
        log.setOperateTime(LocalDateTime.now());
        log.setClassName(className);
        log.setMethodName(methodName);
        log.setMethodParams(methodParams);
        log.setReturnValue(ObjectMapper.writeValueAsString(result));
        log.setCostTime(costTime);
        operateLogMapper.insert(log);

        // 第7步：返回原始返回值
        return result;
    }
}
```

## OperateLogMapper

```java
@Insert("insert into operate_log (operate_emp_id, operate_time, class_name, " +
        "method_name, method_params, return_value, cost_time) " +
        "values (#{operateEmpId}, #{operateTime}, #{className}, " +
        "#{methodName}, #{methodParams}, #{returnValue}, #{costTime})")
void insert(OperateLog log);
```

## 使用方式 — 在 Controller 方法上加 @Log

```java
@Log
@PostMapping
public Result add(@RequestBody Dept dept) {
    deptService.add(dept);
    return Result.success();
}
// → AOP 自动记录: DeptController.add, 参数[Dept(...)], 返回Result(...), 耗时35ms
```

## 执行流程

```
第1步 → 浏览器 POST /depts {"name":"研发部"}
第2步 → TokenFilter 存入用户 ID=1 到 ThreadLocal
第3步 → Spring AOP 检测到 add() 有 @Log 注解
第4步 → OperationLogAspect 环绕通知开始
第5步 → 记录开始时间
第6步 → CurrentHolder.getCurrentId() → 1
第7步 → 获取: className=DeptController, methodName=add, args=[Dept(name=研发部)]
第8步 → proceed() 执行 add() 方法（真正的业务逻辑）
第9步 → 获取返回值: Result(code=1)
第10步 → 计算耗时: 35ms
第11步 → 插入 operate_log 表
第12步 → 返回原始返回值给调用者
```
', 'AOP核心概念、@Log自定义注解、@Around环绕通知、ProceedingJoinPoint、自动记录操作日志', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 12: 事务传播行为
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '事务传播行为 — REQUIRES_NEW 独立日志事务', '## 场景

新增员工时，无论成功还是失败，都要记录一条操作日志。如果用默认传播行为 REQUIRED，主事务回滚时日志也回滚，丢失操作记录。用 REQUIRES_NEW 让日志在独立事务中提交。

## 代码结构

### 主事务 — EmpServiceImpl.save()

```java
@Transactional(rollbackFor = Exception.class)  // 主事务
@Override
public void save(Emp emp) {
    try {
        emp.setCreateTime(LocalDateTime.now());
        emp.setUpdateTime(LocalDateTime.now());
        empMapper.insert(emp);              // 操作1: 插入员工

        List<EmpExpr> exprList = emp.getExprList();
        if (!CollectionUtils.isEmpty(exprList)) {
            exprList.forEach(expr -> expr.setEmpid(emp.getId()));
            empExprMapper.insertBatch(exprList);  // 操作2: 插入工作经历
        }
        // 操作1或2失败 → 主事务回滚
    } finally {
        // 操作3: 记录日志（无论成败）
        EmpLog empLog = new EmpLog(null, LocalDateTime.now(), "添加员工");
        empLogService.insertLog(empLog);  // 独立事务
    }
}
```

### 子事务 — EmpLogServiceImpl.insertLog()

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)  // 总是新开独立事务
@Override
public void insertLog(EmpLog empLog) {
    empLogMapper.insert(empLog);
}
```

## 传播行为图解

```
┌─────────────────────────────────────────────────────┐
│  主事务 (save, @Transactional)                       │
│                                                     │
│  操作1: empMapper.insert(emp)                       │
│  操作2: empExprMapper.insertBatch()                 │
│                                                     │
│  finally {                                          │
│    ┌─────────────────────────────────────────────┐  │
│    │  子事务 (insertLog, REQUIRES_NEW)            │  │
│    │  操作3: empLogMapper.insert(log)            │  │
│    │  ★ 独立事务，不受主事务影响                    │  │
│    │  ★ 主事务回滚 → 子事务不回滚                   │  │
│    │  ★ 子事务回滚 → 主事务不受影响                 │  │
│    └─────────────────────────────────────────────┘  │
│  }                                                  │
│                                                     │
│  主事务提交/回滚                                     │
└─────────────────────────────────────────────────────┘
```

## 七种传播行为

| 传播行为 | 说明 | 使用场景 |
|---------|------|---------|
| **REQUIRED** (默认) | 有事务就加入，没有就新建 | 大多数业务方法 |
| **REQUIRES_NEW** | 总是新建独立事务，挂起当前事务 | 日志记录（不受主事务影响） |
| SUPPORTS | 有事务就加入，没有就非事务运行 | 查询方法 |
| NOT_SUPPORTED | 非事务运行，有事务就挂起 | 不需要事务的方法 |
| NEVER | 非事务运行，有事务就抛异常 | 不允许在事务中运行 |
| MANDATORY | 必须在事务中运行，没有就抛异常 | 必须被事务方法调用 |
| NESTED | 嵌套事务，可以部分回滚 | 部分失败不影响整体 |

## 为什么用 REQUIRES_NEW 而不是 REQUIRED？

```
场景：工作经历插入失败

用 REQUIRED（默认）：
  主事务回滚 → 日志也在同一事务中 → 日志也回滚 → 丢失操作记录 ❌

用 REQUIRES_NEW：
  子事务独立提交 → 主事务回滚 → 日志已提交，不受影响 → 保留了操作记录 ✅
```
', 'REQUIRES_NEW独立事务、主子事务关系、七种传播行为对比、日志独立提交场景', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 13: 文件上传 — MultipartFile + OSS
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '文件上传 — MultipartFile + 阿里云 OSS', '## 接口定义

`POST /upload` — 上传文件，返回 OSS 访问 URL

请求格式：`Content-Type: multipart/form-data`，字段名 `file`

## Controller 层

```java
@Slf4j
@RestController
public class UploadController {
    @Autowired
    private AliyunOSSOperator aliyunOSSOperator;

    @PostMapping("/upload")
    public Result upload(MultipartFile file) throws Exception {
        // MultipartFile 是 Spring 提供的文件上传接口
        // Spring MVC 自动将 multipart/form-data 中的文件部分绑定到 file 参数

        log.info("文件上传开始：{}", file.getOriginalFilename());

        // 获取文件字节数组，调用 OSS 工具类上传
        String url = aliyunOSSOperator.upload(
            file.getBytes(),
            file.getOriginalFilename()
        );

        log.info("文件上传OSS, url: {}", url);
        return Result.success(url);  // 返回文件访问 URL
    }
}
```

## OSS 配置类

```java
@ConfigurationProperties(prefix = "aliyun.oss")
@Component
public class AliyunOSSProperties {
    private String endpoint;      // https://oss-cn-beijing.aliyuncs.com
    private String bucketName;    // changge-web-tlias
    private String region;        // cn-beijing
    // getter/setter 省略
}
```

### application.yml 配置

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
    // 1. 生成唯一文件名（避免重名覆盖）
    // 格式: yyyy/MM/dd/uuid-原文件名
    String fileName = LocalDate.now() + "/" + UUID.randomUUID() + "-" + originalFilename;

    // 2. 调用阿里云 OSS SDK 上传
    OSS ossClient = new OSSClientBuilder().build(endpoint, accessKeyId, accessKeySecret);
    ossClient.putObject(bucketName, fileName, new ByteArrayInputStream(content));

    // 3. 拼接公网访问 URL
    String url = "https://" + bucketName + "." + endpoint + "/" + fileName;

    // 4. 关闭客户端
    ossClient.shutdown();
    return url;
}
```

## 执行流程

```
第1步 → 浏览器 POST /upload, Content-Type: multipart/form-data
        请求体包含文件二进制数据
第2步 → TokenFilter 校验 JWT
第3步 → Spring MVC 将文件绑定到 MultipartFile file
第4步 → file.getOriginalFilename() → "avatar.jpg"
第5步 → file.getBytes() → 文件字节数组
第6步 → aliyunOSSOperator.upload(bytes, "avatar.jpg")
        — 生成唯一文件名: 2026/08/17/uuid-avatar.jpg
        — OSS SDK 上传到 Bucket
        — 返回 URL: https://changge-web-tlias.oss-cn-beijing.aliyuncs.com/2026/08/17/uuid-avatar.jpg
第7步 → 返回 Result.success(url)
第8步 → JSON: {"code":1, "data":"https://changge-web-tlias.oss-cn-beijing.aliyuncs.com/..."}
第9步 → 前端拿到 URL，用于后续操作（如设置员工头像）
```

## 关键点

1. **MultipartFile**：Spring 内置接口，自动处理 multipart 请求中的文件
2. **唯一文件名**：用 UUID 防止重名覆盖，按日期分目录方便管理
3. **OSS 配置外部化**：通过 `@ConfigurationProperties` 从 yml 读取，不硬编码
4. **凭证安全**：AccessKey 从环境变量读取，不写在代码中
', 'MultipartFile文件接收、阿里云OSS上传、@ConfigurationProperties配置外部化、UUID防重名', 1, 0, 13, NOW(), NOW(), 0, 0);
