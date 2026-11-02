import java.util.Scanner;

public class FindData {
    public static void main(String[] args) {
        // 查找数据：存在则打印第一次出现的索引，不存在则提示
        int[] arr = {33, 5, 22, 44, 55, 33};
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入要查找的数据：");
        int number = sc.nextInt();

        int index = -1;
        for (int i = 0; i < arr.length; i++) {
            if (arr[i] == number) {
                index = i;
                break;
            }
        }

        if (index == -1) {
            System.out.println("该数据不存在");
        } else {
            System.out.println("该数据的索引为：" + index);
        }
    }
}