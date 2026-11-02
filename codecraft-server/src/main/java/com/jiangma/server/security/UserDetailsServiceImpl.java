package com.jiangma.server.security;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.jiangma.server.entity.User;
import com.jiangma.server.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserMapper userMapper;
    private final UserCacheService userCacheService;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userMapper.selectOne(
                new LambdaQueryWrapper<User>().eq(User::getUsername, username)
        );
        if (user == null) {
            throw new UsernameNotFoundException("用户不存在");
        }
        return new UserDetailsImpl(user);
    }

    public UserDetails loadByUserId(Long userId) {
        User user = userCacheService.get(userId);
        if (user == null) {
            user = userMapper.selectById(userId);
            if (user == null) {
                throw new UsernameNotFoundException("用户不存在");
            }
            userCacheService.put(userId, user);
        }
        return new UserDetailsImpl(user);
    }
}