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