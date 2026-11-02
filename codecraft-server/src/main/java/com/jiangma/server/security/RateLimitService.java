package com.jiangma.server.security;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

/**
 * 基于 Redis 计数器的简单限流：窗口内超过最大次数即拒绝。
 * 用于登录防爆破与注册防刷。
 */
@Service
@RequiredArgsConstructor
public class RateLimitService {

    private static final String KEY_PREFIX = "auth:ratelimit:";

    private final StringRedisTemplate stringRedisTemplate;

    /**
     * @return true 表示允许通过
     */
    public boolean tryAcquire(String key, int maxAttempts, Duration window) {
        String fullKey = KEY_PREFIX + key;
        Long count = stringRedisTemplate.opsForValue().increment(fullKey);
        if (count != null && count == 1L) {
            stringRedisTemplate.expire(fullKey, window);
        }
        return count == null || count <= maxAttempts;
    }

    public void reset(String key) {
        stringRedisTemplate.delete(KEY_PREFIX + key);
    }
}