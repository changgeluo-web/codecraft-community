public class TwoSum {
    public static void main(String[] args) {
        // 两数之和：找出和为target的两个数，输出索引
        int[] nums = {2, 7, 11, 15, 7, 2};
        int target = 9;

        // 要求1：只输出第一对满足要求的
        boolean found = false;
        for (int i = 0; i < nums.length - 1 && !found; i++) {
            for (int j = i + 1; j < nums.length; j++) {
                if (nums[i] + nums[j] == target) {
                    System.out.println("第一对：" + i + "," + j);
                    found = true;
                    break;
                }
            }
        }

        // 要求2：输出所有满足要求的
        System.out.println("所有满足要求的索引对：");
        for (int i = 0; i < nums.length - 1; i++) {
            for (int j = i + 1; j < nums.length; j++) {
                if (nums[i] + nums[j] == target) {
                    System.out.println(i + "," + j);
                }
            }
        }
    }
}