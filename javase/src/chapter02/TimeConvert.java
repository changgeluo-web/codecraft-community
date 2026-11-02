public class TimeConvert {
    public static void main(String[] args) {
        // 将总秒数转换为 时:分:秒
        int seconds = 7242;

        int hours = seconds / 3600;
        int minutes = seconds % 3600 / 60;
        int restSeconds = seconds % 3600 % 60;

        System.out.println(seconds + "秒 = " + hours + "小时" + minutes + "分" + restSeconds + "秒");
    }
}