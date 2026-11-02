import java.util.Scanner;

public class BmiInput {
    public static void main(String[] args) {
        // 键盘录入身高体重，计算BMI
        Scanner sc = new Scanner(System.in);

        System.out.println("请输入体重（kg）：");
        double weight = sc.nextDouble();

        System.out.println("请输入身高（m）：");
        double height = sc.nextDouble();

        double bmi = weight / (height * height);
        System.out.println("您的BMI = " + bmi);
    }
}