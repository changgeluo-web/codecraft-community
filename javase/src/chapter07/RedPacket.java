import java.util.Random;
import java.util.Scanner;

public class RedPacket {
    public static void main(String[] args) {
        // 红包问题：M元N个红包，每人最少1分，并为后面的人预留1分
        Scanner sc = new Scanner(System.in);
        int totalFen;
        while (true) {
            System.out.println("请输入红包总金额（元）：");
            totalFen = sc.nextInt() * 100;
            if (totalFen > 0) {
                break;
            }
            System.out.println("金额必须大于0，请重新输入");
        }

        int count;
        while (true) {
            System.out.println("请输入红包个数：");
            count = sc.nextInt();
            if (count > 0 && totalFen >= count) {
                break;
            }
            System.out.println("红包个数不合法（每人最少1分钱），请重新输入");
        }

        Random r = new Random();
        int remain = totalFen;

        for (int i = 1; i <= count; i++) {
            int money;
            if (i == count) {
                // 最后一个人拿剩余全部
                money = remain;
            } else {
                // 每人最少1分，且给后面每人预留1分
                int max = remain - (count - i);
                money = r.nextInt(max) + 1;
            }
            remain = remain - money;
            System.out.println("第" + i + "个人抢到红包：" + (money / 100.0) + "元");
        }
    }
}