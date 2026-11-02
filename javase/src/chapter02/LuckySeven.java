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