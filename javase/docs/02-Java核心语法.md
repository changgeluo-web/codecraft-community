# 第2章：Java核心语法

## 知识点

### 1. 字面量
数据在程序中的书写格式：整数（666）、小数（13.14）、字符（'A'，单引号且仅一个字符）、字符串（"abc"，双引号）、布尔（true/false）、空值（null）。

### 2. 变量
- 格式：`数据类型 变量名 = 数据值;`
- 注意事项：变量名不能重复；使用前必须先赋值；一条语句可定义多个变量（不推荐）
- 常用类型：整数 `int`、小数 `double`

### 3. 数据类型
- 基本数据类型四类八种：
  - 整数：`byte`(1字节) `short`(2) `int`(4，默认) `long`(8，字面量加 L)
  - 小数：`float`(4，字面量加 F) `double`(8，默认)
  - 字符：`char`(2，存一个字符)
  - 布尔：`boolean`(true/false)
- 引用类型：字符串、数组等

### 4. 标识符
- 硬性要求：只能由字母、数字、`_`、`$` 组成；不能以数字开头；不能是关键字；区分大小写
- 建议：类名大驼峰、变量/方法名小驼峰、见名知意

### 5. 键盘录入
```java
Scanner sc = new Scanner(System.in);   // 需要 import java.util.Scanner;
int i = sc.nextInt();
double d = sc.nextDouble();
```

### 6. 算术运算符
- `+ - * /`：整数相除结果仍是整数（取商）；小数运算可能不精确
- `%`：取余，常用于判断奇偶、整除
- 数值拆分公式：个位 `n % 10`；十位 `n / 10 % 10`；百位 `n / 100 % 10`（以此类推）

### 7. 类型转换
- 隐式转换（自动提升）：小范围赋给大范围；取值范围 `byte/short/char → int → long → float → double`；byte/short/char 参与运算先提升为 int
- 强制转换：`(目标类型) 数据`，大范围转小范围，可能丢失精度或溢出

### 8. 字符串/字符的 + 操作
- 字符串 + 任何类型 → 拼接成新字符串
- 字符参与算术运算会转成对应数值（如 '1' → 49）

### 9. 自增自减、赋值、扩展赋值
- `++`/`--`：单独使用前后无区别；参与运算时前置先自增后取值，后置先取值后自增
- `= += -= *= /= %=`：`a += b` 隐含强制转换，等价于 `a = (a的类型)(a + b)`

### 10. 关系/逻辑运算符
- 关系：`== != > < >= <=`，结果是 boolean
- 逻辑：`& | ^ !`；短路版本 `&& ||`（左边能确定结果时右边不再执行，推荐）

### 11. 三元运算符
`关系表达式 ? 表达式1 : 表达式2`，结果必须被使用（赋值或输出）。

### 12. 优先级
不需要死记，记住：**小括号优先于一切**。

## 练习

| 文件 | 题目 |
|------|------|
| `RedPacketBalance.java` | 红包余额（变量定义与运算） |
| `GameCharacter.java` | 游戏人物属性（变量） |
| `BmiCalculator.java` | 计算BMI（数据类型） |
| `InputSum.java` | 键盘录入两数求和 |
| `BmiInput.java` | 键盘录入身高体重算BMI |
| `NumberSplit.java` | 三位数拆分个十百位 |
| `TimeConvert.java` | 秒数转时分秒 |
| `CompareHeight.java` | 比较身高（关系运算符） |
| `DivisibleBy3.java` | 判断能否被3整除 |
| `RangeCheck.java` | 判断是否在1~10之间 |
| `OutOfRangeCheck.java` | 判断是否不在1~10之间 |
| `PalindromeNumber.java` | 判断四位回文数 |
| `LuckySeven.java` | 7的有缘数 |

## 参考答案

> 以下为本章各题的参考实现，源文件位于 `src/chapter02/` 目录，每个文件可独立编译运行。

### 1. 红包余额（变量定义与运算）

源文件：`RedPacketBalance.java`

```java
public class RedPacketBalance {
    public static void main(String[] args) {
        // 微信余额100元，支付宝余额10元，银行卡余额20元
        double wechat = 100;
        double alipay = 10;
        double bank = 20;

        // 问题一：一共有多少钱
        System.out.println("总余额：" + (wechat + alipay + bank) + "元");

        // 问题二：微信收了10元红包，又发了2元红包
        wechat = wechat + 10;
        wechat = wechat - 2;
        System.out.println("微信最终余额：" + wechat + "元");
    }
}
```

### 2. 游戏人物属性（变量）

源文件：`GameCharacter.java`

```java
public class GameCharacter {
    public static void main(String[] args) {
        // 定义游戏人物的各项属性
        String name = "亚瑟";
        char gender = '男';
        int age = 30;
        double height = 185.5;
        boolean isAlive = true;

        System.out.println("姓名：" + name);
        System.out.println("性别：" + gender);
        System.out.println("年龄：" + age);
        System.out.println("身高：" + height + "cm");
        System.out.println("是否存活：" + isAlive);
    }
}
```

### 3. 计算BMI（数据类型）

源文件：`BmiCalculator.java`

```java
public class BmiCalculator {
    public static void main(String[] args) {
        // BMI = 体重(kg) / 身高(m)的平方
        double weight = 69.3;
        double height = 1.75;

        double bmi = weight / (height * height);
        System.out.println("体重：" + weight + "kg，身高：" + height + "m");
        System.out.println("BMI = " + bmi);
    }
}
```

### 4. 键盘录入两数求和

源文件：`InputSum.java`

```java
import java.util.Scanner;

public class InputSum {
    public static void main(String[] args) {
        // 键盘录入两个整数，求和
        Scanner sc = new Scanner(System.in);

        System.out.println("请输入第一个整数：");
        int num1 = sc.nextInt();

        System.out.println("请输入第二个整数：");
        int num2 = sc.nextInt();

        int result = num1 + num2;
        System.out.println(num1 + " + " + num2 + " = " + result);
    }
}
```

### 5. 键盘录入身高体重算BMI

源文件：`BmiInput.java`

```java
import java.util.Scanner;

public class BmiInput {
    public static void main(String[] args) {
        // 键盘录入身高体重，计算BMI
        Scanner sc = new Scanner(System.in);

        System.out.println("请输入体重（kg）：");
        double weight = sc.nextDouble();

        System.out.println("请输入身高（m）：");
        double height = sc.nextDouble();

        double bmi = weight / (height * height);
        System.out.println("您的BMI = " + bmi);
    }
}
```

### 6. 三位数拆分个十百位

源文件：`NumberSplit.java`

```java
import java.util.Scanner;

public class NumberSplit {
    public static void main(String[] args) {
        // 键盘录入一个三位数，拆分为个位、十位、百位
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入一个三位数：");
        int number = sc.nextInt();

        // 公式：个位 = 数字 % 10；十位 = 数字 / 10 % 10；百位 = 数字 / 100 % 10
        int ones = number % 10;
        int tens = number / 10 % 10;
        int hundreds = number / 100 % 10;

        System.out.println("个位：" + ones);
        System.out.println("十位：" + tens);
        System.out.println("百位：" + hundreds);
    }
}
```

### 7. 秒数转时分秒

源文件：`TimeConvert.java`

```java
public class TimeConvert {
    public static void main(String[] args) {
        // 将总秒数转换为 时:分:秒
        int seconds = 7242;

        int hours = seconds / 3600;
        int minutes = seconds % 3600 / 60;
        int restSeconds = seconds % 3600 % 60;

        System.out.println(seconds + "秒 = " + hours + "小时" + minutes + "分" + restSeconds + "秒");
    }
}
```

### 8. 比较身高（关系运算符）

源文件：`CompareHeight.java`

```java
import java.util.Scanner;

public class CompareHeight {
    public static void main(String[] args) {
        // 键盘录入两人身高，比较谁更高
        Scanner sc = new Scanner(System.in);

        System.out.println("请输入第一个人的身高（cm）：");
        int height1 = sc.nextInt();

        System.out.println("请输入第二个人的身高（cm）：");
        int height2 = sc.nextInt();

        System.out.println("第一个人是否更高：" + (height1 > height2));
        System.out.println("两人身高是否相同：" + (height1 == height2));
    }
}
```

### 9. 判断能否被3整除

源文件：`DivisibleBy3.java`

```java
import java.util.Scanner;

public class DivisibleBy3 {
    public static void main(String[] args) {
        // 判断一个数能否被3整除
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入一个整数：");
        int number = sc.nextInt();

        boolean result = number % 3 == 0;
        System.out.println(number + " 能否被3整除：" + result);
    }
}
```

### 10. 判断是否在1~10之间

源文件：`RangeCheck.java`

```java
import java.util.Scanner;

public class RangeCheck {
    public static void main(String[] args) {
        // 判断数字是否在1~10之间
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入一个整数：");
        int number = sc.nextInt();

        boolean inRange = number >= 1 && number <= 10;
        System.out.println(number + " 是否在1~10之间：" + inRange);
    }
}
```

### 11. 判断是否不在1~10之间

源文件：`OutOfRangeCheck.java`

```java
import java.util.Scanner;

public class OutOfRangeCheck {
    public static void main(String[] args) {
        // 判断数字是否不在1~10之间
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入一个整数：");
        int number = sc.nextInt();

        boolean outOfRange = number < 1 || number > 10;
        System.out.println(number + " 是否不在1~10之间：" + outOfRange);
    }
}
```

### 12. 判断四位回文数

源文件：`PalindromeNumber.java`

```java
import java.util.Scanner;

public class PalindromeNumber {
    public static void main(String[] args) {
        // 键盘录入一个四位整数，判断是否为回文数
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入一个四位整数：");
        int number = sc.nextInt();

        // 拆分每一位
        int ones = number % 10;
        int tens = number / 10 % 10;
        int hundreds = number / 100 % 10;
        int thousands = number / 1000 % 10;

        // 回文：千位==个位 且 百位==十位
        boolean isPalindrome = thousands == ones && hundreds == tens;
        System.out.println(number + " 是否为回文数：" + isPalindrome);
    }
}
```

### 13. 7的有缘数

源文件：`LuckySeven.java`

```java
import java.util.Scanner;

public class LuckySeven {
    public static void main(String[] args) {
        // 7的有缘数：包含7 或 是7的倍数
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入一个两位整数：");
        int number = sc.nextInt();

        int ones = number % 10;
        int tens = number / 10;

        boolean isLucky = ones == 7 || tens == 7 || number % 7 == 0;
        System.out.println(number + " 是否为7的有缘数：" + isLucky);
    }
}
```

