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