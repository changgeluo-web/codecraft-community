public class MultiplicationTableMethod {
    public static void main(String[] args) {
        // 设计一个方法打印九九乘法表
        printMultiplicationTable();
    }

    public static void printMultiplicationTable() {
        for (int i = 1; i <= 9; i++) {
            for (int j = 1; j <= i; j++) {
                System.out.print(j + "*" + i + "=" + (i * j) + "\t");
            }
            System.out.println();
        }
    }
}