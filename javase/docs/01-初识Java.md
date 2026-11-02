# 第1章：初识Java

## 知识点

### 1. Java 程序的运行步骤
1. 编写 `.java` 源文件
2. 编译：`javac HelloWorld.java` → 生成 `.class` 字节码文件
3. 运行：`java HelloWorld`，由 JVM 执行字节码

### 2. HelloWorld 结构
```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```
- `public class HelloWorld`：定义类，类名必须与文件名完全一致
- `main` 方法：程序入口，固定写法
- `System.out.println`：输出并换行；`print` 不换行

### 3. 注释
| 类型 | 格式 |
|------|------|
| 单行注释 | `// 内容` |
| 多行注释 | `/* 内容 */`（不能嵌套） |
| 文档注释 | `/** 内容 */`（可被 javadoc 提取） |

### 4. 关键字
被 Java 赋予特殊含义的单词（如 `public`、`class`、`static`、`int`），全部小写，不能用作用户自定义标识符。

## 练习

| 文件 | 说明 |
|------|------|
| `src/chapter01/HelloWorld.java` | 第一个 Java 程序 |

## 参考答案

> 以下为本章各题的参考实现，源文件位于 `src/chapter01/` 目录，每个文件可独立编译运行。

### 1. 第一个 Java 程序

源文件：`HelloWorld.java`

```java
public class HelloWorld {
    public static void main(String[] args) {
        // 单行注释：输出内容到控制台
        System.out.println("Hello, World!");
        /* 多行注释：
           这是第一个Java程序 */
        System.out.println("你好，Java！");
    }
}
```

