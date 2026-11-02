import java.util.Scanner;

public class CompareHeight {
    public static void main(String[] args) {
        // 键盘录入两人身高，比较谁更高
        Scanner sc = new Scanner(System.in);

        System.out.println("请输入第一个人的身高（cm）：");
        int height1 = sc.nextInt();

        System.out.println("请输入第二个人的身高（cm）：");
        int height2 = sc.nextInt();

        System.out.println("第一个人是否更高：" + (height1 > height2));
        System.out.println("两人身高是否相同：" + (height1 == height2));
    }
}