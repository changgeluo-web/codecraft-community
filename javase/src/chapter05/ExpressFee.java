import java.util.Scanner;

public class ExpressFee {
    public static void main(String[] args) {
        // 快递邮费：首重1kg 10元；超1-5kg每kg加2元；超5kg每kg加1.5元；不足1kg按1kg算
        Scanner sc = new Scanner(System.in);
        double weight;
        while (true) {
            System.out.println("请输入快递重量（kg，必须大于0）：");
            weight = sc.nextDouble();
            if (weight > 0) {
                break;
            }
            System.out.println("重量不合法，请重新输入");
        }

        double fee = calculateFee(weight);
        System.out.println("快递运费：" + fee + "元");
    }

    public static double calculateFee(double weight) {
        // 不足1kg按1kg算：向上取整
        int kg = (int) Math.ceil(weight);

        double fee = 10;
        if (kg > 5) {
            fee = fee + (5 - 1) * 2 + (kg - 5) * 1.5;
        } else if (kg > 1) {
            fee = fee + (kg - 1) * 2;
        }
        return fee;
    }
}