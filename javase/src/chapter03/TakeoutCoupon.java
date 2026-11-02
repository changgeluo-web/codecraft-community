import java.util.Scanner;

public class TakeoutCoupon {
    public static void main(String[] args) {
        // 饱了么：全场9折；美单：满30减10。比较哪家更划算
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入订单金额：");
        double price = sc.nextDouble();

        double baoPrice = price * 0.9;
        double meiPrice = price >= 30 ? price - 10 : price;

        System.out.println("饱了么应付：" + baoPrice);
        System.out.println("美单应付：" + meiPrice);

        if (baoPrice < meiPrice) {
            System.out.println("饱了么更划算");
        } else if (baoPrice > meiPrice) {
            System.out.println("美单更划算");
        } else {
            System.out.println("两家一样");
        }
    }
}