public class BmiCalculator {
    public static void main(String[] args) {
        // BMI = 体重(kg) / 身高(m)的平方
        double weight = 69.3;
        double height = 1.75;

        double bmi = weight / (height * height);
        System.out.println("体重：" + weight + "kg，身高：" + height + "m");
        System.out.println("BMI = " + bmi);
    }
}