package com.jiangma.server.vo;

import lombok.Data;

@Data
public class TagVO {

    private Long id;
    private String name;
    /** 归属项目（分类）ID，NULL 表示全局标签 */
    private Long categoryId;
    /** 被引用次数（管理端返回，公开接口可为 null） */
    private Long postCount;
}