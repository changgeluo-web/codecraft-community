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