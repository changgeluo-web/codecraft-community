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