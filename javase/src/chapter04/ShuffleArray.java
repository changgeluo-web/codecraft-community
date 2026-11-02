import java.util.Random;

public class ShuffleArray {
    public static void main(String[] args) {
        // 打乱数组：随机抽取一个索引与当前索引交换
        int[] arr = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
        Random r = new Random();

        for (int i = arr.length - 1; i > 0; i--) {
            int j = r.nextInt(i + 1);
            int temp = arr[i];
            arr[i] = arr[j];
            arr[j] = temp;
        }

        for (int i = 0; i < arr.length; i++) {
            System.out.print(arr[i] + " ");
        }
        System.out.println();
    }
}