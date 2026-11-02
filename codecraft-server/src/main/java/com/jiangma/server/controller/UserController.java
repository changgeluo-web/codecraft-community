package com.jiangma.server.controller;

import com.jiangma.server.common.Result;
import com.jiangma.server.dto.PasswordChangeRequest;
import com.jiangma.server.dto.UserProfileRequest;
import com.jiangma.server.service.UserService;
import com.jiangma.server.vo.UserVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public Result<UserVO> me() {
        return Result.success(userService.currentUser());
    }

    @PutMapping("/me")
    public Result<Void> updateProfile(@Valid @RequestBody UserProfileRequest request) {
        userService.updateProfile(request);
        return Result.success(null);
    }

    @PutMapping("/me/password")
    public Result<Void> changePassword(@Valid @RequestBody PasswordChangeRequest request) {
        userService.changePassword(request.getOldPassword(), request.getNewPassword());
        return Result.success(null);
    }
}
