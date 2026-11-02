public class EverestFold {
    public static void main(String[] args) {
        // 珠穆朗玛峰：纸厚0.1毫米，折叠多少次能达到8848860毫米
        double thickness = 0.1;
        int count = 0;

        while (thickness < 8848860) {
            thickness = thickness * 2;
            count++;
        }

        System.out.println("需要折叠 " + count + " 次");
        System.out.println("折叠后厚度：" + thickness + " 毫米");
    }
}