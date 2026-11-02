public class RemoveDuplicatesSorted {
    public static void main(String[] args) {
        // 递增有序数组去除重复元素
        int[] arr = {1, 1, 2, 2, 3, 4, 4, 5, 6, 6, 6, 7};

        // 新数组最多和原数组一样长
        int[] result = new int[arr.length];
        int size = 0;

        for (int i = 0; i < arr.length; i++) {
            // 只保留每个重复段第一个（前一个和它不同）
            if (i == 0 || arr[i] != arr[i - 1]) {
                result[size] = arr[i];
                size++;
            }
        }

        for (int i = 0; i < size; i++) {
            System.out.print(result[i] + " ");
        }
        System.out.println();
    }
}