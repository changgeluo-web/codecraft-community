public class ShapePrinter {
    public static void main(String[] args) {
        // 案例一：打印长方形（5行8列）
        for (int i = 1; i <= 5; i++) {
            for (int j = 1; j <= 8; j++) {
                System.out.print("* ");
            }
            System.out.println();
        }
        System.out.println("--------------------");

        // 案例二：打印正三角形（5行）
        for (int i = 1; i <= 5; i++) {
            for (int j = 1; j <= i; j++) {
                System.out.print("* ");
            }
            System.out.println();
        }
        System.out.println("--------------------");

        // 案例三：打印倒三角形（5行）
        for (int i = 5; i >= 1; i--) {
            for (int j = 1; j <= i; j++) {
                System.out.print("* ");
            }
            System.out.println();
        }
        System.out.println("--------------------");

        // 案例四：打印梯形（5行，上底4，每行多2个）
        for (int i = 1; i <= 5; i++) {
            for (int j = 1; j <= 4 + 2 * (i - 1); j++) {
                System.out.print("* ");
            }
            System.out.println();
        }
        System.out.println("--------------------");

        // 案例五：打印平行四边形（5行5列，逐行左移）
        for (int i = 1; i <= 5; i++) {
            for (int j = 1; j <= 5 - i; j++) {
                System.out.print("  ");
            }
            for (int j = 1; j <= 5; j++) {
                System.out.print("* ");
            }
            System.out.println();
        }
    }
}