public class ArrayDefine {
    public static void main(String[] args) {
        // 练习1：定义数组存储3位同学的年龄
        int[] ages = {18, 19, 20};
        for (int i = 0; i < ages.length; i++) {
            System.out.println("第" + (i + 1) + "位同学年龄：" + ages[i]);
        }

        // 练习2：定义数组存储5位同学的身高
        double[] heights = {1.75, 1.68, 1.80, 1.62, 1.71};
        for (int i = 0; i < heights.length; i++) {
            System.out.println("第" + (i + 1) + "位同学身高：" + heights[i]);
        }

        // 练习3：定义数组存储3位同学的名字
        String[] names = {"小明", "小红", "小刚"};
        for (int i = 0; i < names.length; i++) {
            System.out.println("第" + (i + 1) + "位同学名字：" + names[i]);
        }
    }
}