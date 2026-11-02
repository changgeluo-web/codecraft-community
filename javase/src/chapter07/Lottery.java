import java.util.Random;

public class Lottery {
    public static void main(String[] args) {
        // 大乐透：前区01-35选5个不重复，后区01-12选2个不重复，跨区可重复
        int[] myFront = generateNumbers(5, 35);
        int[] myBack = generateNumbers(2, 12);
        System.out.print("我的投注  前区：");
        printNumbers(myFront);
        System.out.print("          后区：");
        printNumbers(myBack);

        int[] winFront = generateNumbers(5, 35);
        int[] winBack = generateNumbers(2, 12);
        System.out.print("开奖号码  前区：");
        printNumbers(winFront);
        System.out.print("          后区：");
        printNumbers(winBack);

        int frontHit = countHit(myFront, winFront);
        int backHit = countHit(myBack, winBack);
        System.out.println("命中：前区" + frontHit + "个，后区" + backHit + "个");
        System.out.println("中奖结果：" + checkPrize(frontHit, backHit));
    }

    // 从1~max中随机抽取count个不重复号码
    public static int[] generateNumbers(int count, int max) {
        Random r = new Random();
        int[] numbers = new int[count];
        int size = 0;
        while (size < count) {
            int number = r.nextInt(max) + 1;
            boolean exists = false;
            for (int i = 0; i < size; i++) {
                if (numbers[i] == number) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                numbers[size] = number;
                size++;
            }
        }
        return numbers;
    }

    // 统计两组号码命中的个数
    public static int countHit(int[] mine, int[] win) {
        int hit = 0;
        for (int i = 0; i < mine.length; i++) {
            for (int j = 0; j < win.length; j++) {
                if (mine[i] == win[j]) {
                    hit++;
                    break;
                }
            }
        }
        return hit;
    }

    // 根据中奖规则判断奖级
    public static String checkPrize(int front, int back) {
        if (front == 5 && back == 2) {
            return "一等奖";
        } else if (front == 5 && back == 1) {
            return "二等奖";
        } else if ((front == 5 && back == 0) || (front == 4 && back == 2)) {
            return "三等奖";
        } else if ((front == 4 && back == 1) || (front == 3 && back == 2)) {
            return "四等奖";
        } else if ((front == 4 && back == 0) || (front == 3 && back == 1) || (front == 2 && back == 2)) {
            return "五等奖";
        } else if ((front == 3 && back == 0) || (front == 1 && back == 2)
                || (front == 2 && back == 1) || (front == 0 && back == 2)) {
            return "六等奖";
        } else {
            return "未中奖";
        }
    }

    // 打印号码，不足两位补0
    public static void printNumbers(int[] numbers) {
        for (int i = 0; i < numbers.length; i++) {
            if (numbers[i] < 10) {
                System.out.print("0" + numbers[i] + " ");
            } else {
                System.out.print(numbers[i] + " ");
            }
        }
        System.out.println();
    }
}