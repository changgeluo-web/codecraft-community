package com.jiangma.server.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户个人学习进度（每个用户对每个知识点一条记录）。
 * status: 0待学 1学习中 2已掌握
 */
@Data
@TableName("user_post_progress")
public class UserPostProgress {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long postId;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}