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