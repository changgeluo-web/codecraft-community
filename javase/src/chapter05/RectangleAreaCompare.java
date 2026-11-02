public class RectangleAreaCompare {
    public static void main(String[] args) {
        // 给定两个长方形，判断哪个面积更大
        double area1 = getArea(3.5, 4.2);
        double area2 = getArea(5.0, 2.8);

        System.out.println("长方形1面积：" + area1);
        System.out.println("长方形2面积：" + area2);

        if (area1 > area2) {
            System.out.println("长方形1面积更大");
        } else if (area1 < area2) {
            System.out.println("长方形2面积更大");
        } else {
            System.out.println("两个长方形面积相等");
        }
    }

    public static double getArea(double length, double width) {
        return length * width;
    }
}