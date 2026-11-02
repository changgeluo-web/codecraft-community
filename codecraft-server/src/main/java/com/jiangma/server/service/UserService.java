package com.jiangma.server.service;

import com.jiangma.server.dto.RegisterRequest;
import com.jiangma.server.dto.UserProfileRequest;
import com.jiangma.server.vo.LoginVO;
import com.jiangma.server.vo.UserVO;

public interface UserService {

    LoginVO register(RegisterRequest request);
    LoginVO login(String usernameOrEmail, String password);
    LoginVO refreshTokens(String refreshToken);
    UserVO currentUser();
    void updateProfile(UserProfileRequest request);
    void changePassword(String oldPassword, String newPassword);
}
