import java.util.Scanner;

public class DigitSum {
    public static void main(String[] args) {
        // 数位之和：给定整数n，计算所有数位之和，负数先取绝对值
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入一个整数：");
        int number = sc.nextInt();

        // 负数取绝对值
        if (number < 0) {
            number = -number;
        }

        int sum = 0;
        while (number != 0) {
            sum = sum + number % 10;
            number = number / 10;
        }

        System.out.println("数位之和：" + sum);
    }
}