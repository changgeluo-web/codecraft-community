import java.util.Random;

public class RemoveDuplicates {
    public static void main(String[] args) {
        // 获取10个1-100之间不重复的随机数
        Random r = new Random();
        int[] arr = new int[10];
        int count = 0;

        while (count < arr.length) {
            int number = r.nextInt(100) + 1;
            // 判断number是否已经在数组中
            boolean exists = false;
            for (int i = 0; i < count; i++) {
                if (arr[i] == number) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                arr[count] = number;
                count++;
            }
        }

        for (int i = 0; i < arr.length; i++) {
            System.out.print(arr[i] + " ");
        }
        System.out.println();
    }
}