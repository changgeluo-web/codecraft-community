import java.util.Scanner;

public class ExamPass {
    public static void main(String[] args) {
        // 成绩 >= 60 通过，否则不通过
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入考试成绩：");
        double score = sc.nextDouble();

        if (score >= 60) {
            System.out.println("恭喜，考试通过！");
        } else {
            System.out.println("很遗憾，考试未通过。");
        }
    }
}