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