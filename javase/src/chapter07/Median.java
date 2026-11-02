public class Median {
    public static void main(String[] args) {
        // 中位数：二路归并合并两个正序数组，求中位数
        int[] arr1 = {1, 3, 5, 7};
        int[] arr2 = {2, 4, 6, 8, 9};

        int[] merged = merge(arr1, arr2);

        System.out.print("合并后数组：");
        for (int i = 0; i < merged.length; i++) {
            System.out.print(merged[i] + " ");
        }
        System.out.println();

        double median;
        int mid = merged.length / 2;
        if (merged.length % 2 == 1) {
            median = merged[mid];
        } else {
            median = (merged[mid - 1] + merged[mid]) / 2.0;
        }
        System.out.println("中位数：" + median);
    }

    public static int[] merge(int[] arr1, int[] arr2) {
        int[] result = new int[arr1.length + arr2.length];
        int i = 0;
        int j = 0;
        int k = 0;
        while (i < arr1.length && j < arr2.length) {
            if (arr1[i] <= arr2[j]) {
                result[k] = arr1[i];
                i++;
            } else {
                result[k] = arr2[j];
                j++;
            }
            k++;
        }
        while (i < arr1.length) {
            result[k] = arr1[i];
            i++;
            k++;
        }
        while (j < arr2.length) {
            result[k] = arr2[j];
            j++;
            k++;
        }
        return result;
    }
}