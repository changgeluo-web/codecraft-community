import java.util.Scanner;

public class BestCoupon {
    public static void main(String[] args) {
        // 优惠券：满10减8/满50减30/满100减50/满200减90；会员卡8折（二选一）
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入商品总价：");
        double price = sc.nextDouble();

        // 方案一：使用优惠券
        double couponPrice;
        if (price >= 200) {
            couponPrice = price - 90;
        } else if (price >= 100) {
            couponPrice = price - 50;
        } else if (price >= 50) {
            couponPrice = price - 30;
        } else if (price >= 10) {
            couponPrice = price - 8;
        } else {
            couponPrice = price;
        }

        // 方案二：使用会员卡
        double vipPrice = price * 0.8;

        System.out.println("优惠券价格：" + couponPrice);
        System.out.println("会员卡价格：" + vipPrice);

        double best = couponPrice < vipPrice ? couponPrice : vipPrice;
        System.out.println("最优惠价格：" + best);
    }
}