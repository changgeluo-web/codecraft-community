import java.util.Scanner;

public class GameHp {
    public static void main(String[] args) {
        // 游戏血量：初始200，受到X点伤害，恢复Y点血，X和Y必须大于0否则重新录入
        Scanner sc = new Scanner(System.in);
        int hp = 200;

        int hurt;
        while (true) {
            System.out.println("请输入受到的伤害值（大于0）：");
            hurt = sc.nextInt();
            if (hurt > 0) {
                break;
            }
            System.out.println("伤害值不合法，请重新录入");
        }

        int recover;
        while (true) {
            System.out.println("请输入恢复的血量（大于0）：");
            recover = sc.nextInt();
            if (recover > 0) {
                break;
            }
            System.out.println("恢复值不合法，请重新录入");
        }

        hp = hp - hurt + recover;

        // 游戏人物不会死亡，最少1点血
        if (hp < 1) {
            hp = 1;
        }

        System.out.println("最终血量：" + hp);
    }
}