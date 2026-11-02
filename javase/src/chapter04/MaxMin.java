public class MaxMin {
    public static void main(String[] args) {
        // 求最值：找出数组中的最大值和最小值
        int[] arr = {33, 5, 22, 44, 55};

        int max = arr[0];
        int min = arr[0];
        for (int i = 1; i < arr.length; i++) {
            if (arr[i] > max) {
                max = arr[i];
            }
            if (arr[i] < min) {
                min = arr[i];
            }
        }

        System.out.println("最大值：" + max);
        System.out.println("最小值：" + min);
    }
}