import java.util.Scanner;

public class TriangleCheck {
    public static void main(String[] args) {
        // 任意两边之和大于第三边，才能构成三角形
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入三条边长：");
        double a = sc.nextDouble();
        double b = sc.nextDouble();
        double c = sc.nextDouble();

        if (a + b > c && a + c > b && b + c > a) {
            System.out.println("可以构成三角形");
        } else {
            System.out.println("不能构成三角形");
        }
    }
}