import java.util.Scanner;

public class PrimeCheck {
    public static void main(String[] args) {
        // 找质数：键盘录入一个大于等于2的整数，判断是否为质数
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入一个大于等于2的整数：");
        int number = sc.nextInt();

        boolean isPrime = true;
        for (int i = 2; i < number; i++) {
            if (number % i == 0) {
                isPrime = false;
                break;
            }
        }

        if (isPrime) {
            System.out.println(number + " 是质数");
        } else {
            System.out.println(number + " 不是质数");
        }
    }
}