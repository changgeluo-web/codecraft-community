import java.util.Random;
import java.util.Scanner;

public class GuessNumber {
    public static void main(String[] args) {
        // 猜数字：程序生成1-100随机数，循环猜直到猜中
        Random r = new Random();
        int answer = r.nextInt(100) + 1;
        Scanner sc = new Scanner(System.in);

        while (true) {
            System.out.println("请输入你猜的数字（1-100）：");
            int guess = sc.nextInt();

            if (guess > answer) {
                System.out.println("猜大了");
            } else if (guess < answer) {
                System.out.println("猜小了");
            } else {
                System.out.println("恭喜你，猜中了！");
                break;
            }
        }
    }
}