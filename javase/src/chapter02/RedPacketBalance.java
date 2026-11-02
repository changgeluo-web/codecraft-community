public class RedPacketBalance {
    public static void main(String[] args) {
        // 微信余额100元，支付宝余额10元，银行卡余额20元
        double wechat = 100;
        double alipay = 10;
        double bank = 20;

        // 问题一：一共有多少钱
        System.out.println("总余额：" + (wechat + alipay + bank) + "元");

        // 问题二：微信收了10元红包，又发了2元红包
        wechat = wechat + 10;
        wechat = wechat - 2;
        System.out.println("微信最终余额：" + wechat + "元");
    }
}