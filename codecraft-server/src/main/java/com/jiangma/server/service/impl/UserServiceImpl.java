package com.jiangma.server.service.impl;

import com.jiangma.server.common.BusinessException;
import com.jiangma.server.dto.RegisterRequest;
import com.jiangma.server.dto.UserProfileRequest;
import com.jiangma.server.entity.User;
import com.jiangma.server.mapper.UserMapper;
import com.jiangma.server.security.JwtUtil;
import com.jiangma.server.security.SecurityUtil;
import com.jiangma.server.security.TokenBlacklistService;
import com.jiangma.server.security.UserCacheService;
import com.jiangma.server.service.UserService;
import com.jiangma.server.vo.LoginVO;
import com.jiangma.server.vo.UserVO;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final UserCacheService userCacheService;
    private final TokenBlacklistService tokenBlacklistService;

    @Override
    public LoginVO register(RegisterRequest request) {
        if (userMapper.selectByUsername(request.getUsername()) != null) {
            throw new BusinessException("用户名已存在");
        }
        if (userMapper.selectByEmail(request.getEmail()) != null) {
            throw new BusinessException("邮箱已被注册");
        }
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setEmail(request.getEmail());
        user.setNickname(StringUtils.hasText(request.getNickname()) ? request.getNickname() : request.getUsername());
        user.setRole("USER");
        user.setStatus(1);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        user.setDeleted(0);
        userMapper.insert(user);
        return buildLoginVO(user);
    }

    @Override
    public LoginVO login(String usernameOrEmail, String password) {
        User user = userMapper.selectByUsername(usernameOrEmail);
        if (user == null && usernameOrEmail.contains("@")) {
            user = userMapper.selectByEmail(usernameOrEmail);
        }
        if (user == null || user.getDeleted() != null && user.getDeleted() == 1) {
            throw new BusinessException("用户名或密码错误");
        }
        if (user.getStatus() == null || user.getStatus() != 1) {
            throw new BusinessException("账号已被禁用");
        }
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }
        return buildLoginVO(user);
    }

    @Override
    public LoginVO refreshTokens(String refreshToken) {
        Claims claims;
        try {
            claims = jwtUtil.parseToken(refreshToken);
        } catch (Exception e) {
            throw new BusinessException(401, "刷新令牌无效或已过期");
        }
        if (!jwtUtil.isType(claims, JwtUtil.TYPE_REFRESH)) {
            throw new BusinessException(401, "令牌类型错误");
        }
        if (tokenBlacklistService.isBlacklisted(claims.getId())) {
            throw new BusinessException(401, "刷新令牌已失效");
        }
        Long userId = Long.valueOf(claims.getSubject());
        User user = userMapper.selectById(userId);
        if (user == null || user.getStatus() == null || user.getStatus() != 1) {
            throw new BusinessException(401, "用户不存在或已被禁用");
        }
        return buildLoginVO(user);
    }

    @Override
    public UserVO currentUser() {
        Long userId = SecurityUtil.currentUserId();
        if (userId == null) {
            throw new BusinessException(401, "未登录");
        }
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        return convertToVO(user);
    }

    @Override
    public void updateProfile(UserProfileRequest request) {
        Long userId = SecurityUtil.currentUserId();
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        if (request.getNickname() != null) {
            user.setNickname(request.getNickname());
        }
        if (request.getBio() != null) {
            user.setBio(request.getBio());
        }
        if (request.getAvatarUrl() != null) {
            user.setAvatar(request.getAvatarUrl());
        }
        user.setUpdatedAt(LocalDateTime.now());
        userMapper.updateById(user);
        userCacheService.evict(userId);
    }

    @Override
    public void changePassword(String oldPassword, String newPassword) {
        Long userId = SecurityUtil.currentUserId();
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new BusinessException("当前密码不正确");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setUpdatedAt(LocalDateTime.now());
        userMapper.updateById(user);
        userCacheService.evict(userId);
    }

    private LoginVO buildLoginVO(User user) {
        LoginVO vo = new LoginVO();
        vo.setAccessToken(jwtUtil.generateAccessToken(user.getId(), user.getUsername(), user.getRole()));
        vo.setRefreshToken(jwtUtil.generateRefreshToken(user.getId(), user.getUsername(), user.getRole()));
        vo.setUser(convertToVO(user));
        return vo;
    }

    private UserVO convertToVO(User user) {
        UserVO vo = new UserVO();
        BeanUtils.copyProperties(user, vo);
        return vo;
    }
}
