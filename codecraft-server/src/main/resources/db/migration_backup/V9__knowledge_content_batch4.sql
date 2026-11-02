-- 批次4: 知识点 14-18 (报表统计、全局异常、ThreadLocal、动态SQL、统一响应)
USE jiangma;

-- 知识点 14: 报表统计
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '报表统计 — GROUP BY + CASE WHEN + IF 聚合查询', '## 接口清单

| 方法 | URL | 功能 |
|------|-----|------|
| GET | /report/empJobData | 统计各职位人数（饼图） |
| GET | /report/empGenderData | 统计男女人数（柱状图） |

## 1. 统计员工职位人数

### Controller

```java
@GetMapping("/empJobData")
public Result getEmpJobData() {
    log.info("统计员工职位人数");
    JobOption jobOption = reportService.getEmpJobData();
    return Result.success(jobOption);
}
```

### Service

```java
@Override
public JobOption getEmpJobData() {
    // 查询数据库: List<Map> [{pos:"学工部", num:2}, {pos:"教研部", num:3}]
    List<Map<String, Object>> list = empMapper.countEmpJobData();

    // Stream API 提取职位名称列表
    List<Object> jobList = list.stream()
        .map(dataMap -> dataMap.get("pos"))
        .toList();

    // Stream API 提取人数数据列表
    List<Object> dataList = list.stream()
        .map(dataMap -> dataMap.get("num"))
        .toList();

    return new JobOption(jobList, dataList);
}
```

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

**要点：** CASE WHEN 将数字编码转为中文名称，GROUP BY 按职位分组，COUNT(*) 统计每组人数。

## 2. 统计员工性别人数

### Mapper XML

```xml
<select id="countEmpGenderData" resultType="java.util.Map">
    select if(gender = 1, '男性员工', '女性员工') as name,
           count(*) as value
    from emp
    group by gender
</select>
```

**IF 函数 vs CASE WHEN：**
- `IF(condition, true_val, false_val)` — 只有两路分支
- `CASE WHEN ... THEN ... WHEN ... THEN ... ELSE ... END` — 多路分支

## 执行流程

```
第1步 → GET /report/empJobData
第2步 → empMapper.countEmpJobData()
        SQL: select (case when job=1 then '学工部' ... else '其他' end) pos,
              count(*) num from emp group by job order by num
第3步 → MySQL 返回: [{pos:"学工部", num:2}, {pos:"教研部", num:3}, ...]
第4步 → Stream API 提取:
        jobList = ["学工部", "教研部", "咨询部", "就业部", "人事部"]
        dataList = [2, 3, 1, 1, 0]
第5步 → 组装 JobOption(jobList, dataList)
第6步 → JSON: {"code":1, "data":{"jobList":[...], "dataList":[...]}}
第7步 → 前端用数据渲染饼图
```

## Stream API 要点

```java
list.stream()                           // 转为流
    .map(dataMap -> dataMap.get("pos")) // 每个 Map 取 "pos" 值
    .toList();                          // 收集为 List
```
', 'GROUP BY分组统计、CASE WHEN多路分支、IF两路分支、Stream API提取数据、饼图数据组装', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 15: 全局异常处理
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '全局异常处理 — @ControllerAdvice 统一捕获', '## 问题

没有全局异常处理时，Controller 抛出异常会直接返回 500 错误页面，用户体验差，且可能暴露内部信息。

## GlobalExceptionHandler

```java
@ControllerAdvice  // 全局控制器增强，捕获所有 Controller 抛出的异常
public class GlobalExceptionHandler {

    // 捕获所有异常
    @ExceptionHandler(Exception.class)
    @ResponseBody
    public Result handleException(Exception e) {
        log.error("系统异常：{}", e.getMessage(), e);
        return Result.error("出错啦");
    }

    // 捕获主键冲突异常
    @ExceptionHandler(DuplicateKeyException.class)
    @ResponseBody
    public Result handleDuplicateKey(DuplicateKeyException e) {
        return Result.error("数据已存在");
    }
}
```

## BusinessException — 自定义业务异常

```java
public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}
```

**为什么继承 RuntimeException？**
- 不需要在方法签名上声明 throws
- 不需要 try-catch
- 适合业务规则校验失败时抛出

## 使用场景 — 班级删除校验

```java
// ClazzServiceImpl
@Override
public void deleteById(Integer id) {
    Integer count = studentMapper.countByClazzId(id);
    if (count > 0) {
        throw new BusinessException("班级下有学员, 不能直接删除~");
        // 抛出后被 GlobalExceptionHandler 捕获
    }
    clazzMapper.deleteById(id);
}
```

## 异常处理流程

```
场景：删除有学员的班级

第1步 → ClazzServiceImpl.deleteById(1)
第2步 → 查询 count=5 > 0
第3步 → throw new BusinessException("班级下有学员, 不能直接删除~")
第4步 → 异常向上抛: Service → Controller
第5步 → @ControllerAdvice 捕获
第6步 → @ExceptionHandler(Exception.class) 匹配（BusinessException 是 Exception 子类）
第7步 → 返回 Result.error("出错啦")
第8步 → JSON: {"code":0, "msg":"出错啦"}
```

## 注解详解

| 注解 | 作用 |
|------|------|
| `@ControllerAdvice` | 声明全局异常处理器，扫描所有 Controller |
| `@ExceptionHandler(X.class)` | 声明处理哪种异常 |
| `@ResponseBody` | 返回 JSON 而非页面 |

## 设计要点

1. **异常分层**：系统异常返回通用提示，业务异常返回具体原因
2. **不暴露堆栈**：用户只看到友好消息，详细堆栈记录在日志中
3. **统一出口**：所有异常最终都通过 Result 对象返回，格式一致
', '@ControllerAdvice全局捕获、@ExceptionHandler分类处理、BusinessException业务异常、统一错误响应', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 16: ThreadLocal
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, 'ThreadLocal — 线程隔离的上下文传递', '## 问题

Tomcat 使用线程池处理请求，多个请求并发执行。需要在一次请求的任意层（Filter → Controller → Service → AOP）中获取当前登录用户 ID，但这些层之间不直接传参。

## 解决方案

使用 ThreadLocal 在 Filter 中存储用户 ID，后续任意层通过 CurrentHolder 获取。

## CurrentHolder 实现

```java
public class CurrentHolder {
    private static final ThreadLocal<Integer> CURRENT_ID = new ThreadLocal<>();

    public static void setCurrentId(Integer id) {
        CURRENT_ID.set(id);
    }

    public static Integer getCurrentId() {
        return CURRENT_ID.get();
    }

    public static void remove() {
        CURRENT_ID.remove();
    }
}
```

## 原理图

```
┌─────────────┐
│   线程 1     │ → ThreadLocal 存 id=1 → Controller → Service → AOP 取 id=1
├─────────────┤
│   线程 2     │ → ThreadLocal 存 id=2 → Controller → Service → AOP 取 id=2
├─────────────┤
│   线程 3     │ → ThreadLocal 存 id=3 → Controller → Service → AOP 取 id=3
└─────────────┘

每个线程有独立的 ThreadLocal 副本，互不干扰。
```

## 使用位置

| 位置 | 操作 | 代码 |
|------|------|------|
| TokenFilter | setCurrentId(id) | `CurrentHolder.setCurrentId(id)` |
| OperationLogAspect | getCurrentId() | `Integer id = CurrentHolder.getCurrentId()` |
| TokenFilter (finally) | remove() | `CurrentHolder.remove()` |

## TokenFilter 中的使用

```java
// 解析 JWT 成功后
Integer id = Integer.valueOf(claims.get("id").toString());
CurrentHolder.setCurrentId(id);  // 存入 ThreadLocal

chain.doFilter(req, resp);       // 放行，后续任意层可获取

// finally 块中
CurrentHolder.remove();          // 清除，防止内存泄漏
```

## OperationLogAspect 中的使用

```java
@Around("@annotation(com.changge.anno.Log)")
public Object recordLog(ProceedingJoinPoint joinPoint) throws Throwable {
    Integer operateEmpId = CurrentHolder.getCurrentId();  // 取出用户 ID
    // ... 记录操作日志，operateEmpId 就是当前登录用户
}
```

## 为什么必须 remove？

```
Tomcat 线程池：
  线程1 处理请求A（用户ID=1）→ 没清除 → 线程1 归还线程池
  线程1 复用处理请求B（用户ID=2）→ 但 ThreadLocal 还残留 id=1
  → AOP 记录日志时取到的是上一个请求的用户 ID → 数据错乱！

解决：每次请求结束（finally 块）必须 remove()，清除当前线程的副本。
```

## ThreadLocal 内存泄漏

```
线程池中线程长期存活 → ThreadLocal 引用的对象无法 GC
→ 如果存的是大对象且不 remove → 内存泄漏

最佳实践：
  1. 用完就 remove
  2. 不要存大对象
  3. 在 Filter/Interceptor 的 finally 中清除
```
', 'ThreadLocal线程隔离原理、CurrentHolder实现、Filter存AOP取、必须remove防止内存泄漏', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 17: MyBatis 动态 SQL
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, 'MyBatis 动态 SQL — if/where/set/foreach', '## 动态 SQL 标签一览

| 标签 | 作用 | 典型场景 |
|------|------|---------|
| `<if>` | 条件成立时拼接 SQL 片段 | 按需筛选 |
| `<where>` | 自动处理 AND 前缀 | 多条件查询 |
| `<set>` | 自动处理末尾逗号 | 动态更新 |
| `<foreach>` | 遍历集合生成 SQL | 批量操作 |

## 1. `<where>` + `<if>` — 条件查询

```xml
<select id="list" resultType="com.changge.pojo.Emp">
    select e.*, d.name as deptName
    from emp e left join dept d on e.dept_id = d.id
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

**`<where>` 的作用：**
- 条件全空 → 不生成 WHERE 子句
- 第一个条件前多出 AND → 自动去掉
- 相当于 `<trim prefix="WHERE" prefixOverrides="AND|OR">`

## 2. `<set>` + `<if>` — 动态更新

```xml
<update id="updateById">
    update emp
    <set>
        <if test="username != null and username != ''">username = #{username},</if>
        <if test="name != null and name != ''">name = #{name},</if>
        <if test="gender != null">gender = #{gender},</if>
        <if test="phone != null and phone != ''">phone = #{phone},</if>
        <if test="salary != null">salary = #{salary},</if>
        <if test="updateTime != null">update_time = #{updateTime}</if>
    </set>
    where id = #{id}
</update>
```

**`<set>` 的作用：**
- 自动去掉末尾多余的逗号
- 只更新非空字段，未传的字段保持不变
- 相当于 `<trim prefix="SET" suffixOverrides=",">`

## 3. `<foreach>` — 批量操作

### 批量删除

```xml
<delete id="deleteByIds">
    delete from emp where id in
    <foreach collection="ids" item="id" separator="," open="(" close=")">
        #{id}
    </foreach>
</delete>
```

生成 SQL: `delete from emp where id in (1, 2, 3)`

### 批量插入

```xml
<insert id="insertBatch">
    insert into emp_expr (emp_id, begin, end, company, job) values
    <foreach collection="empList" item="emp" separator=",">
        (#{emp.empid}, #{emp.begin}, #{emp.end}, #{emp.company}, #{emp.job})
    </foreach>
</insert>
```

生成 SQL: `insert into emp_expr (...) values (8, ...), (8, ...), (8, ...)`

## `<foreach>` 属性详解

| 属性 | 说明 |
|------|------|
| `collection` | 集合参数名（与方法参数名一致） |
| `item` | 循环变量名 |
| `separator` | 每次循环之间的分隔符 |
| `open` | 循环体外面的前缀 |
| `close` | 循环体外面的后缀 |

## `#{}` vs `${}`

| 写法 | 说明 | 安全性 |
|------|------|--------|
| `#{name}` | 预编译参数占位符（PreparedStatement） | ✅ 防 SQL 注入 |
| `${name}` | 字符串直接拼接 | ❌ 有 SQL 注入风险 |

**始终用 `#{}`，除非需要动态表名/列名（此时必须校验输入）。**

## 实际效果示例

```
请求: GET /emps?name=张&gender=1
生成 SQL:
  SELECT e.*, d.name as deptName
  FROM emp e LEFT JOIN dept d ON e.dept_id = d.id
  WHERE e.name LIKE concat('%','张','%') AND e.gender = '1'
  ORDER BY e.update_time desc

请求: GET /emps （无参数）
生成 SQL:
  SELECT e.*, d.name as deptName
  FROM emp e LEFT JOIN dept d ON e.dept_id = d.id
  ORDER BY e.update_time desc
  （<where> 条件全空，不加 WHERE）
```
', 'if条件拼接、where自动处理AND、set自动处理逗号、foreach批量操作、井号防注入', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 18: 统一响应格式
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '统一响应格式 — Result + PageResult', '## 设计目标

所有接口返回统一的 JSON 格式，前端只需按固定结构解析，不用为每个接口写特殊处理。

## Result 类

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Result {
    private Integer code;    // 1=成功, 0=失败
    private String msg;      // 错误信息（成功时为 null）
    private Object data;     // 业务数据（失败时为 null）

    // 快捷方法
    public static Result success() {
        return new Result(1, null, null);
    }

    public static Result success(Object data) {
        return new Result(1, null, data);
    }

    public static Result error(String msg) {
        return new Result(0, msg, null);
    }
}
```

## PageResult 类

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PageResult {
    private Long total;      // 总记录数
    private List rows;       // 当前页数据列表
}
```

## 响应格式示例

### 成功（无数据）

```json
{"code": 1, "msg": null, "data": null}
```

### 成功（有数据）

```json
{"code": 1, "msg": null, "data": {"id": 3, "name": "教研部"}}
```

### 成功（分页）

```json
{
    "code": 1,
    "msg": null,
    "data": {
        "total": 7,
        "rows": [
            {"id": 1, "name": "张无忌", "gender": 1},
            {"id": 2, "name": "赵敏", "gender": 2}
        ]
    }
}
```

### 失败

```json
{"code": 0, "msg": "用户名或密码错误", "data": null}
```

## Controller 使用方式

```java
// 查询 → 返回数据
@GetMapping("/{id}")
public Result getInfo(@PathVariable Integer id) {
    Dept dept = deptService.getInfo(id);
    return Result.success(dept);        // {code:1, data:{...}}
}

// 增删改 → 无数据
@PostMapping
public Result add(@RequestBody Dept dept) {
    deptService.add(dept);
    return Result.success();            // {code:1, data:null}
}

// 失败
return Result.error("用户名或密码错误"); // {code:0, msg:"..."}
```

## 前端解析

```javascript
axios.get('/depts/3').then(response => {
    if (response.data.code === 1) {
        // 成功，取 data
        console.log(response.data.data);  // {id:3, name:"教研部"}
    } else {
        // 失败，取 msg
        alert(response.data.msg);
    }
});
```

## 设计要点

1. **统一格式**：所有接口都是 `{code, msg, data}`，前端解析逻辑一致
2. **语义明确**：code=1 成功，code=0 失败，不用 HTTP 状态码（业务状态码和传输状态码分离）
3. **静态工厂方法**：`Result.success()` / `Result.error()` 让 Controller 代码更简洁
4. **PageResult 独立类**：分页查询额外需要 total（总条数），单独封装
', 'Result统一响应类、PageResult分页封装、code/msg/data三字段设计、前端解析逻辑', 1, 0, 13, NOW(), NOW(), 0, 0);
