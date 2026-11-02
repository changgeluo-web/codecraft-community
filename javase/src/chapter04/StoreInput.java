import java.util.Scanner;

public class StoreInput {
    public static void main(String[] args) {
        // 键盘录入5个整数，存入数组并遍历
        Scanner sc = new Scanner(System.in);
        int[] arr = new int[5];

        for (int i = 0; i < arr.length; i++) {
            System.out.println("请输入第" + (i + 1) + "个整数：");
            arr[i] = sc.nextInt();
        }

        System.out.println("遍历数组：");
        for (int i = 0; i < arr.length; i++) {
            System.out.println(arr[i]);
        }
    }
}