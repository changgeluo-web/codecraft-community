package com.jiangma.server.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UserVO {

    private Long id;
    private String username;
    private String nickname;
    private String email;
    private String bio;
    private String avatar;
    private String role;
    private Integer status;
    private LocalDateTime createdAt;
}
