public class CompareOverload {
    public static void main(String[] args) {
        // 方法重载：比较两个整数是否相同，兼容byte/short/int/long
        byte a = 10;
        byte b = 10;
        System.out.println("byte比较：" + compare(a, b));

        short c = 20;
        short d = 30;
        System.out.println("short比较：" + compare(c, d));

        System.out.println("int比较：" + compare(100, 100));
        System.out.println("long比较：" + compare(999L, 888L));
    }

    public static boolean compare(byte a, byte b) {
        return a == b;
    }

    public static boolean compare(short a, short b) {
        return a == b;
    }

    public static boolean compare(int a, int b) {
        return a == b;
    }

    public static boolean compare(long a, long b) {
        return a == b;
    }
}