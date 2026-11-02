public class BodyTemperature {
    public static void main(String[] args) {
        // 体温 >= 38 度打印警告
        double temperature = 38.5;

        if (temperature >= 38) {
            System.out.println("警告：体温异常，请及时就医！");
        }
        System.out.println("当前体温：" + temperature + "度");
    }
}