package com.jiangma.server.security;

import com.jiangma.server.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

/**
 * 用户信息 Redis 缓存：避免 JWT 过滤器每次请求都查库。
 * 资料/密码/状态变更时主动失效。
 */
@Service
@RequiredArgsConstructor
public class UserCacheService {

    private static final String KEY_PREFIX = "user:info:";
    private static final Duration TTL = Duration.ofMinutes(5);

    private final RedisTemplate<String, Object> redisTemplate;

    public User get(Long userId) {
        if (userId == null) {
            return null;
        }
        try {
            Object value = redisTemplate.opsForValue().get(KEY_PREFIX + userId);
            return value instanceof User user ? user : null;
        } catch (Exception e) {
            return null;
        }
    }

    public void put(Long userId, User user) {
        if (userId == null || user == null) {
            return;
        }
        try {
            redisTemplate.opsForValue().set(KEY_PREFIX + userId, user, TTL);
        } catch (Exception ignored) {
        }
    }

    public void evict(Long userId) {
        if (userId == null) {
            return;
        }
        try {
            redisTemplate.delete(KEY_PREFIX + userId);
        } catch (Exception ignored) {
        }
    }
}