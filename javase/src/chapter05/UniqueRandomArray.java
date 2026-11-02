import java.util.Random;

public class UniqueRandomArray {
    public static void main(String[] args) {
        // 获取10个1-100之间不重复的随机数，用方法实现
        int[] arr = getUniqueRandomArray(10, 1, 100);
        printArray(arr);
    }

    public static int[] getUniqueRandomArray(int length, int min, int max) {
        Random r = new Random();
        int[] arr = new int[length];
        int count = 0;
        while (count < length) {
            int number = r.nextInt(max - min + 1) + min;
            if (!contains(arr, count, number)) {
                arr[count] = number;
                count++;
            }
        }
        return arr;
    }

    public static boolean contains(int[] arr, int size, int number) {
        for (int i = 0; i < size; i++) {
            if (arr[i] == number) {
                return true;
            }
        }
        return false;
    }

    public static void printArray(int[] arr) {
        for (int i = 0; i < arr.length; i++) {
            System.out.print(arr[i] + " ");
        }
        System.out.println();
    }
}