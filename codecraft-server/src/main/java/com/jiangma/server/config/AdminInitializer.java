package com.jiangma.server.config;

import com.jiangma.server.entity.User;
import com.jiangma.server.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 启动时确保存在可用的 ADMIN 账号。
 * 用户名 jiangma.admin.username（默认 admin）；密码 jiangma.admin.password，未配置时随机生成并打印到启动日志。
 * 仅首次创建时写入密码，不会覆盖已有账号的密码。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AdminInitializer implements ApplicationRunner {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    @Value("${jiangma.admin.username:admin}")
    private String adminUsername;

    @Value("${jiangma.admin.password:}")
    private String adminPassword;

    @Override
    public void run(ApplicationArguments args) {
        User admin = userMapper.selectByUsername(adminUsername);
        if (admin == null) {
            boolean generated = adminPassword == null || adminPassword.isBlank();
            String pwd = generated ? randomPassword() : adminPassword;
            admin = new User();
            admin.setUsername(adminUsername);
            admin.setEmail(adminUsername + "@admin.local");
            admin.setNickname("管理员");
            admin.setPassword(passwordEncoder.encode(pwd));
            admin.setRole("ADMIN");
            admin.setStatus(1);
            admin.setCreatedAt(LocalDateTime.now());
            admin.setUpdatedAt(LocalDateTime.now());
            admin.setDeleted(0);
            userMapper.insert(admin);
            if (generated) {
                log.warn("已创建初始管理员账号 {}，随机初始密码：{}（请登录后立即修改；可通过 JIANGMA_ADMIN_PASSWORD 预设）", adminUsername, pwd);
            } else {
                log.info("已创建初始管理员账号: {}", adminUsername);
            }
        } else if (!"ADMIN".equals(admin.getRole())) {
            admin.setRole("ADMIN");
            admin.setUpdatedAt(LocalDateTime.now());
            userMapper.updateById(admin);
            log.info("已将账号 {} 提升为管理员", adminUsername);
        }
    }

    private String randomPassword() {
        String chars = "abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        StringBuilder sb = new StringBuilder(14);
        java.security.SecureRandom rnd = new java.security.SecureRandom();
        for (int i = 0; i < 14; i++) {
            sb.append(chars.charAt(rnd.nextInt(chars.length())));
        }
        return sb.toString();
    }
}