public class FindElement {
    public static void main(String[] args) {
        // 查找元素：存在打印索引，不存在打印应插入的位置（二分查找）
        int[] nums = {1, 3, 5, 6};
        int target = 2;

        int left = 0;
        int right = nums.length - 1;
        while (left <= right) {
            int mid = (left + right) / 2;
            if (nums[mid] == target) {
                System.out.println("索引：" + mid);
                return;
            } else if (nums[mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        // 循环结束时left就是应插入的位置
        System.out.println("不存在，应插入的位置：" + left);
    }
}