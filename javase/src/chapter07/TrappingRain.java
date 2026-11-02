public class TrappingRain {
    public static void main(String[] args) {
        // 接雨水：左右扫描取交集（取min），减去柱子高度
        int[] height = {0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1};

        // 从左往右：记录每个位置左边（含自己）最高的柱子
        int[] left = new int[height.length];
        int max = 0;
        for (int i = 0; i < height.length; i++) {
            if (height[i] > max) {
                max = height[i];
            }
            left[i] = max;
        }

        // 从右往左：记录每个位置右边（含自己）最高的柱子
        int[] right = new int[height.length];
        max = 0;
        for (int i = height.length - 1; i >= 0; i--) {
            if (height[i] > max) {
                max = height[i];
            }
            right[i] = max;
        }

        // 每个位置的雨水 = min(左最高, 右最高) - 柱子高度
        int water = 0;
        for (int i = 0; i < height.length; i++) {
            int level = Math.min(left[i], right[i]);
            water = water + (level - height[i]);
        }

        System.out.println("能接的雨水：" + water + " 个单位");
    }
}