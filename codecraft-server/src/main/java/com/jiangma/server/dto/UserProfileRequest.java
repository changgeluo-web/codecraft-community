package com.jiangma.server.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UserProfileRequest {

    @Size(max = 32, message = "昵称长度不能超过32")
    private String nickname;

    @Size(max = 200, message = "简介长度不能超过200")
    private String bio;

    @Size(max = 500, message = "头像地址过长")
    private String avatarUrl;
}