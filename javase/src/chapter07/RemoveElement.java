public class RemoveElement {
    public static void main(String[] args) {
        // 移除元素：快慢指针删除所有等于val的元素
        int[] nums = {0, 1, 2, 2, 3, 0, 4, 2};
        int val = 2;

        int slow = 0;
        for (int fast = 0; fast < nums.length; fast++) {
            if (nums[fast] != val) {
                nums[slow] = nums[fast];
                slow++;
            }
        }

        System.out.println("剩余 " + slow + " 个元素：");
        for (int i = 0; i < slow; i++) {
            System.out.print(nums[i] + " ");
        }
        System.out.println();
    }
}