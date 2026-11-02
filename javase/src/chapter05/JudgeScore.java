import java.util.Scanner;

public class JudgeScore {
    public static void main(String[] args) {
        // 评委打分：5个评委0-100分，去掉最高分和最低分，剩余求平均
        Scanner sc = new Scanner(System.in);
        int[] scores = new int[5];

        for (int i = 0; i < scores.length; i++) {
            while (true) {
                System.out.println("请输入第" + (i + 1) + "个评委的分数（0-100）：");
                int score = sc.nextInt();
                if (score >= 0 && score <= 100) {
                    scores[i] = score;
                    break;
                }
                System.out.println("分数超出范围，请重新录入");
            }
        }

        int max = getMax(scores);
        int min = getMin(scores);
        int sum = getSum(scores);

        double finalScore = (sum - max - min) * 1.0 / (scores.length - 2);

        System.out.println("最高分：" + max);
        System.out.println("最低分：" + min);
        System.out.println("总分：" + sum);
        System.out.println("选手最终得分：" + finalScore);
    }

    public static int getMax(int[] arr) {
        int max = arr[0];
        for (int i = 1; i < arr.length; i++) {
            if (arr[i] > max) {
                max = arr[i];
            }
        }
        return max;
    }

    public static int getMin(int[] arr) {
        int min = arr[0];
        for (int i = 1; i < arr.length; i++) {
            if (arr[i] < min) {
                min = arr[i];
            }
        }
        return min;
    }

    public static int getSum(int[] arr) {
        int sum = 0;
        for (int i = 0; i < arr.length; i++) {
            sum = sum + arr[i];
        }
        return sum;
    }
}