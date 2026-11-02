package com.jiangma.server.security;

import com.jiangma.server.config.JiangMaProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class JwtUtil {

    public static final String TYPE_ACCESS = "access";
    public static final String TYPE_REFRESH = "refresh";

    private final JiangMaProperties properties;
    private SecretKey key;

    @PostConstruct
    public void init() {
        byte[] bytes = properties.getJwt().getSecret().getBytes(StandardCharsets.UTF_8);
        if (bytes.length < 32) {
            throw new IllegalStateException("JIANGMA_JWT_SECRET 未配置或长度不足 32 字节，请在项目根目录 .env 中设置（参考 .env.example）");
        }
        key = Keys.hmacShaKeyFor(bytes);
    }

    public String generateAccessToken(Long userId, String username, String role) {
        return buildToken(userId, username, role, TYPE_ACCESS, properties.getJwt().getAccessExpiration());
    }

    public String generateRefreshToken(Long userId, String username, String role) {
        return buildToken(userId, username, role, TYPE_REFRESH, properties.getJwt().getRefreshExpiration());
    }

    private String buildToken(Long userId, String username, String role, String type, long expirationMillis) {
        Date now = new Date();
        Date expiration = new Date(now.getTime() + expirationMillis);
        return Jwts.builder()
                .id(UUID.randomUUID().toString())
                .subject(String.valueOf(userId))
                .claim("username", username)
                .claim("role", role)
                .claim("type", type)
                .issuedAt(now)
                .expiration(expiration)
                .signWith(key)
                .compact();
    }

    public Claims parseToken(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public Long getUserId(String token) {
        return Long.valueOf(parseToken(token).getSubject());
    }

    public boolean validateToken(String token) {
        try {
            parseToken(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public boolean isType(Claims claims, String type) {
        return type.equals(claims.get("type", String.class));
    }
}