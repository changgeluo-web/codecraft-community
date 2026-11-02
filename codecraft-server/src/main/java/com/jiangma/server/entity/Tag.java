package com.jiangma.server.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("tag")
public class Tag {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    /** 归属项目（分类）ID，NULL 表示全局标签 */
    private Long categoryId;
    private LocalDateTime createdAt;
    private Integer deleted;
}