public class MultiplicationTable {
    public static void main(String[] args) {
        // 九九乘法表：\t制表符让上下对齐
        for (int i = 1; i <= 9; i++) {
            for (int j = 1; j <= i; j++) {
                System.out.print(j + "*" + i + "=" + (i * j) + "\t");
            }
            System.out.println();
        }
    }
}