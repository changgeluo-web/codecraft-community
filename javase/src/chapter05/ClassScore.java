import java.util.Scanner;

public class ClassScore {
    public static void main(String[] args) {
        // 统计10名学生成绩：及格率、平均分、最高分
        Scanner sc = new Scanner(System.in);
        int[] scores = new int[10];

        for (int i = 0; i < scores.length; i++) {
            while (true) {
                System.out.println("请输入第" + (i + 1) + "名学生的成绩（0-100）：");
                int score = sc.nextInt();
                if (score >= 0 && score <= 100) {
                    scores[i] = score;
                    break;
                }
                System.out.println("成绩无效，请重新输入");
            }
        }

        int passCount = getPassCount(scores);
        double passRate = passCount * 1.0 / scores.length;
        double avgScore = getSum(scores) * 1.0 / scores.length;
        int max = getMax(scores);

        System.out.println("及格人数：" + passCount);
        System.out.println("及格率：" + (passRate * 100) + "%");
        System.out.println("平均分：" + avgScore);
        System.out.println("最高分：" + max);
    }

    public static int getPassCount(int[] arr) {
        int count = 0;
        for (int i = 0; i < arr.length; i++) {
            if (arr[i] >= 60) {
                count++;
            }
        }
        return count;
    }

    public static int getSum(int[] arr) {
        int sum = 0;
        for (int i = 0; i < arr.length; i++) {
            sum = sum + arr[i];
        }
        return sum;
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
}