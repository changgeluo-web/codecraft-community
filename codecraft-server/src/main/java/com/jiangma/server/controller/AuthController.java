package com.jiangma.server.controller;

import com.jiangma.server.common.BusinessException;
import com.jiangma.server.common.Result;
import com.jiangma.server.dto.LoginRequest;
import com.jiangma.server.dto.RefreshRequest;
import com.jiangma.server.dto.RegisterRequest;
import com.jiangma.server.security.JwtUtil;
import com.jiangma.server.security.RateLimitService;
import com.jiangma.server.security.TokenBlacklistService;
import com.jiangma.server.service.UserService;
import com.jiangma.server.vo.LoginVO;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private static final int LOGIN_MAX_ATTEMPTS = 5;
    private static final Duration LOGIN_WINDOW = Duration.ofMinutes(15);
    private static final int REGISTER_MAX_ATTEMPTS = 10;
    private static final Duration REGISTER_WINDOW = Duration.ofHours(1);

    private final UserService userService;
    private final RateLimitService rateLimitService;
    private final TokenBlacklistService tokenBlacklistService;
    private final JwtUtil jwtUtil;

    @PostMapping("/register")
    public Result<LoginVO> register(@Valid @RequestBody RegisterRequest request, HttpServletRequest httpRequest) {
        String ip = clientIp(httpRequest);
        if (!rateLimitService.tryAcquire("register:" + ip, REGISTER_MAX_ATTEMPTS, REGISTER_WINDOW)) {
            throw new BusinessException(429, "注册过于频繁，请稍后再试");
        }
        return Result.success(userService.register(request));
    }

    @PostMapping("/login")
    public Result<LoginVO> login(@Valid @RequestBody LoginRequest request, HttpServletRequest httpRequest) {
        String key = "login:" + request.getUsername().toLowerCase() + ":" + clientIp(httpRequest);
        if (!rateLimitService.tryAcquire(key, LOGIN_MAX_ATTEMPTS, LOGIN_WINDOW)) {
            throw new BusinessException(429, "尝试次数过多，请15分钟后再试");
        }
        LoginVO vo = userService.login(request.getUsername(), request.getPassword());
        rateLimitService.reset(key);
        return Result.success(vo);
    }

    @PostMapping("/refresh")
    public Result<LoginVO> refresh(@Valid @RequestBody RefreshRequest request) {
        return Result.success(userService.refreshTokens(request.getRefreshToken()));
    }

    /** 登出：将当前 access token 拉黑直至其自然过期 */
    @PostMapping("/logout")
    public Result<Void> logout(HttpServletRequest request) {
        String bearer = request.getHeader("Authorization");
        if (StringUtils.hasText(bearer) && bearer.startsWith("Bearer ")) {
            String token = bearer.substring(7);
            try {
                Claims claims = jwtUtil.parseToken(token);
                long ttl = claims.getExpiration().getTime() - System.currentTimeMillis();
                if (ttl > 0) {
                    tokenBlacklistService.blacklist(claims.getId(), Duration.ofMillis(ttl));
                }
            } catch (Exception ignored) {
                // 无效 token 无需处理
            }
        }
        return Result.success();
    }

    private String clientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (StringUtils.hasText(forwarded)) {
            return forwarded.split(",")[0].trim();
        }
        String realIp = request.getHeader("X-Real-IP");
        if (StringUtils.hasText(realIp)) {
            return realIp;
        }
        return request.getRemoteAddr();
    }
}