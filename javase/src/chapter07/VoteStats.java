import java.util.Random;

public class VoteStats {
    public static void main(String[] args) {
        // 统计投票：1000人投票，0弃权，1-5候选人，统计得票数和得票率
        Random r = new Random();
        // votes[0]弃权票，votes[1]~votes[5]候选人得票
        int[] votes = new int[6];
        int total = 1000;

        for (int i = 0; i < total; i++) {
            int vote = r.nextInt(6);
            votes[vote]++;
        }

        int maxIndex = 1;
        for (int i = 1; i <= 5; i++) {
            System.out.println(i + "号候选人得票数：" + votes[i]
                    + "，得票率：" + (votes[i] * 100.0 / total) + "%");
            if (votes[i] > votes[maxIndex]) {
                maxIndex = i;
            }
        }
        System.out.println("得票最多的候选人：" + maxIndex + "号");

        System.out.println("弃票数：" + votes[0]
                + "，弃票率：" + (votes[0] * 100.0 / total) + "%");
    }
}