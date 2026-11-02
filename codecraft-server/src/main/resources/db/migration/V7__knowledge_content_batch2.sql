-- 批次2: 知识点 5-8 (员工管理核心)

-- 知识点 5: 员工分页查询
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '员工分页查询 — PageHelper + 动态条件', '## 接口定义

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
第4步 → empMapper.list() 执行动态 SQL：
        SELECT ... FROM emp e LEFT JOIN dept d ON e.dept_id = d.id
        WHERE e.name LIKE concat('%','张','%') AND e.gender = '1'
        ORDER BY e.update_time desc
        LIMIT 0, 10    ← PageHelper 自动拼接
第5步 → PageHelper 执行 COUNT 获取 total
第6步 → 组装 PageResult(total=7, rows=[...10条])
第7步 → 返回 JSON: {"code":1, "data":{"total":7, "rows":[...]}}
```
', 'PageHelper分页原理、动态SQL条件查询、EmpQueryParam参数对象、执行流程', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 6: 新增员工 — 事务+批量插入
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '新增员工 — 事务管理 + 批量插入工作经历', '## 接口定义

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
@Transactional(rollbackFor = Exception.class)  // 开启事务，任何异常都回滚
@Override
public void save(Emp emp) {
    try {
        // 第1步：设置时间
        emp.setCreateTime(LocalDateTime.now());
        emp.setUpdateTime(LocalDateTime.now());

        // 第2步：插入员工基本信息
        // @Options(useGeneratedKeys=true, keyProperty="id")
        // 插入后 MySQL 自增主键自动回填到 emp.id
        empMapper.insert(emp);

        // 第3步：处理工作经历列表
        List<EmpExpr> exprList = emp.getExprList();
        if (!CollectionUtils.isEmpty(exprList)) {
            // 遍历设置 empId（此时 emp.getId() 已是自增回填的 ID）
            exprList.forEach(expr -> expr.setEmpid(emp.getId()));
            // 批量插入
            empExprMapper.insertBatch(exprList);
        }
    } finally {
        // 第4步：无论成败都记录日志
        // EmpLogService 使用 REQUIRES_NEW 独立事务
        // 主事务回滚，日志仍保留
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

**关键：** `useGeneratedKeys=true` + `keyProperty="id"` 让插入后的自增 ID 回填到 emp 对象，后续设置工作经历的 empId 就靠这个。

## Mapper — 工作经历批量插入（XML）

```xml
<insert id="insertBatch">
    insert into emp_expr (emp_id, begin, end, company, job) values
    <foreach collection="empList" item="emp" separator=",">
        (#{emp.empid}, #{emp.begin}, #{emp.end}, #{emp.company}, #{emp.job})
    </foreach>
</insert>
```

**`<foreach>` 标签：** 遍历列表生成 SQL 片段，`separator=","` 用逗号分隔每段，最终生成：
```sql
insert into emp_expr (emp_id, begin, end, company, job)
values (8, '2020-01', '2022-06', '腾讯', '后端'), (8, ...)
```

## EmpLogService — 独立事务

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)  // 总是新开独立事务
@Override
public void insertLog(EmpLog empLog) {
    empLogMapper.insert(empLog);
}
```

## 执行流程

```
第1步 → POST /emps，请求体含员工信息 + exprList
第2步 → @RequestBody 反序列化为 Emp 对象
第3步 → 事务开启
第4步 → 设置 createTime/updateTime
第5步 → empMapper.insert(emp) 插入员工
        SQL: insert into emp (username, ...) values ('zhangsan', ...)
        MySQL 自增生成 id=8，回填到 emp.id
第6步 → 遍历 exprList，设置 empId=8
第7步 → empExprMapper.insertBatch(exprList) 批量插入工作经历
        SQL: insert into emp_expr (...) values (8, ...), (8, ...)
第8步 → finally: empLogService.insertLog() 独立事务记录日志
        SQL: insert into emp_log (operate_time, info) values (..., '添加员工')
        ★ REQUIRES_NEW：即使主事务回滚，日志也保留
第9步 → 事务提交
第10步 → 返回 Result.success()
```

## 为什么要 REQUIRES_NEW？

场景：工作经历插入失败（如数据格式错误），主事务回滚。但我们仍想记录"曾尝试添加员工"的日志。如果用默认 REQUIRED，日志跟着主事务一起回滚，丢失操作记录。用 REQUIRES_NEW，日志在独立事务中已提交，不受主事务影响。
', '事务管理、主键回填、foreach批量插入、REQUIRES_NEW独立事务、执行流程', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 7: resultMap 一对多关联
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, 'resultMap 一对多关联 — 员工 + 工作经历', '## 接口定义

`GET /emps/{id}` — 查询单个员工详细信息，包含工作经历列表

## Mapper 层 — EmpMapper.xml（核心）

```xml
<!-- resultMap：定义 emp 表和 emp_expr 表的联合映射 -->
<resultMap id="empResultMap" type="com.changge.pojo.Emp">
    <!-- 主表 emp 的字段映射 -->
    <id property="id" column="id"/>
    <result property="username" column="username"/>
    <result property="name" column="name"/>
    <result property="gender" column="gender"/>
    <result property="phone" column="phone"/>
    <result property="job" column="job"/>
    <result property="salary" column="salary"/>
    <result property="entryDate" column="entry_date"/>
    <result property="deptId" column="dept_id"/>
    <result property="createTime" column="create_time"/>
    <result property="updateTime" column="update_time"/>

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

<!-- 关联查询 -->
<select id="getById" resultMap="empResultMap">
    select
        e.*,
        ee.id as ee_id,
        ee.emp_id as ee_empid,
        ee.begin as ee_begin,
        ee.end as ee_end,
        ee.company as ee_company,
        ee.job as ee_job
    from emp e
        left join emp_expr ee on e.id = ee.emp_id
    where e.id = #{id}
</select>
```

## resultMap 标签详解

| 标签 | 作用 |
|------|------|
| `<resultMap>` | 定义结果映射规则，将查询结果列映射到 Java 对象属性 |
| `<id>` | 主键映射，MyBatis 用它判断是否是同一对象（去重） |
| `<result>` | 普通字段映射 |
| `<collection>` | 一对多关系映射，property 是 Java 集合属性名，ofType 是集合元素类型 |

## 为什么用别名 ee_id, ee_empid？

两个表都有 id 字段，如果不用别名，MyBatis 无法区分 emp.id 和 emp_expr.id。用 `ee_` 前缀避免列名冲突。

## MyBatis 合并行原理

```
SQL 返回多行（每行一条工作经历）:
  | id=5 | name=张无忌 | ee_id=1 | company=腾讯 |
  | id=5 | name=张无忌 | ee_id=2 | company=阿里 |

MyBatis 根据 <id property="id" column="id"/> 判断 id=5 是同一个员工
→ 合并为一 个 Emp 对象
→ 将每行的 ee_* 字段组装成 EmpExpr 对象，加入 exprList
→ 最终: Emp(id=5, name=张无忌, exprList=[EmpExpr(腾讯), EmpExpr(阿里)])
```

## Service 层

```java
@Override
public Emp getInfo(Integer id) {
    return empMapper.getById(id);  // 返回包含工作经历列表的员工对象
}
```

## Controller 层

```java
@GetMapping("/{id}")
public Result getInfo(@PathVariable Integer id) {
    log.info("根据ID查询员工信息:{}", id);
    Emp emp = empService.getInfo(id);
    return Result.success(emp);
}
```

## 执行流程

```
第1步 → GET /emps/5
第2步 → @PathVariable 提取 id=5
第3步 → empMapper.getById(5) 执行关联查询
        SQL: select e.*, ee.id as ee_id, ... from emp e
              left join emp_expr ee on e.id = ee.emp_id where e.id = 5
第4步 → MySQL 返回多行（每行一条工作经历）
第5步 → MyBatis 根据 resultMap 合并行：
        - emp 基本信息取第一行
        - 每行的 ee_* 组装成 EmpExpr 加入 exprList
第6步 → 返回 Emp 对象（含 exprList）
第7步 → JSON: {"code":1, "data":{"id":5, "name":"张无忌", "exprList":[...]}}
```
', 'resultMap定义、collection一对多映射、列名别名避免冲突、MyBatis合并行原理', 1, 0, 13, NOW(), NOW(), 0, 0);

-- 知识点 8: 删除员工 — 批量删除 + 事务
INSERT INTO `post` (`author_id`, `title`, `content`, `summary`, `status`, `view_count`, `category_id`, `created_at`, `updated_at`, `deleted`, `study_status`) VALUES
(1, '批量删除员工 — foreach + 事务保证一致性', '## 接口定义

`DELETE /emps?ids=1,2,3` — 批量删除员工，同时删除关联的工作经历

## Controller 层

```java
@DeleteMapping
public Result delete(@RequestParam List<Integer> ids) {
    // @RequestParam 将 ids=1,2,3 绑定为 List<Integer>
    log.info("删除员工信息：{}", ids);
    empService.delete(ids);
    return Result.success();
}
```

**要点：** `@RequestParam List<Integer> ids` 自动将逗号分隔的参数转为 List。

## Service 层 — 事务保证

```java
@Transactional(rollbackFor = Exception.class)  // 事务保证两步同时成功或同时失败
@Override
public void delete(List<Integer> ids) {
    empMapper.deleteByIds(ids);        // 第1步：删除员工
    empExprMapper.deleteByEmpIds(ids); // 第2步：删除工作经历
    // 如果第2步失败，第1步也回滚
}
```

## Mapper — 批量删除员工（XML foreach）

```xml
<delete id="deleteByIds">
    delete from emp where id in
    <foreach collection="ids" item="id" separator="," open="(" close=")">
        #{id}
    </foreach>
</delete>
```

**生成 SQL：** `delete from emp where id in (1, 2, 3)`
- `open="("` `close=")"` 在循环体外加括号
- `separator=","` 用逗号分隔每个元素

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
第4步 → empMapper.deleteByIds([1,2,3])
        SQL: delete from emp where id in (1, 2, 3)
第5步 → empExprMapper.deleteByEmpIds([1,2,3])
        SQL: delete from emp_expr where emp_id in (1, 2, 3)
第6步 → 两步都成功 → 事务提交
        如果第5步失败 → 第4步也回滚（事务保证）
第7步 → 返回 Result.success()
```

## 事务的作用

没有事务：删了员工但工作经历没删 → 脏数据
有事务：两步在同一事务中，要么都成功要么都回滚 → 数据一致性
', 'foreach生成IN列表、@RequestParam绑定List、事务保证关联数据一致性', 1, 0, 13, NOW(), NOW(), 0, 0);
