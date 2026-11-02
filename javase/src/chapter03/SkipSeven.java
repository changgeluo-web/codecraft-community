public class SkipSeven {
    public static void main(String[] args) {
        // 逢七过：打印1~100，数字包含7或是7的倍数时输出"过"
        for (int i = 1; i <= 100; i++) {
            if (i % 7 == 0 || i / 10 == 7 || i % 10 == 7) {
                System.out.println("过");
                continue;
            }
            System.out.println(i);
        }
    }
}